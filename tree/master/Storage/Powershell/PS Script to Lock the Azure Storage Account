#The below PowerShell script helps to Lock an Azure Storage Account .

#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service. 
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, 
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

#Lock level can be set as CanNotDelete (Delete in portal) and ReadOnly (Read-only in portal).

#CanNotDelete - Authorized users can still read and modify a resource, but they can't delete the resource.

#ReadOnly - Authorized users can read a resource, but they can't delete or update the resource.

## Input Parameters  
$resourceGroupName="XXXX"   
$StorageAcctName="XXXX"  
$lockName="XXXX"  
$lockNotes="XXXX"  
 
## Connect to Azure Account  
Connect-AzAccount   
 
## Function to lock Azure Storage Account resource  
Function LockResource  
{  
    Write-Host -ForegroundColor Green "Locking the resource..."  
 
    ## Lock the resource  
    New-AzResourceLock -LockLevel CanNotDelete -LockName $lockName -LockNotes $lockNotes -ResourceName $StorageAcctName -ResourceType Microsoft.Storage/storageAccounts -ResourceGroupName $resourceGroupName -Force  
  
    Write-Host -ForegroundColor Green "Display all locks for a resource group..."  
 
    ## Display all locks for a resource group  
    Get-AzResourceLock -ResourceGroupName $resourceGroupName  
}  
  
LockResource  
 
## Disconnect from Azure Account  
Disconnect-AzAccount   
