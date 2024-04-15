"""Core app handlers."""

import logging
from pprint import pformat

from django.utils.encoding import force_str


def build_request_repr(request):
    """Builds and returns the request's representation string.

    The request's attributes may be overridden by pre-processed values.
    """
    # Since this is called as part of error handling, we need to be very
    # robust against potentially malformed input.
    try:
        get = pformat(request.GET)
    except Exception:
        get = "<could not parse>"
    try:
        post = pformat(request.POST)
    except Exception:
        post = "<could not parse>"
    try:
        cookies = pformat(request.COOKIES)
    except Exception:
        cookies = "<could not parse>"
    try:
        meta = pformat(request.META)
    except Exception:
        meta = "<could not parse>"
    return force_str(
        f"<{request.__class__.__name__}\npath:{request.path},\nGET:{get!s},\nPOST:{post!s},\nCOOKIES:{cookies!s},\nMETA:{meta!s}>",
    )


class AdminWatchdogHandler(logging.Handler):
    """An exception log handler that register exception for the site backend."""

    def __init__(self) -> None:
        """AdminWatchdogHandler constructor."""
        logging.Handler.__init__(self)

    def emit(self, record):
        """Raw message parser.

        Args:
            record: raw message representation
        """
        from core.models import LogEntry

        # Get request specific info (location, ...)
        try:
            request = record.request
            request_repr = build_request_repr(request)
        except AttributeError:
            request = None
            request_repr = "unavailable"

        LogEntry(
            levelname=record.levelname,
            shortmessage=record.getMessage(),
            message=self.format(record),
            request_repr=request_repr,
        ).save()
