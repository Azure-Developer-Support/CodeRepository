#The below PowerShell script helps you checking the replication status of the blobs in the source container configured under object replication policy.

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

#Provide Source Storage Account Name
$storageaccountname = "Storage Account Name"

#Provide Source Storage Account Access Keys
$storage_account_key = "Storage Account Access Key”

#Provide Source Container Name
$container = "Source Container Name"

$context = New-AzStorageContext -StorageAccountName $storageaccountname -StorageAccountKey $storage_account_key
$MaxReturn = 5000
do
{
$blob_list = Get-AzStorageBlob -Context $context -Container $container  -MaxCount $MaxReturn -ContinuationToken $ContinuationToken
foreach($blob in $blob_list)
{
             write-host "Blob Name" $blob.Name
             Write-Host "Blob Replication Rule" $blob.BlobProperties.ObjectReplicationSourceProperties[0].Rules[0].RuleId
             Write-Host "Blob Replication Status" $blob.BlobProperties.ObjectReplicationSourceProperties[0].Rules[0].ReplicationStatus
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

