#include <sourcemod>

#define PLUGIN_VERSION "0.0.1"

static String:KVPath[PLATFORM_MAX_PATH];
new Handle:ClientTimer[32];
static Minutes[32];
static Kills[32];
static Deaths[32];

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
	PrintToServer("Euporia Tf2 Plugin started");
	//CreateDirectory("addons/sourcemod/data/playerinfo.txt", 3);
	BuildPath(Path_SM, KVPath, sizeof(KVPath), "data/playerinfo.txt");
   	RegConsoleCmd("sm_stats", Command_getInfo, "");
  	 HookEvent("player_death", player_death);
}

public OnPluginEnd()
{
   UnhookEvent("player_death", player_death);
}

public OnClientPutInServer(client)
{
   AlterPlayerInfo(client, 1);
   ClientTimer[client] = CreateTimer(60.0, TimerAddMinutes, client, TIMER_REPEAT);
}

public OnClientDisconnect(client)
{
   CloseHandle(ClientTimer[client]);
        if(client > 0)
         AlterPlayerInfo(client, 0);
}

public Action:Command_getInfo(client, args)
{
   new String:Name[32];
   GetClientName(client, Name, sizeof(Name));
   
   PrintToChatAll("%s has %d Minutes.", Name, Minutes[client]);
   return Plugin_Handled;
}

public player_death(Handle:event, const String:name[], bool:dontBroadcast)
{
   new client = GetClientOfUserId(GetEventInt(event, "userid"));
   new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

   if(client == 0 || attacker == 0)
   {
      return Plugin_Continue;
   }

   new String:name[32], String:aname[32];
   GetClientName(client, name, 32);
   GetClientName(attacker, aname, 32);

   if(client == attacker)
   {
      PrintToChatAll("%s Humiliated Theirself", name);
      Deaths[client]++;
      return Plugin_Continue;
   } else {
      PrintToChatAll("%s killed %s", aname, name);
      Kills[attacker]++;
      Deaths[client]++;
      return Plugin_Continue;
   }


}

public Action:TimerAddMinutes(Handle:timer, any:client)
{
   if(IsClientConnected(client) && IsClientInGame(client))
   {
      Minutes[client]++;
   }
}

public AlterPlayerInfo(client, connection)
{
   new Handle:DB = CreateKeyValues("PlayersInfo");
   FileToKeyValues(DB, KVPath);
   
   new String:SID[32];
   GetClientAuthString(client, SID, sizeof(SID));
   
   if(connection == 1)
   {
      //we are connecting
      if(KvJumpToKey(DB, SID, true))
      {
         new String:name[MAX_NAME_LENGTH], String:temp_name[MAX_NAME_LENGTH];
         GetClientName(client, name, sizeof(name));
         
         KvGetString(DB, "name", temp_name, sizeof(temp_name), "NULL");
         
         Minutes[client] = KvGetNum(DB, "Minutes", 0);
         Deaths[client] = KvSetNum(DB, "Deaths", 0);
         Kills[client] = KvSetNum(DB, "Kills", 0);
         
         new connections = KvGetNum(DB, "connections");
         
         if(StrEqual(temp_name, "NULL") && connections == 0)
         {
            PrintToChatAll("%s is new to the server.", name);
         } else {
            PrintToChatAll("%s last connected as %s. Has %d connections.", name, temp_name, connections);
         }
         KvSetNum(DB, "connections", ++connections);
         KvSetString(DB, "name", name);
      }
   } else if(connection == 0)
   {
      //we are disconnecting
      if(KvJumpToKey(DB, SID, true))
      {
         KvSetNum(DB, "Minutes", Minutes[client]);
         KvSetNum(DB, "Deaths", Deaths[client]);
         KvSetNum(DB, "Kills", Kills[client]);
      }
   }
   
   KvRewind(DB);
   KeyValuesToFile(DB, KVPath);
   CloseHandle(DB);
}
