###ATTENTION: DISCLAIMER###
 
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages
 
 
############# Script Overview #################################################################
########## Helps to list the blobnames in a conatiner with its last access time  #########

$storageAccountName = "Your storage account name" 
$storageAccountKey = "Access Key of your storage account"
# Replace with the desired file extension to delete


# Connect to Azure Storage account
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey


# Step 2: List all containers within the specified storage account
$containers = Get-AzStorageContainer -Context $context

# Step 3: Retrieve all blobs from the specified container and print Blobname and last access time
foreach ($container in $containers) {
    $blobs = Get-AzStorageBlob -Container $container.Name -Context $context
    foreach ($blob in $blobs) {
        # Print Blobname and last access time
        $properties = $blob.BlobClient.GetProperties()
        Write-Output "Blob Name: $($blob.Name), Last Access Time: $($properties.Value.LastAccessed)"  # Last access time property may need to be adjusted based on actual blob properties
    }
} 

