#The below script helps in transferring the queue data from one queue storage account to another queue storage account in same subscription. 

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

$sourceStorageAccountName = "xx"
$sourceStorageAccountKey = "xx"
 
$destinationStorageAccountName = "xx" 
$destinationStorageAccountKey = "xx"
 
# Connect to the source and destination storage accounts 
$sourceContext = New-AzStorageContext -StorageAccountName $sourceStorageAccountName -StorageAccountKey $sourceStorageAccountKey
 
$destinationContext = New-AzStorageContext -StorageAccountName $destinationStorageAccountName -StorageAccountKey $destinationStorageAccountKey
 
# Get messages from the source queue 
$sourcequeue = Get-AzStorageQueue -Context $sourceContext
 
foreach ($x in $sourcequeue)
{
#create queue in destination account
$desqueue = New-AzStorageQueue -Name $x.Name -Context $destinationContext
 
for ($i=1; $i -le $x.ApproximateMessageCount; $i++)
   {
        $message = $x.QueueClient.ReceiveMessageAsync()
        $desqueue.QueueClient.SendMessageAsync($message.Result.Value.MessageText)
  }
}
