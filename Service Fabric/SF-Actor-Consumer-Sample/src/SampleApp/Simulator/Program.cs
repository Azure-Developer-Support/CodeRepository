using Microsoft.Extensions.Configuration;
using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace Simulator
{
    class Program
    {
        static async Task Main(string[] args)
        {
            Console.WriteLine("***** start test *******");
            Console.ReadLine();

            // Get config settings from AppSettings
            IConfigurationBuilder builder = new ConfigurationBuilder().AddJsonFile("appsettings.json")
                                                                    .AddJsonFile("appsettings.Development.json");
            IConfigurationRoot configuration = builder.Build();
            
            // read app URI
            string statelessUri = configuration["APP-URL"];

            var httpClient = new HttpClient();
            httpClient.BaseAddress = new Uri(statelessUri);

            var actorObject = new ActorWrap[5];
            for (int i = 0; i < 5; i++)
            {
                actorObject[i] = new ActorWrap
                {
                    ActorGuid = Guid.NewGuid().ToString(),
                    Value = new Random().Next(1, 999)
                };
            }

            // POST
            await PostApiInvoke(httpClient, actorObject);

            Console.ReadLine();

            // GET
            await GetApiInvoke(httpClient, actorObject);

            Console.ReadLine();

            // GET again
            await GetApiInvoke(httpClient, actorObject);

            Console.ReadLine();

            // GET again
            await GetApiInvoke(httpClient, actorObject);

            Console.ReadLine();

            // DELETE
            await DeleteApiInvoke(httpClient, actorObject);

            Console.ReadLine();

            // GET again
            await GetApiInvoke(httpClient, actorObject);

            Console.WriteLine("******** test over *********");
            Console.ReadLine();
        }

        private static async Task DeleteApiInvoke(HttpClient httpClient, ActorWrap[] actorObject)
        {
            for (int i = 0; i < 5; i++)
            {
                var result = await httpClient.SendAsync(new HttpRequestMessage
                {
                    Method = HttpMethod.Delete,
                    RequestUri = new Uri($"{httpClient.BaseAddress.AbsoluteUri}/{actorObject[i].ActorGuid}")
                });
                if (result.IsSuccessStatusCode)
                {
                    Console.WriteLine($"{i} - DELETE call succeeded");
                }
                else
                {
                    Console.WriteLine($"{i} - DELETE call failed");
                }
            }
        }

        private static async Task GetApiInvoke(HttpClient httpClient, ActorWrap[] actorObject)
        {
            for (int i = 0; i < 5; i++)
            {
                var result = await httpClient.SendAsync(new HttpRequestMessage
                {
                    Method = HttpMethod.Get,
                    RequestUri = new Uri($"{httpClient.BaseAddress.AbsoluteUri}/{actorObject[i].ActorGuid}")
                });
                if (result.IsSuccessStatusCode)
                {
                    Console.WriteLine($"{i} - result: {await result.Content.ReadAsStringAsync()}");
                }
                else
                {
                    Console.WriteLine($"{i} - GET call failed");
                }
            }
        }

        private static async Task PostApiInvoke(HttpClient httpClient, ActorWrap[] actorObject)
        {
            for (int i = 0; i < 5; i++)
            {
                var result = await httpClient.SendAsync(new HttpRequestMessage
                {
                    Method = HttpMethod.Post,
                    Content = new StringContent(
                                            JsonSerializer.Serialize(actorObject[i]),
                                            Encoding.UTF8,
                                            "application/json")
                });
                if (result.IsSuccessStatusCode)
                {
                    Console.WriteLine($"{i} - POST call succeeded");
                }
                else
                {
                    Console.WriteLine($"{i} - POST call failed");
                }
            }
        }
    }

    class ActorWrap
    {
        public string ActorGuid { get; set; }
        public int Value { get; set; }
    }
}
