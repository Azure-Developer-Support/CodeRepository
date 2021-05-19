// DISCLAIMER
// By using the following materials or sample code you agree to be bound by the license terms below 
// and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
// These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you 
// are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you 
// are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
// not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to 
// use and modify the sample code and to reproduce and distribute the object code form of the sample code, 
// provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product 
// in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in 
// which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors 
// a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
// limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and 
// suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result 
// from the use or distribution of the sample code. 

// Dependencies: Following packages needs to be installed
// @azure/storage-file-datalake
// @azure/identity

// This class file contains NodeJs sample code to generate a User Delegation SAS for a Service Principal 
// scoped at directory in an ADLS Gen 2 Storage account

const { DataLakeServiceClient, DataLakeSASSignatureValues, generateDataLakeSASQueryParameters, DirectorySASPermissions, SASProtocol } = require("@azure/storage-file-datalake");
const { DefaultAzureCredential } = require("@azure/identity");
const fs = require('fs');
const https = require('https');

const storageAccountName = "STORAGE_ACCOUNT_NAME"
const containerName = "FILE_SYSTEM_NAME";
const directoryName = "DIRECTORY_NAME";
const dfsEndpoint = "dfs.core.windows.net"

async function main() {
  // Setting environemt variables. Alternatively use .env file or set at operating system environment (preferred)
  process.env['ACCOUNT_NAME'] = storageAccountName;
  process.env['AZURE_CLIENT_ID'] = "SPN_CLIENT_ID";
  process.env['AZURE_CLIENT_SECRET'] = "SPN_CLIENT_SECRET";
  process.env['AZURE_TENANT_ID'] = "TENANT_ID";

  const datalakeServiceClient = getDataLakeServiceClientAD(storageAccountName);

  const directorySAS = await getDirectorySAS(datalakeServiceClient);

  // Downloading a file to test the User Delegation SAS
  let URL = `https://${storageAccountName}.${dfsEndpoint}/${containerName}/${directoryName}/readme.txt?${directorySAS}`;
  downloadFile(URL);
}

function getDataLakeServiceClientAD(accountName) {
  try {
    // Using DefaultAzureCredential to create credential using environment variables set
    const defaultAzureCredential = new DefaultAzureCredential();

    // Get DataLakeServiceClient using the DefaultAzureCredential object
    const datalakeServiceClient = new DataLakeServiceClient(
        `https://${accountName}.${dfsEndpoint}`,
        defaultAzureCredential
    );
    return datalakeServiceClient;
  }
  catch(e) {
    console.log('Catch an error: ', e)
  }
}

async function getDirectorySAS(datalakeServiceClient) {
  try {
    const startsOn = new Date();
    const expiresOn = new Date();
    startsOn.setTime(startsOn.getTime() - 100 * 60 * 1000);
    expiresOn.setTime(expiresOn.getTime() + 100 * 60 * 60 * 1000);
	
	// Get the User Delegation key, required for generating SAS 
    const userDelegationKey = await datalakeServiceClient.getUserDelegationKey(startsOn, expiresOn);

	// Generate the User Delegation SAS token
    return generateDataLakeSASQueryParameters({
        pathName: directoryName, // SAS token will be scoped at/valid on this directory.
        fileSystemName: containerName,
        permissions: DirectorySASPermissions.parse("racwdl"),
        expiresOn,
        directoryDepth: 1,
        isDirectory: true,
        protocol: SASProtocol.Https,
        version: "2020-02-10"
      },
      userDelegationKey,
      storageAccountName
    ).toString();
  }
  catch(e) {
    console.log('Catch an error: ', e)
  }
}

function downloadFile(url) {
  try {
    https.get(url,(res) => {
      // File will be stored at this path
      const path = `/path_to_file/readme.txt`;
      const filePath = fs.createWriteStream(path);
      res.pipe(filePath);
      filePath.on('finish',() => {
          filePath.close();
          console.log('Download Completed');
      })
    });
  }
  catch(e) {
    console.log('Catch an error: ', e)
  }
}

main();
