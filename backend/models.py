from django.db import models
from django.conf import settings

class Bucket(models.Model):
    name = models.CharField(max_length=32)
    # TODO: should not be editable, editable=False
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    created_date = models.DateTimeField(auto_now_add=True)
    last_modified = models.DateTimeField(auto_now=True)

    def __str__(self) -> str:
        return self.name

class Goal(models.Model):
    SEMI_MONTHLY = 'SEMI_MONTHLY'
    MONTHLY = 'MONTHLY'
    BI_WEEKLY = 'BI_WEEKLY'
    WEEKLY = 'WEEKLY'
    NA = 'NA'
    CONTRIB_FREQUENCY = [
        (SEMI_MONTHLY, 'Semi Monthly'),
        (MONTHLY, 'Monthly'),
        (BI_WEEKLY, 'Bi-Weekly'),
        (WEEKLY, 'Weekly'),
        (NA, 'N/A'),
    ]
    name = models.CharField(max_length=32)
    goal_amount = models.DecimalField(decimal_places=2, max_digits=9)
    amount_saved = models.DecimalField(decimal_places=2, max_digits=9, default=0)
    auto_update = models.BooleanField(default=True)
    created_date = models.DateTimeField(auto_now_add=True)
    last_modified = models.DateTimeField(auto_now=True)
    contrib_amount = models.DecimalField(decimal_places=2, max_digits=9)
    contrib_frequeny = models.CharField(
        max_length=32,
        choices=CONTRIB_FREQUENCY,
        default=MONTHLY
    )
    bucket = models.ForeignKey(Bucket, on_delete=models.CASCADE)

    def __str__(self) -> str:
        return self.name
