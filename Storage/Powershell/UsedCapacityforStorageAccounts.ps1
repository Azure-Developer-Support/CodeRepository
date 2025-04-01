## This code  is to fetch  Used Capacity for  all the storage accounts  across  the subscriptions
##'By using the following materials or sample code you agree to be bound by the license terms below'and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference.
##'These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you'are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you'are for your internal use only. Any sample code is provided for the purpose of illustration only and is'not intended to be used in a production environment. 
##We grant you a nonexclusive, royalty-free right to'use and modify the sample code and to reproduce and distribute the object code form of the sample code,'provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product'in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in'which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors'a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable'limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and'suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result'from the use or distribution of the sample code."
$sub = Get-AzSubscription | select Name
$sub | foreach { 
    Set-AzContext -Subscription $_.Name
    $currentSub = $_.Name
    $resourceGroups = Get-AzResourceGroup | select ResourceGroupName
    $resourceGroups | foreach {
        $currentRG = $_.ResourceGroupName
        $storageAccounts = Get-AzStorageAccount -ResourceGroupName $currentRG | select StorageAccountName
            $storageAccounts | foreach {
            $storageAccount = $_.StorageAccountName
            $CurrentSAID = (Get-AzStorageAccount -ResourceGroupName $currentRG -AccountName $storageAccount).Id
            $usedCapacity = (Get-AzMetric -ResourceId $CurrentSAID -MetricName "UsedCapacity").Data
            $usedCapacityInMB = $usedCapacity.Average / 1024 / 1024
            "$storageAccount,$usedCapacityInMB,$CurrentRG,$currentSub" >> ".\storageAccountsUsedCapacity.csv"
                                        }
                    }
                }
