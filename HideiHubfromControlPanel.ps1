<#	
  .Synopsis
    Prevent Intelligent Hub from showing in Add/Remove Programs
  .NOTES
	  Created:          September, 2021
	  Created by:       Phil Helmling, @philhelmling
	  Organization:     VMware, Inc.
	  Filename:         HideiHubfromControlPanel.ps1
	.DESCRIPTION
    Adds the key to Prevent Intelligent Hub from showing in Add/Remove Programs 
    
    Install command: powershell.exe -ep bypass -file .\HideiHubfromControlPanel.ps1
    Uninstall command: powershell.exe -ep bypass -file .\HideiHubfromControlPanel.ps1 -Uninstall
    Install Complete: Registry DWORD value HKEY_LOCAL_MACHINE\SOFTWARE\AIRWATCH\HideiHubfromControlPanel = 1
    
  .EXAMPLE
    powershell.exe -ep bypass -file .\HideiHubfromControlPanel.ps1
#>
param (
    [Parameter(Mandatory=$false)]
    [Switch]$Uninstall
)
$uninstallString = @()
$uninstallString += (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where-Object { $_.DisplayName -like "Workspace ONE Intelligent Hub*" })
$uninstallString += (Get-ItemProperty HKLM:\Software\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\* | where-Object { $_.DisplayName -like "Workspace ONE Intelligent Hub*" })

$instcompletekey = "Registry::HKLM\SOFTWARE\AIRWATCH"

foreach ($uninstallpath in $uninstallString)
{
  if($Uninstall){
    Remove-ItemProperty -Path $uninstallpath.PSPath -Name "SystemComponent"
    Remove-ItemProperty -Path $instcompletekey -Name "HideiHubfromControlPanel"
    break
  }
  
  $uninstallpathexists = Get-ItemProperty -Path $uninstallpath.PSPath -Name "SystemComponent" -ErrorAction SilentlyContinue
  If($uninstallpathexists){
    Set-ItemProperty -Path $uninstallpath.PSPath -Name "SystemComponent" -Type "Dword" -Value 1
    New-ItemProperty -Path $instcompletekey -Name "HideiHubfromControlPanel" -PropertyType "Dword" -Value 1
  }else{
    New-ItemProperty -Path $uninstallpath.PSPath -Name "SystemComponent" -PropertyType "Dword" -Value 1
    New-ItemProperty -Path $instcompletekey -Name "HideiHubfromControlPanel" -PropertyType "Dword" -Value 1
  }
}
