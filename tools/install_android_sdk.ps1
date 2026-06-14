# Install Android SDK components required by Godot 4.6 Android export.
$ErrorActionPreference = "Stop"

$SdkRoot = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$CmdlineZip = Join-Path $env:TEMP "commandlinetools-win.zip"
$CmdlineExtract = Join-Path $env:TEMP "android-cmdline-extract"
$CmdlineLatest = Join-Path $SdkRoot "cmdline-tools\latest"
$DownloadUrl = "https://dl.google.com/android/repository/commandlinetools-win-13114758_latest.zip"
$Packages = @(
	"platform-tools",
	"build-tools;35.0.1",
	"platforms;android-35",
	"cmdline-tools;latest"
)

Write-Host "SDK root: $SdkRoot"
New-Item -ItemType Directory -Force -Path $SdkRoot | Out-Null

if (-not (Test-Path (Join-Path $CmdlineLatest "bin\sdkmanager.bat"))) {
	Write-Host "Downloading Android command-line tools..."
	Invoke-WebRequest -Uri $DownloadUrl -OutFile $CmdlineZip
	if (Test-Path $CmdlineExtract) {
		Remove-Item $CmdlineExtract -Recurse -Force
	}
	Expand-Archive -Path $CmdlineZip -DestinationPath $CmdlineExtract -Force
	New-Item -ItemType Directory -Force -Path $CmdlineLatest | Out-Null
	Copy-Item -Path (Join-Path $CmdlineExtract "cmdline-tools\*") -Destination $CmdlineLatest -Recurse -Force
}

$SdkManager = Join-Path $CmdlineLatest "bin\sdkmanager.bat"
if (-not (Test-Path $SdkManager)) {
	throw "sdkmanager.bat not found at $SdkManager"
}

Write-Host "Accepting SDK licenses..."
$licenseInput = ("y`n" * 40)
$licenseInput | & $SdkManager --sdk_root=$SdkRoot --licenses | Out-Host

Write-Host "Installing SDK packages..."
& $SdkManager --sdk_root=$SdkRoot @Packages | Out-Host

$adb = Join-Path $SdkRoot "platform-tools\adb.exe"
$apksigner = Get-ChildItem -Path (Join-Path $SdkRoot "build-tools") -Recurse -Filter "apksigner.bat" -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not (Test-Path $adb)) {
	throw "adb not found after install"
}
if ($null -eq $apksigner) {
	throw "apksigner not found after install"
}

Write-Host "Installed successfully."
Write-Host "ADB: $adb"
Write-Host "apksigner: $($apksigner.FullName)"
Write-Host "Set Godot Editor Settings -> Export -> Android -> Android SDK Path to:"
Write-Host $SdkRoot
