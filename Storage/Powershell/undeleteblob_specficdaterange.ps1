###ATTENTION: DISCLAIMER###
 
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages
 
 
############# Script Overview #################################################################
########## Helps to undelete blobs with specific timeframe on the mentioned Storage account Container  #########

# Define the storage account context
$storageAccountName = "SA"  # Replace with your storage account name
$resourceGroupName = "RG"    # Replace with your resource group name
$context = (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName).Context

# Define the container and date-time range
$containerName = "CN"  # Replace with your container name
$startDateTime = Get-Date "2025-02-27T10:00:00" # Replace with your start date and time
$endDateTime = Get-Date "2025-02-27T15:49:00"   # Replace with your end date and time
$MaxReturn = 100
$Token=Null

do {
    # Get a list of all blobs in the container including soft deleted ones
    $Blobs = Get-AzStorageBlob -Container $containerName -Context $context -IncludeDeleted -MaxCount $MaxReturn -ContinuationToken $Token
    write-host "========================================"
    write-host "All Blobs including soft deleted ones: " $Blobs.Name

    # Filter blobs based on the specified date range
    $DeletedBlobs = $Blobs | Where-Object { 
        ($_.ListBlobProperties.Properties.DeletedOn.DateTime -ge $startDateTime) -and 
        ($_.ListBlobProperties.Properties.DeletedOn.DateTime -le $endDateTime) -and 
        ($_.IsDeleted -eq $true)
    }

    if ($DeletedBlobs.Count -gt 0) {
        $DeletedBlobs.BlobBaseClient.Undelete()
    }

    $Token = $Blobs[$Blobs.Count - 1].ContinuationToken
} while ($Token -ne $Null) 

