#The below PowerShell script helps you to delete the older blobs based on the Last Modified date and blob type like page blob from your storage account.
#The script can be modified based on the requirements.

#Disclaimer

#By using the following materials or sample code you agree to be bound by the license terms below 
#and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
#These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you 
#are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you 
#are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
#not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to 
#use and modify the sample code and to reproduce and distribute the object code form of the sample code, 
#provided that you agree: (i) to not use Microsoftâ€™s name, logo, or trademarks to market your software product 
#in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in 
#which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors 
#a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
#limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and 
#suppliers from and against any third party claims or lawsuits, including attorneysâ€™ fees, that arise or result 
#from the use or distribution of the sample code."



$number_of_days_old = 0 #Change it accordingly based on how old files you want to delete
$current_date = get-date
$date_older_for_blob_to_be_deleted = $current_date.AddDays(-$number_of_days_old)

# Number of blobs deleted
$deleted_blobs = 0

# Storage account details
$storage_account_name = "xxxxxxx"
$storage_account_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

$context = New-AzStorageContext -StorageAccountName $storage_account_name -StorageAccountKey $storage_account_key
$containers = Get-AzStorageContainer -Context $context

$MaxReturn = 5000

foreach($container in $containers)
{

$ContinuationToken = $null

do
{

$blob_list = Get-AzStorageBlob -Context $context -Container $container.Name -MaxCount $MaxReturn -ContinuationToken $ContinuationToken


## Iterate through each blob
foreach($blob in $blob_list){

    $blob_date = [datetime]$blob.LastModified.UtcDateTime
   
    # Check if the last modified date is less than our requirement and blob type you want to delete
    if($blob_date -le $date_older_for_blob_to_be_deleted -and $blob.BlobType -like "pageblob") {

       
        # Delete the blob
        Remove-AzStorageBlob -Container $container.Name -Blob $blob.Name -Context $context

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

}
write-output "Blobs deleted: " $deleted_blobs 
