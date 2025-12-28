###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


############# Script Overview #################################################################
##########The below PowerShell script helps delete files with a specific extension from a given subfolder path
######in an Azure Data Lake Storage Gen2 container (hierarchical namespace enabled). 
######It recursively scans the specified directory and removes matching files while skipping folders.######

# Input Parameters
$storageAccountName = "<YourStorageAccountName>"
$storageAccountKey = "<YourStorageAccountKey>"
$containerName = "<YourContainerName>"         # Also called the file system name
$subfolderPath = "<Your/Subfolder/Path>"       # Example: "logs/2025/may"
$fileExtension = ".txt"                        # Extension of files to delete
 
# Authenticate with storage account
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
 
# Get list of items in the specified subfolder path
$items = Get-AzDataLakeGen2ChildItem -Context $context -FileSystem $containerName -Path $subfolderPath -Recurse
 
foreach ($item in $items) {
    if (-not $item.IsDirectory -and $item.Name.EndsWith($fileExtension)) {
        $blobPath = $item.Path
        Remove-AzDataLakeGen2Item -Context $context -FileSystem $containerName -Path $blobPath -Force
        Write-Output "Deleted: $blobPath"
    }
}
