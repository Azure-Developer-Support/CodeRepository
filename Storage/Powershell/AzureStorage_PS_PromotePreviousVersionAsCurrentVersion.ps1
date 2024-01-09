#The below PowerShell Script will promote the previous versions as current version that matches the prefix match within the container. 

#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, 
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


Set-AzContext -Subscription AddsubscriptionID
$storageAccount = Get-AzStorageAccount -ResourceGroupName "AddResourceGroupName" -Name "AddStorageAccountname"
$containerName = "AddContainerName"

$ctx = $storageAccount.Context

    $totalblobCount = 0

    $blob_Token = $null

    write-host "Processing container $containerName...   " -ForegroundColor magenta

        $listOfBlobs = Get-AzStorageBlob -Container $containerName -Prefix "AddPrefix" -IncludeDeleted -IncludeVersion -Context $ctx 
        if($listOfBlobs -eq $null) {
            break
        }

        $latestBlobs = $listOfBlobs | Group-Object Name | ForEach-Object { $_.Group | Sort-Object LastModified | Select-Object -Last 1 } | Where-Object { $_.IsLatestVersion -ne $true -and $_.VersionId -ne $null}

        foreach ($blob in $latestBlobs) {

            $totalblobCount++
            $blob | Copy-AzStorageBlob `
                        -DestContainer $containerName `
                        -DestBlob $blob.Name
        }
write-host "Job completed with blobs versions found : $totalblobCount"
