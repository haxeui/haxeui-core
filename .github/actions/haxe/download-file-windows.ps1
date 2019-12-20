param([string]$url,[string]$output)

# usage: powershell ./download-file-windows.ps1 -url https://github.com/HaxeFoundation/haxe/releases/download/4.0.3/haxe-4.0.3-win64.zip -output haxe-4.0.3-win64.zip

Write-Host "url : " $url 
Write-Host "output : " $output 

#$url = "https://github.com/HaxeFoundation/haxe/releases/download/4.0.3/haxe-4.0.3-win64.zip"
$output_file = "$PSScriptRoot\$output"

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output_file)