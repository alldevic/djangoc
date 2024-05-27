"""Jinja2 environment module.

More: https://www.webforefront.com/django/setupjinjadataforalltemplates.html
"""

from typing import Any

from django.templatetags.static import static
from django.urls import reverse
from flags.templatetags.feature_flags import flag_disabled, flag_enabled
from jinja2 import Environment, pass_context


class JinjaEnvironment(Environment):
    """Jinja2 environment."""

    def __init__(self, **kwargs: Any) -> None:
        """Jinja2 environment constructor."""
        super().__init__(**kwargs)

        self.globals.update(
            {
                "static": static,
                "url": reverse,
                # django-flags support
                "flag_enabled": pass_context(flag_enabled),
                "flag_disabled": pass_context(flag_disabled),
            }
        )
