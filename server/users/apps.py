"""Core app config module."""

import contextlib

from django.apps import AppConfig


class UsersConfig(AppConfig):
    """Core app config."""

    default_auto_field = "django.db.models.BigAutoField"
    name = "users"

    def ready(self) -> None:
        """Signals registration."""
        with contextlib.suppress(Exception):
            from users.signals import register_signals

            register_signals()
        return super().ready()
