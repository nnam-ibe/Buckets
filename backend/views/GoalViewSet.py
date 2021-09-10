from django.shortcuts import get_object_or_404

from backend.utils import Utils
from rest_framework import status, viewsets
from rest_framework.response import Response

from ..serializers import BucketSerializer, GoalSerializer
from ..models import Goal
from ..lib.authorization import Authorization, Action

class GoalViewSet(viewsets.ModelViewSet):
    queryset = Goal.objects.all()
    serializer_class = GoalSerializer

    def create(self, request):
        auth = Authorization(request)
        if auth.has_error():
            return auth.get_error_as_response()

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        record = serializer.validated_data.copy()
        record['user'] = record.get('bucket').user
        if not auth.authorize(action=Action.CREATE, record=record):
            return auth.get_error_as_response()

        goal = Goal.objects.create(**serializer.validated_data)
        saved_data = self.get_serializer(goal).data
        return Response(saved_data, status=status.HTTP_201_CREATED)

    def list(self, request):
        auth = Authorization(request)
        if auth.has_error():
            return auth.get_error_as_response()

        bucket_models = Goal.objects.filter(bucket__user=auth.user).all()
        serialized_data = self.get_serializer(bucket_models, many=True).data
        return Response(serialized_data, status=status.HTTP_200_OK)

    def retrieve(self, request, pk=None):
        auth = Authorization(request)
        if auth.has_error():
            return auth.get_error_as_response()

        queryset = Goal.objects.filter(bucket__user=auth.user).all()
        goal = get_object_or_404(queryset, pk=pk)
        serialized_data = self.get_serializer(goal).data
        return Response(serialized_data)
