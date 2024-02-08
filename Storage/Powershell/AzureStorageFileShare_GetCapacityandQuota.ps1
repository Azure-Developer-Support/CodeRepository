#Azure Storage FileShare - PowerShell
###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################
##########This script helps in finding Total UsedCapacity , Quota (Maximum Capacity) and AccessTier in Azure File Shares for each FileShares across Subscriptions #########################
##########This script excludes the snapshots #############

# Authenticate to Azure (sign in if not already authenticated)
Connect-AzAccount

#### Specify the path for the CSV file with storage account details###
########### SAMPLE CSV INPUT FILE  ##############
#StorageAccountName	ResourceGroupName	SubscriptionId
#twdqwetestim3m	NetworkWatcherRG	XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXX
#backupcache12	redislab	XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXX


$inputCsvFilePath = "~\fileinput.csv"
$outputCsvFilePath = "~\FileShareInfo.csv"


# Read storage account details from the CSV file
$inputStorageDetails = Import-Csv -Path $inputCsvFilePath

# Create an array to store file share information
$fileShareInfoArray = @()

foreach ($storageDetail in $inputStorageDetails) {
    $storageAccountName = $storageDetail.StorageAccountName
    $resourceGroupName = $storageDetail.ResourceGroupName
    $subscriptionId = $storageDetail.SubscriptionId

    # Set the subscription context
    Set-AzContext -SubscriptionId $subscriptionId -ErrorAction SilentlyContinue
    # Get the storage account
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction SilentlyContinue
    if ($storageAccount -ne $null) {
        # Get a list of Azure File Shares in the storage account
        $fileShares = Get-AzStorageShare -Context $storageAccount.Context -ErrorAction SilentlyContinue
        
        if ($fileShares -ne $null) {
            # Display information about each file share
            foreach ($fileShare in $fileShares) {
                if ($fileShare.IsSnapshot -eq $false){
                $fileShareName = $fileShare.Name
                $fileShareCapacity = $fileShare.ShareProperties.QuotaInGB
                $fileShareTier = $fileShare.ShareProperties.AccessTier
                $metric = $fileShare.ShareClient.GetStatistics()
                               

                if ($metric) {
                    $fileShareUsedCapacity= [math]::Round(($metric.Value.ShareUsageInBytes * 0.000001),1)
                } else {
                    $fileShareUsedCapacity = "Metric not available"
                }

                # Create a custom object with file share information output in GiB
                $fileShareInfo = [PSCustomObject]@{
                    'Subscription'        = $subscriptionId
                    'ResourceGroup'       = $resourceGroupName
                    'StorageAccount'      = $storageAccountName
                    'FileShare'           = $fileShareName
                    'MaximumCapacityInGiB'= $fileShareCapacity
                    'UsedCapacityInMB'    = $fileShareUsedCapacity
                    'AccessTier'          = $fileShareTier
                }

                # Add the custom object to the array
                $fileShareInfoArray += $fileShareInfo
                }
            }
        }else {
     Write-Host "Check Network Access / Permissions for Storage Account - $storageDetail"
    }
    }
    
}

# Export the array to a CSV file
$fileShareInfoArray | Export-Csv -Path $outputCsvFilePath -NoTypeInformation

Write-Host "File share information exported to $outputCsvFilePath"

# Disconnect from Azure (optional)
Disconnect-AzAccount
