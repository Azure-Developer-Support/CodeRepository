'By using the following materials or sample code you agree to be bound by the license terms below 
'and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
'These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you 
'are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you 
'are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
'not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to 
'use and modify the sample code and to reproduce and distribute the object code form of the sample code, 
'provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product 
'in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in 
'which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors 
'a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
'limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and 
'suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result 
'from the use or distribution of the sample code."

# Storage account details
$storage_account_name = " "
$storage_account_key = " "

$context = New-AzStorageContext -StorageAccountName $storage_account_name -StorageAccountKey $storage_account_key
$container = ' '

$MaxReturn = 5000

foreach($container in $containers)
{

$ContinuationToken = $null

do
{

$blob_list = Get-AzStorageBlob -Container $container -Context $context  -MaxCount $MaxReturn -ContinuationToken $ContinuationToken

Write-Host "Below are the list of Blobs with active leave" -ForegroundColor Red -BackgroundColor Yellow
## Iterate through each blob
foreach($blob in $blob_list){

if($blob.BlobProperties.LeaseState -contains 'Leased')
{
     
    Write-Host  "Name:"  $blob.Name  "Lease State:"  $blob.BlobProperties.LeaseState  "Lease Status:"  $blob.BlobProperties.LeaseStatus
    $blob.ICloudBlob.ReleaseLease() 
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
