#The below PowerShell script helps you to count the number blobs only from selected containers in the storage account
#The script can be modified based on the requirements.
#In case there are multiple blobs you might need to implement continuation token scheme to ensure the scirpt traverses through all the blobs

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

$resourceGroup = "Your Resource Group Name"
$storageAccountName = "Your Storage Account Name"

$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName

$ctx = $storageAccount.Context

#Pass the list of containers in a comma separated list for which you to list the blobs

$listOfContainers = 'testcontainer1','testcontainer2'

Write-Host "Container name with its Blobs count"

# loops through the list of containers and retrieves the count of blobs in each container.

for ([int] $b = 0; $b -lt $listOfContainers.Count; $b++)
      {

$listOfBlobs= Get-AzStorageBlob -Container $listOfContainers[$b] -Context $ctx

Write-Host "Container name:" $listOfContainers[$b] " Blob counts: " $listOfBlobs.Count

      }

