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


$MaxReturn = 1500
#Please modify the following properties
$resourceGroup = ""
$storageAccountName = ""
$containerName = ""
$FullPath = ""
#ignore fullpath variable you want to get total size of container opposed to path along storage
#End Modifications
 
$Total = 0
$Token = $Null
$thesum = 0
 
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName 
 
$ctx = $storageAccount.Context 	
 
do
{
     $Blobs = Get-AzStorageBlob -Container $ContainerName -MaxCount $MaxReturn -Prefix $FullPath -ContinuationToken $Token -Context $ctx
     $Total += $Blobs.Count
     if($Blobs.Length -le 0) { Break;}
     $Token = $Blobs[$blobs.Count -1].ContinuationToken;
     $temp = $Blobs | Measure-Object -property length -sum
     $thesum =  $thesum + $temp.Sum
}
While ($Token -ne $Null)

$totalsize = [math]::ceiling((($thesum/1024)/1024))
Write-Host " "
Write-Host "++++++++++++++++++++++++++++++"
Write-Host " "
Echo "Total $Total blobs in container $ContainerName"
Write-Host " "
Write-Host "The size of $FullPath is = " $totalsize "MB"
Write-Host "-----All Property-----"