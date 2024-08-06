###ATTENTION: DISCLAIMER###
 
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages
 
 
########## Script Overview #################################################################
########## This script helps list the storage accounts with Public Network Access enabled or disabled within a subscription #######

# Ensure you have the necessary modules installed
Install-Module -Name Az -Force -Scope CurrentUser

# Connect to your Azure account
Connect-AzAccount

# Specify your subscription (optional if you want to use the default subscription)
$subscriptionId = "your-subscription-id"
Select-AzSubscription -SubscriptionId $subscriptionId

# Get all storage accounts in the subscription
$storageAccounts = Get-AzStorageAccount

# Create an array to hold the results
$result = @()

# Loop through each storage account
foreach ($storageAccount in $storageAccounts) {
    $networkRuleSet = $storageAccount.NetworkRuleSet
    $publicNetworkAccess = if ($networkRuleSet.DefaultAction -eq "Allow") { "Enabled" } else { "Disabled" }
    
    # Add the storage account information to the results array
    $result += [PSCustomObject]@{
        StorageAccountName = $storageAccount.StorageAccountName
        ResourceGroupName  = $storageAccount.ResourceGroupName
        Location           = $storageAccount.Location
        PublicNetworkAccess = $publicNetworkAccess
    }
}

# Output the results
$result | Format-Table -AutoSize

#End of Script#
