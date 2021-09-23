from enum import Enum
from typing import Dict

from django.http.response import HttpResponse
from django.core.exceptions import ObjectDoesNotExist

from business_logic.Exceptions import UserNotFoundError, InvalidRequestError
from ..models import Bucket

class RecordType(Enum):
    GOAL = 'GOAL'
    BUCKET = 'BUCKET'

class Action(Enum):
    CREATE = 'create'
    UPDATE = 'update'
    DELETE = 'delete'
    VIEW = 'view'
    LIST = 'list'


class Authorization():
    error = None
    user = None
    request_data = None
    is_authorized = False

    def __init__(self, request) -> None:
        self.request = request
        if not request.user.is_authenticated:
            self.error = UserNotFoundError("Must be login to perform action")
        else:
            self.set_user(request.user)
            self.request_data = request.data

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

    def update(self, record, **kwargs) -> bool:
        user_id = self.request_data.get('user', None)
        if user_id is not None:
            # if the user id is included in the payload,
            # ensure it is the id of the current user
            if self.user.id != user_id:
                self.__set_error(InvalidRequestError())
                return False

        if record['_type'] == RecordType.GOAL:
            buc_id = self.request_data.get('bucket')
            request_has_bucket = buc_id is not None
            bucket_is_changing = buc_id != record.get('bucket')

            if request_has_bucket and bucket_is_changing:
                # if a goals bucket id is changing, ensure the user has access
                # the new bucket
                try:
                    Bucket.objects.filter(user=self.user).get(id=buc_id)
                except ObjectDoesNotExist:
                    self.__set_error(InvalidRequestError())
                    return False

        return True

    def delete():
        pass
    def view(self, record) -> bool:
        pass
    def list(self, record) -> bool:
        pass
