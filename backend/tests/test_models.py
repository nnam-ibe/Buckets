from django.test import TestCase

from django.contrib.auth.models import User

from backend.models import Bucket
from backend.models import Goal

class BucketTestCase(TestCase):
    def setUp(self):
        username = 'testuser'
        password = '123456'
        self.user = User.objects.create_user(username=username, password=password)

    def test_create_bucket(self):
        name = 'TD Savings Account'
        bucket = Bucket.objects.create(name=name, user=self.user)
        self.assertEqual(bucket.name, name)
        self.assertEqual(bucket.user, self.user)
        self.assertIsNotNone(bucket.created_date)
        self.assertIsNotNone(bucket.last_modified)
        self.assertIsNotNone(Bucket.objects.get(user=self.user))

    def test_create_goal(self):
        bucket = Bucket.objects.create(name="test name", user=self.user)
        goal_args = {
            "name": "Sample Goal",
            "goal_amount": 399.99,
            "amount_saved": 100,
            "contrib_amount": 50,
            "bucket": bucket,
        }
        goal = Goal.objects.create(**goal_args)

        self.assertIsNotNone(goal.created_date)
        self.assertIsNotNone(goal.last_modified)
        self.assertEqual(goal.auto_update, True)
        self.assertIsNotNone(Goal.objects.get(name=goal_args["name"]))
        self.assertIsNotNone(Goal.objects.get(goal_amount=goal_args["goal_amount"]))
        self.assertIsNotNone(Goal.objects.get(amount_saved=goal_args["amount_saved"]))
        self.assertIsNotNone(Goal.objects.get(contrib_amount=goal_args["contrib_amount"]))
        self.assertIsNotNone(Goal.objects.get(bucket=goal_args["bucket"]))
