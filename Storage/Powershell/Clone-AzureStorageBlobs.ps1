#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

#############Script Overview#################################################################
#This PowerShell script allows users to clone Azure Storage blobs either by copying a single blob within the same container or by copying all blobs from one container to another. 
#It provides an interactive menu to select the desired operation and uses Azure PowerShell commands to perform the cloning.

############################Script Sample 1#######################################

# Authenticate to Azure
Connect-AzAccount

# Set subscription
$subscriptionId = Read-Host "Enter your Azure subscription ID"
Select-AzSubscription -SubscriptionId $subscriptionId

# Common Parameters
$resourceGroupName = Read-Host "Enter the Resource Group Name"
$storageAccountName = Read-Host "Enter the Storage Account Name"

# Get storage context
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$context = $storageAccount.Context

# Menu
Write-Host "Choose an option:"
Write-Host "1 - Clone a single blob within the same container"
Write-Host "2 - Clone an entire container to another container"
$option = Read-Host "Enter your choice (1 or 2)"

if ($option -eq "1") {
    # Clone a single blob
    $containerName = Read-Host "Enter the container name"
    $sourceBlobName = Read-Host "Enter the source blob name"
    $destinationBlobName = Read-Host "Enter the destination blob name"

    Write-Host "Cloning blob '$sourceBlobName' to '$destinationBlobName' in container '$containerName'..."

    Start-AzStorageBlobCopy -SrcBlob $sourceBlobName `
                            -SrcContainer $containerName `
                            -DestBlob $destinationBlobName `
                            -DestContainer $containerName `
                            -Context $context

    $copyStatus = Get-AzStorageBlobCopyState -Container $containerName -Blob $destinationBlobName -Context $context
    Write-Host "Copy Status: $($copyStatus.Status)"
}
elseif ($option -eq "2") {
    # Clone entire container
    $sourceContainer = Read-Host "Enter the source container name"
    $destinationContainer = Read-Host "Enter the destination container name"

    # Ensure destination container exists
    $destContainerExists = Get-AzStorageContainer -Name $destinationContainer -Context $context -ErrorAction SilentlyContinue
    if (-not $destContainerExists) {
        Write-Host "Creating destination container '$destinationContainer'..."
        New-AzStorageContainer -Name $destinationContainer -Context $context | Out-Null
    }

    # Get all blobs in the source container
    $blobs = Get-AzStorageBlob -Container $sourceContainer -Context $context

    Write-Host "Cloning $($blobs.Count) blobs from '$sourceContainer' to '$destinationContainer'..."

    foreach ($blob in $blobs) {
        Start-AzStorageBlobCopy -SrcBlob $blob.Name `
                                -SrcContainer $sourceContainer `
                                -DestBlob $blob.Name `
                                -DestContainer $destinationContainer `
                                -Context $context
    }

    Write-Host "Container copy initiated. Check blob statuses if needed."
}
else {
    Write-Host "Invalid option selected. Exiting script."
}
