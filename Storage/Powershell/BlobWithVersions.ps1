Import-Module Az.Storage

$storageAccountName = "karsan" 
$StorageAccountKey = "Account Key" 
$storageContainer = "testcontainer"  
#get context  
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $StorageAccountKey  
  
#$MaxReturn = 100 
$Token = $Null    
  
do   
{   
      # get a list of all of the blobs in the container  
#$Blobs = Get-AzStorageBlob -Container $storageContainer -Context $ctx -IncludeDeleted -MaxCount $MaxReturn  -ContinuationToken $Token 
$Blobs = Get-AzStorageBlob -Container $storageContainer -Context $ctx -IncludeDeleted -IncludeVersion   -ContinuationToken $Token 
	
####Looping  to fecth deleted  blobs  

$Blobs.Name

#### Looping to  fetch blobs with Versions

$BlobswithVersion = $($Blobs | Where-Object { $_.VersionId -ne $Null}  ) 
#$DeletedBlobswithVersion = $($Blobs | Where-Object { $_.BlobProperties.LeaseState -ne $State} )
write-host "========================================="   
	write-host "All  blobs with versions : "   

$BlobswithVersion | Group-Object -Property Name -NoElement | Sort-Object -Property Count -Descending | Format-Table 


write-host "========================================="   

$Token = $Blobs[$Blobs.Count -1].ContinuationToken;   
}while ($Token -ne $Null) 
