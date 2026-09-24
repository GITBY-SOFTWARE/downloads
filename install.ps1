[CmdletBinding()]
param()

# Install the Gitby CLI + TUI for the current Windows user. Running it again
# updates an existing install in place (so does `gitby update`).
# Optional environment variables: GITBY_VERSION, GITBY_CHANNEL (set to
# "development" for the dev-stack pre-release channel), GITBY_INSTALL_DIR,
# GITBY_DOWNLOAD_BASE, and GITBY_NO_MODIFY_PATH.
#
# Everything below is function definitions until the last line calls
# Install-Gitby, so a download cut off part-way (`irm ... | iex`) runs nothing.
#
# The archive is checked against the release's SHA256SUMS. That file comes from
# the same release, so the check catches a truncated or corrupted download, not
# a release replaced as a whole: artifact signing is still to come.

# Tell running programs (Explorer, terminals started from it) that the user
# environment changed, as [Environment]::SetEnvironmentVariable would have.
# Best effort: where Add-Type is unavailable, new sign-ins still see the change.
function Send-GitbySettingChange {
    try {
        if (-not ("Gitby.NativeMethods" -as [type])) {
            Add-Type -Namespace Gitby -Name NativeMethods -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
'@
        }
        $result = [UIntPtr]::Zero
        # HWND_BROADCAST, WM_SETTINGCHANGE, SMTO_ABORTIFHUNG, 5 s.
        [void][Gitby.NativeMethods]::SendMessageTimeout([IntPtr]0xffff, 0x1a, [UIntPtr]::Zero, "Environment", 2, 5000, [ref]$result)
    } catch {}
}

# Append a folder to the user's PATH in the registry, keeping the value as it is
# stored. [Environment]::GetEnvironmentVariable returns it with every %VARIABLE%
# expanded and SetEnvironmentVariable writes it back as a plain string, which
# would replace those references with today's values for good (and turn the
# REG_EXPAND_SZ value into REG_SZ). Returns $true when the value changed.
function Add-GitbyUserPath {
    param([string]$Directory)
    $wanted = $Directory.TrimEnd("\")
    $key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey("Environment")
    try {
        $current = ""
        $kind = [Microsoft.Win32.RegistryValueKind]::ExpandString
        if (@($key.GetValueNames()) -contains "Path") {
            $current = [string]$key.GetValue("Path", "", [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
            $kind = $key.GetValueKind("Path")
            if ($kind -ne [Microsoft.Win32.RegistryValueKind]::String -and $kind -ne [Microsoft.Win32.RegistryValueKind]::ExpandString) {
                $kind = [Microsoft.Win32.RegistryValueKind]::ExpandString
            }
        }
        foreach ($entry in ($current -split ";")) {
            if (-not $entry) { continue }
            $expanded = [Environment]::ExpandEnvironmentVariables($entry)
            if ($entry.TrimEnd("\") -ieq $wanted -or $expanded.TrimEnd("\") -ieq $wanted) {
                return $false
            }
        }
        # Appended, never prepended: user entries already follow the system
        # ones, and Gitby does not need to win over the user's other tools.
        $updated = if ($current) { $current.TrimEnd(";") + ";" + $Directory } else { $Directory }
        $key.SetValue("Path", $updated, $kind)
    } finally {
        $key.Close()
    }
    Send-GitbySettingChange
    return $true
}

function Install-Gitby {
    $ErrorActionPreference = "Stop"
    $ProgressPreference = "SilentlyContinue"

    # Windows PowerShell 5.1 may default to a protocol set without TLS 1.2, which
    # GitHub requires. Opt in additively; PowerShell 7 ignores this harmlessly.
    try {
        [Net.ServicePointManager]::SecurityProtocol = `
            [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    } catch {}

    $repository = "GITBY-SOFTWARE/downloads"
    $version = if ($env:GITBY_VERSION) { $env:GITBY_VERSION } else { "latest" }
    $channel = if ($env:GITBY_CHANNEL) { $env:GITBY_CHANNEL } else { "release" }
    if ($env:GITBY_INSTALL_DIR) {
        $installDirectory = $env:GITBY_INSTALL_DIR
    } else {
        if (-not $env:LOCALAPPDATA) {
            throw "LOCALAPPDATA is not set. Provide GITBY_INSTALL_DIR."
        }
        $installDirectory = Join-Path $env:LOCALAPPDATA "Gitby\bin"
    }

    # Detect the OS architecture. PowerShell 7 exposes RuntimeInformation, but on
    # Windows PowerShell 5.1 the static property silently resolves to $null (so
    # .ToString() on it crashed the whole installer). Fall back to the environment;
    # PROCESSOR_ARCHITEW6432 covers a 32-bit or emulated process on a 64-bit OS.
    $architecture = $null
    try {
        $architecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
    } catch {
        $architecture = $null
    }
    if (-not $architecture) {
        $architecture = if ($env:PROCESSOR_ARCHITEW6432) {
            $env:PROCESSOR_ARCHITEW6432
        } else {
            $env:PROCESSOR_ARCHITECTURE
        }
    }

    # Only the x64 build is published. Windows 11 on ARM runs x64 programs under
    # emulation, so it gets that build; Windows 10 on ARM cannot run it.
    $asset = "gitby-windows-x64.zip"
    $architectureLabel = "x64"
    switch (([string]$architecture).ToUpperInvariant()) {
        { $_ -in "X64", "AMD64" } { break }
        "ARM64" {
            if ([Environment]::OSVersion.Version.Build -lt 22000) {
                throw "Gitby does not publish a Windows ARM64 build yet, and this version of Windows cannot run the x64 build (Windows 11 on ARM can, under emulation)."
            }
            Write-Host "No native ARM64 build yet: installing the x64 build, which Windows 11 runs under emulation."
            $architectureLabel = "x64, emulated"
            break
        }
        default { throw "Unsupported Windows architecture: $architecture. Gitby publishes a Windows x64 build only." }
    }

    if ($env:GITBY_DOWNLOAD_BASE) {
        $base = $env:GITBY_DOWNLOAD_BASE.TrimEnd("/")
    } elseif ($channel -eq "development") {
        # The development channel is a single moving pre-release ("development")
        # built from every push to main; those binaries talk to the dev stack, not
        # gitby.cloud, and are not for production use. GITBY_VERSION is ignored.
        $base = "https://github.com/$repository/releases/download/development"
        Write-Host "Using the development channel (dev stack; not for production)."
    } elseif ($version -eq "latest") {
        $base = "https://github.com/$repository/releases/latest/download"
    } else {
        $releaseTag = if ($version.StartsWith("v")) { $version } else { "v$version" }
        $base = "https://github.com/$repository/releases/download/$releaseTag"
    }

    $temporaryDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("gitby-install-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $temporaryDirectory | Out-Null

    try {
        $archivePath = Join-Path $temporaryDirectory $asset
        $checksumsPath = Join-Path $temporaryDirectory "SHA256SUMS"

        Write-Host "Downloading Gitby for windows/$architectureLabel..."
        Invoke-WebRequest -UseBasicParsing -Uri "$base/$asset" -OutFile $archivePath
        Invoke-WebRequest -UseBasicParsing -Uri "$base/SHA256SUMS" -OutFile $checksumsPath

        $expectedHash = $null
        foreach ($line in Get-Content -LiteralPath $checksumsPath) {
            $parts = $line.Trim() -split "\s+", 2
            if ($parts.Count -eq 2 -and $parts[1] -eq $asset -and $parts[0] -match "^[0-9a-fA-F]{64}$") {
                $expectedHash = $parts[0].ToLowerInvariant()
                break
            }
        }
        if (-not $expectedHash) {
            throw "Release checksum for $asset is missing or invalid."
        }

        $actualHash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actualHash -ne $expectedHash) {
            throw "Checksum mismatch for $asset."
        }

        $expandedDirectory = Join-Path $temporaryDirectory "expanded"
        Expand-Archive -LiteralPath $archivePath -DestinationPath $expandedDirectory -Force
        $sourceBinary = Join-Path $expandedDirectory "gitby.exe"
        if (-not (Test-Path -LiteralPath $sourceBinary -PathType Leaf)) {
            throw "Release archive did not contain gitby.exe."
        }

        New-Item -ItemType Directory -Force -Path $installDirectory | Out-Null
        $destination = Join-Path $installDirectory "gitby.exe"
        # A per-run token (NOT $PID): re-running the installer in the SAME PowerShell
        # session reuses the PID, so the retired name collided and Move-Item -Force
        # could not clobber the previous (often still-locked) .gitby.old.<pid>.exe -
        # "Cannot create a file when that file already exists". A GUID never collides.
        $token = [guid]::NewGuid().ToString("N")
        $staged = Join-Path $installDirectory (".gitby.new." + $token + ".exe")
        Copy-Item -LiteralPath $sourceBinary -Destination $staged -Force

        # Binaries an earlier update set aside while they were still running, plus
        # any staged copy a previous run left behind. Best-effort: one still held
        # open (its process alive) stays until the next run, and that is fine now
        # that retired names are unique.
        Get-ChildItem -LiteralPath $installDirectory -Force -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Name -like ".gitby.old.*.exe" -or $_.Name -like ".gitby.new.*.exe" -or
                $_.Name -like ".gitby-browser.old.*.exe" -or $_.Name -like ".gitby-browser.new.*.exe"
            } |
            Where-Object { $_.FullName -ne $staged } |
            ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue }

        # Update in place: Windows will not overwrite an executable, and will not
        # delete one that is running, but it will rename one. So the installed
        # binary steps aside, the new one takes its name, and the old file goes
        # as soon as nothing holds it open.
        $updating = Test-Path -LiteralPath $destination -PathType Leaf
        $retired = $null
        if ($updating) {
            $retired = Join-Path $installDirectory (".gitby.old." + $token + ".exe")
            Move-Item -LiteralPath $destination -Destination $retired -Force
        }
        try {
            Move-Item -LiteralPath $staged -Destination $destination -Force
        } catch {
            if ($retired -and (Test-Path -LiteralPath $retired -PathType Leaf)) {
                Move-Item -LiteralPath $retired -Destination $destination -Force -ErrorAction SilentlyContinue
            }
            throw
        }
        if ($retired) {
            Remove-Item -LiteralPath $retired -Force -ErrorAction SilentlyContinue
        }

        # The browser sidecar, when the archive shipped one: install it next to
        # gitby.exe. The TUI finds the sidecar beside its own binary, so both must
        # land in the same directory. Reuse the same step-aside rename dance, since
        # Windows will not overwrite a running executable but will rename it.
        $sourceBrowser = Join-Path $expandedDirectory "gitby-browser.exe"
        if (Test-Path -LiteralPath $sourceBrowser -PathType Leaf) {
            $browserDestination = Join-Path $installDirectory "gitby-browser.exe"
            $stagedBrowser = Join-Path $installDirectory (".gitby-browser.new." + $token + ".exe")
            Copy-Item -LiteralPath $sourceBrowser -Destination $stagedBrowser -Force

            $updatingBrowser = Test-Path -LiteralPath $browserDestination -PathType Leaf
            $retiredBrowser = $null
            if ($updatingBrowser) {
                $retiredBrowser = Join-Path $installDirectory (".gitby-browser.old." + $token + ".exe")
                Move-Item -LiteralPath $browserDestination -Destination $retiredBrowser -Force
            }
            try {
                Move-Item -LiteralPath $stagedBrowser -Destination $browserDestination -Force
            } catch {
                if ($retiredBrowser -and (Test-Path -LiteralPath $retiredBrowser -PathType Leaf)) {
                    Move-Item -LiteralPath $retiredBrowser -Destination $browserDestination -Force -ErrorAction SilentlyContinue
                }
                throw
            }
            if ($retiredBrowser) {
                Remove-Item -LiteralPath $retiredBrowser -Force -ErrorAction SilentlyContinue
            }
        } else {
            # No sidecar in this archive: an older one beside gitby.exe would be
            # paired with a newer client, so it steps aside and gitby fetches the
            # sidecar published for its own version instead.
            $staleBrowser = Join-Path $installDirectory "gitby-browser.exe"
            if (Test-Path -LiteralPath $staleBrowser -PathType Leaf) {
                $retiredStale = Join-Path $installDirectory (".gitby-browser.old." + $token + ".exe")
                Move-Item -LiteralPath $staleBrowser -Destination $retiredStale -Force -ErrorAction SilentlyContinue
                Remove-Item -LiteralPath $retiredStale -Force -ErrorAction SilentlyContinue
            }
        }

        $pathChanged = $false
        $pathEntries = @($env:PATH -split ";" | Where-Object { $_ })
        $alreadyOnPath = $pathEntries | Where-Object {
            $_.TrimEnd("\") -ieq $installDirectory.TrimEnd("\")
        }

        if (-not $alreadyOnPath) {
            $env:PATH = "$env:PATH;$installDirectory"
        }
        if (-not $env:GITBY_NO_MODIFY_PATH) {
            $pathChanged = Add-GitbyUserPath $installDirectory
        }

        if ($updating) {
            Write-Host "Updated Gitby at $destination"
        } else {
            Write-Host "Installed Gitby to $destination"
        }
        if ($pathChanged) {
            Write-Host "Added $installDirectory to your user PATH. Open a new terminal, then run: gitby"
        } else {
            Write-Host "Run: gitby   (later, 'gitby update' installs new releases)"
        }
    } finally {
        Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Install-Gitby
