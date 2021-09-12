from django.shortcuts import get_object_or_404

from rest_framework import status, viewsets
from rest_framework.response import Response

from ..serializers import GoalSerializer
from ..models import Bucket, Goal
from ..lib.authorization import Authorization, Action, RecordType

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

        goal_models = Goal.objects.filter(bucket__user=auth.user).all()
        serialized_data = self.get_serializer(goal_models, many=True).data
        return Response(serialized_data, status=status.HTTP_200_OK)

    def retrieve(self, request, pk=None):
        auth = Authorization(request)
        if auth.has_error():
            return auth.get_error_as_response()

        queryset = Goal.objects.filter(bucket__user=auth.user).all()
        goal = get_object_or_404(queryset, pk=pk)
        serialized_data = self.get_serializer(goal).data
        return Response(serialized_data, status=status.HTTP_200_OK)

    def _get_auth_record(self, serializer):
        record = serializer.validated_data.copy()
        record['_type'] = RecordType.GOAL
        return record

    def update(self, request, *args, **kwargs):
        auth = Authorization(request)
        if auth.has_error():
            return auth.get_error_as_response()

        partial = kwargs.get('partial', False)
        pk = kwargs.get('pk', None)
        queryset = Goal.objects.filter(bucket__user=auth.user).select_related('bucket').all()
        goal = get_object_or_404(queryset, pk=pk)

        serializer = self.get_serializer(goal, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)

        record = self._get_auth_record(serializer)

        if not auth.authorize(Action.UPDATE, record):
            return auth.get_error_as_response()

        self.perform_update(serializer)

        if getattr(goal, '_prefetched_objects_cache', None):
            # If 'prefetch_related' has been applied to a queryset, we need to
            # forcibly invalidate the prefetch cache on the goal.
            goal._prefetched_objects_cache = {}

        return Response(serializer.data, status=status.HTTP_200_OK)
