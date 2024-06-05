"""Jinja2 environment module.

More: https://www.webforefront.com/django/setupjinjadataforalltemplates.html
"""

from typing import Any

from django.contrib.staticfiles.storage import staticfiles_storage
from django.urls import reverse
from jinja2 import Environment


class JinjaEnvironment(Environment):
    """Jinja2 environment."""

    def __init__(self, **kwargs: Any) -> None:
        """Jinja2 environment constructor."""
        super().__init__(**kwargs)

        self.globals.update(
            {
                "static": staticfiles_storage.url,
                "url": reverse,
            }
        )
