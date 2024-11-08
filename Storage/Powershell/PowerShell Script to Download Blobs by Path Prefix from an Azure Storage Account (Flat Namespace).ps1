PowerShell Script to Download Blobs by Path Prefix from an Azure Storage Account (Flat Namespace).

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

Connect-AzAccount
$subscriptionId = "Your subscriptionID"
Select-AzSubscription -SubscriptionId $subscriptionId
$resourceGroupName = "your-resource-group-name"    # Replace with your resource group name
$storageAccountName = "your-storage-account-name"  # Replace with your storage account name
$containerName = "insights-activity-logs"         # The container name
$prefix = "resourceId=/SUBSCRIPTIONS/$subscriptionId/y=2024" # Path of the blobs
$destinationPath = "C:\path\to\download\directory" # Replace with your desired local path
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$ctx = $storageAccount.Context
$blobs = Get-AzStorageBlob -Container $containerName -Context $ctx -Prefix $prefix
 
foreach ($blob in $blobs) {
   $filePath = Join-Path -Path $destinationPath -ChildPath $blob.Name.Replace("/", "\")
   $fileDir = Split-Path -Path $filePath -Parentz
   if (!(Test-Path $fileDir)) {
        New-Item -ItemType Directory -Force -Path $fileDir
   }
   Write-Output "Downloading $($blob.Name) to $filePath"
   Get-AzStorageBlobContent -Blob $blob.Name -Container $containerName -Context $ctx -Destination $filePath -Force
}

