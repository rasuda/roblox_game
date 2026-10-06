local Constants = {
	ContractState = {
		AVAILABLE = "AVAILABLE", CARRIED = "CARRIED", DROPPED = "DROPPED",
		DEPOSITED = "DEPOSITED", SIGNING = "SIGNING", SIGNED = "SIGNED",
	},
	GuardianState = {
		IDLE = "IDLE", ALERT = "ALERT", CHASE = "CHASE",
		ATTACK = "ATTACK", RETURN = "RETURN",
	},
	RemoteNames = {
		StateUpdate = "StateUpdate", Notification = "Notification", Reveal = "Reveal",
		TransferWindow = "TransferWindow", SlideTackle = "SlideTackle", SellWeakest = "SellWeakest",
	},
}
return table.freeze(Constants)
