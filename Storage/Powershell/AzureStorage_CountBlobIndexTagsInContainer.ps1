#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. 
#Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
#The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

# Connect to your Azure account
Connect-AzAccount
# Provide your subscription ID
$subscriptionId = "XXXXXXX"
# Set the context to the subscription
Select-AzSubscription -SubscriptionId $subscriptionId
# Provide the name of your resource group, storage account, and container
$resourceGroupName = "XXX"
$storageAccountName = "XXXXXX"
$containerName = "XXXXXX"
# Get the context of the storage account
$ctx = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName).Context
# Initialize a counter for the total number of tags
$totalTags = 0
# Retrieve the list of blobs in the container
$blobs = Get-AzStorageBlob -Container $containerName -Context $ctx
# Loop through each blob and retrieve its tags
foreach ($blob in $blobs) {
   $blobName = $blob.Name
   $tags = Get-AzStorageBlobTag -Blob $blobName -Container $containerName -Context $ctx
   $totalTags += $tags.Count
}
# Output the total number of tags
Write-Output "Total number of blob index tags: $totalTags"
