# -*- coding: utf-8 -*-
{
    'name': '{{ cookiecutter.module_name }}',
    'summary': '''
        {{ cookiecutter.module_description }}
    ''',
    'category': '{{ cookiecutter.category }}',
    'version': '{{ cookiecutter.odoo_version }}.0.0.1',
    'depends': [
        '{{ cookiecutter.depends }}',
    ],
    'data': [
        # './security/groups.xml',
        # './security/ir.model.access.csv',
    ],
    'assets': {

    },
    'external_dependencies': {
        'python':['{{ cookiecutter.external_dependencies }}'],
    },
    'license': '{{ cookiecutter.license }}',
    'installable': {{ cookiecutter.installable }},
    'application': {{ cookiecutter.application }},
    'auto_install': {{ cookiecutter.auto_install }},
    'author': "{{ cookiecutter.author_name }}",
}

