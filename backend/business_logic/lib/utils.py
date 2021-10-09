from rest_framework.response import Response

from ..Exceptions import UserNotFoundError


class Utils:
    @staticmethod
    def get_user_from_request(request):
        # TODO: unused method
        if not request.user.is_authenticated:
            raise UserNotFoundError("Must login to perform action")

        return request.user

    @staticmethod
    def get_error_response(err):
        # TODO: unused method
        return Response(
            {
                "status": err.message,
                "message": err.message,
            },
            status=err.status,
        )
