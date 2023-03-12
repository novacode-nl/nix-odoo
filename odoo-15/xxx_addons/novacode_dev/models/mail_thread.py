# Copyright Nova Code (https://www.novacode.nl)
# See LICENSE file for full licensing details.

import logging
import traceback

from odoo import api, models

_logger = logging.getLogger(__name__)


class MailThread(models.AbstractModel):
    _inherit = 'mail.thread'

    @api.model
    def message_process(self, model, message, custom_values=None,
                        save_original=False, strip_attachments=False,
                        thread_id=None):
        """ log a traceback when exception """
        try:
            return super().message_process(
                model,
                message,
                custom_values=custom_values,
                save_original=save_original,
                strip_attachments=strip_attachments,
                thread_id=thread_id,
            )
        except Exception as e:
            exc_info = traceback.format_exc()
            _logger.error(e)
            _logger.error(exc_info)
            return
