#This script will help to create BLM Policy on multiple Storage accounts (for all Blobs of all ST Accounts) of a RG/Subscription. 
#It will help to set actions for Data Move to Cool Tier --> Cool to Archive--> Delete Blob (USers can select days according to their requirement).
#It will help to set actions for deleting versions and Snapshots as well.
#If Users want to set only one action in that case they can comment other actions by using # in script.



#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service.
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including,
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including,
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages


################# Azure Blob Storage - PowerShell ####################    
Connect-AzAccount 
Set-AzContext -SubscriptionName 'XXXXXXXXXXXXXXXXXXXXXXX' 
$resourceGroup = "YYYYYYY" 
$storageAccounts = @("XYZ", "ABC",................,"NNN") 

#Set BLT policy on each storage account 

foreach ($storageAccount in $storageAccounts) 
{ 

#Create actions 
$action = Add-AzStorageAccountManagementPolicyAction -InputObject $action -BaseBlobAction TierToCool -daysAfterModificationGreaterThan 30 
Add-AzStorageAccountManagementPolicyAction -InputObject $action -BaseBlobAction TierToArchive -daysAfterModificationGreaterThan 90
Add-AzStorageAccountManagementPolicyAction -BaseBlobAction Delete -daysAfterModificationGreaterThan 180 
Add-AzStorageAccountManagementPolicyAction -InputObject $action -SnapshotAction Delete -daysAfterCreationGreaterThan 90
Add-AzStorageAccountManagementPolicyAction -InputObject $action -BlobVersionAction Delete -daysAfterCreationGreaterThan 90


#Set the filter
$filter = New-AzStorageAccountManagementPolicyFilter -BlobType blockBlob 

# Create a new rule object. 
$rule1 = New-AzStorageAccountManagementPolicyRule -Name "sample-rule" -Action $action -Filter $filter 

# Create the policy.
Set-AzStorageAccountManagementPolicy -ResourceGroupName $resourceGroup -StorageAccountName $storageAccount -Rule $rule1    
}
