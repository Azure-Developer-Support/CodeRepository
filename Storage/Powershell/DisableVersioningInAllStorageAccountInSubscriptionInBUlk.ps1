
#The below PowerShell script helps to disable blob versioning feature on all storage accounts part of a subscription, please evaluate and understand the scripts before you execute. 
#First execute the scripts present at : https://github.com/Azure-Developer-Support/CodeRepository/blob/master/Storage/Powershell/FindAllStorageAccountsPartOfSubscriptionWithVersioningEnabled.ps1 for getting all storage accounts in a subscription before your run this scripts.

#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, 
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 




Connect-AzAccount
#Make sure you select the right subscription
Set-AzContext -SubscriptionId "a177bdb0-44ce-4b6e-a01e-9444cfa34b5c"
$accounts = Get-AzStorageAccount

foreach($account in $accounts)
{

try{
    if((Get-AzStorageBlobServiceProperty -ResourceGroupName $account.ResourceGroupName -AccountName $account.StorageAccountName).IsVersioningEnabled -eq $true)
    {

            $result = Update-AzStorageBlobServiceProperty -ResourceGroupName $account.ResourceGroupName -AccountName $account.StorageAccountName -IsVersioningEnabled $false
            if($result -ne $null)
            { 
            write-output "Versioning Disabled on account :" $account.StorageAccountName
            }
            else
            {
            write-output "Error occured while disabling versioning on account:" $account.StorageAccountName "Please check the error on the console"
            }      
      }
   }
    catch
    {
      Write-Output "some exception occurred"
      Write-Output $_
    }
}
