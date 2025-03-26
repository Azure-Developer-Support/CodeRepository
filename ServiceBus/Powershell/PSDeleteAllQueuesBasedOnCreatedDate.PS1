###ATTENTION: DISCLAIMER###

#DISCLAIMER
# The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. 
# Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
# The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of 
# this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, 
# damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the 
# sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


# Connect to Azure
Connect-AzAccount

# Define parameters
$ResourceGroupName = "<RESOURCE_GROUP>"
$NamespaceName = "<NAMESPACE>"
$CutoffDate = (Get-Date "2025-03-26") # Specify the date threshold

# List all queues in the namespace
$queues = Get-AzServiceBusQueue -ResourceGroupName $ResourceGroupName -NamespaceName $NamespaceName

foreach ($queue in $queues) {
    # Check if the queue was created before the cutoff date
    if ($queue.CreatedAt -lt $CutoffDate) {
        Write-Host "Deleting queue: $($queue.Name) (Created On: $($queue.CreatedAt)"
        
        # Delete the queue
        Remove-AzServiceBusQueue -ResourceGroupName $ResourceGroupName -NamespaceName $NamespaceName -Name $queue.Name
    } else {
        Write-Host "Skipping queue: $($queue.Name) (Created On: $($queue.CreatedAt))"
    }
}
