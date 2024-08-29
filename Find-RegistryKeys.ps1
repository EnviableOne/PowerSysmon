Function Find-RegistryKeys{
 param()
 $productIDs = Import-Csv -Path ./Inc/productversions.inc -Encoding utf8 #csv of productIDs
 $regkeys= Get-Content -Path ./inc/regkeys.inc
 $ProdMatch="\\\{[0-9A-F]{8}-?[0-9A-F]{4}-?[0-9A-F]{4}-?[0-9A-F]{4}-?[0-9A-F]{12}\}\\"
 $vers = New-Object -TypeName System.Collections.ArrayList

 ForEach($regkey in $regkeys){
  if ($regkey.match("<ProductID>")){
     foreach($id in $productIDs){
        $newkey = $regkey.Replace("<ProductID>",$id.id)
        $regkeys.add($newkey)
     }
     $regkeys.Remove($regkey)
     
  }
  else{
    if(Test-Path $regkey){
      try{
        Get-item -Path $regkey | Remove-Item -Recurse:$regkey.recurse
        if ($regkey -match $ProdMatch){
          $prid = [regex]::Matches($regkey,$ProdMatch)[0].Replace("-","") 
          $prid = $prid.substring(0,8) + "-" + $prid.substring(8,4) + "-" + $prid.substring(12,4) + "-" + $prid.substring(16,4) + "-" + $prid.substring(20)
          $match=$productIDs."Agent Verson" | where-object {$productIDs.id -eq $prid}
          $vers += $match
         }
        }
      Catch{
         Write-Error "$($regkey.name) exists but was not deleted"
      }
    } 
  }
 }
}