from http import HTTPStatus

from rest_framework.test import APITestCase

from business_logic.tests.utils import Utils


class AuthenticationAPITestCase(APITestCase):
    def test_register_user(self):
        """
        Should be able to create a user via the api
        """
        payload = Utils.get_test_user_credentials()
        response = self.client.post("/api/auth/register", payload, format="json")
        self.assertEqual(response.status_code, HTTPStatus.OK._value_)

        # assert the response contains user and token info
        self.assertIn("token", response.data)
        self.assertIn("user", response.data)
        registered_user = response.data.get("user")
        self.assertIn("id", registered_user)
        self.assertIn("username", registered_user)
        self.assertEqual(registered_user["username"], payload["username"])
        self.assertIn("email", registered_user)
        self.assertEqual(registered_user["email"], payload["email"])
        self.assertNotIn("password", registered_user)

    def test_user_login(self):
        """
        Should be able to login with a created user
        """
        credentials = Utils.get_test_user_credentials()
        self.client.post("/api/auth/register", credentials, format="json")

        payload = {
            "username": credentials.get("username"),
            "password": credentials.get("password"),
        }
        response = self.client.post("/api/auth/login", payload, format="json")
        self.assertEqual(response.status_code, HTTPStatus.OK._value_)
        self.assertIn("token", response.data)
        logged_in_user = response.data.get("user")
        self.assertIn("id", logged_in_user)
        self.assertIn("username", logged_in_user)
        self.assertEqual(logged_in_user["username"], payload["username"])
        self.assertIn("email", logged_in_user, logged_in_user)
        self.assertNotIn("password", logged_in_user)

    def test_incorrect_credentials(self):
        """
        Should not be able to login with incorrect credentials
        """
        credentials = Utils.get_test_user_credentials()
        self.client.post("/api/auth/register", credentials, format="json")

        payload = {
            "username": credentials.get("username"),
            "password": "incorrect password",
        }
        response = self.client.post("/api/auth/login", payload, format="json")
        self.assertEqual(response.status_code, HTTPStatus.BAD_REQUEST._value_)

    def test_get_user_via_token(self):
        """
        Should be able to get a user via their auth token
        """
        credentials = Utils.get_test_user_credentials()
        res = self.client.post("/api/auth/register", credentials, format="json")

        self.assertIn("token", res.data)
        token = res.data.get("token")

        response = self.client.get(
            "/api/auth/user", format="json", HTTP_AUTHORIZATION=f"Token {token}"
        )
        self.assertEqual(response.status_code, HTTPStatus.OK._value_)
        self.assertIn("id", response.data)
        self.assertIn("username", response.data)
        self.assertEqual(response.data["username"], credentials["username"])
        self.assertIn("email", response.data, response.data)
        self.assertEqual(response.data["email"], credentials["email"])
        self.assertNotIn("password", response.data)

    def test_user_logout(self):
        """
        Should be able to logout via the api, and the session token should be destroyed
        """
        credentials = Utils.get_test_user_credentials()
        login_payload = {
            "username": credentials.get("username"),
            "password": credentials.get("password"),
        }
        self.client.post("/api/auth/register", credentials, format="json")
        res = self.client.post("/api/auth/login", login_payload, format="json")
        token = res.data["token"]

        # test retrieve user via token while logged in
        response = self.client.get(
            "/api/auth/user", format="json", HTTP_AUTHORIZATION=f"Token {token}"
        )
        self.assertEqual(response.status_code, HTTPStatus.OK._value_)

        response = self.client.post(
            "/api/auth/logout", format="json", HTTP_AUTHORIZATION=f"Token {token}"
        )
        self.assertEqual(response.status_code, HTTPStatus.NO_CONTENT._value_)

        # test cannot retrieve user via token after logout
        response = self.client.get(
            "/api/auth/user", format="json", HTTP_AUTHORIZATION=f"Token {token}"
        )
        self.assertEqual(response.status_code, HTTPStatus.UNAUTHORIZED._value_)
