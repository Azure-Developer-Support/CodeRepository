#The below PowerShell script helps to undelete  the blobs present in available state.



#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service.
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including,
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including,
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages

Import-Module Az.Storage

$storageAccountName = "test" 
$StorageAccountKey = "XXXX" 
$storageContainer = "testcontainer"  
#get context  
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $StorageAccountKey  
  
#$MaxReturn = 100 
$Token = $Null    
  
do   
{   
      # get a list of all of the blobs in the container  
#	$Blobs = Get-AzStorageBlob -Container $storageContainer -Context $ctx -IncludeDeleted -MaxCount $MaxReturn  -ContinuationToken $Token 
$Blobs = Get-AzStorageBlob -Container $storageContainer -Context $ctx -IncludeDeleted -IncludeVersion   -ContinuationToken $Token 
	write-host "========================================="   
	write-host "All Blobs including soft deleted ones: "   
	$Blobs.Name   
	$c=0   
	$State="Available"   
$Blobs.Count
	foreach($blob in $Blobs){ 
         
     write-host "Blob state: " $blob.BlobProperties.LeaseState
		if($blob.BlobProperties.LeaseState -ne $State)   
		{   
		write-host "========================================"   
		$c++ 
		write-host "Blob name: " $blob.Name   
		write-host "Deleted at: " $blob.Properties.DeletedTime.ToString()   

# To Undelete the blobs   
	write-host "Undeleting blobs...." 
	$blob..Undelete()
		}   
	}   
	write-host "A total of " $c " blobs were soft deleted out of a total of " $Blobs.Name.Count " blobs" 
	
	$Token = $blob[$blob.Count -1].ContinuationToken;   
}while ($Token -ne $Null) 
