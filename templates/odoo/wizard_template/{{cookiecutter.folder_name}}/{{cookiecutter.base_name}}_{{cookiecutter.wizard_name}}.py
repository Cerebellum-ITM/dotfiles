# -*- coding: utf-8 -*-
from ..tools.logger_config import configure_logger

from odoo import api, models, fields, _
from odoo.exceptions import UserError, ValidationError

_logger = configure_logger()

class {{ cookiecutter.base_name.capitalize() }}{{ cookiecutter.wizard_name.capitalize() }}Wizard(models.TransientModel):
    """ 
        Wizard allowing to import a BOM from a CSV file
    """
    _name = '{{ cookiecutter.base_name }}.{{ cookiecutter.wizard_name }}.wizard'
    _description = "{{ cookiecutter.description }}"
