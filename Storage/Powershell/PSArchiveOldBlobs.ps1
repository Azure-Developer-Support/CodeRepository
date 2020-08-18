###
## DISCLAIMER : This is a sample and is provided as is with no warranties express or implied.
## https://gist.github.com/ajith-k
###

[CmdletBinding(DefaultParametersetName="SharedKey")]
param(

  [Parameter(Mandatory=$true, HelpMessage="Storage Account Name")] 
  [String] $storage_account_name,

  [Parameter(Mandatory=$true, HelpMessage="Any one of the two shared access keys", ParameterSetName="SharedKey", Position=1)] 
  [String] $storage_shared_key,
  
  [Parameter(Mandatory=$true, HelpMessage="SAS Token : the GET parameters", ParameterSetName="SASToken", Position=1)] 
  [String] $storage_sas_token,

  [Parameter(Mandatory=$true, HelpMessage="Archive blobs older than these many days", Position=2)] 
  [int] $older_than_days,

  [Parameter(Mandatory=$false, HelpMessage="Prefix string to filter containers", Position=3)] 
  [String] $container_prefix = $null,

  [Parameter(Mandatory=$false, HelpMessage="Prefix string to filter blobs", Position=4)] 
  [String] $blob_prefix = $null

  
)

$containerstats = @()

If ($PsCmdlet.ParameterSetName -eq "SharedKey")
{
        $Ctx = New-AzureStorageContext -StorageAccountName $storage_account_name -StorageAccountKey $storage_shared_key
}
Else
{
        $Ctx = New-AzureStorageContext -StorageAccountName $storage_account_name -SasToken $storage_sas_token
}

$HighWaterMarkDate = (([System.DateTimeOffset]::Now).AddDays(($older_than_days * -1)))
　
$container_continuation_token = $null

do {
        if ($container_prefix.Length -le 0)
        {
            $containers = Get-AzureStorageContainer -Context $Ctx -MaxCount 5000 -ContinuationToken $container_continuation_token
        }
        else
        {
            $containers = Get-AzureStorageContainer -Context $Ctx -MaxCount 5000 -ContinuationToken $container_continuation_token -Prefix $container_prefix
        }

        $container_continuation_token = $null;
        
        if ($containers -ne $null)
        {
                $container_continuation_token = $containers[$containers.Count - 1].ContinuationToken

                for ([int] $c = 0; $c -lt $containers.Count; $c++)
                {
                        $container = $containers[$c].Name

                        Write-Verbose "Processing container : $container"

                        $total_blob_count = 0
                        $archive_blob_count = 0
                        $tier_changed_blob_count = 0
                        $non_block_blobs_skipped = 0
                        $newer_blobs = 0
                
                        $blob_continuation_token = $null
                
                        do {
                        
                                $blobs = Get-AzureStorageBlob -Context $Ctx -Container $container -MaxCount 5000 -IncludeDeleted -ContinuationToken $blob_continuation_token -Prefix $blob_prefix

                                $blob_continuation_token = $null;

                                if ($blobs -ne $null)
                                {
                                        $blob_continuation_token = $blobs[$blobs.Count - 1].ContinuationToken

                                        for ([int] $b = 0; $b -lt $blobs.Count; $b++)
                                        {
                                                $total_blob_count++
                                                
                                                if ($blobs[$b].ICloudBlob.Properties.StandardBlobTier -eq [Microsoft.WindowsAzure.Storage.Blob.StandardBlobTier]::Archive)
                                                {
                                                    $archive_blob_count++
                                                }
                                                else
                                                {
                                                    if ($blobs[$b].LastModified -lt $HighWaterMarkDate) 
                                                    {
                                                        if ($blobs[$b].BlobType -eq [Microsoft.WindowsAzure.Storage.Blob.BlobType]::BlockBlob)
                                                        {
                                                            $blobs[$b].ICloudBlob.setStandardBlobTier([Microsoft.WindowsAzure.Storage.Blob.StandardBlobTier]::Archive)
                                                            $tier_changed_blob_count++
                                                        }
                                                        else
                                                        {
                                                            Write-Verbose ("Skipping non-block blob {0} because there is no option currently to set tier for it." -f $blobs[$b].ICloudBlob.Uri.AbsolutePath)
                                                            $non_block_blobs_skipped++
                                                        }
                                                    }
                                                    else
                                                    {
                                                        $newer_blobs++
                                                    }
                                                        
                                                }
                                        }

                                        If ($blob_continuation_token -ne $null)
                                        {
                                                Write-Verbose ("Blob listing continuation token = {0}" -f $blob_continuation_token.NextMarker)
                                        }
                                }
                        } while ($blob_continuation_token -ne $null)

                        Write-Verbose "Finished processing Container $container"
                        
                        $containerstats += [PSCustomObject] @{ 
                                                Name = $container 
                                                TotalBlobCount = $total_blob_count 
                                                PreviousArchivedBlobCount = $archive_blob_count 
                                                BlobsArchivedNow = $tier_changed_blob_count
                                                NonBlockBlobsSkipped = $non_block_blobs_skipped
                                                NewerBlobs = $newer_blobs 
                                                }
                }
   }
 
   If ($container_continuation_token -ne $null)
   {
                Write-Verbose ("Container listing continuation token = {0}" -f $container_continuation_token.NextMarker)
   }

} while ($container_continuation_token -ne $null)


Write-Host "Total container stats"
$containerstats | Format-Table -AutoSize 
