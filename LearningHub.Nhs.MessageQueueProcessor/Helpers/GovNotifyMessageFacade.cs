namespace LearningHub.Nhs.MessageQueueProcessor.Helpers
{
    using System;
    using System.Net.Http;
    using System.Text;
    using System.Threading.Tasks;
    using LearningHub.Nhs.MessageQueueProcessor.Services.Interfaces;
    using Newtonsoft.Json;

    /// <summary>
    /// The GovNotifyMessageFacade.
    /// </summary>
    public class GovNotifyMessageFacade : IGovNotifyMessageFacade
    {
        private readonly IClientService clientService;

        /// <summary>
        /// Initializes a new instance of the <see cref="GovNotifyMessageFacade"/> class.
        /// </summary>
        /// <param name="clientService">httpClient.</param>
        public GovNotifyMessageFacade(IClientService clientService)
        {
            this.clientService = clientService;
        }

        /// <summary>
        /// The PostAsync.
        /// </summary>
        /// <typeparam name="TModel">The request.</typeparam>
        /// <typeparam name="TResult">the response.</typeparam>
        /// <param name="endpoint">endpoint url.</param>
        /// <param name="request">request.</param>
        /// <returns>The response.</returns>
        public async Task<TResult> PostAsync<TModel, TResult>(string endpoint, TModel request)
        {
            var requestContent = new StringContent(JsonConvert.SerializeObject(request), Encoding.UTF8, "application/json");

            var response = await this.clientService.ApiHttpClient.PostAsync(endpoint, requestContent);
            if (response.IsSuccessStatusCode)
            {
                return this.HandleSuccess<TResult>(response);
            }

            throw this.HandleFailure(response);
        }

        /// <summary>
        /// The GetAsync.
        /// </summary>
        /// <typeparam name="TResult">The response.</typeparam>
        /// <param name="endpoint">endpoint url.</param>
        /// <returns>The responses.</returns>
        public async Task<TResult> GetAsync<TResult>(string endpoint)
        {
            var response = await this.clientService.ApiHttpClient.GetAsync(endpoint);
            if (response.IsSuccessStatusCode)
            {
                return this.HandleSuccess<TResult>(response);
            }

            throw this.HandleFailure(response);
        }

        private T HandleSuccess<T>(HttpResponseMessage response)
        {
            var result = response.Content.ReadAsStringAsync().Result;
            return JsonConvert.DeserializeObject<T>(result);
        }

        private Exception HandleFailure(HttpResponseMessage response)
        {
            if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized
                        ||
                     response.StatusCode == System.Net.HttpStatusCode.Forbidden)
            {
                return new Exception("Access Denied");
            }
            else
            {
                return new Exception($"Exception HttpStatusCode={response.StatusCode}");
            }
        }
    }
}
