#The below PowerShell script helps to identify the empty containers in the storage account.

###ATTENTION: DISCLAIMER###
 
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages.
 
 
############# Script Overview #################################################################

########## Helps to identify the empty containers in the storage account #########

# Ensure you have the Azure PowerShell module installed
# Install-Module -Name Az -AllowClobber -Force

# Import the Azure module if not already
#Import-Module Az

# Connect to your Azure account
Connect-AzAccount

# Define the storage account details
$resourceGroupName = "ResourceGroupName"
$storageAccountName = "StorageaccountName"

# Get the storage account context
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$ctx = $storageAccount.Context

# List all containers in the storage account
$containers = Get-AzStorageContainer -Context $ctx

# Iterate through each container and check if it is empty
foreach ($container in $containers) {
    $blobList = Get-AzStorageBlob -Container $container.Name -Context $ctx
    if ($blobList.Count -eq 0) {
        Write-Output "Empty container found: $($container.Name)"
    }
}

## Disconnect from Azure Account  
Disconnect-AzAccount
