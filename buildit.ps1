
# Set the Lazarus FPC path in the environment variable for the script
$env:PATH = "C:\lazarus\fpc\3.2.2\bin\x86_64-win64;" + $env:PATH

# Define the desired download directory and Lazarus version details
$DOWNLOAD_DIR = "$HOME\downloads"
$LAZARUS_VERSION = "fixes_3_0"
$LAZARUS_ZIP = "lazarus-$LAZARUS_VERSION.zip"
$LAZARUS_URL = "https://gitlab.com/freepascal.org/lazarus/lazarus/-/archive/$LAZARUS_VERSION/$LAZARUS_ZIP"
$UNZIP_DIR = "lazarus-$LAZARUS_VERSION\lazarus-$LAZARUS_VERSION"

# Navigate to the desired download directory
Set-Location $DOWNLOAD_DIR -ErrorAction Stop

# Remove the previous zip file if it exists
if (Test-Path $LAZARUS_ZIP) {
    Remove-Item $LAZARUS_ZIP -ErrorAction Stop
}

# Remove the previous Lazarus directory if it exists
if (Test-Path $UNZIP_DIR) {
    Remove-Item $UNZIP_DIR -Recurse -ErrorAction Stop
}

# Download the zip file using Invoke-WebRequest with retry logic
$retryCount = 0
$downloaded = $false
do {
    try {
        Invoke-WebRequest $LAZARUS_URL -OutFile $LAZARUS_ZIP -ErrorAction Stop
        $downloaded = $true
    } catch {
        $retryCount++
        Start-Sleep -Seconds 3
    }
} while (-not $downloaded -and $retryCount -lt 3)

if (-not $downloaded) {
    Write-Error "Download failed."
    exit 1
}

# Unzip the downloaded file
Expand-Archive $LAZARUS_ZIP -ErrorAction Stop

# Enter the unzipped Lazarus directory
Set-Location $UNZIP_DIR -ErrorAction Stop

# Clean and build Lazarus with the specified parameters
# Note: Ensure you have the necessary tools installed to run 'make'

& make clean bigide

# Remove the 'com.apple.quarantine' attribute from the files
# Note: This command is macOS specific and might not work directly in PowerShell
Get-ChildItem -Recurse | Unblock-File -ErrorAction Continue

Write-Host "Lazarus $LAZARUS_VERSION has been successfully installed."

# End of the script
