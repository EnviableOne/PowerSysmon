$ErrorActionPreference = 'SilentlyContinue'
$file = Get-Item "C:\Windows\Sysmon64.exe"
#gets latest version from SYsinternals website
$req = (Invoke-WebRequest -uri "https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon" -UseBasicParsing)
$content=$req.Content.substring($req.Content.indexof("<div class=`"content `">"),71)
$ver=[single]$content.substring($content.lastindexof("v")+1)
#set AWN Paths
$awnPath = "${env:ProgramFiles(x86)}\Arctic Wolf Networks"
$sysmonPath = "$awnPath\Sysmon"

if($null -ne $file){
 #sysmon installed run uninstall
 $fileVersion = $file.VersionInfo.ProductVersion
 if ($fileVersion -ge $ver) {
  Write-Host "Sysmon version is above $($ver.tostring()), stopping script." -ForegroundColor Red
  return
 } 
 Write-Host "Sysmon version is below $($ver.tostring()), removal starting..." -ForegroundColor Green
 Start-Process Sysmon64.exe -ArgumentList "-u","force" -Wait

 Stop-Service Sysmon64 -Force
 Stop-Service sysmondrv -Force

 start-process fltmc -ArgumentList "unload","SysmonDrv" -wait -NoNewWindow
 start-process sc -ArgumentList "delete","sysmon64" -Wait -NoNewWindow
 start-process sc -ArgumentList "delete","sysmondrv" -Wait -NoNewWindow
 
 If (test-path "C:\Windows\Sysmon64.exe"){ Remove-Item -Path "C:\Windows\Sysmon64.exe" -Force}
 If (test-path "C:\Windows\SysmonDrv.sys"){Remove-Item -Path "C:\Windows\SysmonDrv.sys" -Force}
 If (test-path "HKLM:\SYSTEM\CurrentControlSet\Services\SysmonDrv"){ Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SysmonDrv" -Recurse -Force}
 If (test-path "HKLM:\SYSTEM\CurrentControlSet\Services\Sysmon64"){Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Sysmon64" -Recurse -Force}

 Write-Host "Uninstall has been run."
}
if (-not (Test-Path $sysmonPath)) {
 New-Item -ItemType Directory -Path $sysmonPath
}

Write-Host "Downloading latest Sysmon" -ForegroundColor Green
Invoke-WebRequest -Uri "https://live.sysinternals.com/Sysmon64.exe" -OutFile "$sysmonPath\Sysmon64.exe"
copy-item "$sysmonPath\Sysmon64.exe" "$env:windir\"

Write-Host "Running Sysmon64.exe -i -accepteula from $sysmonPath"
Start-Process -FilePath "$SysmonPath\Sysmon64.exe" -ArgumentList "-accepteula","-i" -Wait

 $NewVersion = (Get-Item "$sysmonPath\Sysmon64.exe" -ea SilentlyContinue).VersionInfo.ProductVersion

if ($null -ne $fileVersion){
 #old version existed
 if ($NewVersion -ge $ver) {
  #install worked
  Write-Host "Sysmon version $fileversion has been upgraded to $($ver.tostring())" -ForegroundColor Green
  Restart-Service -name "Arctic Wolf Manager"
  New-Item -ItemType File -Path "$SysmonPath\Installed.txt" -Force
 } 
 else {
  #Install failed
  Write-Host "Sysmon version is still $fileversion, Upgrade failed" -ForegroundColor Red
  New-Item -ItemType File -Path "$sysmonPath\FAIL.txt" -Force
 }
}
else {
 if ($null -ne $NewVersion){
  #installed
  Write-Host "Sysmon version $($ver.tostring()) has been Installed" -ForegroundColor Green
  Restart-Service -name "Arctic Wolf Agent Manager"
  New-Item -ItemType File -Path "$SysmonPath\Installed.txt" -Force
 }
 else {
  #install failed
  Write-Host "Sysmon was not Installed" -ForegroundColor Red
  New-Item -ItemType File -Path "$sysmonPath\FAIL.txt" -Force
 }
}