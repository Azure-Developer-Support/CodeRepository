
# Note: if the blobs are deleted in the Archive tier when versioning and soft delete is enabled it not supported to promote previous version to a new current version)
#Snapshots that are tiered to archive can't be rehydrated back into the snapshot. That is, the snapshot can't be brought back to a hot or cool tier. The only way to retrieve the data from an archive snapshot or version is to copy it to a new blob
#This script helps to copy Versions in Archive tier to new blob in destination container with rehydration to online tier

#Disclaimer
#By using the following materials or sample code you agree to be bound by the license terms below 
#and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
#These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you 
#are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you 
#are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
#not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to 
#use and modify the sample code and to reproduce and distribute the object code form of the sample code, 
#provided that you agree: (i) to not use Microsoftâ€™s name, logo, or trademarks to market your software product 
#in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in 
#which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors 
#a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
#limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and 
#suppliers from and against any third party claims or lawsuits, including attorneysâ€™ fees, that arise or result 
#from the use or distribution of the sample code."

Set-AzContext -Subscription SubID
$storageAccount = Get-AzStorageAccount -ResourceGroupName "RGname" -Name "Storagename"
$containerName = "Source conatiner name"
$containerName1="Destination conatiner name"

$ctx = $storageAccount.Context

    $totalblobCount = 0

    $blob_Token = $null

    write-host "Processing container $containerName...   " -ForegroundColor magenta

        $listOfBlobs = Get-AzStorageBlob -Container $containerName -IncludeDeleted -IncludeVersion -Context $ctx 
        if($listOfBlobs -eq $null) {
            break
        }

        $latestBlobs = $listOfBlobs | Group-Object Name | ForEach-Object { $_.Group | Sort-Object LastModified | Select-Object -Last 1 } | Where-Object { $_.IsLatestVersion -ne $true -and $_.VersionId -ne $null -and $_.AccessTier -eq "Archive"}

        foreach ($blob in $latestBlobs) {

            $totalblobCount++
            #$blob | Copy-AzStorageBlob `
                        #-DestContainer $containerName1 `
                        #-DestBlob $blob.Name

               $blob | Start-AzStorageBlobCopy -DestContainer $containerName1 -RehydratePriority High -StandardBlobTier Hot 
        }
write-host "Job completed with blobs versions found : $totalblobCount"
