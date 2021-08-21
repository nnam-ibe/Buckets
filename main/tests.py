from django.test import TestCase
from django.contrib.auth.models import User
from .models import Bucket

class BucketTestCase(TestCase):
	def setUp(self):
		username = 'testuser'
		password = '123456'
		self.user = User.objects.create_user(username=username, password=password)
		# self.client.login(username=username, password=password)

	def test_create_bucket(self):
		name = 'TD Savings Account'
		bucket = Bucket.objects.create(name=name, user=self.user)
		self.assertEqual(bucket.name, name)
		self.assertEqual(bucket.user, self.user)
		self.assertIsNotNone(bucket.created_date)
		self.assertIsNotNone(bucket.last_modified)

	def test_get_buckets(self):
		print(Bucket.objects.all())
		self.assertIsNotNone(Bucket.objects.get(user=self.user))