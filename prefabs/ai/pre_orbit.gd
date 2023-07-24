extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard):
	return actor.preorbit()
