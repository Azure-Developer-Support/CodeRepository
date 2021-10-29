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

# The below script is a sample piece of code wherein we are copying the blobs present in a folder inside a storage
# container of one storage account to another container in destination storage account along with folder.
# We are performing a listing of blobs and then copying them by matching the pattern
# The sample is doing a asynchronous copy of the blobs via COPY BLOB API in the backend
#--------------------------------------------------------------------------

import os
from azure.storage.blob import BlobServiceClient
from azure.storage.blob import ContainerClient
from azure.storage.blob._shared.base_client import create_configuration

connection_string1="Connection String for Source Storage Account"
connection_string2="Connection String for Destination Storage Account"

SOURCE_CONTAINER_NAME = "Name of source container in source storage account"
DESTINATION_CONTAINER_NAME = "Name of destination container in destination storage account"

config = create_configuration(storage_sdk='blob')

# Instantiate a Container Clients
# Source Container in Source Account;
container1 = ContainerClient.from_connection_string(connection_string1, container_name=SOURCE_CONTAINER_NAME)

# Destination Container in Destination Account; we can skip this too as we will not be using this in the below sample
container2 = ContainerClient.from_connection_string(connection_string2, container_name=DESTINATION_CONTAINER_NAME)

# Instantiate a Blob Service Clients for source and destination accounts
service_client1 = BlobServiceClient.from_connection_string(connection_string1, _configuration=config)
service_client2 = BlobServiceClient.from_connection_string(connection_string2, _configuration=config)

#Listing the blob from Source Container and matching the folder and copying them to destination container;
#myfolder is the folder name inside the source container of source storage account
blob_list = container1.list_blobs(name_starts_with="myfolder/")
for blob in blob_list:
        print("\t" + blob.name)
        sb=service_client1.get_blob_client(SOURCE_CONTAINER_NAME, str(blob.name))
        print(str(sb.url))
        cb = service_client2.get_blob_client(DESTINATION_CONTAINER_NAME, str(blob.name))
        cb.start_copy_from_url(str(sb.url)+str("SAS TOKEN for source account"))
