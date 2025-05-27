namespace LearningHub.Nhs.MessageQueueProcessor.Helpers
{
    using System.Threading.Tasks;

    /// <summary>
    /// IGovNotifyMessageFacade.
    /// </summary>
    public interface IGovNotifyMessageFacade
    {
        /// <summary>
        /// Makes a HTTP Get request to the OpenApi.
        /// </summary>
        /// <typeparam name="TRequest">request.</typeparam>
        /// <typeparam name="TResponse">response.</typeparam>
        /// <param name="endpoint">endpoint url.</param>
        /// <param name="request">the request.</param>
        /// <returns>The response.</returns>
        Task<TResponse> PostAsync<TRequest, TResponse>(string endpoint, TRequest request);

        /// <summary>
        /// Makes a HTTP Post request to the OpenApi.
        /// </summary>
        /// <typeparam name="TResponse">the response.</typeparam>
        /// <param name="endpoint">endpoint url.</param>
        /// <returns>The response.</returns>
        Task<TResponse> GetAsync<TResponse>(string endpoint);
    }
}
