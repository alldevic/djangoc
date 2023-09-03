"""MiniO init command."""
from django.conf import settings
from django.core.management.base import BaseCommand
from minio import Minio
from minio_storage.policy import Policy


class Command(BaseCommand):
    """MiniO init command."""

    def __init__(self, *_args, **_kwargs) -> None:
        """Creating client."""
        super().__init__(*_args, **_kwargs)
        self.mclient = Minio(
            endpoint=settings.MINIO_STORAGE_ENDPOINT,
            access_key=settings.MINIO_STORAGE_ACCESS_KEY,
            secret_key=settings.MINIO_STORAGE_SECRET_KEY,
            secure=False,
        )

    def handle(self, *_args, **_options) -> str | None:
        """Init buckets."""
        if not self.mclient.bucket_exists(settings.MINIO_STORAGE_MEDIA_BUCKET_NAME):
            self.mclient.make_bucket(
                bucket_name=settings.MINIO_STORAGE_MEDIA_BUCKET_NAME,
                object_lock=True,
            )
            self.mclient.set_bucket_policy(
                bucket_name=settings.MINIO_STORAGE_MEDIA_BUCKET_NAME,
                policy=Policy(Policy.get).bucket(
                    settings.MINIO_STORAGE_MEDIA_BUCKET_NAME,
                    json_encode=True,
                ),
            )

        if not self.mclient.bucket_exists(settings.MINIO_STORAGE_MEDIA_BACKUP_BUCKET):
            self.mclient.make_bucket(
                bucket_name=settings.MINIO_STORAGE_MEDIA_BACKUP_BUCKET,
                object_lock=False,
            )
            self.mclient.set_bucket_policy(
                bucket_name=settings.MINIO_STORAGE_MEDIA_BACKUP_BUCKET,
                policy=Policy(Policy.get).bucket(
                    settings.MINIO_STORAGE_MEDIA_BACKUP_BUCKET,
                    json_encode=True,
                ),
            )

        print("All buckets:")
        for bucket in self.mclient.list_buckets():
            print(bucket.name)
