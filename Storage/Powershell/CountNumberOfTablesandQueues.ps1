﻿#The below PowerShell script helps to get list the tables and queue present in the storage account.
#It also provides the total count of the same as well.

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

#Connect-AzAccount

$StorageAccount = "Your Storage Account Name"
$StorageAccountKey = "Your Storage Account Access Key"
 
$ctx = New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $StorageAccountKey
 
$alltablename=(Get-AzStorageTable –Context $ctx).CloudTable

Write-Host "List Of Tables in the Account : "

foreach($table in $alltablename)
{
    Write-Host $table
}

Write-Host "Total Number Of Tables : "  $alltablename.Count

$allqueuename=(Get-AzStorageQueue –Context $ctx).CloudQueue

Write-Host "List Of Queue in the Account : "

foreach($queue in $allqueuename)
{
    Write-Host $queue.Name
}

Write-Host "Total Number Of Queues : "  $allqueuename.Count
