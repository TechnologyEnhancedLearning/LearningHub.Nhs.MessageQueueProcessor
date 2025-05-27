namespace LearningHub.Nhs.MessageQueueProcessor.Services.Interfaces
{
    using System.Threading.Tasks;

    /// <summary>
    /// The IMessageQueueProcessorService.
    /// </summary>
    public interface IMessageQueueProcessorService
    {
        /// <summary>
        /// Process the messages in Pending state.
        /// </summary>
        /// <returns>return.</returns>
        Task ProcessQueueAsync();
    }
}
