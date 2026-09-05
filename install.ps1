[CmdletBinding()]
param()

# Install the Gitby CLI + TUI for the current Windows user. Running it again
# updates an existing install in place (so does `gitby update`).
# Optional environment variables: GITBY_VERSION, GITBY_INSTALL_DIR,
# GITBY_DOWNLOAD_BASE, and GITBY_NO_MODIFY_PATH.

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

$asset = switch (([string]$architecture).ToUpperInvariant()) {
    { $_ -in "X64", "AMD64" } { "gitby-windows-x64.zip"; break }
    "ARM64" { "gitby-windows-arm64.zip"; break }
    default { throw "Unsupported Windows architecture: $architecture. Gitby supports x64 and ARM64." }
}
$architectureLabel = if ($asset -eq "gitby-windows-arm64.zip") { "arm64" } else { "x64" }

if ($env:GITBY_DOWNLOAD_BASE) {
    $base = $env:GITBY_DOWNLOAD_BASE.TrimEnd("/")
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
    $staged = Join-Path $installDirectory (".gitby.new." + $PID + ".exe")
    Copy-Item -LiteralPath $sourceBinary -Destination $staged -Force

    # Binaries an earlier update set aside while they were still running.
    Get-ChildItem -LiteralPath $installDirectory -Filter ".gitby.old.*.exe" -Force -ErrorAction SilentlyContinue |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue }

    # Update in place: Windows will not overwrite an executable, and will not
    # delete one that is running, but it will rename one. So the installed
    # binary steps aside, the new one takes its name, and the old file goes
    # as soon as nothing holds it open.
    $updating = Test-Path -LiteralPath $destination -PathType Leaf
    $retired = $null
    if ($updating) {
        $retired = Join-Path $installDirectory (".gitby.old." + $PID + ".exe")
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

    $pathChanged = $false
    $pathEntries = @($env:PATH -split ";" | Where-Object { $_ })
    $alreadyOnPath = $pathEntries | Where-Object {
        $_.TrimEnd("\") -ieq $installDirectory.TrimEnd("\")
    }

    if (-not $alreadyOnPath) {
        $env:PATH = "$installDirectory;$env:PATH"
    }
    if (-not $env:GITBY_NO_MODIFY_PATH) {
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        $userEntries = @($userPath -split ";" | Where-Object { $_ })
        $alreadyInUserPath = $userEntries | Where-Object {
            $_.TrimEnd("\") -ieq $installDirectory.TrimEnd("\")
        }
        if (-not $alreadyInUserPath) {
            $newUserPath = if ($userPath) { "$installDirectory;$userPath" } else { $installDirectory }
            [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
            $pathChanged = $true
        }
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
