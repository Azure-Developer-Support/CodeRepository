#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. 
#Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
#The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 
#This script will Get all storage accounts in the current subscription, Iterate over each storage account, containers and then Add storage account, container, and blob details to results to an output.CSV file
#Connect to Azure account
Connect-AzAccount
 
# Get all subscriptions
$subscription = "XXXX"
 
# Initialize an empty array to store results
 $results = @()
# Iterate over each subscription
 
    Set-AzContext -Subscription $subscription
 
    # Get all storage accounts in the current subscription
    $accounts = Get-AzStorageAccount
 
    # Iterate over each storage account
    foreach ($account in $accounts) {
        Write-Host "Listing all containers in the account $($account.StorageAccountName)" -ForegroundColor Red
 
        # Get storage account keys
        $keys = Get-AzStorageAccountKey -ResourceGroupName $account.ResourceGroupName -Name $account.StorageAccountName
        $ctx = New-AzStorageContext -StorageAccountName $account.StorageAccountName -StorageAccountKey $keys[0].Value
 
        # Get all containers in the storage account
        $containers = Get-AzStorageContainer -Context $ctx
 
        # Iterate over each container
        foreach ($container in $containers) {
            # Get all blobs in the container
            $blobs = Get-AzStorageBlob -Container $container.Name -Context $ctx
 
            # Add storage account, container, and blob details to results
            foreach ($blob in $blobs) {
                $result = @{
                    Account = $account.StorageAccountName
                    Container = $container.Name
                    BlobName = $blob.Name
                    BlobSize = $blob.Length
                    BlobLastModified = $blob.LastModified
                }
                $results += New-Object PSObject -Property $result
            }
        }
    }
 
# Export the results to a CSV file
$results | Export-Csv -Path "C:\tmp\StorageAccountBlobsReport.csv" -NoTypeInformation
 
# Print a success message
Write-Host "Storage account blobs report exported to StorageAccountBlobsReport.csv"
