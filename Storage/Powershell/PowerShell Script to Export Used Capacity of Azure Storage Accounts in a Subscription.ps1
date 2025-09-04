#This PowerShell script will help you to export Used Capacity of Azure Storage Accounts in a Subscription.

#Disclaimer
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

#Used Capacity in MB

# Login to Azure
Connect-AzAccount

# Set your subscription (replace with your SubscriptionId or Name)
$subscriptionId = "<SubscriptionId>"   # or use Subscription Name

# Set the subscription context
Set-AzContext -SubscriptionId $subscriptionId | Out-Null
$currentSub = (Get-AzSubscription -SubscriptionId $subscriptionId).Name

# Prepare output array
$results = @()

# Get all resource groups in the subscription
$resourceGroups = Get-AzResourceGroup

foreach ($rg in $resourceGroups) {
    $currentRG = $rg.ResourceGroupName

    # Get all storage accounts in the resource group
    $storageAccounts = Get-AzStorageAccount -ResourceGroupName $currentRG

    foreach ($sa in $storageAccounts) {
        $storageAccount = $sa.StorageAccountName
        $CurrentSAID = $sa.Id

        # Get UsedCapacity metric (latest datapoint)
        $metric = Get-AzMetric -ResourceId $CurrentSAID -MetricName "UsedCapacity"

        $latest = $metric.Data | Sort-Object TimeStamp -Descending | Select-Object -First 1

        if ($latest.Total -ne $null) {
            $usedCapacityMB = ($latest.Total / 1MB)   # 
        } elseif ($latest.Average -ne $null) {
            $usedCapacityMB = ($latest.Average / 1MB) # 
        } else {
            $usedCapacityMB = 0
        }

        # Add result to array
        $results += [pscustomobject]@{
            Subscription    = $currentSub
            ResourceGroup   = $currentRG
            StorageAccount  = $storageAccount
            UsedCapacityMB  = $usedCapacityMB  # 
        }
    }
}

# Export results to CSV
$results | Export-Csv -Path ".\StorageAccountsUsedCapacity.csv" -NoTypeInformation
Write-Host "Export completed: .\StorageAccountsUsedCapacity.csv"


#Used Capacity in GB

# Login to Azure
Connect-AzAccount

# Set your subscription (replace with your SubscriptionId or Name)
$subscriptionId = "<SubscriptionId>"   # or use Subscription Name

# Set the subscription context
Set-AzContext -SubscriptionId $subscriptionId | Out-Null
$currentSub = (Get-AzSubscription -SubscriptionId $subscriptionId).Name

# Prepare output array
$results = @()

# Get all resource groups in the subscription
$resourceGroups = Get-AzResourceGroup

foreach ($rg in $resourceGroups) {
    $currentRG = $rg.ResourceGroupName

    # Get all storage accounts in the resource group
    $storageAccounts = Get-AzStorageAccount -ResourceGroupName $currentRG

    foreach ($sa in $storageAccounts) {
        $storageAccount = $sa.StorageAccountName
        $CurrentSAID = $sa.Id

        # Get UsedCapacity metric (latest datapoint)
        $metric = Get-AzMetric -ResourceId $CurrentSAID -MetricName "UsedCapacity"

        $latest = $metric.Data | Sort-Object TimeStamp -Descending | Select-Object -First 1

        if ($latest.Total -ne $null) {
            $usedCapacityGB = ($latest.Total / 1GB)   # ✅ no rounding
        } elseif ($latest.Average -ne $null) {
            $usedCapacityGB = ($latest.Average / 1GB) #
        } else {
            $usedCapacityGB = 0
        }

        # Add result to array
        $results += [pscustomobject]@{
            Subscription    = $currentSub
            ResourceGroup   = $currentRG
            StorageAccount  = $storageAccount
            UsedCapacityGB  = $usedCapacityGB  # 
        }
    }
}

# Export results to CSV
$results | Export-Csv -Path ".\StorageAccountsUsedCapacity.csv" -NoTypeInformation
Write-Host "Export completed: .\StorageAccountsUsedCapacity.csv"


