###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################
##########These scripts provide Container size along with Softdelete and blob version for a storage account #########################


#Please update these value as per your scenario


[CmdletBinding(DefaultParametersetName="SharedKey")]
param(

  [Parameter(Mandatory=$true, HelpMessage="Storage Account Name")] 
  [String] $storage_account_name,

  [Parameter(Mandatory=$true, HelpMessage="Any one of the two shared access keys", ParameterSetName="SharedKey", Position=1)] 
  [String] $storage_shared_key,
  
  [Parameter(Mandatory=$true, HelpMessage="SAS Token : the GET parameters", ParameterSetName="SASToken", Position=1)] 
  [String] $storage_sas_token
  
)

$containerstats = @()

If ($PsCmdlet.ParameterSetName -eq "SharedKey")
{
  $Ctx = New-AzStorageContext -StorageAccountName $storage_account_name -StorageAccountKey $storage_shared_key
}
Else
{
  $Ctx = New-AzStorageContext -StorageAccountName $storage_account_name -SasToken $storage_sas_token
}

$container_continuation_token = $null

do {

  $containers = Get-AzStorageContainer -Context $Ctx -MaxCount 5000 -ContinuationToken $container_continuation_token
  
         
  $container_continuation_token = $null;
        
  if ($containers -ne $null)
  {
    $container_continuation_token = $containers[$containers.Count - 1].ContinuationToken

    for ([int] $c = 0; $c -lt $containers.Count; $c++)
    {
      $container = $containers[$c].Name
         Write-Host "Container List"  $container

      Write-Verbose "Processing container : $container"

      $total_usage = 0
      $total_blob_count = 0
      $soft_delete_usage = 0
      $soft_delete_count = 0
      $version_count =0 
      $version_usage =0
      $blob_continuation_token = $null
    
        $blobs = Get-AzStorageBlob -Context $Ctx -Container $container -MaxCount 5000 -IncludeVersion -IncludeDeleted -ContinuationToken $blob_continuation_token
     
      do {
    
                        
        $blob_continuation_token = $null;

        if ($blobs -ne $null)
        {
          $blob_continuation_token = $blobs[$blobs.Count - 1].ContinuationToken

          for ([int] $b = 0; $b -lt $blobs.Count; $b++)
          {
            $total_blob_count++
            $total_usage += $blobs[$b].Length
            if ($blobs[$b].IsDeleted)
            {
              $soft_delete_count++
              $soft_delete_usage += $blobs[$b].Length
            }
            if ($blobs[$b].VersionId)
            {
              $version_count++
              $version_usage += $blobs[$b].Length
            }
          }

          If ($blob_continuation_token -ne $null)
          {
            Write-Verbose "Blob listing continuation token = {0}".Replace("{0}",$blob_continuation_token.NextMarker)
          }
        }
     } while ($blob_continuation_token -ne $null)

      Write-Verbose "Calculated size of $container = $total_usage with soft_delete usage of $soft_delete_usage"
                        
      $containerstats += [PSCustomObject] @{ 
        Name = $container 
        TotalBlobCount = $total_blob_count 
        TotalBlobUsage = $total_usage 
        SoftDeletedBlobCount = $soft_delete_count 
        SoftDeletedBlobUsage = $soft_delete_usage 
        VersionCount = $version_count
        VersionUsage = $version_usage
      }
    }
  }

  If ($container_continuation_token -ne $null)
  {
    Write-Verbose "Container listing continuation token = {0}".Replace("{0}",$container_continuation_token.NextMarker)
  }

} while ($container_continuation_token -ne $null)


Write-Host "Total container stats"
$containerstats | Format-Table -AutoSize  

#Write-Host "Total blob stats"
#$blobstats | Format-Table -AutoSize  
