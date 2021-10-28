#The below PowerShell script gets all the Archived blobs from a Source Container and rehydrates it to an online tier by copying the blob to a different container. You can modify the script as per your requirement.

#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, 
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


Connect-AzAccount
$rgName = "Resource Group Name"
$accountName = "your storage account name"
$srcContainerName = "Source Container"
$destContainerName = "Destination Container"

$storageAccount = Get-AzStorageAccount -ResourceGroupName $rgName -AccountName $accountName 
$ctx = $storageAccount.Context

$MaxReturn = 5000

$blob_continuation_token = $null
             
  do 
    {

      $blobs = Get-AzStorageBlob -Context $ctx -Container $srcContainerName -MaxCount $MaxReturn -ContinuationToken $blob_continuation_token | Where-Object{$_.ICloudBlob.Properties.StandardBlobTier -eq "Archive"}
      $blobs | Start-AzStorageBlobCopy -DestContainer $destContainerName -RehydratePriority High -StandardBlobTier Hot -Context $ctx
       
      if ($blobs -ne $null)
        {
          $blob_continuation_token = $blobs[$blobs.Count - 1].ContinuationToken
                                       
        }

      if ($blob_continuation_token -ne $null)
        {
         Write-Verbose ("Blob listing continuation token = {0}" -f $blob_continuation_token.NextMarker)
        }

    } while ($blob_continuation_token -ne $null)

