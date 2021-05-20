#The below PowerShell script helps append data to the already existing Append blob in the storage account. If the append blob is not present in the storage account, a new Append Blob is created. 

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

Connect-AzAccount -Subscription "xxxx"

#set-up the storage account context
$StorageAccountName = "xxx"
$StorageAccountKey = "xxx"
$storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

#check if the append blob is present in the storage account  
if(Get-AzStorageBlob -Container "xxx" -Context $storageContext -Blob "test.txt")
{
# Get append blob object 
$appendBlob = Get-AzStorageBlob -Container "xxx" -Blob "test1.txt" -Context $storageContext 

#Option 1 : To append data to the blob using a file - Option 1
$appendBlob.ICloudBlob.AppendFromFile("C:\Users\xxx\Desktop\sample.txt")

#Option 2: To append data from a stream 
$f = Get-Item "C:\Users\xxx\Desktop\sample.txt"
$fs = $f.OpenRead()
$appendBlob.ICloudBlob.AppendBlock($fs)
$fs.Close()

}

else
{
#Copy the data to the storage account as append blob
Set-AzStorageBlobContent -File "C:\Users\xxx\Desktop\sample.txt" -Container "xxx" -BlobType Append -Context $storageContext -force -Verbose
}

 



