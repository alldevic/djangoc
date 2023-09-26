"""Core app views."""

import uuid
from datetime import datetime, timedelta

from django.http import HttpRequest, HttpResponse
from django.shortcuts import render


def index(request: HttpRequest) -> HttpResponse:
    """Hello world view.

    Args:
        request: Request from client

    Returns:
        Rendered response
    """
    context = {}
    tmp = [
        {
            "id": i,
            "key": str(uuid.uuid4()),
            "time": str(datetime.now() + timedelta(minutes=i)),
            "txt": "".join((str(i) * i)[:500]),
        }
        for i in range(1000)
    ]

    context["store"] = {}
    context["store"]["todos"] = tmp

    return render(request, "core/hello_world.html", context)
