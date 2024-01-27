#Azure Storage Queue - PowerShell
###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

#############Script Overview#################################################################
##########This script is designed to calculate the total number of messages across all queues in a storage account, as well as to determine the number of messages stored in each individual queue.#########################


Connect-AzAccount
Set-AzContext -SubscriptionName '<Subscription-Name>'
$storageAcc = Get-AzStorageAccount -ResourceGroupName "<Resource-Group-Name" -Name "<Storage-Account-Name>"
$ctx=$storageAcc.Context

$queues = (Get-AzStorageQueue -Context $ctx).CloudQueue
$numOfQueues = $queues.count

Write-Host "Total number of queues in the storage account : " $numOfQueues

write-host "========================================" 

$totalNumberOfMessagesInAllQueues = 0

foreach($queue in $queues)
{
    #Write-Host $queue.Name

    $queueName = $queue.Name

    $queue = Get-AzStorageQueue -Context $ctx -Name $queueName
    $count = $queue.ApproximateMessageCount

    $totalNumberOfMessagesInAllQueues = $totalNumberOfMessagesInAllQueues + $count

    Write-Host "Total number of messages in the " $queueName : $count

    write-host "----------------------------------------"
}

Write-Host "Total number of messages in the all the queues" : $totalNumberOfMessagesInAllQueues
