#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

#This Powershell script will help you delete blobs in a storage account based on access tier.

# Set your Azure Storage account details
$storageAccountName = "<storage_Account_Name>"
$storageAccountKey = "<Access_Key>"
$targetAccessTier = "Cool"  # Set the target access tier (e.g., "Cool" or "Hot" or "Cold" or "Archive")

# Authenticate to the storage account
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# Get all containers in the storage account
$containers = Get-AzStorageContainer -Context $context

# Iterate through each container
foreach ($container in $containers) {
    Write-Host "Processing container $($container.Name)"
    
    # Get all blobs in the container
    $blobs = Get-AzStorageBlob -Context $context -Container $container.Name
    
    # Iterate through each blob and check its access tier
    foreach ($blob in $blobs) {
        $blobAccessTier = $blob.ICloudBlob.Properties.StandardBlobTier
        if ($blobAccessTier -eq $targetAccessTier) {
            Write-Host "Deleting blob $($blob.Name) in container $($container.Name) with access tier $($blobAccessTier)"
            Remove-AzStorageBlob -Context $context -Container $container.Name -Blob $blob.Name
            Write-Host "Blob deleted."
        }
    }
}
