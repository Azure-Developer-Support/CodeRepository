#param(
#    [parameter(Mandatory=$true)]
#    [String]$storageAccessKey,
#
#    # StorageAccount name for content deletion.
#    [Parameter(Mandatory = $true)] 
#    [String]$StorageAccountName,
#
#    # StorageContainer name for content deletion.
#    [Parameter(Mandatory = $true)] 
#    [String]$FileName,
########################################################################
#Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
#THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
#INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. We grant You a nonexclusive, 
#royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that. 
#You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; (ii) to include 
#a valid copyright notice on Your software product in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us 
#and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of 
#the Sample Code.
########################################################################
#)
$storageAccessKey = "<access key>";
$StorageAccountName = "<storage account>";
$FileName = "file.txt";
$tags = @{"tag1" = "value1"; "tag2" = "value2" } 
$containerToken = $NULL;
$blobToken = $NULL;
$maxreturnvalue = 1000;

#Get storage Context
$StorageAccountContext = New-AzStorageContext -storageAccountName $StorageAccountName -StorageAccountKey $storageAccessKey;
do{
    #Get list of containers
    $containers = Get-AzStorageContainer -Context $StorageAccountContext -MaxCount $maxreturnvalue -ContinuationToken $containerToken;

    if($containers -eq $null) {break;}

    #Iterate containers
    foreach ($container in $containers)
    {
        $containerName = $container.Name;
        do{
            $blobs = Get-AzStorageBlob -Container $containerName -Context $StorageAccountContext -MaxCount $maxreturnvalue -ContinuationToken $containerToken;

            $blobs = $blobs; 
            $blobsupdated = 0;
            if($blobs -eq $null) {break;}

            #Iterate blobs   
            foreach ($blob in $blobs)
            {
                $blobname = $blob.Name
                if ($blobname -eq $FileName)
                {
                    Write-output ("Blob {0} equals filename {1} " –f $blob.Name, $FileName);
                    Write-output ("Updating Blob {0} tag to tag name" –f $blob.Name);
                    #Get-AzStorageBlobTag -Context $StorageAccountContext -Container $container -Blob $blobname
                    Set-AzStorageBlobTag -Context $StorageAccountContext -Container $containerName -Blob $blobname -Tag $tags
                    Write-output ("Updated blob with tags: {0}" –f $blobname);
                    $blobsupdated++;
                }
                else 
                {
                    Write-output ("Blob name did not match.");
                }
            }
            $blobToken = $blobs[$blobs.Count -1].ContinuationToken;
        }
        While($null -ne $blobToken)
        
        Write-output ("{0} blobs updated from container {1}." –f $blobsupdated, $containerName);
        $containerName = $null;
    }
    $containerToken = $containers[$containers.Count -1].ContinuationToken;
}
While($null -ne $containerToken)

