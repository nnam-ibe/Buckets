from django.urls import include, path

from rest_framework import routers

from .views import BucketViewSet, GoalViewSet

router = routers.DefaultRouter()
router.register(r'bucket', BucketViewSet)
router.register(r'goal', GoalViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
