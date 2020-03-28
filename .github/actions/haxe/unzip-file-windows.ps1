param([string]$file,[string]$output)

# usage: powershell ./unzip-file-windows.ps1 -file haxe-4.0.3-win64.zip -output C:\Haxe

$temp = "$PSScriptRoot\unzipped"
Expand-Archive -LiteralPath "$PSScriptRoot\$file" -DestinationPath $temp
Set-Location -Path $PSScriptRoot\unzipped\haxe*
dir
xcopy * $output /s /y