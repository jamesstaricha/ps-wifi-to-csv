<#
	.SYNOPSIS
		A brief description of the wifi-to-csv.ps1 file.
	
	.DESCRIPTION
		This script will convert wifi xml profiles to one csv file.
	
	.PARAMETER export
		This parameter will export the wlan profiles from the current machine.
	
	.NOTES
		===========================================================================
		Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.181
		Created on:   	7/18/2021 2:33 PM
		Created by:   	James Staricha
		Organization: 	Panobit, LLC
		Filename:     	wifi-to-csv.ps1
		===========================================================================
#>
param
(
	[Parameter(Mandatory = $false)]
	[switch]$export
)
$_EXPORT_FOLDER = "C:\temp"


function exportWifi()
{
	netsh wlan export profile key=clear folder=$_EXPORT_FOLDER
}

function checkExportFolder()
{
	If (!(test-path $_EXPORT_FOLDER))
	{
		New-Item -ItemType Directory -Force -Path $_EXPORT_FOLDER
	}
}

function extractWifiDetails($file)
{
	$XMLfile = $file
	[XML]$wifiDetails = Get-Content $XMLfile
	$results = @()
	
	foreach ($wifiDetail in $wifiDetails.WLANProfile)
	{
		$details = @{
			Name = Write-Output $wifiDetail.name
			Password = $wifiDetail.MSM.security.sharedKey.keyMaterial
			ConnectionType = $wifiDetail.connectionType
			ConnectionMode = $wifiDetail.connectionMode
			Authentication = $wifiDetail.MSM.security.authEncryption.authentication
			Encryption = $wifiDetail.MSM.security.authEncryption.encryption
		}
		
		$results += New-Object PSObject -Property $details
		
	}
	return $results
}


Write-Output "Starting WiFi-To-CSV Script"
checkExportFolder

if ($export)
{
	Write-Output "Exporting Wi-Fi profiles..."
	exportWifi
	Write-Output "Exporting Wi-Fi profiles completed."
}

$finalresults = @()

Get-ChildItem -Path $_EXPORT_FOLDER | Foreach-Object {
	
	#Do something with $_.FullName
	Write-Output $_.FullName
	$finalresults += extractWifiDetails($_.FullName)
}

Write-Output $finalresults

$finalresults | export-csv -Path D:\wifi-list.csv -NoTypeInformation
