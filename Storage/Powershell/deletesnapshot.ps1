###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################
##########This script helps in deleting the snapshots in the specific container #########################

# Replace with your actual storage account details
$accountname = "" # Replace with your Storage account name
$accountkey = "" # Replace with your Access key
$containerName = ""  # Replace with your container name

# Connect to your Azure Storage account
$ctx = New-AzStorageContext -StorageAccountName $accountname -StorageAccountKey $accountkey

# Get all blobs in the specified container
$blobs = Get-AzStorageBlob -Container $containerName -Context $ctx

# Iterate through each blob and delete its snapshots
foreach ($blob in $blobs) 
{
    if ($blob.SnapshotTime) 
    {
        Remove-AzStorageBlob -Container $containerName -Blob $blob.Name -SnapshotTime $blob.SnapshotTime -Context $ctx -Force
        Write-Host "Deleted snapshot for blob: $($blob.Name)"
    }
  }
Write-Host "All blob snapshots have been deleted (excluding specified paths)."

