import json
from http import HTTPStatus

from django.contrib.auth.models import User

from rest_framework.test import APITestCase

class BucketViewSetTestCase(APITestCase):
    def setUp(self):
        username = 'testuser'
        password = '123456'
        self.user = User.objects.create_user(username=username, password=password)
        self.client.login(username=username, password=password)

    def test_get_buckets(self):
        response = self.client.get('/api/bucket/')
        self.assertEqual(response.status_code, HTTPStatus.OK._value_)

    def test_create_bucket_should_validate_user(self):
        self.client.logout()
        bucket_data = {
            'name': 'Test Saving Account',
            'user': self.user.id,
        }
        response = self.client.post('/api/bucket/', bucket_data, format='json')
        self.assertEqual(response.status_code, HTTPStatus.BAD_REQUEST._value_)

    def test_create_bucket(self):
        bucket_data = {
            'name': 'Test Saving Account',
            'user': self.user.id,
        }
        response = self.client.post('/api/bucket/', bucket_data, format='json')
        self.assertEqual(response.status_code, HTTPStatus.CREATED._value_)
        self.assertEqual(response.data["name"], bucket_data["name"])