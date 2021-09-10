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

    def test_retrieve_goals(self):
        """
        Should only be able to retrieve the goals of the current user
        """
        user_bucket = Utils.create_test_bucket(user=self.user)
        other_bucket = Utils.create_test_bucket()
        user_goals = Utils.create_test_goals(len=5, bucket=user_bucket)
        other_goals = Utils.create_test_goals(len=3, bucket=other_bucket)

        for goal in user_goals:
            response = self.client.get(f'/api/goal/{goal.id}/')
            self.assertEqual(response.status_code, HTTPStatus.OK._value_)

        for goal in other_goals:
            response = self.client.get(f'/api/goal/{goal.id}/')
            self.assertEqual(response.status_code, HTTPStatus.NOT_FOUND._value_)

    def test_patch_goal(self):
        """
        Should be able to update own goals
        """
        user_bucket = Utils.create_test_bucket(user=self.user)
        user_goals = Utils.create_test_goals(len=5, bucket=user_bucket)

        for goal in user_goals:
            payload = {
                'id': goal.id,
                'name': Utils.get_random_string(),
            }
            response = self.client.patch(f'/api/goal/{goal.id}/', payload, format='json')
            self.assertEqual(response.status_code, HTTPStatus.OK._value_)
            self.assertEqual(response.data['id'], goal.id)
            self.assertEqual(response.data['name'], payload['name'])

    def test_patch_bucket_should_validate_user(self):
        """
        Should not be able to update others goals
        """
        other_bucket = Utils.create_test_bucket()
        other_goals = Utils.create_test_goals(len=3, bucket=other_bucket)

        for goal in other_goals:
            payload = payload = {
                'id': goal.id,
                'name': Utils.get_random_string(),
            }
            response = self.client.patch(f'/api/goal/{goal.id}/', payload, format='json')
            self.assertEqual(response.status_code, HTTPStatus.NOT_FOUND._value_)

    def test_put_goal(self):
        """
        Should be able to put own goals
        """
        user_bucket = Utils.create_test_bucket(user=self.user)
        user_goals = Utils.create_test_goals(len=5, bucket=user_bucket)

        for goal in user_goals:
            payload = Utils.get_test_goal(id=goal.id, bucket=user_bucket.id)
            response = self.client.put(f'/api/goal/{goal.id}/', payload, format='json')
            self.assertEqual(response.status_code, HTTPStatus.OK._value_)
            self.assertEqual(response.data['id'], goal.id)
            self.assertEqual(response.data['name'], payload['name'])

    def test_put_goal_should_validate_user(self):
        """
        Should not be able to update others goals
        """
        other_bucket = Utils.create_test_bucket()
        other_goals = Utils.create_test_goals(len=3, bucket=other_bucket)

        for goal in other_goals:
            payload = Utils.get_test_goal(id=goal.id, bucket=other_bucket.id)
            response = self.client.put(f'/api/goal/{goal.id}/', payload, format='json')
            self.assertEqual(response.status_code, HTTPStatus.NOT_FOUND._value_)

    def test_change_goal_bucket(self):
        """
        Should be able to change a goals bucket
        """
        # TODO: the flip side is should not be able to move to another users bucket
        user_buckets = Utils.create_test_buckets(user=self.user, len=2)
        goal1 = Utils.create_test_goal(bucket=user_buckets[0])
        goal2 = Utils.create_test_goal(bucket=user_buckets[1])

        # move goal1 to the second bucket
        payload1 = Utils.get_test_goal(id=goal1.id, bucket=user_buckets[1].id)
        response = self.client.patch(f'/api/goal/{goal1.id}/', payload1, format='json')
        self.assertEqual(response.status_code, HTTPStatus.OK._value_)
