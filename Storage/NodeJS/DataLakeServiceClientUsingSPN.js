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

// This class file contains NodeJs sample code to interact with an ADLS Gen 2 Storage account
// using a Service Principal

const { DataLakeServiceClient } = require("@azure/storage-file-datalake");
const { DefaultAzureCredential } = require("@azure/identity");

async function main() {
    const storageAccountName = "STORAGE_ACCOUNT_NAME"

    // Setting environment variables. Alternatively use .env file or set at operating system environment
    process.env['ACCOUNT_NAME'] = storageAccountName;
    process.env['AZURE_CLIENT_ID'] = "SPN_CLIENT_ID";
    process.env['AZURE_CLIENT_SECRET'] = "SPN_CLIENT_SECRET";
    process.env['AZURE_TENANT_ID'] = "TENANT_ID";

    // Create DataLake Service client
    const adlsService = GetDataLakeServiceClientAD(storageAccountName);

    // Create File System/Container client
    const fileSystemClient = await CreateFileSystem(adlsService);

    // Create Directory client
    const directoryClient = await CreateDirectory(fileSystemClient);

    // Create and write data to a file
    await CreateFile(directoryClient);
}

function GetDataLakeServiceClientAD(accountName) {
  try {
    // Using DefaultAzureCredential to create credential using environment variables set
    const defaultAzureCredential = new DefaultAzureCredential();

    // Get DataLakeServiceClient using the DefaultAzureCredential object
    const datalakeServiceClient = new DataLakeServiceClient(
        `https://${accountName}.dfs.core.windows.net`,
        defaultAzureCredential
    );
    return datalakeServiceClient;
  }
  catch(e) {
    console.log('Catch error: ', e)
  }
}

async function CreateFileSystem(datalakeServiceClient) {
  try {
    // Container/files system name
    const fileSystemName = "nodejs-system";

    // Get FileSystem client
    const fileSystemClient = datalakeServiceClient.getFileSystemClient(fileSystemName);

    // Creating file system if not exists
    await fileSystemClient.createIfNotExists();
    console.log(`Create file system ${fileSystemName} successfully`);
    return fileSystemClient;
  }
  catch(e) {
    console.log('Catch error: ', e)
  }
}

async function CreateDirectory(fileSystemClient) {
  try {
    // Directory name
    const directoryName = "parent1";

    // Get directory client
    const directoryClient = fileSystemClient.getDirectoryClient(directoryName);
    
    // Create directory
    await directoryClient.create();
    console.log(`Directory ${directoryName} created successfully`);
    return directoryClient;
  }
  catch(e) {
    console.log('Catch error: ', e)
  }
}

async function CreateFile(directoryClient) {
  try {
    // File content
    const content = "Hello World!";
    
    // File name
    const fileName = "File1.txt";
    
    // Get file client
    const fileClient = directoryClient.getFileClient(fileName);
    
    // Create the file
    await fileClient.create();
    
    // Append/write data to file
    await fileClient.append(content, 0, content.length);
    
    // Flush file contents
    await fileClient.flush(content.length);
    console.log(`Create and upload file ${fileName} successfully`);
  }
  catch(e) {
    console.log('Catch error: ', e)
  }
}

main();