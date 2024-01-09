#The below PowerShell script helps you to add role assignment with condition based on blob path using Azure ABAC.
#The script can be modified based on the requirements.

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

#Please note that the built-in roles on which you can use role-assignment conditions include: Storage Blob Data Reader, Storage Blob Data Contributor, Storage Blob Data Owner
$roleDefinitionId = "2a2b9908-6ea1-4ae2-8e65-a410df84e7d1" #Adding blob path condition with Storage Blob Data Reader role

$userObjectId = "<User-object-Id-Of-The-User-Whom-You-Want-To-Assign-Role>"
$scope= "<Azure-storage-account-resource-URI>"
$description = "Read access to test container with path"
$condition = "((!(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'} AND NOT SubOperationMatches{'Blob.List'})) OR (@Resource[Microsoft.Storage/storageAccounts/blobServices/containers/blobs:path] StringLike '/test/v1/v4/*'))"
$conditionVersion = "2.0"

New-AzRoleAssignment -ObjectId $userObjectId -Scope $scope -RoleDefinitionId $roleDefinitionId -Description $description -Condition $condition -ConditionVersion $conditionVersion
