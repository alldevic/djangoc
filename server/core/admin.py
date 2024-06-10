"""Core app admin."""

from django.contrib import admin
from django.utils.html import format_html
from django.utils.safestring import SafeText
from django.utils.translation import gettext_lazy as _

from core.models import LogEntry


@admin.register(LogEntry)
class LogEntryAdmin(admin.ModelAdmin[LogEntry]):
    """LogEntry admin page."""

    date_hierarchy = "when"
    list_display = ("when", "levelname", "shortmessage")
    list_filter = ("levelname",)
    readonly_fields = (
        "when",
        "levelname",
        "shortmessage",
        "show_message",
        "show_request_repr",
    )
    search_fields = (
        "shortmessage",
        "message",
        "request_repr",
    )

    @admin.display(description=_("Message"))
    def show_message(self, object: LogEntry) -> SafeText:
        """Safety message representation.

        Args:
            object: message instance

        Returns:
            Escaped message representation
        """
        return format_html("<pre>{0}</pre>", object.message)

    @admin.display(description=_("Request representation"))
    def show_request_repr(self, object: LogEntry) -> SafeText:
        """Safety request representation.

        Args:
            object: request instance

        Returns:
            Escaped reuqest representation
        """
        return format_html("<pre>{0}</pre>", object.request_repr)
