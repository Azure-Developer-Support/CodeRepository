#The below PowerShell script helps to Sort Containers by Last Modified Date .



#Disclaimer
#The sample scripts are not supported under any Microsoft standard support program or service.
#The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including,
#without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including,
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages


################# Azure Blob Storage - PowerShell ####################    
  
## Input Parameters    
$resourceGroupName="test"    
$storageAccName="test"    
  
## Connect to Azure Account    
Connect-AzAccount     
  
## Function to get all the containers    
Function GetAllStorageContainer    
{    
    Write-Host -ForegroundColor Green "Retrieving storage container.."        
    ## Get the storage account from which container has to be retrieved    
    $storageAcc=Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccName        
    ## Get the storage account context    
    $ctx=$storageAcc.Context    
    ## List all the containers    
    $containers=Get-AzStorageContainer  -Context $ctx  | sort @{expression="LastModified";Descending=$false}   
    foreach($container in $containers)    
    {  
        write-host -ForegroundColor Yellow "Container Name :::" $container.Name  , "Date   :::"  $container.LastModified  
       
       
    }    
}     
    
GetAllStorageContainer     
  
## Disconnect from Azure Account    
Disconnect-AzAccount   
