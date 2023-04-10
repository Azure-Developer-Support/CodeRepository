###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################
########### Update the latest revision for new imports/update on APIs #########################

#To achieve this, we would need to follow 3 steps :
#First create a revision 
#Set it as current 
#Then do the import/update functionality.


#The New-AzApiManagementContext cmdlet creates an instance of PsAzureApiManagementContext
#Create a PsApiManagementContext instance
$context = New-AzApiManagementContext -ResourceGroupName "ContosoResources" -ServiceName "Contoso"


#The Get-AzApiManagementApi cmdlet gets one or more Azure API Management APIs.
#Get a management API by ID : This command gets the API with the specified ID. 


#[incase you dont know the ApiId - This command gets all of the APIs for the specified context.
#$ApiMgmtContext = New-AzApiManagementContext -ResourceGroupName "Api-Default-WestUS" -ServiceName "contoso" Get-AzApiManagementApi -Context $ApiMgmtContext]

$getAPIcontext = Get-AzApiManagementApi -Context $context -ApiId $ApiId


#Note :You can define your own revision name so if will be unique.
#increment the revision based off the current revision number

$newRevision = [int]$getAPIcontext.ApiRevision + 1;  
#[int]$apiContext.ApiRevision.Split(" ")[ $apiContext.ApiRevision.Split(" ").Count-1]

#Import an swagger API from path
Import-AzApiManagementApi -Context $context -SpecificationFormat OpenApi -ApiId cc6740489f0d4bbab55f99ed1fdfbd73 -SpecificationPath "C:\contoso\specifications\echoapi.wadl" -Path "myswaggerfile"  -ApiRevision $newRevision 

#Creates an API Release of an API Revision
#The New-AzApiManagementApiRelease cmdlet creates an API Release for an API Revision in API Management context. A Release is used to make the Api Revision as Current Revision.

New-AzApiManagementApiRelease -Context $context  -ApiId $ApiId -ApiRevision $newRevision -Note "Releasing version  $($newRevision)"
