import random
import string

from django.contrib.auth.models import User

from backend.models import Bucket

class Utils:
    @staticmethod
    def create_sample_user(username=None, password=None):
        if username is None:
            username = Utils.get_random_string()
        if password is None:
            password = Utils.get_random_string()

        user = User.objects.create_user(username=username, password=password)
        return user

    @staticmethod
    def create_sample_bucket(user=None):
        if user is None:
            user = Utils.create_sample_user()

        bucket_attr = {
            "name": Utils.get_random_string(),
            "user": user,
        }
        bucket = Bucket.objects.create(**bucket_attr)
        return bucket

    @staticmethod
    def create_sample_buckets(user=None, len=3):
        if user is None:
            user = Utils.create_sample_user()

        buckets = []
        for i in range(len):
            buckets.append(Utils.create_sample_bucket(user))

        return buckets

    @staticmethod
    def get_random_string(len=8):
        letters = string.ascii_lowercase
        rand_str = ''.join(random.choice(letters) for i in range(len))
        return rand_str