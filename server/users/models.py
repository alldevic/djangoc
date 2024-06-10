"""Users models."""

from typing import Any, ClassVar

from django.conf import settings
from django.contrib.auth.models import AbstractUser, UserManager
from django.db import models

from . import consts


class CustomUserManager(UserManager["User"]):
    """Custom UserManager with unique identifier is email instead of username."""

    def create_user(
        self,
        username: str,
        email: str | None = None,
        password: str | None = None,
        **_extra_fields: Any,
    ) -> "User":
        """Create and return a User with username, email, and password."""
        if email is None:
            raise ValueError(consts.ERROR_EMAIL_REQUIRED)
        if username is None:
            raise ValueError(consts.ERROR_USERNAME_REQUIRED)

        email = self.normalize_email(email)
        user = self.model(username=username, email=email)
        user.set_password(password)
        user.save()

        return user

    def create_superuser(
        self,
        username: str,
        email: str | None = None,
        password: str | None = None,
        **_extra_fields: Any,
    ) -> "User":
        """Create and return a SuperUser with admin permissions."""
        user = self.create_user(username, email, password)
        user.is_staff = True
        user.is_superuser = True
        user.is_active = True
        user.save()

        return user


class User(AbstractUser):
    """Custom user model."""

    username = models.CharField(max_length=255, unique=True)
    email = models.EmailField(unique=True)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS: ClassVar[list[str]] = [
        "username",
    ]

    objects: ClassVar[UserManager["User"]] = CustomUserManager()

    def __str__(self) -> str:
        """String representation."""
        return self.email


class Profile(models.Model):
    """Profile model associated to each User object."""

    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    image = models.URLField(
        default="https://static.productionready.io/images/smiley-cyrus.jpg"
    )
    bio = models.TextField(max_length=1000, blank=True)

    def __str__(self) -> str:
        """String representation."""
        return self.user.username
