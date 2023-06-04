"""Jinja2 environment module.

More: https://www.webforefront.com/django/setupjinjadataforalltemplates.html
"""

from typing import Any, Self

from django.contrib.staticfiles.storage import staticfiles_storage
from django.urls import reverse
from jinja2 import Environment


class JinjaEnvironment(Environment):
    """Jinja2 environment."""

    def __init__(self: Self, **kwargs: dict[str, Any]) -> None:
        """Jinja2 environment constructor."""
        super().__init__(**kwargs)
        self.globals["static"] = staticfiles_storage.url
        self.globals["url"] = reverse
