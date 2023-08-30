"""Core app models."""

from django.db import models
from django.utils.translation import gettext_lazy as _


class LogEntry(models.Model):
    """LogEntry model."""

    class Meta:
        """LogEntry Meta."""

        verbose_name = _("Log entry")
        verbose_name_plural = _("Log entries")

    when = models.DateTimeField(
        _("When"),
        auto_now_add=True,
        editable=False,
    )
    levelname = models.TextField(
        _("Level name"),
        editable=False,
    )
    shortmessage = models.TextField(
        _("Short message"),
        editable=False,
    )
    message = models.TextField(
        _("Message"),
        editable=False,
    )
    request_repr = models.TextField(
        _("Request representation"),
        editable=False,
    )
