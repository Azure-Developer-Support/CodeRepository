###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


############# Script Overview ###############################################################################
########## listing the Redis caches and their associated minimum tls versions present in a subscription.#####

# Ensure you have the Az.RedisCache module installed
Install-Module -Name Az.RedisCache

# Connect to your Azure account
Connect-AzAccount

# Set the context to the subscription where the Redis caches are located
Select-AzSubscription -SubscriptionName "YourSubscriptionName"

# Get all Redis caches in the subscription
$redisCaches = Get-AzRedisCache

# Loop through each cache and output its name and minimum TLS version
foreach ($cache in $redisCaches) {
    $name = $cache.Name
    $resourceGroupName = $cache.ResourceGroupName
    $properties = Get-AzRedisCache -ResourceGroupName $resourceGroupName -Name $name
    $minTlsVersion = $properties.MinimumTlsVersion
    Write-Output "Name: $name, Minimum TLS Version: $minTlsVersion"
}
#End of Script#
