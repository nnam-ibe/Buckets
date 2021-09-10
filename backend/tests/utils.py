import random
import string

from django.contrib.auth.models import User

from backend.models import Bucket, Goal

class Utils:
    @staticmethod
    def get_random_string(len=8):
        letters = string.ascii_lowercase
        rand_str = ''.join(random.choice(letters) for i in range(len))
        return rand_str

    @staticmethod
    def create_test_user(username=None, password=None):
        if username is None:
            username = Utils.get_random_string()
        if password is None:
            password = Utils.get_random_string()

        user = User.objects.create_user(username=username, password=password)
        return user

    @staticmethod
    def create_test_bucket(user=None):
        if user is None:
            user = Utils.create_test_user()

        bucket_attr = {
            "name": Utils.get_random_string(),
            "user": user,
        }
        bucket = Bucket.objects.create(**bucket_attr)
        return bucket

    @staticmethod
    def create_test_buckets(user=None, len=3):
        if user is None:
            user = Utils.create_test_user()

        buckets = []
        for i in range(len):
            buckets.append(Utils.create_test_bucket(user))

        return buckets

    @staticmethod
    def get_test_goal(**kwargs):
        via_api = kwargs.get('via_api', True)
        goal = {
            'name': kwargs.get('name', Utils.get_random_string()),
            'goal_amount': kwargs.get('goal_amount', '500.00'),
            'amount_saved': kwargs.get('amount_saved', '20.00'),
            'contrib_amount': kwargs.get('contrib_amount', '30.00'),
            'contrib_frequeny': kwargs.get('contrib_frequeny', 'MONTHLY'),
            'bucket': kwargs.get('bucket',
                Utils.create_test_bucket().id if via_api else Utils.create_test_bucket()),
        }
        goal_id = kwargs.get('id', None)
        if goal_id is not None:
            goal['id'] = goal_id
        return goal

    @staticmethod
    def create_test_goal(**kwargs):
        goal_attrs = Utils.get_test_goal(**kwargs)
        return Goal.objects.create(**goal_attrs)

    @staticmethod
    def create_test_goals(len=3, **kwargs):
        goals = []
        for i in range(len):
            goals.append(Utils.create_test_goal(**kwargs))
        return goals