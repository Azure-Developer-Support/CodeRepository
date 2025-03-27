#The below PowerShell script helps to Copy Blobs with Index Tags Between Azure Storage Accounts.

#DISCLAIMER:
#By using the following materials or sample code you agree to be bound by the license terms below and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
#These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you are located, one of its affiliates) and you. Any materials (other than this sample code) we provide to you are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
#not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to use and modify the sample code and to reproduce and distribute the object code form of the sample code, provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product 
#in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
#limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the sample code." 



$sourceContext = New-AzStorageContext -StorageAccountName "Source storage account" -StorageAccountKey "Access key"
$destContext = New-AzStorageContext -StorageAccountName "Destination storage account" -StorageAccountKey "Access key"

# Define Blob Details
$sourceContainer = "Source Container Name"
$destinationContainer = "Destination Container Name"

# Initialize Continuation Token
$continuationToken = $null

do {
    # Fetch blobs in pages with the continuation token
    $blobResults = Get-AzStorageBlob -Container $sourceContainer -Context $sourceContext -IncludeTag -MaxCount 1000 -ContinuationToken $continuationToken

    # Extract blobs and update the continuation token
    $blobs = $blobResults | Where-Object { $_ -is [Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel.AzureStorageBlob] }
    $continuationToken = $blobResults.ContinuationToken

    foreach ($blob in $blobs) {
        $blobName = $blob.Name
        Write-Host "Processing blob: $blobName"

        # Retrieve index tags
        $tags = $blob.Tags

        # Copy blob to destination
        $copyStatus = Start-AzStorageBlobCopy -SrcBlob $blobName -SrcContainer $sourceContainer -Context $sourceContext `
            -DestBlob $blobName -DestContainer $destinationContainer -DestContext $destContext

        if ($copyStatus) {
            Write-Host "Copy started for: $blobName"

            # Apply tags to the copied blob
            if ($tags) {
                Set-AzStorageBlobTag -Container $destinationContainer -Blob $blobName -Context $destContext -Tag $tags
                Write-Host "Applied tags for: $blobName"
            }
        } else {
            Write-Host "Failed to copy: $blobName"
        }
    }

} while ($continuationToken -ne $null)  # Continue if more blobs exist

Write-Host "All blobs copied successfully with tags!" 
