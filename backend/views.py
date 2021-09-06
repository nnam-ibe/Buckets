from django.http.response import HttpResponse
from django.shortcuts import get_object_or_404

from rest_framework import serializers, status, viewsets
from rest_framework.response import Response

from .serializers import BucketSerializer, GoalSerializer
from .models import Bucket, Goal
from .utils import get_user_from_request
from .Exceptions import UserNotFoundError, InvalidRequestError

# TODO: remove
def index(request):
    return HttpResponse("Hello, world. You're at the main index.")

# TODO: remove
def get_buckets(request):
    return None

class BucketViewSet(viewsets.ModelViewSet):
    queryset = Bucket.objects.all()
    serializer_class = BucketSerializer

    def validate_serializer(self, serializer):
        if serializer.is_valid():
            return

        raise InvalidRequestError(message="Request is invalid")

    def create(self, request):
        try:
            # TODO: verify user attr is the same as logged in user
            get_user_from_request(request)
            serializer = self.serializer_class(data=request.data)
            self.validate_serializer(serializer)
        except (UserNotFoundError, InvalidRequestError) as err:
             return Response({
                'status': 'Bad request',
                'message': err.message
            }, status=err.status)

        Bucket.objects.create(**serializer.validated_data)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class GoalViewSet(viewsets.ModelViewSet):
    queryset = Goal.objects.all()
    serializer_class = GoalSerializer