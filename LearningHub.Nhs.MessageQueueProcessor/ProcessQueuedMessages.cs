namespace LearningHub.Nhs.MessageQueueProcessor
{
    using System;
    using System.Threading.Tasks;
    using LearningHub.Nhs.MessageQueueProcessor.Services.Interfaces;
    using Microsoft.Azure.Functions.Worker;
    using Microsoft.Extensions.Logging;

    /// <summary>
    /// Process pending messages.
    /// </summary>
    public class ProcessQueuedMessages
    {
        private readonly IMessageQueueProcessorService processorService;
        private readonly ILogger<ProcessQueuedMessages> logger;

        /// <summary>
        /// Initializes a new instance of the <see cref="ProcessQueuedMessages"/> class.
        /// </summary>
        /// <param name="processorService">processorService.</param>
        /// <param name="logger">logger.</param>
        public ProcessQueuedMessages(IMessageQueueProcessorService processorService, ILogger<ProcessQueuedMessages> logger)
        {
            this.processorService = processorService;
            this.logger = logger;
        }

        /// <summary>
        /// Timer trigger for sending messages. "0 */2 * * * *" is every 2 minutes.
        /// </summary>
        /// <param name="myTimer">The timer, currently configured to run every 2 minutes.</param>
        /// <returns>A <see cref="Task"/> representing the asynchronous operation.</returns>
        [Function("ProcessQueuedMessages")]
        public async Task RunAsync([TimerTrigger("0 */2 * * * *")] TimerInfo myTimer)
        {
            this.logger.LogInformation($"Message Queue Timer trigger function executed at: {DateTime.Now}");
            await this.processorService.ProcessQueueAsync();
        }
    }
}
