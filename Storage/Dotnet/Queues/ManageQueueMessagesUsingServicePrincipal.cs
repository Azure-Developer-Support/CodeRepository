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
// Azure.Storage.Queues
// Azure.Identity
// System.Configuration.ConfigurationManager

// This class file contains .Net Core 3.1 sample code to connect to storage account queue,
// to send, receive and delete messages using a Service Principal credentials

using Azure.Identity;
using Azure.Storage.Queues;
using Azure.Storage.Queues.Models;
using System;
using System.Configuration;

namespace QueueSamples
{
    class ManageQueueMessagesUsingServicePrincipal
    {
        public void SendReceiveMessages()
        {
            // Name of the queue to send messages to
            Uri queueUri = new Uri(ConfigurationManager.AppSettings["QueueUri"]);

            var credentials = new ClientSecretCredential(
                ConfigurationManager.AppSettings["TenantID"],
                ConfigurationManager.AppSettings["ClientID"],
                ConfigurationManager.AppSettings["ClientSecret"]
            );

            // Create queue client using accountURI and Service Principal credentials
            QueueClient queueClient = new QueueClient(queueUri, credentials);

            // sending test messages
            for (int i = 0; i < 10; i++)
            {
                queueClient.SendMessage($"{i} - {DateTime.Now.Ticks}");
            }

            // Read messages from the queue
            foreach (QueueMessage message in queueClient.ReceiveMessages(maxMessages: 10).Value)
            {
                // Display the message and its properties
                Console.WriteLine($"Message: \"{message.Body}\" : {message.MessageId} : {message.InsertedOn}");

                // Delete the message once it has been processed
                queueClient.DeleteMessage(message.MessageId, message.PopReceipt);
            }
            Console.WriteLine("Completed Successfully!");
        }
    }
}
