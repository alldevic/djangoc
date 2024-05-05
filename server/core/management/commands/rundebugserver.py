"""Override default runserver with debugpy."""

import os
from typing import Any

from django.contrib.staticfiles.management.commands import runserver
from django.core.management.base import CommandParser


class Command(runserver.Command):
    """Extendeed default Django's runserver command."""

    def add_arguments(self, parser: CommandParser) -> None:
        """Entry point for subclassed commands to add custom arguments."""
        super().add_arguments(parser)

        parser.add_argument(
            "--enable-debugger",
            action="store_true",
            dest="enable_debugger",
            help="Enables debugger",
        )

    def run(self, **options: Any) -> None:
        """Command executor."""
        if os.environ.get("RUN_MAIN") or os.environ.get("WERKZEUG_RUN_MAIN"):
            import debugpy

            address = "0.0.0.0"
            port = 5678

            try:
                debugpy.listen(address=(address, port))
                print(f"Debugger: Listening at {address}:{port}")
            except (OSError, RuntimeError):
                print(f"Debugger: Port {port} already in use")

        super().run(**options)
