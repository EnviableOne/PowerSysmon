$log_file = 'sysmon-uninstall.log'

$items = @(
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

foreach ( $i in $items ) {
    $error.Clear();
    Remove-Item -Path $i -Force -Recurse -ErrorAction SilentlyContinue
    If($error) {
        $result = $error.Exception.Message
    } Else {
        $result = "O : $i"
    }
    Write-Output "$result".ToString() | Out-File -Filepath $log_file -Append -NoClobber -Encoding UTF8
}