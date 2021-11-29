# DISCLAIMER
# By using the following materials or sample code you agree to be bound by the license terms below
# and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference.
# These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you
# are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you
# are for your internal use only. Any sample code is provided for the purpose of illustration only and is
# not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to
# use and modify the sample code and to reproduce and distribute the object code form of the sample code,
# provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product
# in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in
# which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors
# a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable
# limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and
# suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result
# from the use or distribution of the sample code.

# The below sample connects to storage account and generate a container based SAS token.
# The below sample generates a SAS token starting from current time and having expiry for 2 days.

Connect-AzAccount
$storageAccountName="Storage Account Name"
$storageAccountKey = "Storage Account Access Key"
$storageContainerName="Storage Account Container Name"

$sctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# Specify the start date
$start = [System.DateTime]::Now.Date

# Specify the end date
$end = [System.DateTime]::Now.AddDays(2)

# Specify the parameters along with appropriate perimssions 
$sastoken = New-AZStorageContainerSASToken -Name $storageContainerName -Permission rwdl -StartTime $start -ExpiryTime $end -Context $sctx

# Display the value for SAS Token
Write-Host $sastoken

#You can now make use of this SAS token to peform the operations ahead over the container.