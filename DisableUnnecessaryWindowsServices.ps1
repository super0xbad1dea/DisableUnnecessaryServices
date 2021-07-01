# Script to disable unnecessary Windows Services, based on Microsoft Recommendation.
#
# https://docs.microsoft.com/en-us/windows-server/security/windows-services/security-guidelines-for-disabling-system-services-in-windows-server
# https://docs.microsoft.com/en-us/windows/application-management/per-user-services-in-windows

$WindowsSystemServices = @(
    "AxInstSV", # ActiveX Installer (AxInstSV)
    "bthserv", # Bluetooth Support Service
    "dmwappushservice", # dmwappushsvc
    "MapsBroker", # Downloaded Maps Manager
    "lfsvc", # Geolocation Service
    "SharedAccess", # Internet Connection Sharing (ICS)
    "lltdsvc", # Link-Layer Topology Discovery Mapper
    "wlidsvc", # Microsoft Account Sign-in Assistant
    "NgcSvc", # Microsoft Passport
    "NgcCtnrSvc", # Microsoft Passport Container
    "NcbService", # Network Connection Broker
    "PhoneSvc", # Phone Service
    "Spooler", # Print Spooler
    "PrintNotify", # Printer Extensions and Notifications
    "PcaSvc", # Program Compatibility Assistant Service
    "QWAVE", # Quality Windows Audio Video Experience
    "RmSvc", # Radio Management Service
    "SensorDataService", # Sensor Data Service
    "SensrSvc", # Sensor Monitoring Service
    "SensorService", # Sensor Service
    "ShellHWDetection", # Shell Hardware Detection
    "ScDeviceEnum", # Smart Card Device Enumeration Service
    "SSDPSRV", # SSDP Discovery
    "WiaRpc", # Still Image Acquisition Events
    "TabletInputService", # Touch Keyboard and Handwriting Panel Service
    "upnphost", # UPnP Device Host
    "WalletService", # WalletService
    "Audiosrv", # Windows Audio
    "AudioEndpointBuilder", # Windows Audio Endpoint Builder
    "FrameServer", # Windows Camera Frame Server
    "stisvc", # Windows Image Acquisition (WIA)
    "wisvc", # Windows Insider Service
    "icssvc", # Windows Mobile Hotspot Service
    "WpnService", # Windows Push Notifications System Service
    "XblAuthManager", # Xbox Live Auth Manager
    "XblGameSave" # Xbox Live Game Save
)

$WindowsUserServices = @(
    "CDPUserSvc", # CDPUserSvc
    "OneSyncSvc", # Sync Host
    "PimIndexMaintenanceSvc", # Contact Data
    "UnistoreSvc", # User Data Storage
    "UserDataSvc", # User Data Access
    "WpnUserService" # Windows Push Notifications User Service
)

Write-Output "[i] Disable unnecessary Windows Services (MS Recommendation)"
Write-Output "[i] $(Get-Date)"

ForEach ($Service in $WindowsSystemServices) {
   try {
        Stop-Service -Name "$Service" -Force -ErrorAction Stop
        Set-Service -Name $Service -StartupType Disabled -ErrorAction Stop
        $CheckServiceStatus = (Get-Service -Name $Service)
        if (($CheckServiceStatus.Status -eq "Stopped") -and ($CheckServiceStatus.StartType -eq "Disabled")) {
            Write-Output "[+] Service $($Service) is stopped and disabled"
        } elseif (($CheckServiceStatus.Status -eq "Stopped") -and ($CheckServiceStatus.StartType -ne "Disabled")) {
            Write-Output "[-] Service $($Service) is stopped, but not disabled"
        } elseif (($CheckServiceStatus.Status -ne "Stopped") -and ($CheckServiceStatus.StartType -ne "Disabled")) {
           Write-Output "[!] Service $($Service) is not stopped and not disabled"
        }        
    } catch {
        Write-Output "[!] Service $($Service) could not be stopped and disabled"
    }
}

ForEach ($Service in $WindowsUserServices) {
    try {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$Service" -Name "Start" -Value "4" -ErrorAction Stop
        Stop-Service -Name "$Service*" -Force -ErrorAction Stop
        $CheckServiceStatus = (Get-Service -Name "$Service*")
        if (($CheckServiceStatus.Status -eq "Stopped") -and ($CheckServiceStatus.StartType -eq "Disabled")) {
            Write-Output "[+] Service $($Service) is stopped and disabled"
        } elseif (($CheckServiceStatus.Status -eq "Stopped") -and ($CheckServiceStatus.StartType -ne "Disabled")) {
            Write-Output "[-] Service $($Service) is stopped, but not disabled. Reboot is necessary to take effect"
        } elseif (($CheckServiceStatus.Status -ne "Stopped") -and ($CheckServiceStatus.StartType -ne "Disabled")) {
           Write-Output "[!] Service $($Service) is not stopped and not disabled"
        } 
   } catch {
        Write-Output "[!] Service $($Service) could not be stopped and disabled"
   }
}