from http import HTTPStatus
from datetime import timedelta
from django.utils import timezone
from rest_framework.test import APITestCase, APIClient

from business_logic.models import Goal
from business_logic.lib import scheduler
from .utils import Utils


class GoalScheduleTestCase(APITestCase):
    user_name = "goaltestuser"
    user_pass = "12345676"

    @classmethod
    def setUpTestData(cls):
        cls.user = Utils.create_test_user(cls.user_name, cls.user_pass)
        login_payload = {
            "username": cls.user_name,
            "password": cls.user_pass,
        }
        client = APIClient()
        res = client.post("/api/auth/login", login_payload, format="json")
        cls.token = res.data["token"]
        cls.header_token = {"HTTP_AUTHORIZATION": f"Token {cls.token}"}

    def test_create_goal_schedule(self):
        """
        Schedule should be created for auto_update goals
        """
        bucket = Utils.create_test_bucket(user=self.user)
        payload = Utils.get_test_goal(
            bucket=bucket.id, auto_update=True, contrib_frequency="MONTHLY"
        )
        response = self.client.post(
            "/api/goal/", payload, format="json", **self.header_token
        )
        self.assertEqual(
            response.status_code, HTTPStatus.CREATED._value_, msg=response.reason_phrase
        )
        goal_id = response.data["id"]
        self.assertIsNotNone(goal_id)

        schedule = scheduler.retrieve_schedule(goal_id)
        self.assertEqual(str(goal_id), schedule.name)
        self.assertEqual(str(goal_id), schedule.args)
        self.assertEqual(
            scheduler.get_schedule_type(Goal.MONTHLY), schedule.schedule_type
        )
        self.assertEqual(schedule.repeats, 1)
        self.assertIsNotNone(schedule.next_run)

    def test_should_not_create_schedule(self):
        """
        Should not create schedule for goals that are not auto_update=True
        """
        bucket = Utils.create_test_bucket(user=self.user)
        payload = Utils.get_test_goal(
            bucket=bucket.id, auto_update=False, contrib_frequency="NA"
        )
        response = self.client.post(
            "/api/goal/", payload, format="json", **self.header_token
        )
        self.assertEqual(
            response.status_code, HTTPStatus.CREATED._value_, msg=response.reason_phrase
        )
        goal_id = response.data["id"]
        schedule = scheduler.retrieve_schedule(goal_id)
        self.assertIsNone(schedule)

    def test_goal_schedule_is_updated(self):
        """
        Should update goal schedule when the goal is updated.
        """
        now = timezone.now()
        bucket = Utils.create_test_bucket(user=self.user)
        payload = Utils.get_test_goal(
            bucket=bucket.id, auto_update=True, contrib_frequency="MONTHLY"
        )
        response = self.client.post(
            "/api/goal/", payload, format="json", **self.header_token
        )
        self.assertEqual(
            response.status_code, HTTPStatus.CREATED._value_, msg=response.reason_phrase
        )
        goal_id = response.data["id"]
        schedule = scheduler.retrieve_schedule(goal_id)
        self.assertEqual(
            scheduler.get_schedule_type(Goal.MONTHLY), schedule.schedule_type
        )
        self.assertTrue(now + timedelta(days=32) > schedule.next_run)

        # change contrib_frequency to yearly
        payload = {
            "id": goal_id,
            "contrib_frequency": "YEARLY",
        }
        response = self.client.patch(
            f"/api/goal/{goal_id}/", payload, format="json", **self.header_token
        )

        schedule = scheduler.retrieve_schedule(goal_id)
        self.assertEqual(
            scheduler.get_schedule_type(Goal.YEARLY), schedule.schedule_type
        )
        self.assertTrue(
            now + timedelta(days=360) < schedule.next_run, schedule.next_run
        )

    def test_goal_schedule_should_be_deleted(self):
        """
        Should delete goal's schedule when the goal is deleted
        """
        bucket = Utils.create_test_bucket(user=self.user)
        payload = Utils.get_test_goal(
            bucket=bucket.id, auto_update=True, contrib_frequency="MONTHLY"
        )
        response = self.client.post(
            "/api/goal/", payload, format="json", **self.header_token
        )
        self.assertEqual(
            response.status_code, HTTPStatus.CREATED._value_, msg=response.reason_phrase
        )
        goal_id = response.data["id"]
        schedule = scheduler.retrieve_schedule(goal_id)
        self.assertEqual(
            scheduler.get_schedule_type(Goal.MONTHLY), schedule.schedule_type
        )

        response = self.client.delete(f"/api/goal/{goal_id}/", **self.header_token)
        schedule = scheduler.retrieve_schedule(goal_id)
        self.assertIsNone(schedule)

    def test_goal_next_run_date(self):
        """
        Scheduled next run date should be within acceptable range
        """
        now = timezone.now()
        bucket = Utils.create_test_bucket(user=self.user)
        weekly_payload = Utils.get_test_goal(
            bucket=bucket.id, auto_update=True, contrib_frequency="WEEKLY"
        )
        monthly_payload = Utils.get_test_goal(
            bucket=bucket.id, auto_update=True, contrib_frequency="MONTHLY"
        )
        quarterly_payload = Utils.get_test_goal(
            bucket=bucket.id, auto_update=True, contrib_frequency="QUARTERLY"
        )
        yearly_payload = Utils.get_test_goal(
            bucket=bucket.id, auto_update=True, contrib_frequency="YEARLY"
        )

        response = self.client.post(
            "/api/goal/", weekly_payload, format="json", **self.header_token
        )
        goal_id = response.data["id"]
        weekly_schedule = scheduler.retrieve_schedule(goal_id)
        self.assertEqual(
            scheduler.get_schedule_type(Goal.WEEKLY), weekly_schedule.schedule_type
        )
        self.assertTrue(now + timedelta(days=7) < weekly_schedule.next_run)
        self.assertTrue(now + timedelta(days=8) > weekly_schedule.next_run)

        response = self.client.post(
            "/api/goal/", monthly_payload, format="json", **self.header_token
        )
        goal_id = response.data["id"]
        monthly_schedule = scheduler.retrieve_schedule(goal_id)
        self.assertEqual(
            scheduler.get_schedule_type(Goal.MONTHLY), monthly_schedule.schedule_type
        )
        self.assertTrue(now + timedelta(days=28) < monthly_schedule.next_run)
        self.assertTrue(now + timedelta(days=32) > monthly_schedule.next_run)

        response = self.client.post(
            "/api/goal/", quarterly_payload, format="json", **self.header_token
        )
        goal_id = response.data["id"]
        quarterly_schedule = scheduler.retrieve_schedule(goal_id)
        self.assertEqual(
            scheduler.get_schedule_type(Goal.QUARTERLY),
            quarterly_schedule.schedule_type,
        )
        self.assertTrue(now + timedelta(days=89) < quarterly_schedule.next_run)
        self.assertTrue(now + timedelta(days=92) > quarterly_schedule.next_run)

        response = self.client.post(
            "/api/goal/", yearly_payload, format="json", **self.header_token
        )
        goal_id = response.data["id"]
        yearly_schedule = scheduler.retrieve_schedule(goal_id)
        self.assertEqual(
            scheduler.get_schedule_type(Goal.YEARLY), yearly_schedule.schedule_type
        )
        self.assertTrue(now + timedelta(days=365) < yearly_schedule.next_run)
        self.assertTrue(now + timedelta(days=367) > yearly_schedule.next_run)
