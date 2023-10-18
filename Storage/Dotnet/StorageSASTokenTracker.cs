//'By using the following materials or sample code you agree to be bound by the license terms below 
//'and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
//'These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you 
//'are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you 
//'are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
//'not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to 
//'use and modify the sample code and to reproduce and distribute the object code form of the sample code, 
//'provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product 
//'in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in 
//'which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors 
//'a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
//'limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and 
//'suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result 
//'from the use or distribution of the sample code."  

// Dependencies: Following nuget packages needs to be installed
//using Azure.Identity;
//using Azure.Security.KeyVault.Secrets;

// By USing this class you can trigger an alert By using any jobes or Email or Event whener SAS token is going to be expire

//Steps:-
//1. Create a key Vault.
//2. Update the Vault URI in class.
//3. Create a Secret Object in Key Vault and Update the SAS toke of Storage account in that.
//4. Update the secret name in class.
//5. Update the date differnce instead N (Eg.- 5)

using System.Configuration;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

namespace StorageSASTokenTracker
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var kvUri = "https://<<KeyVaultName>>.vault.azure.net/";
            var client = new SecretClient(new Uri(kvUri), new DefaultAzureCredential());

            var secret =  await client.GetSecretAsync("<<SecretName>>");

            var secretValue = secret.Value;
            var sasToken = secretValue.Value;

            var expiryVaue = sasToken.Split("se=")[1].Split('&')[0];

            int dateDifference = (Convert.ToDateTime(expiryVaue) - DateTime.Now.Date).Days;

            if (dateDifference < N)
            {
                Console.WriteLine("Your storage account SAS token is expiring in {0} day(s)", dateDifference);
            }
            Console.ReadLine();
        }

       
    }
}
