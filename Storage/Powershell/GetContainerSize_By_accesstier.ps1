# Define the storage account and container name
$storageAccountName = "<<StorageAccountName>>"
$containerName = "<<ContainerName>>"
$resourceGroupName = "<<ResourceGroupName>>"
$outputCSVPath = "<<Path_to_CSV\container_capacity.csv>>"

# Get a reference to the storage account and the context
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$Ctx = $storageAccount.Context

# Initialize the continuation token for blobs
$ContinuationToken = $null

# Create an empty array to store the results
$results = @()

    
    # Loop through all blobs in the container
    do {
        # List all blobs in the container with the continuation token
        $blobs = Get-AzStorageBlob -Container $containerName -Context $Ctx -IncludeDeleted -IncludeVersion -ContinuationToken $ContinuationToken
        $ContinuationToken = $blobs.ContinuationToken
        
        # Group blobs by Access Tier and calculate the total size for each tier
        $groupedBlobs = $blobs | Group-Object -Property AccessTier
        foreach ($group in $groupedBlobs) {
            $tier = $group.Name
            $totalSize = ($group.Group | Measure-Object -Property Length -Sum).Sum
            Write-Host "Total size for $tier tier: $totalSize bytes"
            
            # Add the results to the array
            $results += [PSCustomObject]@{
                AccessTier = $tier
                TotalSizeBytes = $totalSize
            }
        }
    } while ($ContinuationToken -ne $null)


# Export the results to a CSV file
$results | Export-Csv -Path $outputCSVPath -NoTypeInformation
