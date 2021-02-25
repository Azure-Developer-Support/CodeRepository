# The below script is a sample piece of code that helps you connecting to an BLOB Storage account using Azure SDK for Python
# There are different authentication mechanism for making the connection and I have made use of connection string
# Upload Blob operation (with overwrite if exists) and listing of blobs
#--------------------------------------------------------------------------
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service.
# The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.
# The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
# In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including,
# without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages
#--------------------------------------------------------------------------

#IMPORT THE LIBRARIES INTO YOUR FILE
import os
from azure.storage.blob import BlobServiceClient

#DECLERATION OF VARIABLES
AZURE_STORAGE_CONTAINER_NAME = 'testcontainer1'

#SETTING UP CONFIGURATION STRING
connection_string="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

#INSTANTIATE A BLOBSERVICECLIENT
blob_service_client = BlobServiceClient.from_connection_string(connection_string)

#PRINTING LIST OF CONTAINERS
containers = list(blob_service_client.list_containers(logging_enable=True))
print("{} containers.".format(len(containers)))

container_name = "AZURE_STORAGE_CONTAINER_NAME"

#CREATE A FILE IN LOCAL MACHINE
local_path = "XXXXXXXXXXXXXXX"
local_file_name = "SampleText" + ".txt"
upload_file_path = os.path.join(local_path, local_file_name)

#WRITING DATA TO FILE
file = open(upload_file_path, 'w')
file.write("This is new Text!")
file.close()

#CREATE A BLOB CLIENT USING THE LOCAL FILE NAME AS NAME FOR THE BLOB
blob_client = blob_service_client.get_blob_client(container=container_name, blob=local_file_name)

print("\nUploading to Azure Storage as blob:\n\t" + local_file_name)

#UPLOAD THE CREATED FILE; OVERWRITE OPTION SET AS TRUE WILL OVERWRITE THE EXISTING FILE
with open(upload_file_path, "rb") as data:
    blob_client.upload_blob(data, overwrite=True)

#INSTANTIATE A CONTAINER CLIENT
container_client = blob_service_client.get_container_client(AZURE_STORAGE_CONTAINER_NAME)

#LIST THE BLOBS IN A CONTAINER
print("\nList of Blobs in Container are :\n\t" )
blob_list = container_client.list_blobs()
for blob in blob_list:
   print("\t" + blob.name)
