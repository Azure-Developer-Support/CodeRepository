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

# Dependencies: Following libraries needs to be installed
# azure-storage-file-datalake
# azure.identity
# Enable VMs Managed Identity and assign necessary RBAC or ACLs to the identity on your ADLS Gen 2 Storage account

# This class file contains Python 3 sample code to interact with an ADLS Gen 2 Storage account
# using an Azure VMs Managed Identity for authentication

import os, uuid, sys
from azure.storage.filedatalake import DataLakeServiceClient
from azure.identity import ManagedIdentityCredential

#using DefaultAzureCredential to use VMs Managed Service Identity
credential = ManagedIdentityCredential()
try:
    #create a DataLakeServiceClient with VMs MSI Credential
    global service_client
    service_client = DataLakeServiceClient(account_url="{}://{}.dfs.core.windows.net".format("https", "adlsgen2account"), credential=credential)
    print("Create a data lake service client")

    #create a file system client and create a new filesystem/container
    global file_system_client
    file_system_client = service_client.create_file_system(file_system="file-system")
    print("New file system created")

    #create a new directory in the filesystem
    file_system_client.create_directory("my-directory")
    print("New directory created")

    print("Uploading local file to ADLS Gen 2")
    #get the client of the newly created directory
    directory_client = file_system_client.get_directory_client("my-directory")

    #create a file using the directory client
    file_client = directory_client.create_file("uploaded-file.txt")

    #open and read local file
    local_file = open("file-to-upload.txt",'rb')
    file_contents = local_file.read()

    #append content to the new file and flush data
    file_client.append_data(data=file_contents, offset=0, length=len(file_contents))
    file_client.flush_data(len(file_contents))
    print("File upload successfull")

except Exception as e:
    print(e)