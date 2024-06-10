"""Admin panel integrations."""

from django.contrib import admin

from .models import Profile, User


class ProfileInline(admin.StackedInline[Profile, User]):
    """Profile widget."""

    model = Profile
    can_delete = False


class UserAdmin(admin.ModelAdmin[User]):
    """User admin page."""

    inlines = (ProfileInline,)


admin.site.register(User, UserAdmin)
