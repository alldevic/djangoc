"""Core app views."""

from django.http import HttpRequest, HttpResponse
from django.shortcuts import render
from django.views.decorators.cache import cache_page


@cache_page(60 * 15)
def index(request: HttpRequest) -> HttpResponse:
    """Hello world view.

    Args:
        request: Request from client

    Returns:
        Rendered response
    """
    return render(request, "core/hello_world.html")
