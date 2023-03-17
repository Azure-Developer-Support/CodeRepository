
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

using System;
using Confluent.Kafka;

class Program
{
    static void Main(string[] args)
    {
        var config = new ProducerConfig
        {
            BootstrapServers = "<your-eventhub-namespace>.servicebus.windows.net:9093",
            SecurityProtocol = SecurityProtocol.SaslSsl,
            SaslMechanism = SaslMechanism.Plain,
            SaslUsername = "$ConnectionString",
            SaslPassword = "<SAS-connection-string>",
            //SslCaLocation = "/etc/ssl/certs/ca-certificates.crt", // Path to trusted root certificate file
            // You can set other producer properties here if needed https://github.com/confluentinc/librdkafka/blob/master/CONFIGURATION.md
            
        };
        
        var topic = "<eventhub-name>";
        
        using (var producer = new ProducerBuilder<Null, string>(config).Build())
        {
            string message = "Test Message";
            producer.ProduceAsync(topic, new Message<Null, string> { Value = message }).GetAwaiter().GetResult();
            Console.WriteLine($"Sent message: {message}");
        }
    }
}
