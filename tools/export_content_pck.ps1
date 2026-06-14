# 导出热更资源包（PCK）。需已安装 Godot 4.6 且 export templates 就绪。
# 用法: .\tools\export_content_pck.ps1
# 可选: .\tools\export_content_pck.ps1 -GodotExe "C:\Godot\Godot_v4.6.2.exe"

param(
    [string]$GodotExe = "godot"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$OutDir = Join-Path $ProjectRoot "build"
$OutPck = Join-Path $OutDir "content.pck"

if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

Write-Host "Exporting Content PCK -> $OutPck"
& $GodotExe --headless --path $ProjectRoot --export-pack "Content PCK" $OutPck
if ($LASTEXITCODE -ne 0) {
    throw "Godot export-pack failed with exit code $LASTEXITCODE"
}

$bytes = (Get-Item $OutPck).Length
$hash = (Get-FileHash -Path $OutPck -Algorithm SHA256).Hash.ToLower()
Write-Host "Done. size=$bytes sha256=$hash"
Write-Host "Upload content.pck to CDN and update manifest version/url/size/sha256."
