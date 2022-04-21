//###ATTENTION: DISCLAIMER###

//DISCLAIMER
//#The sample code are not supported under any Microsoft standard support program or service. The sample code are provided AS IS without warranty of any kind. 
//Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.
//The entire risk arising out of the use or performance of the sample code and documentation remains with you. 
//In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the code be liable for 
//any damages whatsoever (including, #without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss)
//arising out of the use of or inability to use the sample code or documentation, even if Microsoft has been advised of the possibility of such damages 


//#############Script Overview#################################################################

//#The below code will help you flush redis cache programmatically. Ensure you understand the impact of flush all command before implementing this. Please refer : https://redis.io/commands/flushall/
// This code will take connection string as the input parameter and can exceute flush all of the respective redis instance.
// You can use it like this: FlushRedis.exe "<redisname>.redis.cache.windows.net:6380,password=XXXXX=,ssl=True,abortConnect=False"

using StackExchange.Redis;
using System;
using System.Configuration;
using System.Text.Json;
using System.Threading.Tasks;

namespace FlushRedis
{
    class Program
    {
        private static RedisConnection _redisConnection;

        static async Task Main(string[] args)
        {
            if (args == null || args.Length < 1)
            {
                Console.WriteLine("No connection string provided. Please provide the connection string to excecute FlushAll command");
            }
            else
            {
                string connectionStringInPut = args[0];
                _redisConnection = await RedisConnection.InitializeAsync(connectionString: connectionStringInPut);
                try
                {

                    Task thread1 = Task.Run(() => RunRedisCommandsAsync());
                    Task.WaitAll(thread1);
                }
                finally
                {
                    _redisConnection.Dispose();
                }
            }  
        }
        private static async Task RunRedisCommandsAsync()
        {
            //Flush All

            Console.WriteLine($"{Environment.NewLine}Cache command: FlushAll");
            RedisResult flushAllResult = await _redisConnection.BasicRetryAsync(async (db) => await db.ExecuteAsync("FlushAll"));
            Console.WriteLine($"Cache response: {flushAllResult}");
        }
    }
}
