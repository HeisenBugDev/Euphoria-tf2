#include <sourcemod>

public Plugin:myinfo = 
{
	name = "Euphoria-TF2",
	author = "Mcduder",
	description = "This is a script that allows the Euphoria Gaming Network to get/send info and stats, etc.",
	version = "0.0.1",
	url = "euphoriagaming.net"
}

public OnPluginStart()
{
	PrintToServer("Info is starting to be sent");
}
