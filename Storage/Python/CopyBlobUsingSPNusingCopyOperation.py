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

# The below script is a sample piece of code wherein we are copying the blobs matching a prefix inside a storage
# container of one storage account to another container in destination storage account.
# We are performing a listing of blobs and then copying them by matching the pattern
# The sample is doing a asynchronous copy of the blobs via COPY BLOB API in the backend
#--------------------------------------------------------------------------

import os
from azure.storage.blob import BlobServiceClient
from azure.storage.blob import ContainerClient
from azure.storage.blob._shared.base_client import create_configuration
from azure.identity import ClientSecretCredential

AZURE_CLIENT_ID = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
AZURE_TENANT_ID = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
AZURE_CLIENT_SECRET = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
AZURE_SOURCE_STORAGE_ACCOUNT_NAME = 'SOURCE STORAGE ACCOUNT NAME'
AZURE_DESTINATION_STORAGE_ACCOUNT_NAME = 'DESTINATION STORAGE ACCOUNT NAME'

configcredentials = ClientSecretCredential(
    client_id=AZURE_CLIENT_ID,
    tenant_id=AZURE_TENANT_ID,
    client_secret=AZURE_CLIENT_SECRET)

SOURCE_CONTAINER_NAME = "SOURCE CONTAINER NAME"
DESTINATION_CONTAINER_NAME = "DESTINATION CONTAINER NAME"

config = create_configuration(storage_sdk='blob')

# Instantiate a Container Clients
# Source Container in Source Account;
container1=ContainerClient.from_container_url(container_url="{}://{}.blob.core.windows.net/{}".format(
        "https",
        AZURE_SOURCE_STORAGE_ACCOUNT_NAME,
        SOURCE_CONTAINER_NAME),
        credential=configcredentials)

# Destination Container in Destination Account; we can skip this too as we will not be using this in the below sample
container2=ContainerClient.from_container_url(container_url="{}://{}.blob.core.windows.net/{}".format(
        "https",
        AZURE_SOURCE_STORAGE_ACCOUNT_NAME,
        SOURCE_CONTAINER_NAME),
        credential=configcredentials)

# Instantiate a Blob Service Clients for source and destination accounts
service_client1 = BlobServiceClient(account_url="{}://{}.blob.core.windows.net".format(
        "https",
        AZURE_SOURCE_STORAGE_ACCOUNT_NAME,
        container1),
        credential=configcredentials)

service_client2 = BlobServiceClient(account_url="{}://{}.blob.core.windows.net".format(
        "https",
        AZURE_DESTINATION_STORAGE_ACCOUNT_NAME),
        credential=configcredentials)


#Listing the blob from Source Container and matching the patter and copying them to destination container;
blob_list = container1.list_blobs(name_starts_with="XXXXXXXXXXXXXXXXXXXXXXXXX")
for blob in blob_list:
        print("\t" + blob.name)
        sb=service_client1.get_blob_client(SOURCE_CONTAINER_NAME, str(blob.name))
        print(str(sb.url))
        cb = service_client2.get_blob_client(DESTINATION_CONTAINER_NAME, str(blob.name))
        cb.start_copy_from_url(str(sb.url)+str("SAS TOKEN for source account"))
