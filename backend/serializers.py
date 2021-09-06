from rest_framework import serializers
from .models import Bucket, Goal

class BucketSerializer(serializers.ModelSerializer):
    class Meta:
        model = Bucket
        fields = (
            'id',
            'name',
            'user',
            'created_date',
            'last_modified',
        )

class GoalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Goal
        fields = (
            'id',
            'name',
            'goal_amount',
            'amount_saved',
            'auto_update',
            'contrib_amount',
            'contrib_frequeny',
            'bucket',
            'created_date',
            'last_modified',
        )