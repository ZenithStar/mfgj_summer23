extends ActionLeaf
	
func tick(actor: Node, _blackboard: Blackboard):
	return actor.orbital_charge()
