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
# azure.storage.blob
# azure.identity
# urllib
# Create a service principal and assign Reader and Storage Blob Data Reader roles on a ADLS Gen 2 storage account

# This class file contains Python 3 sample code to create a directory scoped 
# User Delegation SAS token using a Service Principals identity for authentication

import base64
import hashlib
import hmac
import requests
import os

from urllib.parse import unquote, quote
from datetime import datetime, timedelta
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient

STORAGE_ACCOUNT = ""
CONTAINER = ""
DIRECTORY = ""

def createDirectoryScopedUserDelegationSAS():
    user_delegation_object = getUserDelegationKey()
    user_delegation_key = user_delegation_object.value #returned from Get User Delegation API
    
    signedPermissions = "rl"
    signedStart = user_delegation_object.signed_start #returned from Get User Delegation API / can be within the delegation key timeframe
    signedExpiry = user_delegation_object.signed_expiry #returned from Get User Delegation API / can be within the delegation key timeframe
    canonicalizedResource = "/blob/"+STORAGE_ACCOUNT+"/"+CONTAINER+"/"+DIRECTORY
    signedKeyObjectId = user_delegation_object.signed_oid #returned from Get User Delegation API
    signedKeyTenantId = user_delegation_object.signed_tid #returned from Get User Delegation API
    signedKeyStart = signedStart #returned from Get User Delegation API
    signedKeyExpiry  = signedExpiry #returned from Get User Delegation API
    signedKeyService = user_delegation_object.signed_service #returned from Get User Delegation API
    signedKeyVersion = user_delegation_object.signed_version #returned from Get User Delegation API
    signedAuthorizedUserObjectId = ""
    signedUnauthorizedUserObjectId = ""
    signedCorrelationId = ""
    signedIP = ""
    signedProtocol = "https"
    signedVersion = signedKeyVersion
    signedResource = "d" # d denotes directory scope
    signedDirectoryDepth = "1"
    signedSnapshotTime = ""
    rscc = ""
    rscd = ""
    rsce = ""
    rscl = ""
    rsct = ""

    # Cosntruct the string to sign
    stringToSign =  unquote(signedPermissions + "\n" + \
                    signedStart + "\n" + \
                    signedExpiry + "\n" + \
                    canonicalizedResource + "\n" + \
                    signedKeyObjectId + "\n" + \
                    signedKeyTenantId + "\n" + \
                    signedKeyStart + "\n" + \
                    signedKeyExpiry  + "\n" + \
                    signedKeyService + "\n" + \
                    signedKeyVersion + "\n" + \
                    signedAuthorizedUserObjectId + "\n" + \
                    signedUnauthorizedUserObjectId + "\n" + \
                    signedCorrelationId + "\n" + \
                    signedIP + "\n" + \
                    signedProtocol + "\n" + \
                    signedVersion + "\n" + \
                    signedResource + "\n" + \
                    signedSnapshotTime + "\n" + \
                    rscc + "\n" + \
                    rscd + "\n" + \
                    rsce + "\n" + \
                    rscl + "\n" + \
                    rsct)
    
    sasToken = signCreateSAS(user_delegation_key, signedPermissions, signedStart, signedExpiry, signedKeyObjectId, signedKeyTenantId, signedKeyStart, signedKeyExpiry, signedKeyService, signedProtocol, signedKeyVersion, signedResource, signedDirectoryDepth, stringToSign)

    #Use the SAS token to make List Files REST API call
    listDirectoryFiles(sasToken)

def listDirectoryFiles(sastoken):
    list_path_api_url = ("https://{0}.dfs.core.windows.net/{1}?directory={2}&recursive=false&resource=filesystem&{3}".format(
            STORAGE_ACCOUNT,
            CONTAINER,
            DIRECTORY,
            sastoken))

    print("GET " + list_path_api_url)
    r = requests.get(list_path_api_url)
    print("Status: ", r.status_code)
    print("Response: " + r.text)

def getUserDelegationKey():
    # Set the Service Principals identity and credentials in the environment variables
    os.environ.setdefault('AZURE_TENANT_ID', '')
    os.environ.setdefault('AZURE_CLIENT_ID', '')
    os.environ.setdefault('AZURE_CLIENT_SECRET', '')
    
    token_credential = DefaultAzureCredential()
    blob_service_client = BlobServiceClient(
        account_url="https://{0}.blob.core.windows.net".format(STORAGE_ACCOUNT),
        credential=token_credential
    )
    
    # Get the user delegation key
    udk = blob_service_client.get_user_delegation_key(key_start_time=datetime.utcnow(), key_expiry_time=datetime.utcnow() + timedelta(hours=2))
    return udk
    
def signCreateSAS(user_delegation_key, signedPermissions, signedStart, signedExpiry, signedKeyObjectId, signedKeyTenantId, signedKeyStart, signedKeyExpiry, signedKeyService, signedProtocol, signedKeyVersion, signedResource, signedDirectoryDepth, stringToSign):
    # Signing the string-to-sign with the user delegation key
    key = base64.b64decode(user_delegation_key.encode('utf-8'))
    hash = hmac.HMAC(key=key,msg=stringToSign.encode('utf-8'),digestmod=hashlib.sha256).digest()
    sig = quote(base64.b64encode(hash))
    
    # Construct the SAS token
    sastoken = ("sp=" + signedPermissions + \
        "&st=" + signedStart + \
        "&se=" + signedExpiry + \
        "&skoid=" + signedKeyObjectId + \
        "&sktid=" + signedKeyTenantId + \
        "&skt=" + signedKeyStart + \
        "&ske=" + signedKeyExpiry + \
        "&sks=" + signedKeyService + \
        "&skv=" +  signedKeyVersion + \
        "&spr=" + signedProtocol + \
        "&sv=" + signedKeyVersion + \
        "&sr=" + signedResource + \
        "&sig=" + sig + \
        "&sdd=" + signedDirectoryDepth)
        
    return sastoken

createDirectoryScopedUserDelegationSAS()