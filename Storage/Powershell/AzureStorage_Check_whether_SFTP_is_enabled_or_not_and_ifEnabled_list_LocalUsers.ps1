###ATTENTION: DISCLAIMER###
 
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages
 

############################################################# Script Overview #############################################################
########## This script helps to retrieves the storage account properties to verify if SFTP support is enabled or disables. #########
########## If SFTP is enabled, the script fetches and enumerates all local users configured for SFTP access on that specific storage account.  #########
########## If no users are found, it notifies accordingly. If SFTP is disabled, the script outputs a clear message indicating that #########

$resourceGroup       = "<resource-group>"
$storageAccountName  = "<storage-account-name>"

#  Login if needed
Connect-AzAccount

#  Get storage account details
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName

if ($storageAccount.EnableSftp -eq $true) {
    Write-Host "SFTP is ENABLED for storage account '$storageAccountName'." -ForegroundColor Green

    try {
        $localUsers = Get-AzStorageLocalUser -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName

        if (-not $localUsers) {
            Write-Host "No local SFTP users found." -ForegroundColor Yellow
        } else {
            Write-Host "`Local SFTP Users:" 
            Write-Host "-----------------------------"

            foreach ($user in $localUsers) {
                Write-Host "Username     : $($user.Name)"
                Write-Host "Home Dir     : $($user.HomeDirectory)"
                Write-Host "Permissions  :"
                $user.PermissionScopes | ForEach-Object {
                    Write-Host "  - Permissions: $($_.Permissions), ContainerName: $($_.ResourceName)"
                }
                Write-Host "-----------------------------"
            }
        }
    }
    catch {
        Write-Host "Error retrieving local users. Ensure your Az.Storage module supports SFTP." -ForegroundColor Red
        Write-Host "Detailed error: $_" -ForegroundColor Red
    }
}
else {
    Write-Host "SFTP is DISABLED for storage account '$storageAccountName'." -ForegroundColor Red
}
