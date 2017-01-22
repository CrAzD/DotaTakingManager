TM_MODULE_FOLDER_TO_LOAD = 'IslandeDefense'

'''
	// Taking Manager
	//----------------------------------------------------------------
	"taking"
	{
		"type"			"taker" //Default Options: taker, depo, or node.
		"nodes"			"gold lumber" //List all nodes this entity can take, seperated with a SPACE.
		"depos"			"name-of-depo01 name_of_depo02 nameOfDepo03"  //List the names (IE: city_center) of all depos this entity can deposit to, spereated with a SPACE.
		"animations"
		{
			"gold"		"animation-location"
			"lumber"	"animation_location"
			"custom"	"animationLocation"
		}
		"capacities"
		{
			"gold"		"5"
			"lumber"	"5"
			"total"		"5"
		}
		"searchRadiuses"
		{
			"node"		"500"
			"depo"		"500"
		}
	}
'''