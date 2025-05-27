namespace LearningHub.Nhs.MessageQueueProcessor.Services
{
    using System;
    using System.Collections.Generic;
    using System.Threading.Tasks;
    using LearningHub.Nhs.MessageQueueProcessor.Helpers;
    using LearningHub.Nhs.MessageQueueProcessor.Services.Interfaces;
    using LearningHub.Nhs.Models.GovNotifyMessaging;
    using Microsoft.Extensions.Logging;
    using Newtonsoft.Json;

    /// <summary>
    /// The MessageQueueProcessorService.
    /// </summary>
    public class MessageQueueProcessorService : IMessageQueueProcessorService
    {
        private readonly IGovNotifyMessageFacade govNotifyMessageFacade;
        private readonly ILogger<MessageQueueProcessorService> logger;

        /// <summary>
        /// Initializes a new instance of the <see cref="MessageQueueProcessorService"/> class.
        /// </summary>
        /// <param name="govNotifyMessageFacade">govNotifyMessageFacade.</param>
        /// <param name="logger">logger.</param>
        public MessageQueueProcessorService(IGovNotifyMessageFacade govNotifyMessageFacade, ILogger<MessageQueueProcessorService> logger)
        {
            this.govNotifyMessageFacade = govNotifyMessageFacade;
            this.logger = logger;
        }

        /// <summary>
        /// The ProcessQueueAsync.
        /// </summary>
        /// <returns>The response.</returns>
        public async Task ProcessQueueAsync()
        {
            var pendingEmails = await this.govNotifyMessageFacade.GetAsync<List<PendingMessageRequests>>("GovNotifyMessage/PendingMessageRequests");

            foreach (var email in pendingEmails)
            {
                GovNotifyResponse result = null;
                try
                {
                    var emailRequest = new EmailRequest
                    {
                        Recipient = email.Recipient,
                        TemplateId = email.TemplateId,
                        Personalisation = !string.IsNullOrEmpty(email.Personalisation) ? JsonConvert.DeserializeObject<Dictionary<string, dynamic>>(email.Personalisation) : null,
                        Id = email.Id,
                    };

                    result = await this.govNotifyMessageFacade.PostAsync<EmailRequest, GovNotifyResponse>("GovNotifyMessage/SendEmail", emailRequest);
                    result.Id = email.Id;
                }
                catch (Exception ex)
                {
                    this.logger.LogError("Failed to send emails: " + ex.Message);
                }

                try
                {
                    if (result != null)
                    {
                        this.logger.LogInformation("Updating emails status.");
                        if (result.IsSuccess)
                        {
                            await this.govNotifyMessageFacade.PostAsync<GovNotifyResponse, object>("GovNotifyMessage/MessageSuccessUpdate", result);
                        }

                        if (!result.IsSuccess)
                        {
                            await this.govNotifyMessageFacade.PostAsync<GovNotifyResponse, object>("GovNotifyMessage/MessageFailedUpdate", result);
                        }
                    }
                }
                catch (Exception ex)
                {
                    this.logger.LogError($"Failed to update emails status: " + ex.Message);
                }
            }
        }
    }
}
