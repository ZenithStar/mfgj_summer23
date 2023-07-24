extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard):
	return SUCCESS if actor.current_hp <= actor.low_hp_threshold else FAILURE

