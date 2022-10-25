###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################

##########These scripts deletes the blobs in $logs conatiner based on last modified date #########################


#Please update these value as per your scenario

$number_of_days_old = 1 #Change it accordingly based on how old files you want to delete
$current_date = get-date
$date_older_for_blob_to_be_deleted = $current_date.AddDays(-$number_of_days_old)
# Number of blobs deleted
$deleted_blobs = 0
# Storage account details
$storage_account_name = ""
$storage_account_key = ""
$container='$logs'
$context = New-AzureStorageContext -StorageAccountName $storage_account_name -StorageAccountKey $storage_account_key
$MaxReturn = 5000
$ContinuationToken = $null
do
{
$blob_list = Get-AzureStorageBlob -Context $context -Container $container -MaxCount $MaxReturn -ContinuationToken $ContinuationToken
## Iterate through each blob
foreach($blob in $blob_list){
    $blob_date = [datetime]$blob.LastModified.UtcDateTime 
    # Check if the last modified date is less than our requirement
    if($blob_date -le $date_older_for_blob_to_be_deleted) {
        # Delete the blob
        Remove-AzureStorageBlob -Container $container -Blob $blob.Name -Context $context
   $deleted_blobs += 1
    }
}
if ($blob_list -ne $null)
{
  $ContinuationToken = $blob_list[$blob_list.Count - 1].ContinuationToken                                    
 }
if ($ContinuationToken -ne $null)
{
   Write-Verbose ("Blob listing continuation token = {0}" -f $ContinuationToken.NextMarker)
}
} while ($ContinuationToken -ne $null)
write-output "Blobs deleted: " $deleted_blobs
