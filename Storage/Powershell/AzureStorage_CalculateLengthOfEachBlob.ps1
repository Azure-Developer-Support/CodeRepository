###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################
##########This script provides and displays size of all the respective containers inside a storage account(General Purpose GPv2)#########################
# Before running this, you need to create a storage account, create some containers inside that account,
# and upload some blobs into the container.
# Note: Container length is calculated by adding size of all the blobs inside it. In order to calculate size of each container,
# we retrieve all of the blobs in the container in one command. 
# If you are going to run this against a container with a lot of blobs
# (more than a couple hundred), use continuation tokens to retrieve the list of blobs.
#
#Similar links where we calculate total size of the blobs in a specific container: https://docs.microsoft.com/en-us/azure/storage/scripts/storage-blobs-container-calculate-size-powershell

############################Script Sample #######################################

#Please update these value as per your scenario
$resourceGroupName="<your storage account resource group>"    
$storageAccName="<your storage account name>" 

#you can uncomment this login command if you're already logged in
Login-AzAccount
 
 ## Display a generic message that you are retrieving storage containers
 Write-Host -ForegroundColor Green "Retrieving storage container.."        
 
 ## Get the storage account from which containers has to be retrieved    
 $storageAcc=Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccName        
 
 ## Get the storage account context    
 $ctx=$storageAcc.Context    
 
 ## List all the containers    
 $containers=Get-AzStorageContainer  -Context $ctx     
 
 ## this loops through the list of all the containers and then there respective blobs and retrieves the length for each blob. Container length will be 
 ## determined by adding the size of all the blobs inside it 
 foreach($container in $containers)    
    {    
         $listOfBLobs = Get-AzStorageBlob -Container $container.Name  -Context $ctx 
         $length = 0
         $listOfBlobs | ForEach-Object {$length = $length + $_.Length}
         # output the container and their respective sizes
         write-host -ForegroundColor Yellow "Container Name is " $container.Name " and its length is " $length
    }     
 
 ##End of script
