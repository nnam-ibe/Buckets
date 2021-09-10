from http import HTTPStatus

from rest_framework.test import APITestCase

from backend.models import Bucket, Goal
from .utils import Utils

class GoalViewSetTestCase(APITestCase):
    user_name = 'goaltestuser'
    user_pass = '12345676'

    def setUp(self):
        self.user = Utils.create_test_user(self.user_name, self.user_pass)
        self.client.login(username=self.user_name, password=self.user_pass)

    def test_create_goal(self):
        """
        Should be able to create a goal
        """
        bucket = Utils.create_test_bucket(user=self.user)
        payload = Utils.get_test_goal(bucket=bucket.id)
        response = self.client.post('/api/goal/', payload, format='json')
        self.assertEqual(response.status_code, HTTPStatus.CREATED._value_, msg=response.reason_phrase)
        self.assertIn('id', response.data)
        for key in payload:
            self.assertEqual(response.data[key], payload[key])

    def test_create_goal_should_validate_user(self):
        """
        Should not be able to create a goal for another users bucket
        """
        bucket = Utils.create_test_bucket()
        payload = Utils.get_test_goal()
        response = self.client.post('/api/goal/', payload, format='json')
        self.assertEqual(response.status_code, HTTPStatus.BAD_REQUEST._value_, msg=response.reason_phrase)

    def test_create_goal_should_validate_user_logged_in(self):
        """
        Should only be able to create a goal when logged in
        """
        self.client.logout()
        bucket = Utils.create_test_bucket(user=self.user)
        payload = Utils.get_test_goal(bucket=bucket.id)
        response = self.client.post('/api/goal/', payload, format='json')
        self.assertEqual(response.status_code, HTTPStatus.FORBIDDEN._value_)

        # should work after loggin in
        self.client.login(username=self.user_name, password=self.user_pass)
        response = self.client.post('/api/goal/', payload, format='json')
        self.assertEqual(response.status_code, HTTPStatus.CREATED._value_)

    def test_list_goals(self):
        """
        Should only be able to list the goals of the current user
        """
        user_bucket = Utils.create_test_bucket(user=self.user)
        other_bucket = Utils.create_test_bucket()

        user_goals = Utils.create_test_goals(len=5, bucket=user_bucket)
        other_goals = Utils.create_test_goals(len=3, bucket=other_bucket)

        total_num_of_goals = len(user_goals) + len(other_goals)
        self.assertEqual(Goal.objects.count(), total_num_of_goals)

        response = self.client.get('/api/goal/')
        self.assertEqual(response.status_code, HTTPStatus.OK._value_)
        data = response.data
        self.assertEqual(len(data), len(user_goals))
