from http import HTTPStatus

from rest_framework.test import APITestCase

from backend.models import Bucket
from .utils import Utils

class BucketViewSetTestCase(APITestCase):
    user_name = 'testuser'
    user_pass = '123456'

    def setUp(self):
        self.user = Utils.create_test_user(self.user_name, self.user_pass)
        self.client.login(username=self.user_name, password=self.user_pass)

    def test_create_bucket(self):
        """
        Should be able to create a bucket as a user
        """
        payload = {
            'name': 'Test Saving Account',
            'user': self.user.id,
        }
        response = self.client.post('/api/bucket/', payload, format='json')
        self.assertEqual(response.status_code, HTTPStatus.CREATED._value_)
        self.assertIn('id', response.data)
        self.assertEqual(response.data["name"], payload["name"])

    def test_create_bucket_for_another_user(self):
        """
        Should not be able to create a bucket for another user
        """
        user = Utils.create_test_user()
        payload = {
            'name': 'Test Saving Account',
            'user': user.id,
        }
        response = self.client.post('/api/bucket/', payload, format='json')
        self.assertEqual(response.status_code, HTTPStatus.BAD_REQUEST._value_)

    def test_create_bucket_should_validate_user_logged_in(self):
        """
        Should only be able to create buckets when logged in
        """
        self.client.logout()
        payload = {
            'name': 'Test Saving Account',
            'user': self.user.id,
        }
        response = self.client.post('/api/bucket/', payload, format='json')
        self.assertEqual(response.status_code, HTTPStatus.FORBIDDEN._value_)
        # should work after loggin in
        self.client.login(username=self.user_name, password=self.user_pass)
        response = self.client.post('/api/bucket/', payload, format='json')
        self.assertEqual(response.status_code, HTTPStatus.CREATED._value_)

    def test_list_buckets(self):
        """
        Should only be able to list the buckets of the current user
        """
        user_buckets = Utils.create_test_buckets(self.user)
        other_buckets = Utils.create_test_buckets(len=5)
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
        user_buckets = Utils.create_test_buckets(self.user)
        other_buckets = Utils.create_test_buckets()

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
        user_buckets = Utils.create_test_buckets(self.user)

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
        others_buckets = Utils.create_test_buckets()

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
        user_buckets = Utils.create_test_buckets(self.user)

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
        others_buckets = Utils.create_test_buckets()

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
        user1 = Utils.create_test_user()
        buc1 = Utils.create_test_bucket(self.user)

        payload1 = {
            'id': buc1.id,
            'user': user1.id,
        }
        response = self.client.patch(f'/api/bucket/{buc1.id}/', payload1, format='json')
        self.assertEqual(response.status_code, HTTPStatus.BAD_REQUEST._value_)

        buc2 = Utils.create_test_bucket(user1)
        payload2 = {
            'id': buc2.id,
            'user': self.user.id,
        }
        response = self.client.patch(f'/api/bucket/{buc2.id}/', payload2, format='json')
        self.assertEqual(response.status_code, HTTPStatus.NOT_FOUND._value_)

    def test_delete_bucket(self):
        """
        Should be able to delete a bucket, and its goals
        """
        bucket = Utils.create_test_bucket(self.user)
        goal = Utils.create_test_goal(bucket=bucket)

        # test can retrieve created bucket and goal
        response = self.client.get(f'/api/bucket/{bucket.id}/')
        self.assertEqual(response.status_code, HTTPStatus.OK._value_)
        response = self.client.get(f'/api/goal/{goal.id}/')
        self.assertEqual(response.status_code, HTTPStatus.OK._value_)

        response = self.client.delete(f'/api/bucket/{bucket.id}/')
        self.assertEqual(response.status_code, HTTPStatus.NO_CONTENT._value_)

        # test cannot retrieve bucket or goal after bucket is deleted
        response = self.client.get(f'/api/bucket/{bucket.id}/')
        self.assertEqual(response.status_code, HTTPStatus.NOT_FOUND._value_)
        response = self.client.get(f'/api/goal/{goal.id}/')
        self.assertEqual(response.status_code, HTTPStatus.NOT_FOUND._value_)

    def test_cannot_delete_other_users_bucket(self):
        """
        Should not be able to delete another users bucket
        """
        bucket = Utils.create_test_bucket()

        response = self.client.get(f'/api/bucket/{bucket.id}/')
        self.assertEqual(response.status_code, HTTPStatus.NOT_FOUND._value_)

    def test_get_bucket_goals(self):
        """
        Should be able to retrieve the goals of a bucket
        """
        bucket = Utils.create_test_bucket(self.user)
        goals = Utils.create_test_goals(bucket=bucket, len=3)

        response = self.client.get(f'/api/bucket/{bucket.id}/goals/')
        self.assertEqual(response.status_code, HTTPStatus.OK._value_)
        self.assertEqual(len(response.data), len(goals))

    def test_cannot_list_goals_of_other_users_bucket(self):
        """
        Should not be able to list the goals of another users bucket
        """
        bucket = Utils.create_test_bucket()
        goals = Utils.create_test_goals(bucket=bucket, len=3)

        response = self.client.get(f'/api/bucket/{bucket.id}/goals/')
        self.assertEqual(response.status_code, HTTPStatus.NOT_FOUND._value_)
