extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard):
	return SUCCESS if actor.check_far_from_spawn() else FAILURE

