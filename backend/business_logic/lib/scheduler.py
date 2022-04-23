import logging
from datetime import timedelta
from django_q.models import Schedule
from django.utils import timezone

from business_logic.models import Goal

logger = logging.getLogger(__name__)

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

    raise Exception(f"unknown contrib frequency: {contrib_freq}")


def get_schedule_type(contrib_freq):
    if contrib_freq == Goal.NA:
        raise Exception("N/A cannot have a schedule")

    schedule = contrib_to_schedule.get(contrib_freq)
    if schedule is None:
        raise Exception(f"Unknown schedule type: {contrib_freq}")
    return schedule


def retrieve_schedule(goal_id):
    """
    Retrieves a schedule using its id.

    Returns None if the schedule is not found.
    """
    try:
        return Schedule.objects.get(name=str(goal_id))
    except Schedule.DoesNotExist:
        return None


def schedule_goal(goal):
    """
    Schedules a goal to be auto updated based on the contrib_frequency
    """
    logger.debug(f"Scheduling goal ({goal.id}")
    existing_schedule = retrieve_schedule(goal.id)
    if existing_schedule is None:
        Schedule.objects.create(
            func="business_logic.lib.goal_service.update_goal_hook",
            hook="business_logic.lib.scheduler.cleanup_goal_schedule_hook",
            args=goal.id,
            name=goal.id,
            schedule_type=get_schedule_type(goal.contrib_frequency),
            next_run=get_next_run_date(goal.contrib_frequency),
            repeats=1,
        )
        return

    if not goal.auto_update:
        delete_schedule(schedule=existing_schedule)
        return

    existing_schedule.schedule_type = get_schedule_type(goal.contrib_frequency)
    existing_schedule.next_run = get_next_run_date(goal.contrib_frequency)
    existing_schedule.save()


def delete_schedule(goal_id=None, schedule=None):
    """
    Deletes a schedule

    Requires a goal_id or schedule object
    """
    if goal_id == None and schedule == None:
        raise Exception("Requires a goal_id or schedule object")

    if schedule is None:
        schedule = retrieve_schedule(goal_id)
        if schedule is None:
            return

    schedule.delete()


def cleanup_goal_schedule_hook(task):
    """
    Deletes a goals schedule if a goal has auto_update==False
    """
    goal = task.result
    if goal is None:
        logger.warning(f"[cleanup_goal_schedule_hook] recieved no goal, nothing to do")
        return

    if goal.auto_update:
        return

    delete_schedule(goal_id=goal.id)
