#The below PowerShell script helps delete blobs/files with specific extension on a container and based on last modified time.

#Disclaimer
#By using the following materials or sample code you agree to be bound by the license terms below 
#and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
#These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you 
#are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you 
#are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
#not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to 
#use and modify the sample code and to reproduce and distribute the object code form of the sample code, 
#provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product 
#in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in 
#which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors 
#a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
#limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and 
#suppliers from and against any third party claims or lawsuits, including attorneys fees, that arise or result 
#from the use or distribution of the sample code."

$number_of_days_old = 30  #Kindly change it accordingly based on how old files you would like to delete
$current_date = get-date
$date_older_for_blob_to_be_deleted = $current_date.AddDays(-$number_of_days_old)


$storageAccountName = ""
$storageAccountKey = ""
$containerName = ""
$fileExtension = ".txt" # Replace with the desired file extension to delete

# Connect to Azure Storage account
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# Get a list of all blobs in the container
$blobs = Get-AzStorageBlob -Context $context -Container $containerName

# Loop through each blob and delete those with the specified file extension
foreach ($blob in $blobs) {
    $blob_date = [datetime]$blob.LastModified.UtcDateTime
    if ($blob.Name.EndsWith($fileExtension) -and $blob_date -le $date_older_for_blob_to_be_deleted) {
        Remove-AzStorageBlob -Context $context -Container $containerName -Blob $blob.Name
        Write-Output "Deleted blob: $($blob.Name)"
    }
}
