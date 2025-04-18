#This script uses an SAS token to authenticate against an Azure storage account and deletes all previous blob versions inside of a designated container

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

#Docs
#https://learn.microsoft.com/en-us/powershell/module/az.storage/remove-azstorageblob?view=azps-13.3.0&tryIt=true&source=docs#example-4-remove-a-single-blob-version
#https://learn.microsoft.com/en-us/rest/api/storageservices/create-service-sas#permissions-for-a-directory-container-or-blob

#Needs account level SAS for x permission to delete previous versions

# Parameters – replace these with your actual values
$storageAccountName = ""
$containerName      = ""
$sasToken           = ""

# Create a storage context using the SAS token
$context = New-AzStorageContext -StorageAccountName $storageAccountName -SasToken $sasToken

# Retrieve all blobs, including their versions
$blobs = Get-AzStorageBlob -Container $containerName -Context $context -IncludeVersion

foreach ($blob in $blobs) {
    # Check if the blob object indicates whether it's the current version.
    if ($blob.IsLatestVersion -eq $true) {
        Write-Host "Skipping current version of blob: $($blob.Name)"
    }
    else {
        Write-Host "Deleting blob version: $($blob.Name) | Version ID: $($blob.VersionId)"
		Remove-AzStorageBlob -Container $containerName -Blob $blob.Name -Context $context -VersionId $blob.VersionId
    }
}
