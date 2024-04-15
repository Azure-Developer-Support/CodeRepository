###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################
##########This script helps in deleting the all the version of blob by keeping last 10 version #########################



# Authenticate to your Azure account
Connect-AzAccount

# Define the variables
$StorageAccountName = "your_storage_account_name"
$ResourceGroupName = "your_resource_group_name"
$ContainerName = "your_container_name"
$VersionsToKeep = 10  # Specify the number of versions you want to keep

# Get the list of blobs and their versions
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$BlobList = Get-AzStorageBlob -Context $StorageAccount.Context -Container $ContainerName -IncludeVersions

# Sort blobs by last modified time in descending order
$SortedBlobs = $BlobList | Sort-Object { $_.LastModified.UtcDateTime } -Descending

# Delete extra versions (keeping the latest $VersionsToKeep versions)
$BlobsToDelete = $SortedBlobs | Select-Object -Skip $VersionsToKeep
foreach ($blob in $BlobsToDelete) {
    Write-Host "Deleting blob version $($blob.Name) (VersionId: $($blob.VersionId))"
    Remove-AzStorageBlob -Context $blob.Context -Container $ContainerName -Blob $blob.Name -VersionId $blob.VersionId -Force
}

Write-Host "Only the latest $VersionsToKeep blob versions are kept."
