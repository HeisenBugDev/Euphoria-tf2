#include <sourcemod>

#define PLUGIN_VERSION "0.0.1"

static String:KVPath[PLATFORM_MAX_PATH];

public Plugin:myinfo = 
{
	name = "Euphoria-TF2",
	author = "Mcduder",
	description = "This is a script that allows the Euphoria Gaming Network to get/send info and stats, etc.",
	version = PLUGIN_VERSION,
	url = "euphoriagaming.net"
}

public OnPluginStart()
{
	PrintToServer("Info is starting to be sent");
	//CreateDirectory("addons/sourcemod/data/playerinfo.txt", 3);
	BuildPath(Path_SM, KVPath, sizeof(KVPath), "data/playerinfo.txt");
}

public OnClientPutInServer(client)
{
	SavePlayerInfo(client);
}

public SavePlayerInfo(client)
{
	new Handle:LogFile = CreateKeyValues("PlayerInfo");
	FileToKeyValues(LogFile, KVPath);
	
	new String:SID[32];
	GetClientAuthString(client, SID, sizeof(SID));
	
	if(KvJumpToKey(LogFile, SID, true))
	{
		new String:name[MAX_NAME_LENGTH], String:temp_name[MAX_NAME_LENGTH];
		GetClientName(client, name, sizeof(name));
		
		KvGetString(LogFile, "name", temp_name, sizeof(temp_name));
		
		new connections = KvGetNum(LogFile, "connections", 0);
		
		if(StrEqual(temp_name, "NULL") && connections == 0)
		{
			PrintToChatAll("%s is new to the server!", name);
		} else {
			PrintToChatAll("%s last connected as %s and has %d connections", name, temp_name, connections);
		}
		
		KvSetNum(LogFile, "connections", connections++);
		KvSetString(LogFile, "name", name);
		
		KvRewind(LogFile);
		KeyValuesToFile(LogFile, KVPath);
		
		CloseHandle(LogFile);
	}
}
