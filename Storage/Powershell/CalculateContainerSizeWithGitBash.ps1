#The below script helps to get the size of container present in the storage account using Git bash and CLI

#Please use Git Bash along with bc for windows/linux to run this Script.

#Extract the files in bc and keep it in the folder

#Open Git bash and run as administrator mode

#We would recommend to use blob inventory as this script can have some limitation in certain scenarios.
#https://learn.microsoft.com/en-us/azure/storage/blobs/blob-inventory


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




#to list
ls
#create directory
mkdir harshi1
az storage blob list     --container-name "container name"     --account-key $(az storage account keys list --account-name "storage account name" --resource-group "resource group name" -o json --query [0].value | tr -d '"')     --account-name "storage account name"      --query "[*].[properties.contentLength]" --output tsv -a >>new directory name (e.g- harshi1 here)


bash: harshi1: Is a directory

 
#change directory to harshi1
Cd harshi1

#Copy bc executables and paste it inside new folder( harshi1) 
 
#Run below command to collect data in tsv format under name xyz.tsv
az storage blob list     --container-name "container name"     --account-key $(az storage account keys list --account-name "storage account name" --resource-group "resource group name" -o json --query [0].value | tr -d '"')     --account-name "storage account name"      --query "[*].[properties.contentLength]"     --output tsv | paste -s -d+ |tr -d $'\r'| 'C:\Users\harshimrinal\harshi1\bc' > xyz.tsv


 
#List and check if it is created

ls

#now use below command to get size of container
cat xyz.tsv
