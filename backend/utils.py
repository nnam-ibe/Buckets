from .Exceptions import UserNotFoundError

def get_user_from_request(request):
    if not request.user.is_authenticated:
        raise UserNotFoundError("Must login to perform action")

    return request.user
