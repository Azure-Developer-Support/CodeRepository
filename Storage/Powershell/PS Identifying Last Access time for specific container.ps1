###ATTENTION: DISCLAIMER###
 
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages
 

############# Script Overview #################################################################
########## Helps to list the blob names in a container with its last access time for specific container  #########
########## Note : If Last Access modified is not enabled then the default format as 01/01/0001 00:00:00 +00:00 ####

# Connect to Azure
Connect-AzAccount
Set-AzContext -SubscriptionName '<Subscription-Name>'

# Define storage account details
$storageAccountName = "Your storage account name"
$storageAccountKey = "Access Key of your storage account"
$containerName = "Specify the container you want to target"   

# Create storage context
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# Retrieve all blobs from the specified container and print Blobname and last access time
$blobs = Get-AzStorageBlob -Container $containerName -Context $context


# Loop through each blob and print its name and last access time
foreach ($blob in $blobs) {
    # Print Blobname and last access time
    $properties = $blob.BlobClient.GetProperties()
    Write-Output "Blob Name: $($blob.Name), Last Access Time: $($properties.Value.LastAccessed)"  # Adjust if LastAccessed is not available
}
