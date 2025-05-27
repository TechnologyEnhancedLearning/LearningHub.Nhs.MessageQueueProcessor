#pragma warning disable SA1200 // Using directives should be placed correctly
using LearningHub.Nhs.MessageQueueProcessor.Configuration;
using LearningHub.Nhs.MessageQueueProcessor.Helpers;
using LearningHub.Nhs.MessageQueueProcessor.Services;
using LearningHub.Nhs.MessageQueueProcessor.Services.Interfaces;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Builder;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = FunctionsApplication.CreateBuilder(args);

builder.ConfigureFunctionsWebApplication();
builder.Configuration.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);
builder.Configuration.AddJsonFile("local.settings.json", optional: true, reloadOnChange: true);
builder.Services.Configure<Settings>(builder.Configuration.GetSection("Settings"));
builder.Services.AddOptions();
builder.Services
    .AddApplicationInsightsTelemetryWorkerService()
    .ConfigureFunctionsApplicationInsights();

builder.Services.AddSingleton<IClientService, ClientService>();
builder.Services.AddScoped<IGovNotifyMessageFacade, GovNotifyMessageFacade>();
builder.Services.AddScoped<IMessageQueueProcessorService, MessageQueueProcessorService>();

builder.Build().Run();
