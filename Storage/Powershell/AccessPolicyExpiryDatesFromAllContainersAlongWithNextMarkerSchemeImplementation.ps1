###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


############# Script Overview #################################################################
########## This script helps in listing the Access Policies and its expiry dates, present in all the containers in a storage account ####
########## along with the next marker scheme implementation in it. #########################


# Replace with your storage account name
$storageAccountName = "<storageAccountName>"

# Get the storage account context
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount

# Initialize the marker
$marker = $null

# Loop through containers using the marker until all are processed
do {
    # List containers using the marker
    $containersResult = Get-AzStorageContainer -Context $ctx -MaxCount 100 -ContinuationToken $marker
    $containers = $containersResult.CloudBlobContainer

    # Loop through each container
    foreach ($container in $containers) {
        # Get the stored access policies for the container
        $policies = Get-AzStorageContainerStoredAccessPolicy -Container $container.Name -Context $ctx

        # Output the details of the policy
        foreach ($policy in $policies) {
            Write-Output "Container: $($container.Name), Policy Name: $($policy.Name), Permissions: $($policy.Permission), Start Time: $($policy.StartTime), Expiry Time: $($policy.ExpiryTime)"
        }
    }

    # Update the marker
    $marker = $containersResult.NextMarker
} while ($marker -ne $null)
 #End of Script#
