# Copyright Nova Code (http://www.novacode.nl)
# See LICENSE file for full licensing details.

import logging

from odoo import api, fields, models

_logger = logging.getLogger(__name__)


class Attachment(models.Model):
    _inherit = 'ir.attachment'

    @api.model
    def _file_read(self, fname):
        """ Don't print traceback, which is annoying with database
        without a filestore """

        full_path = self._full_path(fname)
        try:
            with open(full_path, 'rb') as f:
                return f.read()
        except FileNotFoundError as e:
            _logger.info("%s in _read_file: %s", e.__class__.__name__, e)
        except (IOError, OSError):
            _logger.info("%s in _read_file reading %s", e.__class__.__name__, full_path, exc_info=True)
        return b''
