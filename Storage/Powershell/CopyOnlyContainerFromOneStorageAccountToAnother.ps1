PS script to copy only the conatiner from one storage account to another without data

 #By using the following materials or sample code you agree to be bound by the license terms below 
#and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
#These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you 
#are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you 
#are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
#not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to 
#use and modify the sample code and to reproduce and distribute the object code form of the sample code, 
#provided that you agree: (i) to not use Microsoftâ€™s name, logo, or trademarks to market your software product 
#in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in 
#which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors 
#a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
#limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and 
#suppliers from and against any third party claims or lawsuits, including attorneysâ€™ fees, that arise or result 
#from the use or distribution of the sample code."


# Connect to your Azure account
Connect-AzAccount
Select-AzSubscription -SubscriptionName "HarshiM"

# Source Storage Account details
$storageAccountName = "gpv1har"
$resourceGroupName = "NewhireRG1"

# Destination Storage Account details
$destinationStorageAccountName = "storeusingclim"
$destinationResourceGroupName = "NewhireRG1"

# Get the storage account context
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName
$ctx = $storageAccount.Context

# List all containers in the storage account
$containers = Get-AzStorageContainer -Context $ctx


foreach ($sourceContainer in $sourceContainers) {
    $destinationContainerName = $sourceContainer.Name

    # Check if the container already exists in the destination storage account
    if (-not (Get-AzStorageContainer -Context $destinationCtx -Name $destinationContainerName -ErrorAction SilentlyContinue)) {
        # If the container doesn't exist, create it
        New-AzStorageContainer -Name $destinationContainerName -Context $destinationCtx
        Write-Output "Container '$destinationContainerName' created in the destination storage account."
    } else {
        Write-Output "Container '$destinationContainerName' already exists in the destination storage account."
    }
}
