"""Signals for users app."""

from typing import Any

from django.contrib.auth import get_user_model
from django.db.models.base import Model
from django.db.models.signals import post_save

from .models import Profile


def register_signals() -> None:
    """Signal registration."""
    post_save.connect(create_profile_for_user, sender=get_user_model())
    post_save.connect(save_profile_for_user, sender=get_user_model())


def create_profile_for_user(
    sender: type[Model] | str | None,  # noqa: ARG001
    instance: Any,
    created: bool,
    **_kwargs: Any,
) -> None:
    """Create new profile with new user."""
    if created:
        Profile.objects.create(user=instance)


def save_profile_for_user(
    sender: type[Model] | str | None,  # noqa: ARG001
    instance: Any,
    **_kwargs: Any,
) -> None:
    """Update profile on user edit."""
    instance.profile.save()
