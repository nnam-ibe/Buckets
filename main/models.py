from django.db import models

class Bucket(models.Model):
	name = models.CharField(max_length=32)
	amount_saved = models.DecimalField(decimal_places=2, max_digits=9)

class Goals(models.Model):
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
	goal = models.DecimalField(decimal_places=2, max_digits=9)
	auto_update = models.BooleanField(default=True)
	bucket_id = models.ForeignKey(Bucket, on_delete=models.CASCADE)
	contrib_amount = models.DecimalField(decimal_places=2, max_digits=9)
	contrib_frequeny = models.CharField(
		max_length=32,
		choices=CONTRIB_FREQUENCY,
		default=MONTHLY
	)