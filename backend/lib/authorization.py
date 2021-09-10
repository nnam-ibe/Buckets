from enum import Enum
from typing import Dict

from django.http.response import HttpResponse

from backend.Exceptions import UserNotFoundError, InvalidRequestError

class Action(Enum):
    CREATE = 'create'
    UPDATE = 'update'
    DELETE = 'delete'
    VIEW = 'view'
    LIST = 'list'


class Authorization():
    error = None
    user = None
    is_authorized = False

    def __init__(self, request) -> None:
        self.request = request
        if not request.user.is_authenticated:
            self.error = UserNotFoundError("Must be login to perform action")
        else:
            self.set_user(request.user)

    def set_user(self, user) -> None:
        self.user = user

    def has_error(self) -> bool:
        return self.error is not None

    def get_error(self):
        return self.error

    def __set_error(self, error) -> None:
        self.error = error

    def get_error_as_response(self):
        error = self.get_error()
        return HttpResponse(status=error.status, reason=error.message)

    def is_authorized(self) -> bool:
        return self.is_authorized

    def authorize(self, action: Action, record: Dict, **kwargs) -> bool:
        if (self.has_error()):
            return False

        self.is_authorized = getattr(self, action.value)(record, **kwargs)
        return self.is_authorized

    def create(self, record) -> bool:
        if self.user.id != record.get('user').id:
            self.__set_error(InvalidRequestError())
            return False
        return True

    def update(self, record) -> bool:
        user = record.get('user', None)
        if user is None:
            # if the user attribute is not included in the payload then
            # authorize, as they would have gotten a 404 already if
            # they don't own the resource
            return True

        if self.user.id != user.id:
            self.__set_error(InvalidRequestError())
            return False
        return True

    def delete():
        pass
    def view(self, record) -> bool:
        pass
    def list(self, record) -> bool:
        pass
