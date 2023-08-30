"""Django settings for djangoc project.

Generated by 'django-admin startproject' using Django 4.2.1.

For more information on this file, see
https://docs.djangoproject.com/en/4.2/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/4.2/ref/settings/
"""

from os import environ
from pathlib import Path
from typing import Any


def get_env(key: str, default: Any | None = None) -> Any | None:  # noqa: ANN401
    """Get Environment variable by key.

    Args:
        key: name of environment variable
        default: Default value if variable is not presented. Defaults to None.

    Returns:
        Value if exist, else default
    """
    val = environ.get(key, default)

    if val in ("True", "true"):
        return True

    if val in ("False", "false"):
        return False

    return val


# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/4.2/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = SECRET_KEY = get_env(
    "DJANGO_SECRET_KEY",
    "django-insecure-n8o!62f3o4heq*&)ajls17@#l%l-_w*=z=yw53zef%*n309hr@",
)

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = get_env("DJANGO_DEBUG", True)

ALLOWED_HOSTS = ALLOWED_HOSTS = [
    get_env("DJANGO_DOMAIN_NAME", "dj.localhost"),
    "localhost",
    "0.0.0.0",
    "127.0.0.1",
    "[::1]",
]


# Application definition

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.admindocs",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "django_celery_beat",
    "django_celery_results",
    "django_jinja",
    "redisboard",
    "core",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.contrib.admindocs.middleware.XViewMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "djangoc.urls"

TEMPLATES = [
    {
        "BACKEND": "django_jinja.backend.Jinja2",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {},
    },
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "djangoc.wsgi.application"


# Database
# https://docs.djangoproject.com/en/4.2/ref/settings/#databases

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": get_env("POSTGRES_DB", "postgres_db"),
        "USER": get_env("POSTGRES_USER", "postgresuser"),
        "PASSWORD": get_env("POSTGRES_PASSWORD", "mysecretpass"),
        "HOST": get_env("POSTGRES_HOST", "localhost"),
        "PORT": 5432,
    },
}


# Password validation
# https://docs.djangoproject.com/en/4.2/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": val,
    }
    for val in (
        "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
        "django.contrib.auth.password_validation.MinimumLengthValidator",
        "django.contrib.auth.password_validation.CommonPasswordValidator",
        "django.contrib.auth.password_validation.NumericPasswordValidator",
    )
]

# Internationalization
# https://docs.djangoproject.com/en/4.2/topics/i18n/

LANGUAGE_CODE: str = get_env("DJANGO_LANGUAGE_CODE", "en-us")

TIME_ZONE: str = get_env("DJANGO_TIME_ZONE", "UTC")

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/4.2/howto/static-files/

STATIC_URL = "static/"
STATIC_ROOT = BASE_DIR.parent / "staticfiles"

MEDIA_URL = "media/"
MEDIA_ROOT = BASE_DIR.parent / "media"

STORAGES = {
    "staticfiles": {
        "BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage",
    },
}

WHITENOISE_KEEP_ONLY_HASHED_FILES = True

APPEND_SLASH = True

# Default primary key field type
# https://docs.djangoproject.com/en/4.2/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.redis.RedisCache",
        "LOCATION": "redis://dj_redis:6379/0",
    },
}

# Celery
CELERY_TIMEZONE = get_env("DJANGO_TIME_ZONE", "UTC")
CELERY_TASK_TRACK_STARTED = True
CELERY_TASK_TIME_LIMIT = 3 * 60
CELERY_RESULT_BACKEND = "django-db"
CELERY_CACHE_BACKEND = "default"
CELERY_BROKER_URL = "redis://dj_redis:6379/1"
CELERY_BROKER_CONNECTION_RETRY_ON_STARTUP = True
CELERY_WORKER_MAX_MEMORY_PER_CHILD = 200_000  # KB

if DEBUG:
    try:
        INSTALLED_APPS.append("debug_toolbar")
        MIDDLEWARE.insert(0, "debug_toolbar.middleware.DebugToolbarMiddleware")

        import socket

        hostname, _, ips = socket.gethostbyname_ex(socket.gethostname())
        INTERNAL_IPS = [ip[: ip.rfind(".")] + ".1" for ip in ips] + [
            "127.0.0.1",
            "10.0.2.2",
        ]
        DEBUG_TOOLBAR_CONFIG = {"SHOW_TOOLBAR_CALLBACK": lambda _request: DEBUG}
    except ImportError:
        pass
