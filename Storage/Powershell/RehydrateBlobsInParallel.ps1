# Azure Storage Bulk Rehydrate A Set Of Blobs - PowerShell
### ATTENTION: DISCLAIMER ###

# DISCLAIMER
# The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
# without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


############# Script Overview #################################################################
########## This script help in optimizing the performance for bulk rehydration of a set of blobs #########################

    # Initialize these variables with your values.
    $rgName = "rehydrateresourcegroup" # Resource Group name where storage account is present
    $accountName = "rehydratestorageaccount" # Storage Account name
    $containerName = "rehydratecontainer" # Azure Storage Container name
    $folderName = "store_new/cam.com-1/store_2024/" # Path of the folder where the blobs are present

    # Get Storage Context
    $ctx = (Get-AzStorageAccount -ResourceGroupName $rgName -Name $accountName).Context

    $timer = [Diagnostics.Stopwatch]::StartNew() # Start timer to compare the performance

    # Get all blobs present in a folder of a storage container
    $Blobs = Get-AzStorageBlob -Context $ctx -Container $containerName -Prefix $folderName
    $Blobs | ForEach-Object -Parallel {
                if(($_.BlobType -eq "BlockBlob") -and ($_.AccessTier -eq "Hot") ) {
                    $_.BlobClient.SetAccessTier("Archive", $null)
                }
            }
            $timer.stop() # Stop timer to compare the performance

Write-Output($timer.elapsed.totalseconds)
