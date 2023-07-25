extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard):
	return actor.preorbit()
