###ATTENTION: DISCLAIMER###
 
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages
 
 
############# Script Overview #################################################################
########## This Script helps in listing the storage account TLS version in a Subscription #########

# Connect to Azure (sign in if not already signed in)
Connect-AzAccount
 
# Get all subscriptions
$subscriptions = Get-AzSubscription
 
# Initialize an array to store the results
$results = @()

# Get all storage accounts in the subscription
    $storageAccounts = Get-AzStorageAccount
 
# Loop through each storage account
    foreach ($storageAccount in $storageAccounts) {
        # Get storage account properties
        $properties = Get-AzStorageAccount -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.StorageAccountName |
                      Select-Object @{Label='StorageAccount'; Expression={$_.StorageAccountName}},
                                    @{Label='MinimumTLSVersion'; Expression={$_.MinimumTlsVersion}}
 
        # Add the properties to the results array
        $results += $properties
    }
# Export the results to a CSV file
$results

#End of Script#
