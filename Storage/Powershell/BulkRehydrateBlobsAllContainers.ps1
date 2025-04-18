# This script loops through each container in an Azure storage account and rehydrates any blob in the Archive tier to the Hot tier

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

# Initialize these variables with your values.
$rgName = ""
$accountName = ""

$ctx = (Get-AzStorageAccount -ResourceGroupName $rgName -Name $accountName).Context

$containers = Get-AzStorageContainer -Context $ctx

foreach ($container in $containers) {
    $containerName = $container.Name
    $blobCount = 0
    $Token = $Null
    $MaxReturn = 5000

    do {
        $Blobs = Get-AzStorageBlob -Context $ctx -Container $containerName -MaxCount $MaxReturn -ContinuationToken $Token
        if ($Blobs -eq $Null) { break }
        if ($Blobs.GetType().Name -eq "AzureStorageBlob") {
            $Token = $Null
        } else {
            $Token = $Blobs[$Blobs.Count - 1].ContinuationToken
        }
        $Blobs | ForEach-Object {
            if ($_.BlobType -eq "BlockBlob" -and $_.AccessTier -eq "Archive") {
                $_.BlobClient.SetAccessTier("Hot", $null, "Standard")
            }
        }
    } while ($Token -ne $Null)
}
