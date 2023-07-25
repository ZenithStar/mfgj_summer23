extends ActionLeaf
	
func tick(actor: Node, _blackboard: Blackboard):
	return actor.orbit(true)
