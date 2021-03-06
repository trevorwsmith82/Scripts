########################################################################################
# Version of Software Script
# Author:	Matt Soteros
# Version:	v1.1
########################################################################################
##VARIABLES#############################################################################
# Set base path to prefix all installation paths.
$sPath = "C:\Admin\Software"

# Sets Date for Success or Failure
$Date = (Get-Date).ToString("M-d-yy H:mm:ss")

# Get Computer Name  this will be used for Licensing infomation
$Name = $env:COMPUTERNAME

# Set The Log Location
$sFile = "C:\Admin\SoftwareInstallation.TXT"

# Set base bath for Registry uninstallation Paths
$rPathX64 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
$rPathX86 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"

# Get the computer manufacturer and model from Win32_ComputerSystem.
$computerSystem = Get-WmiObject win32_computerSystem

# Get Chassis Type
$chassis = gwmi win32_SystemEnclosure | select ChassisTypes

# Initiate new Process and ProcessStartInfo objects.
$process = New-Object system.Diagnostics.Process
$si = New-Object System.Diagnostics.ProcessStartInfo

##FUNTIONS#############################################################################
Function WriteToLog($sMessage)
#Writes to Log file in the following format:
#	01/01/2013 01:00:00 : Update...
# Dependents: $sLogLocation
{ 
    $sDate = Get-Date -Format "MM/dd/yyyy"
    $sTime = Get-Date -Format "hh:mm:ss"
    $tMessage = "$sDate $sTime : $sMessage"
    $tMessage | Out-File -FilePath $sLogLocation -Append
}
Function startProcess ($startInfo, $sFileCheckPath)
# Define the startProcess function. This function accepts a ProcessStartInfo
# object, launches that process, and waits for its process id to exit before
# returning.
{
	"Attempting to install" $startInfo.FileName $startInfo.Arguments
	$process.StartInfo = $startInfo
	$process.Start()
	$processID = $process.Id
	$process.WaitForExit()
	#Loop Script with included sleep and file check
	For($i=1; $i -le 30; $i++)
	{
		If (Test-Path $sFileCheckPath){break} #If Checkfile is found For Loop will break
		Start-Sleep -Seconds 60 #Check for completion of install every minute
	}
}
########################################################################################
#   Software Installation
########################################################################################

  #Stop Symantec AV from running while installing Software
    $SMC = Get-Process smc -erroraction silentlycontinue
    IF($SMC -ne $null)
        {$si.FileName = 'C:\Program Files (x86)\Symantec\Symantec Endpoint Protection\12.1.2015.2015.105\Bin64\Smc.exe'
         $si.Arguments = "-stop"
         startProcess $si
        }

#SQL Server 2008 R2
      IF ((Test-Path -Path "$rPathX64\{3A9FC03D-C685-4831-94CF-4EDFD3749497}") -eq $false)
        {Set-Location c:\
         $si.FileName = $sPath + "\smartcop\SQL2008R2\X64\SQLEXPRWT_x64_ENU.exe"
         $si.Arguments = "/Q /SAPWD=`$m@rtc0p /ConfigurationFile=C:\Admin\Software\smartcop\SQL2008R2\X64\ConfigurationFile.ini"
         startProcess $si
         IF ((Test-Path -Path "$rPathX64\{3A9FC03D-C685-4831-94CF-4EDFD3749497}") -eq $True)
         {Add-Content $Sfile "`nSQL Server 2008 R2 Installed $Date"}
         Else
         {Add-Content $Sfile "`nSQL Server 2008 R2 Failed $Date"
         Restart-Computer
         }
        }
    
        #Mobile Forms
     IF (((Test-Path -Path "$rPathX64\{3A9FC03D-C685-4831-94CF-4EDFD3749497}") -eq $true) -and ((Test-Path -Path "$rPathX64\{10BE7BF8-01C3-4FF5-AE39-6DA125C68EE7}") -eq $false))
        {
         $si.FileName = $sPath + "\smartcop\RMS_8_4_19.msi"
         $si.Arguments =  "/qb IS_SQLSERVER_USERNAME=sa IS_SQLSERVER_PASSWORD=`$m@rtc0p /l* c:\admin\Mobileforms.txt"
         startProcess $si
         IF((Test-Path -Path "$rPathX64\{10BE7BF8-01C3-4FF5-AE39-6DA125C68EE7}") -eq $True)
         {Add-Content $Sfile "`nMobile Forms Installed $Date"}
         Else
         {Add-Content $Sfile "`nMobile Forms Failed $Date"
         Restart-Computer
         }
        }      
        
        #SmartCop
      IF (((Test-Path -Path "$rPathX64\{10BE7BF8-01C3-4FF5-AE39-6DA125C68EE7}") -eq $True) -and ((Test-Path -Path "$rPathX64\{D79E6637-C6DE-4946-9083-94D4C46EB929}") -eq $False))
        {
         $si.FileName = $sPath + "\SmartCop\MCT_8_2_13.msi"
         $si.Arguments =  "/qb IS_SQLSERVER_USERNAME=sa IS_SQLSERVER_PASSWORD=`$m@rtc0p /l* c:\admin\SmartCop.txt"
         startProcess $si
         }
         IF((Test-Path -Path "$rPathX64\{D79E6637-C6DE-4946-9083-94D4C46EB929}") -eq $True)
         {Add-Content $Sfile "`nSmartCop Installed $Date"}
         Else
         {Add-Content $Sfile "`nSmartCop Failed $Date"
         Restart-Computer
         }
        

# Adobe FlashPlayer
      IF ((Test-Path -Path "$rPathX64\{DC48E09D-4E5F-4039-B93A-FCED36EFBE55}") -eq $false)
        {
         $si.FileName = $sPath + "\adobe\Flash player\Flash 11.3.300\install_flash_player_11_active_x.msi"
         $si.Arguments = "/Passive /Norestart"
         startProcess $si
         Copy-Item "C:\Admin\Software\adobe\Flash player\Flash 11.3.300\mms.cfg" "C:\Windows\System32\Macromed\Flash"
         IF ((Test-Path -Path "$rPathX64\{DC48E09D-4E5F-4039-B93A-FCED36EFBE55}") -eq $True)
         {Add-Content $sFile "`nAdobe FlashPalyer 11.3.300 Installed $Date"}
         else
         {Add-Content $sFile "`nAdobe FlashPalyer 11.3.300 Failed $Date"
         Restart-Computer 
         }
         }
         
# Adobe Reader
      IF ((Test-Path -Path "$rPathX64\{AC76BA86-7AD7-1033-7B44-AA1000000001}") -eq $false)
        {
         $si.FileName = $sPath + "\adobe\Adobe Reader\10.1\AdbeRdr1010_en_US.msi"
         $si.Arguments = "/Passive /Norestart"
         startProcess $si
          Remove-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run -Name "Adobe ARM"
          Set-Service AdobeARMservice -StartupType Disabled
          Remove-Item -Path "c:\Users\Public\Desktop\Adobe Reader x.lnk"
          IF ((Test-Path -Path "$rPathX64\{AC76BA86-7AD7-1033-7B44-AA1000000001}") -eq $True)
          {Add-Content $sFile "`nAdobe Reader 10.1 Installed $date"}
          Else
          {Add-Content $sFile "`nAdobe Reader 10.1 Failed $Date"
          Restart-Computer -Force
          }
         }
         
## SilverLight 5.1.20125.0
    IF ( (Test-Path -Path "$rPathX86\{89F4137D-6C26-4A84-BDB8-2E5A4BB71E00}") -eq $false)
       {
         $si.FileName = $sPath + "\Silverlight\Silverlight_x64.exe"
         $si.Arguments = "/q"
         startProcess $si
         IF ((Test-Path -Path "$rPathX86\{89F4137D-6C26-4A84-BDB8-2E5A4BB71E00}") -eq $True)
         {Add-Content $sFile "`nSilverlight 5.1.20125.0 Installed $Date"}
         Else
         {Add-Content $sFile "`nSilverlight 5.1.20125.0 Failed $Date"
         Restart-Computer 
         }
       }

# Apple Quicktime
      IF ((Test-Path -Path "$rPathX64\{0E64B098-8018-4256-BA23-C316A43AD9B0}") -eq $false)
        {
         $si.FileName = $sPath + "\QuickTime\QuickTime.msi"
         $si.Arguments = "/Passive"
         startProcess $si
         Remove-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run -Name "QuickTime Task"
         Remove-Item -Path "c:\Users\Public\Desktop\Quicktime Player.lnk"
         IF ((Test-Path -Path "$rPathX64\{0E64B098-8018-4256-BA23-C316A43AD9B0}") -eq $True)
         {Add-Content $sFile "`nApple Quicktime Installed $Date"}
         Else
         {Add-Content $sFile "`nApple Quicktime Failed $Date"
         Restart-Computer
         }
        }
     
# Google Earth 5.1
      IF ((Test-Path -Path "$rPathX64\{28E82311-8616-11E1-BEB0-B8AC6F97B88E}") -eq $false)
        {
         $si.FileName = $sPath + "\Google Earth5.1\Google Earth.msi"
         $si.Arguments = "/Passive"
         startProcess $si
         Remove-Item -Path "c:\Users\Public\Desktop\Google Earth.lnk"
         IF ((Test-Path -Path "$rPathX64\{28E82311-8616-11E1-BEB0-B8AC6F97B88E}") -eq $True)
         {Add-Content $sFile "`nGoogle Earth 5.1 Installed  $Date"}
         Else
         {Add-Content $sFile "`nGoogle Earth 5.1 Failed $Date"
         Restart-Computer 
         }
         }

# Java 1.6.0_20
      IF ((Test-Path -Path "$rPathX64\{26A24AE4-039D-4CA4-87B4-2F83216020FF}") -eq $false)
        {
         $si.FileName = $sPath + "\Java\jre1.6.0_20\jre1.6.0_20.msi"
         $si.Arguments = "/Passive"
         startProcess $si
         IF ((Test-Path -Path "HKLM:\SOFTWARE\Wow6432Node\JavaSoft\Java Update\Policy") -eq $False)
         {
         New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\JavaSoft\Java Update" -ErrorAction SilentlyContinue
         New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\JavaSoft\Java Update\Policy" -ErrorAction SilentlyContinue
         New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\JavaSoft\Java Update\Policy" -Name "EnableJavaUpate" -Value "00000000" -PropertyType "Dword" -ErrorAction SilentlyContinue
        }
        IF ((Test-Path -Path "$rPathX64\{26A24AE4-039D-4CA4-87B4-2F83216020FF}") -eq $True)
        {Add-Content $sFile "`nJava 1.6.0_20 Installed $Date"}
        Else
        {Add-Content $sFile "`nJava 1.6.0_20 Failed $Date"
        Restart-Computer
        }
        }
 
# Office2010 Pro+
      IF ((Test-Path -Path "$rPathX86\Office14.Proplus") -eq $false)
      {If($Name -like "CVE*") 
        {
        $si.FileName = $sPath + "\Office2010x64\setup.exe"
         $si.Arguments = "/AdminFile C:\Admin\Software\Office2010x64\Updates\CVEProgress.MSP"
         startProcess $si
         }
        Else
         {
         $si.FileName = $sPath + "\Office2010x64\setup.exe"
         $si.Arguments = "/AdminFile C:\Admin\Software\Office2010x64\Updates\FHPProgress.MSP"
         startProcess $si
         }
         IF ((Test-Path -Path "$rPathX86\Office14.Proplus") -eq $True)         
         {Add-Content $sFile "`nOffice2010 Pro+ Installed $Date"}
         Else
         {Add-Content $sFile "`nOffice2010 Pro+ Failed $Date"
         Restart-Computer 
         }
       } 
 
# MapPoint2013
      IF (((Test-Path -Path "$rPathX86\Office14.PROPLUS")-eq $TRUE) -and ((Test-Path -Path "$rPathX64\{C82185E8-C27B-4EF4-2013-1111BC2C2B6D}") -eq $false))
        {
         $si.FileName = $sPath + "\MapPoint2013\MapPoint\MSMap\data.msi"
         $si.Arguments = '/Passive'         
         startProcess $si
         IF((Test-Path -Path "$rPathX64\{C82185E8-C27B-4EF4-2013-1111BC2C2B6D}") -eq $True)
         {Add-Content $sFile "`nMapPoint 2013 Installed $Date"}
         else
         {Add-Content $sFile "`nMapPoint 2013 Failed $Date"
         Restart-Computer 
         }
         }

# OmniForm Filler5
      IF ((Test-Path -Path "$rPathX64\{A13560B2-32D2-4F21-8EE4-DE10F85111CB}") -eq $false)
        {
         $si.FileName = $sPath + "\OmniFormFiller5\OmniForm 5.0.msi"
         $si.Arguments = "/Passive"
         startProcess $si
         IF ((Test-Path -Path "$rPathX64\{A13560B2-32D2-4F21-8EE4-DE10F85111CB}") -eq $True)
         {Add-Content $sFile "`nOmniForm Filler5 Installed $Date"}
         Else
         {Add-Content $sFile "`nOmniForm Filler5 Failed $Date"
         Restart-Computer
         }
        }      

# DataWorks Plus Rapid ID
      IF ((Test-Path -Path "$rPathX64\{F12C6B14-1169-4608-A531-ABF451195A41}") -eq $false)
        {
         $si.FileName = $sPath + "\RapidID x64\FLRapidIDClientSetup.msi"
         $si.Arguments = "/Passive"
         startProcess $si
                  IF ((Test-Path -Path "$rPathX64\{F12C6B14-1169-4608-A531-ABF451195A41}") -eq $True)
         {Add-Content $sFile "`nDataWorks Plus Rapid ID Installed $Date"
        }
         Else
         {Add-Content $sFile "`nDataWorks Plus Rapid ID Failed $Date"
         Restart-Computer 
         }  
        }
       
# CrashZone 8.5.5
      IF ((Test-Path -Path "$rPathX64\{3925B518-743B-4567-9FFA-FE1E5CE6DE2D}") -eq $False)
        {
         $d =get-date
         Set-date -date '1/1/2010'
         $si.FileName = $sPath + "\Crashzone\CrashZone855.exe"
         $si.Arguments =  "/s"
         startProcess $si
         Set-Date $d
         IF((Test-Path -Path "$rPathX64\{3925B518-743B-4567-9FFA-FE1E5CE6DE2D}") -eq $True)
         {Add-Content $sFile "`nCrashZone 8.5.5 Installed $Date"}
         Else
         {Add-Content $sFile "`nCrashZone 8.5.5 Failed $Date"
         # Restart-Computer
         }
        }

## Powershell 3.0
    IF (((Test-Path -Path "$rPathX86\Microsoft .NET Framework 4 Extended") -eq $True) -and (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727\NGENService\Roots\Microsoft.PowerShell.Activities, Version=3.0.*") -eq $false)
      {
        $si.FileName = $sPath + "\Powershell3.0\Windows6.1-KB2506143-x64.msu"
         $si.Arguments = "/quiet /norestart"
         startProcess $si
        IF ((Test-Path -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v2.0.50727\NGENService\Roots\Microsoft.PowerShell.Activities, Version=3.0.*") -eq $True)
         {Add-Content $pFile "`nPowershell 3.0 Installed $Date"}
         Else
         {Add-Content $pFile "`nPowershell 3.0 Failed $Date"
        }
       }


# Arbitrator

    If($chassis.chassisTypes -contains '11')
{write-host "Hand Held"}
Elseif(($chassis.chassisTypes -contains '8') -or($chassis.chassisTypes -contains '9') -or ($chassis.chassisTypes -contains '10'))
{
# Arbitrator360 Backend Client
      IF ((Test-Path -Path "$rPathX64\{2BA18783-D085-4C36-8CF8-7EE5D48B1109}") -eq $false)
        {
         $si.FileName = $sPath + "\Arbitrator 360\becsetup.msi"
         $si.Arguments = "/Passive"
         startProcess $si
         Remove-Item -Path "c:\Users\Public\Desktop\Back-End Client.Lnk"
         IF ((Test-Path -Path "$rPathX64\{2BA18783-D085-4C36-8CF8-7EE5D48B1109}") -eq $True)
         {Add-Content $sFile "`nArbitrator360 Backend Client Installed $Date"}
       Else
         {Add-Content $sFile "`nArbitrator360 Backend Client Failed $Date"
         Restart-Computer 
         }
         }

#Arbitrator360 Frontend Client 2.6.17
      IF ((Test-Path -Path "$rPathX64\{AEBD81C1-F7F6-4E6D-BB69-62D508FF3A7F}") -eq $false)
        {
         $si.FileName = $sPath + "\Arbitrator 360\FESetup.exe"
         $si.Arguments = "/S /v/qn"
         startProcess $si
         IF ((Test-Path -Path "$rPathX64\{AEBD81C1-F7F6-4E6D-BB69-62D508FF3A7F}") -eq $True)
         {Add-Content $sFile "`nArbitrator360 Frontend Client 2.6.17 Installed $Date"}
         Else
         {Add-Content $sFile "`nArbitrator360 Frontend Client 2.6.17 Failed $Date"
         Restart-Computer 
         }
         }

         #Arbitrator360 Crystal Reports Client
      IF ((Test-Path -Path "$rPathX64\{CE26F10F-C80F-4377-908B-1B7882AE2CE3}") -eq $false)
        {
         $si.FileName = $sPath + "\Arbitrator 360\CRRedist2008_x86.msi"
         $si.Arguments = "/passive"
         startProcess $si
         IF ((Test-Path -Path "$rPathX64\{CE26F10F-C80F-4377-908B-1B7882AE2CE3}") -eq $True)
         {Add-Content $sFile "`nArbitrator360 Crystal Reports Client Installed $Date"}
         Else
         {Add-Content $sFile "`nArbitrator360 Crystal Reports Client Failed $Date"
         Restart-Computer 
         }
         }
}

Function Laptop
    {
    $Laptop = '\\wds\SYSVOL\Deploy.LAN\scripts\Laptops.ps1'
    Resolve-Path $Laptop
    Invoke-Expression $Laptop     
    }

# Call Laptop software installation 
    IF(($Name -like "CVE-MDT*") -or ($Name -like "CVE-DOT*") -or ($Name -like "CVE-DEP*") -or ($Name -like "FHP-MDT*") -or ($Name -like "DOT-DT*"))
    {
    $Smartcop = 'c:\Admin\Software\SmartCop\smartcop.ps1'
    Resolve-Path $Smartcop
    Invoke-Expression $Smartcop
    }
    Else
   {
    # Looks to see if it is a laptop/Notebook/Portable/ HandHend then install Netmotion, Imprivata, etc....
    $chassis = Get-WmiObject win32_systemenclosure | select chassistypes 
        IF (($chassis.chassistypes -eq '8') -or ($chassis.chassistypes -eq '9') -or ($chassis.chassistypes -eq '10') -or ($chassis.chassistypes -eq '11')){Laptop}
        Else
        {Break}
        #ChassisType 8 = Portable
        #ChassisType 9 = Laptop
        #ChassisType 10 = NoteBook
        #ChassisType 11 = HandHeld
        }

        


 


