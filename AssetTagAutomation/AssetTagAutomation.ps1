<#
	Assettag Powershell Automation Script for Panasonic Toughbooks
	Author: Brian Gonzalez
	Date: 4/15/13
#>
$oInvocation = (Get-Variable MyInvocation).Value
$sCurrentDirectory = Split-Path $oInvocation.MyCommand.Path
$sSerialNumber = (Get-WmiObject -Query "SELECT * FROM Win32_BIOS").SerialNumber
$sModelNumber = (Get-WmiObject -Query "SELECT * FROM Win32_ComputerSystem").Model
$sCurrentAssetTag = (Get-WmiObject -Query "SELECT * FROM Win32_SystemEnclosure").SMBIOSAssetTag
$sNewAssetTag = @(($sModelNumber.SubString(3,3) + $sSerialNumber.Trim()))

# Load Panasonic NewMisc Driver using DrvLoad
Start-Process "x:\windows\system32\drvload.exe" @('"' + $sCurrentDirectory + `
	'\newmisc\newmisc.inf"') -NoNewWindow -WindowStyle Hidden -Wait | Out-Null
# Write Desired AssetTag to Text File
[IO.File]::WriteAllText("$env:temp\NewAssetTag.txt",$sNewAssetTag)
# Execute AssetTag.exe with /F Argument Passing Path to Created Text File
Start-Process "c:\windows\system32\cmd.exe" @('/C start /w "" "' + $sCurrentDirectory + `
	'\AssetTag.exe" /F:"' + $env:temp + '\NewAssetTag.txt" /Y') -NoNewWindow -WindowStyle Hidden -Wait | Out-Null