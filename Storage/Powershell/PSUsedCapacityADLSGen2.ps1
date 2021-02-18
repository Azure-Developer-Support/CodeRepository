#The below PowerShell script helps to get the size of each folder present in a filesystem/Container of ADLS Gen2 storage account using ADLS Gen2 PS module.
# Please note that this provides the total size of immediate directories that are present in the container/filesystem.

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
$storageAccountName = "your storage account name"
$resourceGroupName = "your resource group name"
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageAccountName
$ctx = $storageAccount.Context

$filesystem = "your filesystem/container name"

Write-Host "Filesystem: $filesystem"
 
$dirs = Get-AzDataLakeGen2ChildItem -FileSystem $filesystem -context $Ctx
       
       foreach($dirname in $dirs.name) 
       {
        $total = 0
             $TotalSize = 0
             $Token = $Null
             $items = $Null
             do
              {
                  $items += Get-AzDataLakeGen2ChildItem -context $ctx -FileSystem $filesystem -Path $dirname -Recurse -ContinuationToken $Token
             $total += $items.Count
                  if($items.Length -le 0) { Break;}
                  $Token = $items[$items.Count -1].ContinuationToken;
              }
              While ($Token -ne $Null)
                           
              
             # $items.Count
             $items | ForEach-Object {$TotalSize += $_.Length}
             # $TotalSize
        $TotalSize = $TotalSize/1MB
              
             Write-Host "$dirname  | TotalSize: $TotalSize MB |  TotalFiles: " $items.Count
       }


