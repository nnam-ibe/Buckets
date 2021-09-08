from http import HTTPStatus

from rest_framework.test import APITestCase

from backend.models import Bucket, Goal
from .utils import Utils

class GoalViewSetTestCase(APITestCase):
    user_name = 'testuser'
    user_pass = '123456'

    def setUp(self):
        self.user = Utils.create_sample_user(self.user_name, self.user_pass)
        self.client.login(username=self.user_name, password=self.user_pass)

    def test_create_goal(self):
        """
        Should be able to create a goal
        """
        bucket = Utils.create_sample_bucket()
        payload = {
            'name': 'Test Phone',
            'bucket': bucket.id,
            'goal_amount': '500.00',
            'amount_saved': '20.00',
            'contrib_amount': '30.00',
            'contrib_frequeny': 'MONTHLY',
        }
        response = self.client.post('/api/goal/', payload, format='json')
        self.assertEqual(response.status_code, HTTPStatus.CREATED._value_)
        self.assertIn('id', response.data)
        for key in payload:
            self.assertEqual(response.data[key], payload[key])