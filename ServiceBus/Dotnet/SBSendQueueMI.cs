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

//Pre-requisite: Following nuget packages needs to be installed
//Microsoft.Azure.ServiceBus
//Enable the Managed Identies on the VM/App service where this code will be executed 
//Add RBAC role to the created Security principal in Azure service bus
//This code will send the message to Azure service bus queue using the Managed Identies without any connection string in the code

using System;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Primitives;
using Microsoft.Azure.Services.AppAuthentication;

namespace SBSendQueueMI
{
    class Program
    {
     
        const string endpoint = "sb://yssamplens.servicebus.windows.net";
        const string QueueName = "testqueue";
        
        public static async Task Main(string[] args)
        {
            const int numberOfMessages = 10;
            //queueClient = new QueueClient(ServiceBusConnectionString, QueueName);

            var tokenProvider = new ManagedIdentityServiceBusTokenProvider();
         //   var q = QueueClient.
            var queueClient = new QueueClient(endpoint, QueueName, tokenProvider);

            Console.WriteLine("======================================================");
            Console.WriteLine("Press ENTER key to exit after sending all the messages.");
            Console.WriteLine("======================================================");

          
            try
            {
                for (var i = 0; i < numberOfMessages; i++)
                {
                    // Create a new message to send to the queue
                    string messageBody = $"Message {i}";
                    var message = new Message(Encoding.UTF8.GetBytes(messageBody));

                    

                    // Send the message to the queue
                    await queueClient.SendAsync(message);
                    // Write the body of the message to the console
                    Console.WriteLine($"Sending message: {messageBody}");
                }
            }
            catch (Exception exception)
            {
                Console.WriteLine($"{DateTime.Now} :: Exception: {exception.Message}");
            }

            Console.ReadKey();

            await queueClient.CloseAsync();
        }

    }

    class ManagedIdentityServiceBusTokenProvider : TokenProvider
    {
        private readonly string _managedIdentityTenantId;

        public ManagedIdentityServiceBusTokenProvider(string managedIdentityTenantId = null)
        {
            if (string.IsNullOrEmpty(managedIdentityTenantId))
            {
                // Ensure tenant id is null if none given
                _managedIdentityTenantId = null;
            }
            else
            {
                _managedIdentityTenantId = managedIdentityTenantId;
            }
        }

        public override async Task<SecurityToken> GetTokenAsync(string appliesTo, TimeSpan timeout)
        {
            string accessToken = await GetAccessToken("https://servicebus.azure.net/");
            return new JsonSecurityToken(accessToken, appliesTo);
        }

        private async Task<string> GetAccessToken(string resource)
        {
            var authProvider = new AzureServiceTokenProvider();
            return await authProvider.GetAccessTokenAsync(resource, _managedIdentityTenantId);
        }
    }
}
