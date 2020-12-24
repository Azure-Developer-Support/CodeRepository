#-------------------------------------------------------------------------
# The below script is a sample piece of code that helps you connecting to an ADLS Gen 2 account using Azure SDK for Python
# There are differnet authenticaion mechanism for making the connection and I have made use of 2 of them 
# Listing operation has been performed over the container.
#-------------------------------------------------------------------------

#IMPORT THE LIBRARIES INTO YOUR FILE
from azure.storage.filedatalake import DataLakeServiceClient
from azure.storage.filedatalake._shared.base_client import create_configuration

#OPTION 1  - MAKING USE OF CONNECTION STRING AND CREATING THE DATALAKE CLIENT 
connection_string="PUT CONNECTION STRING HERE"

#CREATE THE DATALAKE SERVICE CLIENT 
service_client = DataLakeServiceClient.from_connection_string(connection_string)

##OPTION 2  - MAKING USE OF ACCESS KEY AND CREATING THE DATALAKE CLIENT 
storage_account_key="ACCESS KEY"
storage_account_name="ACCOUNT NAME" 

#CREATE THE DATALAKE SERVICE CLIENT 
service_client = DataLakeServiceClient(account_url="{}://{}.dfs.core.windows.net".format("https", storage_account_name), credential=storage_account_key)

#PERFORM THE LISTING OPERATION
file_systems = service_client.list_file_systems()
for file_system in file_systems:
    print(file_system.name)
