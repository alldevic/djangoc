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


class Person(models.Model):
    """This is a demo person model."""

    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50)
    date_of_birth = models.DateField()
    picture = models.ImageField(upload_to="person_pics")

    def __str__(self):
        """Default text representaion."""
        return f"{self.first_name} {self.last_name} {self.date_of_birth!s}"
