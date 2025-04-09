import os
import inspect as py_inspect
from typing import Any, Optional
from rich import inspect
from rich.console import Console
from rich.pretty import pretty_repr
from rich.logging import RichHandler
from loguru import logger as _logger  # type: ignore

console = Console(width=200, log_time=False, log_path=False)


def rlog(value: Any) -> None:
    """
    Print the variable in the log using print formatter from the rich library
    """
    frame = py_inspect.currentframe()
    if frame is not None:
        caller_frame = frame.f_back
        if caller_frame is not None:
            caller_info = py_inspect.getframeinfo(caller_frame)
            file_name = caller_info.filename.replace("/mnt/extra-addons/", "").replace(
                "/home/odoo/src/user/", ""
            )
            code_context = ""
            if caller_info.code_context:
                code_context = [
                    line.split("#")[0].strip()
                    for line in caller_info.code_context
                    if line
                ]
            function_name = caller_info.function
            line_number = caller_info.lineno
            _logger.debug(
                f"{file_name}:{function_name}:{line_number} - Context:{code_context}"
            )
            del frame
    _logger.debug(pretty_repr(value))


def rich_inspect(value: Any) -> None:
    """
    Prints the result of using inspect from the rich library to the logs
    """
    odoo_log_path = "/home/odoo/logs/odoo.log"
    if not os.path.exists(odoo_log_path):
        inspect(value)
    else:
        _logger.debug(value)


def _log_formatter(record: dict) -> str:
    """Log message formatter"""
    color_map = {
        "TRACE": "dim blue",
        "DEBUG": "dark_magenta",
        "INFO": "bold",
        "SUCCESS": "bold green",
        "WARNING": "gold1",
        "ERROR": "bold red",
        "CRITICAL": "bold white on red",
    }
    lvl_color = color_map.get(record["level"].name, "bold")
    return (
        f"[not bold green]{{time:YYYY/MM/DD HH:mm:ss.SSS}}[/not bold green] | [{lvl_color}]{{level}}[/{lvl_color}] | "
        + f"[thistle1]{{name}}[/thistle1]:[{lvl_color}]{{function}}[/{lvl_color}]:[{lvl_color}]{{line}}[/{lvl_color}] - [{lvl_color}]{{message}}[/{lvl_color}]"
    )


def configure_logger(log_format: Optional[str] = None):
    """
    Set up the logger to display messages in the console.
    :param log_format: The default log message format is: "<level>{time:YYYY-MM-DD HH:mm:ss.SSS}</level> | <level>{level: <8}</level> | <level>{name}</level>:<level>{function}</level>:<level>{line}</level> - <level>{message}</level>"
    :return: logger
    """

    _logger.remove()
    odoo_log_path = "/home/odoo/logs/odoo.log"
    if not os.path.exists(odoo_log_path):
        if not log_format:
            log_format = "{message}"
        _logger.add(
            RichHandler(
                markup=True,
                console=console,
                show_path=False,
                show_time=False,
                show_level=False,
                rich_tracebacks=True,
                tracebacks_width=300,
                tracebacks_show_locals=True,
            ),
            format=_log_formatter,
            catch=True,
            colorize=True,
        )
    else:
        if not log_format:
            log_format = "<level>{time:YYYY-MM-DD HH:mm:ss.SSS}</level> | <level>{level: <8}</level> | <level>{name}</level>:<level>{function}</level>:<level>{line}</level> - <level>{message}</level>"
        _logger.add(odoo_log_path, format=log_format, catch=True, colorize=True)
    return _logger

