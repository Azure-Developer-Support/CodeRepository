#The below PowerShell script helps you to list the blobs matching last modified date to a particular one

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

$storageaccountname = "Storage Account Name"

$storage_account_key = "Storage Account Key"

$container = "Container Name"

$context = New-AzureStorageContext -StorageAccountName $storageaccountname -StorageAccountKey $storage_account_key

$FolderName = "Folder Name"

$MaxReturn = 5000

$Targetmodifieddate="Date in MM/DD/YYYY format"

$total_blob_count = 0

do

{

$blob_list = Get-AzureStorageBlob -Context $context -Container $container -Prefix $FolderName/  -MaxCount $MaxReturn -ContinuationToken $ContinuationToken

foreach($blob in $blob_list){

    if($blob.ICloudBlob.Properties.LastModified.Date.ToShortDateString() -eq $Targetmodifieddate) {

                write-host "Blob Name" $blob.Name
                write-host "Modified Time:" $blob.ICloudBlob.Properties.LastModified.Date.ToShortDateString();
                $total_blob_count++
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

}while ($ContinuationToken -ne $null)

 Write-Host "Total Number of Blobs : " $total_blob_count