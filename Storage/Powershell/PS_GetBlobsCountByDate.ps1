#Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. 
#THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
#INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 
#We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code 
#form of the Sample Code, provided that. You agree: (i) to not use Our name, logo, or trademarks to market Your software product in
#which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; 
#and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, 
#that arise or result from the use or distribution of the Sample Code.

#Script iterates through blob storage account and returns a count of blobs that are less than the date modified date below

$MaxReturn = 1000
#Please modify the following properties
$resourceGroup = "testresourcegroup"
$storageAccountName = "teststorageaccount"
$dateModified = "04/01/2023"
$accKey =  "testaccesskey"
$checkParam = "CreationTime" #Valid options are LastModified, CreationTime
#End Modifications

#Get storage context and container list
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $accKey 	
$containers = Get-AzStorageContainer -Context $ctx | Select Name

#Iterate each container
Foreach ($container in $containers)
{
    #Continuation token for containers with more then 15k blobs
    $Token = $Null
    $Total = 0
    do
    {
        if($container -eq $NULL) {break;}
        $Blobs = Get-AzStorageBlob -Container $container.Name -Context $ctx.Context | Where-Object{$_.$checkParam.DateTime -lt $dateModified}
        $Total += $Blobs.Count
        if($Blobs.Length -le 0) { Break;}
        $Token = $Blobs[$blobs.Count -1].ContinuationToken;
    }
    While ($Token -ne $Null)
    Write-Host "Total $Total blobs in container" $container.Name
}