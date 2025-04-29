#This script downloads a list of all storage accounts along with their TLS versions in a csv file and updates the Minimum TLS version to 1.2 for each storage account in the specified subscription

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

Connect-AzAccount

Set-AzContext -SubscriptionId "xxxxx-xxxx-xxxx-xxxx-xxxxx"
 
# Initialize an array to store the results
$results = @()

# Get all storage accounts in the subscription
    $storageAccounts = Get-AzStorageAccount
 
# Loop through each storage account
    foreach ($storageAccount in $storageAccounts) {
        # Get storage account properties
        $properties = Get-AzStorageAccount -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.StorageAccountName |
                      Select-Object @{Label='StorageAccount'; Expression={$_.StorageAccountName}},
                                    @{Label='MinimumTLSVersion'; Expression={$_.MinimumTlsVersion}},
                                    @{Label='ResourceGroupName'; Expression={$_.ResourceGroupName}}
 
        # Add the properties to the results array
        $results += $properties
    }

# Export the results to a CSV file
$results | Export-Csv -Path "C:\storageaccountswithtlsversion.csv"

foreach ($current in $results)
{
    if($current.MinimumTLSVersion -notlike "TLS1_2")
    {
        Set-AzStorageAccount -ResourceGroupName $current.ResourceGroupName -AccountName $current.StorageAccount -MinimumTlsVersion TLS1_2
    }
}
