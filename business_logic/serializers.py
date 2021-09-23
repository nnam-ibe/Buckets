from rest_framework import serializers

from .models import Bucket, Goal

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
            'contrib_frequency',
            'bucket',
            'created_date',
            'last_modified',
        )

class BucketSerializer(serializers.ModelSerializer):
    goals = GoalSerializer(many=True, read_only=True)

    class Meta:
        model = Bucket
        fields = (
            'id',
            'name',
            'user',
            'created_date',
            'last_modified',
            'goals',
        )
