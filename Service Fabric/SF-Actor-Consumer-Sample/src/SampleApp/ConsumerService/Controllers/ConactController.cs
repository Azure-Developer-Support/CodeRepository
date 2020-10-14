using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using ConActor.Interfaces.v2;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.ServiceBus;
using Microsoft.Extensions.Configuration;
using Microsoft.ServiceFabric.Actors;
using Microsoft.ServiceFabric.Actors.Client;

namespace ConsumerService.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ConactController : ControllerBase
    {
        // GET api/conact
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }

        [HttpGet]
        [Route("{actorId}")]
        public async Task<int> Get(string actorId)
        {
            var actorIdObj = new ActorId(actorId);
            IConActor actor = null;

            try
            {
                actor = ActorProxy.Create<IConActor>(
                                            actorIdObj,
                                            new Uri("fabric:/DataLossCheckApp/ConActorService"));
                var result = await actor.GetCountAsync(CancellationToken.None);

                // log message
                await Helper.LogMessage(actorId, $"GET - {result}");

                return result;
            }
            catch (Exception ex)
            {
                // log message
                await Helper.LogMessage(actorId, $"GET ERROR - {ex.ToString()}");
                throw ex;
            }
            finally
            {
                if (actorIdObj != null)
                {
                    actorIdObj = null;
                }
                if (actor != null)
                {
                    actor = null;
                }
            }
        }

        [HttpPost]
        public async Task Post(ActorWrap actorWrap)
        {
            var actorIdObj = new ActorId(actorWrap.ActorGuid);
            IConActor actor = null;

            try
            {
                actor = ActorProxy.Create<IConActor>(
                                        actorIdObj,
                                        new Uri("fabric:/DataLossCheckApp/ConActorService"));
                await actor.SetCountAsync(actorWrap.Value, CancellationToken.None);

                // log message
                await Helper.LogMessage(actorWrap.ActorGuid, $"SET - {actorWrap.Value}");
            }
            catch (Exception ex)
            {
                // log message
                await Helper.LogMessage(actorWrap.ActorGuid, $"SET ERROR - {ex.ToString()}");
            }
            finally
            {
                if (actorIdObj != null)
                {
                    actorIdObj = null;
                }
                if (actor != null)
                {
                    actor = null;
                }
            }
        }

        [HttpDelete]
        [Route("{actorId}")]
        public async Task Delete(string actorId)
        {
            var actorIdObj = new ActorId(actorId);
            IActorService actorServiceProxy = null;

            try
            {
                actorServiceProxy = ActorServiceProxy.Create(
                                new Uri("fabric:/DataLossCheckApp/ConActorService"),
                                actorIdObj);
                await actorServiceProxy.DeleteActorAsync(actorIdObj, CancellationToken.None);

                // log message
                await Helper.LogMessage(actorId, $"DELETED");
            }
            catch(Exception ex)
            {
                // log message
                await Helper.LogMessage(actorId, $"DELETE ERROR - {ex.ToString()}");
            }
            finally
            {
                if(actorIdObj != null)
                {
                    actorIdObj = null;
                }
                if(actorServiceProxy != null)
                {
                    actorServiceProxy = null;
                }
            }
        }
    }
}
