extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard):
	return SUCCESS if actor.target != null else FAILURE

