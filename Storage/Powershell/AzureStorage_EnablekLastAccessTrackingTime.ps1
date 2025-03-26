###ATTENTION: DISCLAIMER###
 
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages
 
 
############# Script Overview #################################################################
########## To enable last access time tracking for all Azure Storage accounts in a subscription using PowerShell, you can use the following script #########

AzureStorage_EnablekLastAccessTrackingTime.ps1
# Install the Az.Storage module if not already installed
#Install-Module -Name Az.Storage -AllowClobber -Force

# Connect to your Azure account
Connect-AzAccount

# Set the subscription ID
$subscriptionId = "**********************"
Select-AzSubscription -SubscriptionId $subscriptionId

# Get all storage accounts in the subscription
$storageAccounts = Get-AzStorageAccount

# Loop through each storage account and enable last access time tracking
foreach ($storageAccount in $storageAccounts) {
    $resourceGroupName = $storageAccount.ResourceGroupName
    $storageAccountName = $storageAccount.StorageAccountName

    # Enable last access time tracking
    Enable-AzStorageBlobLastAccessTimeTracking -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName -PassThru
}

Write-Output "Last access time tracking enabled for all storage accounts in the subscription."


#Replace `"your-subscription-id"` with your actual subscription ID. This script will enable last access time tracking for all storage accounts in the specified subscription .
#End of Script#
