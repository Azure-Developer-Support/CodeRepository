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
// StackExchange.Redis


// This class file contains .Net Framework sample code to demo a PUB SUB in Azure Cache for Redis.

using System;
using StackExchange.Redis;


namespace AzureRedisPubSubDemoConsole
{
    internal class Program
    {
        static void Main(string[] args)
        {

            IDatabase redis = lazyConnection.Value.GetDatabase();

            ConnectionMultiplexer cm = lazyConnection.Value;
            var sub = redis.Multiplexer.GetSubscriber();

            //first subscribe, until we publish
            //subscribe to a test message
            sub.Subscribe("test", (channel, message) => {
                Console.WriteLine("Got notification: " + (string)message);
            });

            //create a publisher
            var pub = redis.Multiplexer.GetSubscriber();

            //pubish to test channel a message
            var count = pub.Publish("test", "Hello there I am a test message");
            Console.WriteLine($"Number of listeners for test {count}");


            //pattern match with a message
            sub.Subscribe(new RedisChannel("a*c", RedisChannel.PatternMode.Pattern), (channel, message) => {
                Console.WriteLine($"Got pattern a*c notification: {message}");
            });


            count = pub.Publish("a*c", "Hello there I am a a*c message");
            Console.WriteLine($"Number of listeners for a*c {count}");

            pub.Publish("abc", "Hello there I am a abc message");
            pub.Publish("a1234567890c", "Hello there I am a a1234567890c message");
            pub.Publish("ab", "Hello I am a lost message"); //this mesage is never printed


            //Never a pattern match with a message
            sub.Subscribe(new RedisChannel("*123", RedisChannel.PatternMode.Literal), (channel, message) => {
                Console.WriteLine($"Got Literal pattern *123 notification: {message}");
            });


            pub.Publish("*123", "Hello there I am a *123 message");
            pub.Publish("a123", "Hello there I am a a123 message"); //message is never received due to literal pattern


            //Auto pattern match with a message
            sub.Subscribe(new RedisChannel("zyx*", RedisChannel.PatternMode.Auto), (channel, message) => {
                Console.WriteLine($"Got Literal pattern zyx* notification: {message}");
            });


            pub.Publish("zyxabc", "Hello there I am a zyxabc message");
            pub.Publish("zyx1234", "Hello there I am a zyxabc message");

            //no message being published to it so it will not receive any previous messages
            sub.Subscribe("test", (channel, message) => {
                Console.WriteLine($"I am a late subscriber Got notification: {message}");
            });


            sub.Unsubscribe("a*c");
            count = pub.Publish("abc", "Hello there I am a abc message"); //no one listening anymore
            Console.WriteLine($"Number of listeners for a*c {count}");

            Console.ReadKey();

           
        }



        private static Lazy<ConnectionMultiplexer> lazyConnection = new Lazy<ConnectionMultiplexer>(() =>
        {

            //update the Connection string in the below
            string cacheConnection = "";// Replace this by Azure Redis access Key.
            return ConnectionMultiplexer.Connect(cacheConnection);
        });

        public static ConnectionMultiplexer Connection
        {
            get
            {
                return lazyConnection.Value;
            }
        }
    }
    
}
