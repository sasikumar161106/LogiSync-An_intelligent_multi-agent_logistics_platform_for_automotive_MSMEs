"""
Notification Service
Handles sending SMS and WhatsApp messages for critical alerts via Twilio.
"""
import logging
from app.config import get_settings

logger = logging.getLogger(__name__)

class NotificationService:
    def __init__(self):
        self.settings = get_settings()
        self.enabled = bool(self.settings.twilio_account_sid and self.settings.twilio_auth_token)
        
        if self.enabled:
            try:
                from twilio.rest import Client
                self.client = Client(self.settings.twilio_account_sid, self.settings.twilio_auth_token)
            except ImportError:
                logger.warning("twilio package not installed. Notifications will be stubbed.")
                self.enabled = False

    def send_whatsapp_alert(self, title: str, description: str, severity: str) -> bool:
        """
        Send a WhatsApp alert to the manager.
        """
        if not self.settings.manager_phone_number:
            logger.warning("No manager_phone_number configured. Skipping WhatsApp alert.")
            return False

        message_body = (
            f"🚨 *LogiSync Alert [{severity.upper()}]*\n\n"
            f"*{title}*\n\n"
            f"{description}\n\n"
            f"Please check the LogiSync dashboard to approve or reject the recommended action."
        )

        if not self.enabled:
            # Stubbed output when credentials are not configured
            logger.info("--- [STUB] SENDING WHATSAPP NOTIFICATION ---")
            logger.info(f"To: {self.settings.manager_phone_number or 'Unconfigured'}")
            logger.info(f"Body:\n{message_body}")
            logger.info("--------------------------------------------")
            return True

        try:
            message = self.client.messages.create(
                body=message_body,
                from_=f"whatsapp:{self.settings.twilio_from_number}",
                to=f"whatsapp:{self.settings.manager_phone_number}"
            )
            logger.info(f"WhatsApp alert sent successfully. SID: {message.sid}")
            return True
        except Exception as e:
            logger.error(f"Failed to send WhatsApp alert: {e}")
            return False
