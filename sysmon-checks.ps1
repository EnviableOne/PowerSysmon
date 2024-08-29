$log_file = 'sysmon-checks.log'

$items = @(
    "C:\Windows\Sysmon64.exe",
    "C:\Windows\SysmonDrv.sys",
    "HKLM:\SYSTEM\CurrentControlSet\Services\Sysmon64",
    "HKLM:\SYSTEM\CurrentControlSet\Services\SysmonDrv",
    "HKLM:\SYSTEM\ControlSet001\Services\Sysmon64",
    "HKLM:\SYSTEM\ControlSet001\Services\SysmonDrv",
    "HKLM:\SYSTEM\ControlSet002\Services\Sysmon64",
    "HKLM:\SYSTEM\ControlSet002\Services\SysmonDrv",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Sysmon/Operational",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Publishers\{5770385f-c22a-43e0-bf4c-06f5698ffbd9}",
    "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\EventLog-Microsoft-Windows-Sysmon-Operational"
)

$services = @(
    "Sysmon64",
    "SysmonDrv"
)

foreach ( $i in $items ) {
    If ( Test-Path $i ) {
        $result = 'O'
    } Else {
        $result = 'X'
    }
    Write-Output "$result : $i".ToString() | Out-File -Filepath $log_file -Append -NoClobber -Encoding UTF8
}

foreach ( $s in $services ) {
    $status = (Get-Service $s -ErrorAction SilentlyContinue).Status
    Write-Output "$status : $s".ToString() | Out-File -Filepath $log_file -Append -NoClobber -Encoding UTF8
}