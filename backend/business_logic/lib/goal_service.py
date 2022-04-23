import logging

from business_logic.models import Goal

logger = logging.getLogger(__name__)


def should_update_schedule(original_data, updated_data):
    """
    Returns True if the goal's schedule should be updated
    """
    if original_data.get("auto_update") != updated_data.get("auto_update"):
        return True

    if original_data.get("contrib_frequency") != updated_data.get("contrib_frequency"):
        return True

    return False


def retrieve_goal(goal_id):
    """
    Retrieves a goal using its id.

    Returns None if the goal is not found.
    """
    try:
        return Goal.objects.get(id=goal_id)
    except Goal.DoesNotExist:
        return None


def update_goal_hook(goal_id):
    """
    Updates a goal's amount by its contrib_amount
    """
    logger.debug(f"[update_goal_hook] Updating goal ({goal})")
    goal = retrieve_goal(goal_id)
    if goal is None:
        logger.warning(f"[update_goal_hook] Goal ({goal_id}) not found")
        return

    if not goal.auto_update:
        return goal

    goal.amount += goal.contrib_amount
    goal.save()
    return goal
