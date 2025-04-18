#This script authenticates against an Azure storage account using an Entra token uses the REST API to permanently deletes all soft delete blobs in the archive tier in any container

# ====================================================================================
# DISABLE SOFT DELETE FEATURE ON STORAGE ACCOUNT BEFORE RUNNING THIS SCRIPT
# You can reenable Soft Delete featurs after running this script, if needed.
# By default, the script will only list the total count of soft delete blobs in the archive tier.
# Paremeter $PERMANENT_DELETE needs to be changed from 'LIST' to 'DELETE' to permanently delete blobs.
# ====================================================================================
# DISCLAMER : please note that this script is to be considered as a sample and is provided as is with no warranties express or implied, even more considering this is about deleting data.   
# This script should be tested in a dev environment before using in Production.
# You can use or change this script at you own risk.
# ====================================================================================

#Authentication
Connect-AzAccount

# Define the storage account and resource group
$storageAccountName = ""
$resourceGroup = ""
$PERMANENT_DELETE = "LIST"

# Get the storage account context
$context = (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName).Context

# Get the access token
$token = Get-AzAccessToken -ResourceUrl "https://storage.azure.com/"

# List all containers in the storage account
$containers = Get-AzStorageContainer -Context $context

# Initialize counters
$blobCount = 0
$undeletedCount = 0
$deletedCount = 0

foreach ($container in $containers) {
    # List all blobs in the container, including deleted ones
    $blobs = Get-AzStorageBlob -Container $container.Name -Context $context -IncludeDeleted

    foreach ($blob in $blobs) {
        # Apply the condition to filter blobs
        if ($PERMANENT_DELETE -eq "DELETE" -and $blob.BlobType -eq "BlockBlob" -and $blob.AccessTier -eq "Archive" -and $blob.IsDeleted -eq $true) {
            # Construct the URI for the undelete operation
            $undeleteUri = "https://" + $blob.BlobClient.Uri.Host + $blob.BlobClient.Uri.AbsolutePath + "?comp=undelete"

            # Set the headers with the authorization token
            $headers = @{
                'Authorization' = "Bearer $($token.Token)"
                'x-ms-version' = '2021-12-02'  # Specify the latest storage API version
                'x-ms-date' = (Get-Date).ToUniversalTime().ToString("R")
                'Content-Length' = '0'  # Required for PUT operations without a body
            }

            # Try to undelete the blob
            try {
                $res = Invoke-RestMethod -Method "Put" -Uri $undeleteUri -Headers $headers
                $undeletedCount++
            } catch {
                Write-Warning -Message "Failed to undelete blob in container $($container.Name): $($_.Exception.Message)" -ErrorAction Stop
            }

            # Construct the URI for the delete operation
            $deleteUri = "https://" + $blob.BlobClient.Uri.Host + $blob.BlobClient.Uri.AbsolutePath

            # Try to delete the blob
            try {
                $res = Invoke-RestMethod -Method "Delete" -Uri $deleteUri -Headers $headers
                $deletedCount++
            } catch {
                Write-Warning -Message "Failed to delete blob in container $($container.Name): $($_.Exception.Message)" -ErrorAction Stop
            }
        }if ($PERMANENT_DELETE -eq "LIST" -and $blob.BlobType -eq "BlockBlob" -and $blob.AccessTier -eq "Archive" -and $blob.IsDeleted -eq $true){
			$blobCount++
		}
    }
}

if ($PERMANENT_DELETE -eq "LIST"){
	Write-Output "Soft deleted blobs in archive tier: $blobCount"
} if ($PERMANENT_DELETE -eq "DELETE"){
Write-Output "Total undeleted blobs: $undeletedCount"
Write-Output "Total deleted blobs: $deletedCount"
}
