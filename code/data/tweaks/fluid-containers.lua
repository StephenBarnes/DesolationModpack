-- Modify stack sizes and amounts contained in barrels and canisters.

--[[ Considering various fuel types etc.
Steam:
	Fuel value is 3 MJ per 100 steam.
	Steam cell (made from 1.5 copper ingots) holds 100 steam, which is 3 MJ.
		Stack size 10, so 1000 steam per stack, so 30 MJ per stack.
	Steam canister (made from 2.5 iron ingots) holds 200 steam, which is 6 MJ.
		Stack size 10, so 2000 steam per stack, so 60 MJ per stack.
Petroleum:
	Fuel value is 4MJ per 10 petroleum.
	Petroleum canister holds 30 petroleum = 12 MJ.
		Stack size 10, so 300 petroleum per stack, so 120 MJ per stack.
	Barrel holds 60 petroleum = 24 MJ.
		Stack size 10, so 600 petroleum per stack, so 240 MJ per stack.

TODO I think this requires playtesting. Otherwise it's hard to know how reasonable it is to have eg 60 chrome plating solution per barrel, 600 per stack, etc.
]]