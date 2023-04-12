# Copyright Nova Code (https://www.novacode.nl)
# See LICENSE file for full licensing details.

import logging

from odoo import models
from odoo.tools.safe_eval import wrap_module

_logger = logging.getLogger(__name__)


class IrActionsServer(models.Model):
    _inherit = 'ir.actions.server'

    def _get_eval_context(self, action=None):
        eval_context = super()._get_eval_context(action)
        eval_context['logger'] = _logger
        eval_context['pdb'] = wrap_module(__import__("pdb"), ['set_trace'])
        return eval_context
