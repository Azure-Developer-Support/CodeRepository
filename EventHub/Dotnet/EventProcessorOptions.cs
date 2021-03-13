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
//Microsoft.Azure.EventHubs
//Microsoft.Azure.EventHubs.Processor


//This code will help to configure MaxBatchSize, PrefetchCount using EventProcessorOptions for Event hub EPH receiver 
using System;

using System.Threading.Tasks;

using Microsoft.Azure.EventHubs;

using Microsoft.Azure.EventHubs.Processor;

namespace SampleEphReceiver
{
    public class EventProcessorOptions 

    {

        private const string EventHubConnectionString = "{EH Connection string}";

        private const string EventHubName = "{Event hub  Name}";

        private const string EventHubConsumerGroup = "{EH Consumer group}";
       
        private const string StorageAccountName = "{Storage Account Name}";

        private const string StorageAccountKey = "{Storage Account Key}";
        
         private const string StorageContainerName = "{Storage Container Name}";



        private static readonly string StorageConnectionString = string.Format("DefaultEndpointsProtocol=https;AccountName={0};AccountKey={1}", StorageAccountName, StorageAccountKey);



        public static void Main(string[] args)

        {

            MainAsync(args).GetAwaiter().GetResult();

        }



        private static async Task MainAsync(string[] args)

        {

            Console.WriteLine("Registering EventProcessor...");



            var eventProcessorHost = new EventProcessorHost(

                EventHubName,

                EventHubConsumerGroup,

                EventHubConnectionString,

                StorageConnectionString,

                StorageContainerName);

            var options = new EventProcessorOptions()
            {
                MaxBatchSize = 200,
                PrefetchCount = 300,
                ReceiveTimeout = TimeSpan.FromMinutes(1),
                EnableReceiverRuntimeMetric = true,
                InvokeProcessorAfterReceiveTimeout = false
            };
          
          //Implement a class with name SimpleEventProcessor inheriting IEventProcessor
            
            await eventProcessorHost.RegisterEventProcessorAsync<SimpleEventProcessor>(options);

           

            Console.ReadLine();



            // Disposes of the Event Processor Host

            await eventProcessorHost.UnregisterEventProcessorAsync();

        }

    }
}
