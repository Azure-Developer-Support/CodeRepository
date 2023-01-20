#The below PowerShell script helps to set the TLS version to 1.2(or any) for all the Redis cache under subscription.

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

# Connect to Azure
Connect-AzAccount

# Select the subscription where the Azure Redis Cache instances are located
Select-AzSubscription -SubscriptionId ""

# Get all the Azure Redis Cache instances in the subscription
$redisCaches = Get-AzRedisCache

# Loop through the Azure Redis Cache instances
foreach ($redisCache in $redisCaches) {
    # Get the Azure Redis Cache instance
    $currentRedisCache = Get-AzRedisCache -Name $redisCache.Name -ResourceGroupName $redisCache.ResourceGroupName

    # Set the Azure Redis Cache configuration to use TLS version 1.2
    

    # Update the Azure Redis Cache instance
    Set-AzRedisCache -Name $redisCache.Name -ResourceGroupName $redisCache.ResourceGroupName -MinimumTlsVersion "1.2"

    # Verify the Azure Redis Cache configuration
    $updatedRedisCache = Get-AzRedisCache -Name $redisCache.Name -ResourceGroupName $redisCache.ResourceGroupName
    Write-Output "Azure Redis Cache instance '$($redisCache.Name)' in resource group '$($redisCache.ResourceGroupName)' has been updated to use TLS version 1.2"
}
