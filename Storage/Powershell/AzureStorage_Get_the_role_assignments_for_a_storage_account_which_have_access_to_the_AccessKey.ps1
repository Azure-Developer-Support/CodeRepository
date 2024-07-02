#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 



# This script will help to get the role assignments for a storage account which have access to the Access Key.

Connect-AzAccount -SubscriptionId "<Subscription_ID"
 
# Get the storage account
$storageAccount = Get-AzStorageAccount -ResourceGroupName "<resource_group_name" -Name "<storage_account_name>"
 
# Get all role assignments for the particular storage account
$roleAssignments = Get-AzRoleAssignment -Scope $storageAccount.Id
 
# Loop through each role assignment
foreach ($roleAssignment in $roleAssignments) {
    # Get the role definition for the role assignment
    $roleDefinition = Get-AzRoleDefinition -Id $roleAssignment.RoleDefinitionId
 
    # Check if the role definition includes the 'Microsoft.Storage/storageAccounts/listKeys/action' permission
    if ($roleDefinition.Actions -contains 'Microsoft.Storage/storageAccounts/listKeys/action'-or $roleDefinition.Actions -contains '*' ) {
        # Print out the role assignment
        Write-Output "Role Assignment: $($roleAssignment.RoleDefinitionName) assigned to $($roleAssignment.DisplayName)"
    }
}
