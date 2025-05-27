namespace LearningHub.Nhs.MessageQueueProcessor.Services
{
    using System;
    using System.Net.Http;
    using System.Net.Http.Headers;
    using LearningHub.Nhs.MessageQueueProcessor.Configuration;
    using LearningHub.Nhs.MessageQueueProcessor.Services.Interfaces;
    using Microsoft.Extensions.Options;

    /// <summary>
    /// The ClientService.
    /// </summary>
    public class ClientService : IClientService
    {
        private readonly Settings settings;
        private HttpClient apiClient;

        /// <summary>
        /// Initializes a new instance of the <see cref="ClientService"/> class.
        /// </summary>
        /// <param name="settings">config settings.</param>
        public ClientService(IOptions<Settings> settings)
        {
            this.settings = settings.Value;
        }

        /// <summary>
        /// Gets the ApiHttpClient.
        /// </summary>
        public HttpClient ApiHttpClient
        {
            get
            {
                return this.apiClient ?? (this.apiClient = this.CreateApiClient());
            }
        }

        /// <summary>
        /// CreateApiClient.
        /// </summary>
        private HttpClient CreateApiClient()
        {
            var httpClient = new HttpClient();
            httpClient.DefaultRequestHeaders.Add("X-API-KEY", this.settings.ApiKey);
            httpClient.BaseAddress = new Uri(this.settings.BaseUrl);
            httpClient.DefaultRequestHeaders.Accept.Clear();
            httpClient.DefaultRequestHeaders.Accept.Add(
                    new MediaTypeWithQualityHeaderValue("application/json"));
            return httpClient;
        }
    }
}
