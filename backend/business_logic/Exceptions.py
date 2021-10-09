from rest_framework import status


class UserNotFoundError(Exception):
    """Exception raised when a user is not found.

    Attributes:
        message -- explanation of the error
        status -- response status of the error
    """

    def __init__(self, message="Permission denied", status=status.HTTP_403_FORBIDDEN):
        self.message = message
        self.status = status

    """
    TODO: incorporate
    def __str__(self):
        return f'{self.salary} -> {self.message}'
    """


class InvalidRequestError(Exception):
    """Raised when a request is invalid.

    Attributes:
        message -- explanation of the error
        status -- response status of the error
    """

    def __init__(
        self, message="Request is invalid", status=status.HTTP_400_BAD_REQUEST
    ):
        self.message = message
        self.status = status
