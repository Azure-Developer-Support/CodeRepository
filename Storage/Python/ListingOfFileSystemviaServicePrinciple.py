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

# The below sample connects to ADLS Gen2 Account via a Service Principle and then perform listing of file systems

import os
from azure.storage.filedatalake import DataLakeServiceClient
from azure.identity import ClientSecretCredential

AZURE_CLIENT_ID = "XXXXXXXXXXXXXXXXXXXXXXXXXX"
AZURE_TENANT_ID = "XXXXXXXXXXXXXXXXXXXXXXXXXX"
AZURE_CLIENT_SECRET = "XXXXXXXXXXXXXXXXXXXXXXXXXX"
AZURE_STORAGE_ACCOUNT_NAME = 'XXXXXXXXXXXXXXXXXXXXXXXXXX'

configcredentials = ClientSecretCredential(
    client_id=AZURE_CLIENT_ID,
    tenant_id=AZURE_TENANT_ID,
    client_secret=AZURE_CLIENT_SECRET)

# Construct the DatalakeServiceClient
service_client = DataLakeServiceClient(account_url="{}://{}.dfs.core.windows.net".format(
        "https",
        AZURE_STORAGE_ACCOUNT_NAME),
        credential=configcredentials)

# Performing Listing
file_systems = service_client.list_file_systems()
for file_system in file_systems:
    print(file_system.name)
