namespace LearningHub.Nhs.MessageQueueProcessor.Services.Interfaces
{
    using System.Net.Http;

    /// <summary>
    /// The IClientService.
    /// </summary>
    public interface IClientService
    {
        /// <summary>
        /// Gets the ApiHttpClient.
        /// </summary>
        HttpClient ApiHttpClient { get; }
    }
}
