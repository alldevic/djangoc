"""Core app views."""

from django.http import HttpRequest, HttpResponse
from django.shortcuts import render


def index(request: HttpRequest) -> HttpResponse:
    """Hello world view.

    Args:
        request: Request from client

    Returns:
        Rendered response
    """
    return render(request, "core/hello_world.html")
