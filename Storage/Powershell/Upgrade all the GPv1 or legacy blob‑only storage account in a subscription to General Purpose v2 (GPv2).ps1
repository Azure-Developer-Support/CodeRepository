The below PowerShell script helps to upgrade all the GPv1 or legacy blob‑only storage account in a subscription to General Purpose v2 (GPv2).

#DISCLAIMER:
#By using the following materials or sample code you agree to be bound by the license terms below and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
#These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you are located, one of its affiliates) and you. Any materials (other than this sample code) we provide to you are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
#not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to use and modify the sample code and to reproduce and distribute the object code form of the sample code, provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product 
#in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
#limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the sample code." 

# Login to Azure
Connect-AzAccount

# Get all storage accounts in the subscription
$storageAccounts = Get-AzStorageAccount

# Filter only those accounts where Kind != StorageV2
$nonV2Accounts = $storageAccounts | Where-Object { $_.Kind -ne "StorageV2" }

foreach ($sa in $nonV2Accounts)
{
    Write-Host "Upgrading Storage Account:" $sa.StorageAccountName "in Resource Group:" $sa.ResourceGroupName -ForegroundColor Yellow

    Set-AzStorageAccount -ResourceGroupName $sa.ResourceGroupName -Name $sa.StorageAccountName -UpgradeToStorageV2 -AccessTier Hot

    Write-Host "✔ Successfully upgraded:" $sa.StorageAccountName -ForegroundColor Green
}

Write-Host "Completed processing all non-StorageV2 accounts." -ForegroundColor Cyan
