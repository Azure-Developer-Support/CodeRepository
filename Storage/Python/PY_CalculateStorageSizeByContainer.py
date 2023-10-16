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

STORAGE_ACCOUNT_NAME = '<<Input Storage Account Name>>'

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
    #Initializing sizing variables
    container_total_size = 0
    hot_size = 0
    cool_size = 0
    archive_size = 0

    #Reinitializing the Container Client with specific container
    container_client = blob_service_client.get_container_client(container = c.name)
    blob_list = container_client.list_blobs()
    for b in blob_list:
        if(b.blob_tier == 'Hot'):
            hot_size += b.size
        if(b.blob_tier == 'Cool'):
            cool_size += b.size
        if(b.blob_tier == 'Archive'):
            archive_size += b.size
    
    print('Container name: {}'.format(c.name))
    print('Hot: {} GB, {} MB'.format((hot_size)/1024/1024/1024),(hot_size)/1024/1024))
    print('Cool: {} GB, {} MB'.format((cool_size)/1024/1024/1024),(cool_size)/1024/1024))
    print('Archived: {} GB, {} MB'.format((archive_size)/1024/1024/1024),(archive_size)/1024/1024))
    print('----------------------------------------')
