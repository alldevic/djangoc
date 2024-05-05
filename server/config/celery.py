"""Celery config."""

import os

from celery import Celery
from celery.app.task import Task

Task.__class_getitem__ = classmethod(lambda cls, *_args, **_kwargs: cls)  # type: ignore[attr-defined]

# Set the default Django settings module for the 'celery' program.
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

app = Celery("config")

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
# - namespace='CELERY' means all celery-related configuration keys
#   should have a `CELERY_` prefix.
app.config_from_object("django.conf:settings", namespace="CELERY")

# Load task modules from all registered Django apps.
app.autodiscover_tasks()


@app.task(bind=True, ignore_result=False)
def debug_task(self: Task[[], str]) -> str:
    """Test task.

    Args:
        self: request
    """
    print(f"Request: {self.request!r}")
    return str(self.request)
