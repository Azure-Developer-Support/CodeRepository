###By using the following materials or sample code you agree to be bound by the license terms below  
#and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference.  
#These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you  
#are located, one of its affiliates) and you. Any materials (other than this sample code) we provide to you  
#are for your internal use only. Any sample code is provided for the purpose of illustration only and is  
#not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to  
#use and modify the sample code and to reproduce and distribute the object code form of the sample code,  
#provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product  
#in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in  
#which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors  
#a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable  
#limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and  
#suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result  
#from the use or distribution of the sample code." 
#To undelete a container’s soft deleted blobs: 

$storageAccountName = "xxxx" 
$StorageAccountKey = "xxxx" 
$storageContainer = "xxxx"  
#get context  
$ctx = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $StorageAccountKey  
  
$MaxReturn = 100    
$Token = $Null    
  
do   
{   
      # get a list of all of the blobs in the container  
	$Blobs = Get-AzStorageBlob -Container $storageContainer -Context $ctx -IncludeDeleted -MaxCount $MaxReturn  -ContinuationToken $Token 
	write-host "========================================="   
	write-host "All Blobs including soft deleted ones: "   
	$Blobs.Name   
	$c=0   
	$State="Unspecified"   
	foreach($blob in $Blobs){   
		if($blob.ICloudBlob.Properties.LeaseState -eq $State)   
		{   
		write-host "========================================"   
		$c++ 
		write-host "Blob name: " $blob.Name   
		write-host "Deleted at: " $blob.ICloudBlob.Properties.DeletedTime.ToString()   
		}   
	}   
	write-host "A total of " $c " blobs were soft deleted out of a total of " $Blobs.Name.Count " blobs" 
	# To Undelete the blobs   
	write-host "Undeleting blobs...." 
	$Blobs.ICloudBlob.Undelete() 
	$Token = $blob[$blob.Count -1].ContinuationToken;   
}while ($Token -ne $Null) 
