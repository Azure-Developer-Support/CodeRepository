#The below PowerShell script helps to find the StorageAccount Transcation count in last 24hrs, BlobUsed capacity details along with the BLM Status at the subscription level

#DISCLAIMER:
#By using the following materials or sample code you agree to be bound by the license terms below and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
#These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you are located, one of its affiliates) and you. Any materials (other than this sample code) we provide to you are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
#not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to use and modify the sample code and to reproduce and distribute the object code form of the sample code, provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product 
#in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
#limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the sample code." 
#Note : User should have sufficient permissions to create the directory in the storage account

# Login to Azure
Connect-AzAccount
 
# Define the subscription ID
$subscriptionId = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
 
# Set the context to the subscription
Set-AzContext -SubscriptionId $subscriptionId
 
# Get all storage accounts in the subscription
$storageAccounts = Get-AzStorageAccount
 
# Initialize an array to store the results
$results = @()
 
foreach ($storageAccount in $storageAccounts) {
    $resourceGroupName = $storageAccount.ResourceGroupName
    $storageAccountName = $storageAccount.StorageAccountName
    $accountKind = $storageAccount.Kind
 
    # Get the current date and time
    $currentDate = Get-Date
 
    # Get the date and time 24 hours ago
    $startDate = $currentDate.AddHours(-24)
 
    # Fetch the metrics data for the last 24 hours
    $metric = Get-AzMetric -ResourceId "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Storage/storageAccounts/$storageAccountName/blobServices/default" `
                            -MetricNamespace "microsoft.storage/storageaccounts/blobservices" `
                            -MetricName "Transactions" `
                            -StartTime $startDate `
                            -EndTime $currentDate
 
    # Sum the transaction counts
    $totalTransactions = ($metric.Data | Measure-Object -Property Total -Sum).Sum
 
    # Get the blob capacity metric
    $blobCapacityMetric = Get-AzMetric -ResourceId "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Storage/storageAccounts/$storageAccountName/blobServices/default" `
                                        -MetricNamespace "microsoft.storage/storageaccounts/blobservices" `
                                        -MetricName "BlobCapacity" `
                                        -AggregationType Average
 
    # Extract the blob capacity value
    $blobCapacity = ($blobCapacityMetric.Data | Measure-Object -Property Average -Sum).Sum / 1GB
 
    # Get the subscription name
    $subscription = Get-AzSubscription | Where-Object { $_.Id -eq $subscriptionId }
 
    # Check if lifecycle management is enabled
    try {
        $lifecycleManagement = Get-AzStorageAccountManagementPolicy -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName
        $lifecycleManagementEnabled = if ($lifecycleManagement) { "Enabled" } else { "Not Enabled" }
    } catch {
        $lifecycleManagementEnabled = "Not Enabled"
    }
 
    # Add the result to the array
    $results += [PSCustomObject]@{
        "Storage Account Name" = $storageAccountName
        "Account Kind" = $accountKind
        "Transactions for Last 24hrs" = $totalTransactions
        "Blob Used Capacity in GB" = [math]::Round($blobCapacity, 2)
        "Subscription" = $subscription.Name
        "Lifecycle Management" = $lifecycleManagementEnabled
    }
}
 
# Output the results
$results | Format-Table -AutoSize
