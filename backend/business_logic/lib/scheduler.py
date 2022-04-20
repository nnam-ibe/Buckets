from datetime import timedelta
from django_q.models import Schedule
from django.utils import timezone

from backend.business_logic.models import Goal

contrib_to_schedule = {
    Goal.YEARLY: Schedule.YEARLY,
    Goal.QUARTERLY: Schedule.QUARTERLY,
    Goal.MONTHLY: Schedule.MONTHLY,
    Goal.WEEKLY: Schedule.WEEKLY,
}


def get_next_run_date(contrib_freq):
    if contrib_freq == Goal.NA:
        raise Exception("N/A cannot have a next run date")

    # TODO: Update these to incorporate a date
    now = timezone.now()
    if contrib_freq == Goal.YEARLY:
        return now + timedelta(days=365)
    if contrib_freq == Goal.QUARTERLY:
        return now + timedelta(365 / 4)
    if contrib_freq == Goal.MONTHLY:
        return now + timedelta(days=31)
    if contrib_freq == Goal.WEEKLY:
        return now + timedelta(weeks=1)

    return now + timedelta(weeks=4)


def get_schedule_type(contrib_freq):
    if contrib_freq == Goal.NA:
        raise Exception("N/A cannot have a schedule")

    schedule = contrib_to_schedule.get(contrib_freq)
    if schedule is None:
        # TODO: add error log
        return Schedule.MONTHLY
    return schedule


def retrieve_schedule(goal_id):
    try:
        Schedule.objects.get(id=goal_id)
    except Schedule.DoesNotExist:
        return None


def schedule_goal(goal):
    # todo: handle a goal that has a schedule and no longer has a schedule
    existing_schedule = retrieve_schedule(goal.id)
    if existing_schedule is None:
        Schedule.objects.create(
            func="business_logic.lib.scheduler.update_goal",
            args=goal.id,
            name=goal.id,
            schedule_type=get_schedule_type(goal.contrib_frequency),
            next_run=get_next_run_date(goal.contrib_frequency),
            repeats=1,
        )
        return

    if goal.contrib.frequency == Goal.NA:
        existing_schedule.delete()
        return

    existing_schedule.schedule_type = get_schedule_type(goal.contrib_frequency)
    existing_schedule.next_run = get_next_run_date(goal.contrib_frequency)
    existing_schedule.save()
