###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

#############Script Overview#################################################################
# This script is to undelete blobs with condition of path prefix and deletion time for Azure Data Lake Storage Gen2
# The sincedate could be #specified with parameters $Year, $Month, $Day, $Hour, $Minute, $Second. Please note, the date relevant parameters are using current system environment #time zone. If sincedate is not set, the script will restore all soft-deleted items.
# The script is tested with Powershell 5.1.2, Az.Storage 5.4.
############################Script Sample #######################################

#Please update these value as per your scenario
$storageAccountName = "<Storage Account name>" 
$StorageAccountKey = "<Storage account key>" 
#get context  
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $StorageAccountKey  
$filesystemName= "<Container name>"  
$dirName="<Directory name>"
$MaxReturn = 100    
$Token = $Null  
###year/month/date from which the soft deleted blobs needs to be undeleted. 
$Year = '' #example: 2024
$Month='' #example: 04
$Day='' #example: 11
$Hour='0'
$Minute='0'
$Second = '0'
If($Year -ne '' -and $Month -ne '' -and $Day -ne ''){
   $sinceDate = Get-Date -Year $Year -Month $Month -Day $Day -Hour $Hour -Minute $Minute -Second $Second  -ErrorAction Stop
}else{
   $sinceDate = (Get-Date -AsUTC).AddDays(-366)
}
write-host $sinceDate
do   
{   
   # list the deleted blobs in the path  
   $DeletedItems= Get-AzDataLakeGen2DeletedItem -Context $ctx -FileSystem $filesystemName -Path $dirName -MaxCount $MaxReturn -ContinuationToken $Token #get all deleted items
   write-host "========================================"   
   write-host "Soft deleted items: "   
   $DeletedItems.Path
   $Token = $DeletedItems[$DeletedItems.Count-1].ContinuationToken
   $DeletedItems| Where-Object {$_.DeletedOn -ge [DateTime] $sinceDate} |Restore-AzDataLakeGen2DeletedItem #restore the items that meet the criteria
}while ($Token -ne '') 
 ##End of script
