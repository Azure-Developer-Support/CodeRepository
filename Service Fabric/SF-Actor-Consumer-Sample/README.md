
# Flow
- SF
	- LB -> Stateless [ConsumerService] -----ActorProxy-----> Actor [ConActor]

- External users would hit the Stateless web api endpoint [ConsumerService], which further would make an invocation of the Actor service [ConActor] instance via ActorProxy.

- [ConsumerService] have the logic of line by line logging to understand the application flow. Basically, it would log the messages into the Azure ServiceBus instance.

- Consumer
	- Console app [Simulator] ----HttpClient----> LB -> Stateless [ConsumerService]

- Monitor
	- Console app [SBClient] -> Azure ServiceBus
	
# Applications
- [ConActor] is a `.NET Framework Actor service` on .NET 4.6.1.
- [ConsumerService] is a `Stateless ASP.NET Core` service on .NET Core 3.1 - Web Api.
- [Simulator] is a `Console app` on .NET Core 3.1.
- [SBClient] is a `Console app` on .NET Core 3.1.
	
# How to execute?
- Update `SBConnectionString` parameter value with correct Azure ServiceBus connection string in  `ConsumerService\appsettings.json`
- Build the solution
- Deploy the SF application via `deploy\app-deploy-script.ps1`
- Get the stateless service URI - e.g. http://DNS-name:8034/api/conact
- Update the `APP-URL` parameter value with correct stateless service URI in `Simulator\appsettings.json`
- Update the `SB-CONNECTION-STRING` parameter value with ServiceBus connecion string in `SBClient\appsettings.json`
- Build projects [Simulator] and [SBClient]
- Run [Simulator] and [SBClient] in two separate command prompts to learn the usage of it

