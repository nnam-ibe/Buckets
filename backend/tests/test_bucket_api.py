from http import HTTPStatus

from rest_framework.test import APITestCase

from backend.models import Bucket
from .utils import Utils

class BucketViewSetTestCase(APITestCase):
    user_name = 'testuser'
    user_pass = '123456'

    def setUp(self):
        self.user = Utils.create_sample_user(self.user_name, self.user_pass)
        self.client.login(username=self.user_name, password=self.user_pass)

    def test_create_bucket(self):
        """
        Should be able to create a bucket as a user
        """
        bucket_data = {
            'name': 'Test Saving Account',
            'user': self.user.id,
        }
        response = self.client.post('/api/bucket/', bucket_data, format='json')
        self.assertEqual(response.status_code, HTTPStatus.CREATED._value_)
        self.assertEqual(response.data["name"], bucket_data["name"])

    def test_create_bucket_should_validate_user(self):
        """
        Should only be able to create buckets when logged in
        """
        self.client.logout()
        bucket_data = {
            'name': 'Test Saving Account',
            'user': self.user.id,
        }
        response = self.client.post('/api/bucket/', bucket_data, format='json')
        self.assertEqual(response.status_code, HTTPStatus.FORBIDDEN._value_)
        # clean up
        self.client.login(username=self.user_name, password=self.user_pass)

    def test_list_buckets(self):
        """
        Should only be able to list the buckets of the current user
        """
        user_buckets = Utils.create_sample_buckets(self.user)
        other_buckets = Utils.create_sample_buckets(len=5)
        total_num_of_buckets = len(user_buckets) + len(other_buckets)
        self.assertEqual(Bucket.objects.count(), total_num_of_buckets)

        response = self.client.get('/api/bucket/')
        self.assertEqual(response.status_code, HTTPStatus.OK._value_)
        data = response.data
        self.assertEqual(len(data), len(user_buckets))

    def test_retrieve_bucket(self):
        """
        Should only be able to retrieve the buckets of the current user
        """
        user_buckets = Utils.create_sample_buckets(self.user)
        other_buckets = Utils.create_sample_buckets()

        for buc in user_buckets:
            response = self.client.get(f'/api/bucket/{buc.id}/')
            self.assertEqual(response.status_code, HTTPStatus.OK._value_)

        for buc in other_buckets:
            response = self.client.get(f'/api/bucket/{buc.id}/')
            self.assertEqual(response.status_code, HTTPStatus.NOT_FOUND._value_)

    def test_patch_bucket(self):
        """
        Should be able to update own buckets
        """
        user_buckets = Utils.create_sample_buckets(self.user)

        for buc in user_buckets:
            payload = {
                'id': buc.id,
                'name': Utils.get_random_string(),
            }
            response = self.client.patch(f'/api/bucket/{buc.id}/', payload, format='json')
            self.assertEqual(response.status_code, HTTPStatus.OK._value_)
            self.assertEqual(response.data['id'], buc.id)
            self.assertEqual(response.data['name'], payload['name'])
            self.assertEqual(response.data['user'], buc.user.id)

    def test_patch_bucket_should_validate_user(self):
        """
        Should not be able to update others buckets
        """
        others_buckets = Utils.create_sample_buckets()

        for buc in others_buckets:
            payload = {
                'id': buc.id,
                'name': Utils.get_random_string(),
            }
            response = self.client.patch(f'/api/bucket/{buc.id}/', payload, format='json')
            self.assertEqual(response.status_code, HTTPStatus.NOT_FOUND._value_)

    def test_put_bucket(self):
        """
        Should be able to put own buckets
        """
        user_buckets = Utils.create_sample_buckets(self.user)

        for buc in user_buckets:
            payload = {
                'id': buc.id,
                'name': Utils.get_random_string(),
                'user': self.user.id,
            }
            response = self.client.put(f'/api/bucket/{buc.id}/', payload, format='json')
            self.assertEqual(response.status_code, HTTPStatus.OK._value_)
            self.assertEqual(response.data['id'], buc.id)
            self.assertEqual(response.data['name'], payload['name'])
            self.assertEqual(response.data['user'], buc.user.id)

    def test_put_bucket_should_validate_user(self):
        """
        Should not be able to update others buckets
        """
        others_buckets = Utils.create_sample_buckets()

        for buc in others_buckets:
            payload = {
                'id': buc.id,
                'name': Utils.get_random_string(),
                'user': self.user.id,
            }
            response = self.client.put(f'/api/bucket/{buc.id}/', payload, format='json')
            self.assertEqual(response.status_code, HTTPStatus.NOT_FOUND._value_)

    def test_cannot_change_bucket_user(self):
        """
        Should not be able to change a bucket's user
        """
        user1 = Utils.create_sample_user()
        buc1 = Utils.create_sample_bucket(self.user)

        payload1 = {
            'id': buc1.id,
            'user': user1.id,
        }
        response = self.client.patch(f'/api/bucket/{buc1.id}/', payload1, format='json')
        self.assertEqual(response.status_code, HTTPStatus.NOT_FOUND._value_)

        buc2 = Utils.create_sample_bucket(user1)
        payload2 = {
            'id': buc2.id,
            'user': self.user.id,
        }
        response = self.client.patch(f'/api/bucket/{buc2.id}/', payload2, format='json')
        self.assertEqual(response.status_code, HTTPStatus.NOT_FOUND._value_)