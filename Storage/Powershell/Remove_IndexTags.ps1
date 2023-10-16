
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. 
#Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
#The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

#Removing index tags in a storage account

Connect-AzAccount -Subscription "XXXXXXXXXXXXXXXXXXXXXXXX"

$resourceGroup = "ResourceGroup"
$storageAccountName = "StorageAccoutName"
$containerName = "ContainerName"

# get a reference to the storage account and the context
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName

$ctx = $storageAccount.Context 

# get a list of all of the blobs in the container 
$listOfBlobs= Get-AzStorageBlob -Container $containerName -Context $ctx 


foreach($blob in $listOfBlobs)
{

 $blob= $blob.Name

 $tags = @{}
Set-AzStorageBlobTag -Context $ctx -Container $containerName -Blob $blob -Tag $tags 

}
