from rest_framework import status, viewsets

from ..serializers import BucketSerializer, GoalSerializer
from ..models import Bucket, Goal

class GoalViewSet(viewsets.ModelViewSet):
    queryset = Goal.objects.all()
    serializer_class = GoalSerializer