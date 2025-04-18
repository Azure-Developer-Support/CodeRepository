# This script authenticates against an Azure storage account using an access key connection string and creates a designated amount of test blobs (Default 10000) in a designated container

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient
import os

# Input your access key connection string and container name
connection_string = ""
container_name = ""

# Initialize the BlobServiceClient
blob_service_client = BlobServiceClient.from_connection_string(connection_string)
container_client = blob_service_client.get_container_client(container_name)

# Create the container if it doesn't exist
try:
    container_client.create_container()
except Exception as e:
    print(f"Container already exists: {e}")

# Upload blobs
for i in range(10000):  # Adjust the range for the number of blobs you need
    blob_name = f"test_blob_{i}.txt"
    blob_client = container_client.get_blob_client(blob_name)
    blob_content = f"This is test blob number {i}"
    blob_client.upload_blob(blob_content)
    print(f"Uploaded {blob_name}")
