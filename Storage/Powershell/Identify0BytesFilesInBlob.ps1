#The below PowerShell script helps to find the 0 bytes files in a blob storage .

#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, 
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


################# Script BEGIN ####################  

$ctx = New-AzStorageContext -StorageAccountName <AccountName> -StorageAccountKey <PrimaryKey>
$ContainerName = "containerName"
$MaxReturn = 10000
$loopCount = 0
$Total = 0
$Token = $Null

do {
  $Blobs = Get-AzStorageBlob -Context $ctx -Container $ContainerName -MaxCount $MaxReturn -ContinuationToken $Token

  $Total += $Blobs.Count

  foreach ($blobitem in $Blobs) {
    $loopCount += 1
    Write-Host -NoNewline "`rValidating batch: " $loopCount "/" $blobsList.Length " (Current total:" $Total ")"

    if ($blobitem.Length -eq 0) {
      Write-Host ""
      Write-Host "Zero bytes file found: " $blobitem.Name
    }
  }

  $loopCount = 0
  if ($Blobs.Length -le 0) { Break; }
  $Token = $Blobs[$blobs.Count - 1].ContinuationToken;
}
While ($Token -ne $Null)

Write-Host ""
Write-Host "Finished!"

################# Script END ####################  
