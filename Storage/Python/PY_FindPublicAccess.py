#-------------------------------------------------------------------------
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service.
# The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.
# The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
# In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including,
# without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages

#-------------------------------------------------------------------------

#IMPORT THE LIBRARIES INTO YOUR FILE
#AZ Module will need to be installed for DefaultAzureCredentials as AZ Login is used
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient

STORAGE_ACCOUNT_NAME = '<<input storage account>>'

#Using default account to log into storage account
try:
    account_url = "https://{}.blob.core.windows.net".format(STORAGE_ACCOUNT_NAME)
    default_credential = DefaultAzureCredential()
except Exception as ex:
    print('Failing at default credential with following exception: {}'.format(ex))

# Create the BlobServiceClient object
blob_service_client = BlobServiceClient(account_url, credential=default_credential)

# Create the Container Client for interaction between container / blobs
container_client = blob_service_client.list_containers() 

for c in container_client:
    #Initializing storing variables
    container_name = []
    access_type = []

    #Checking public_access type to see if containers are public
    #None = Containers are private
    #Blob = Containers have anonymous read public access to blobs only
    #Container = Containers have anonymous read public access to container and blobs
    if(c.public_access == 'None'):
        continue
    if(c.public_access == 'blob'):
        container_name.append(c.name)
        access_type.append(c.public_access)
    if(c.public_access == 'container'):
        container_name.append(c.name)
        access_type.append(c.public_access)
        

    for n,a in zip(container_name,access_type):
        print('Container Name: {}, Public Access Type: {}'.format(n,a))
