/*

	 /$$   /$$  /$$$$$$          /$$$$$$$  /$$$$$$$
	| $$$ | $$ /$$__  $$        | $$__  $$| $$__  $$
	| $$$$| $$| $$  \__/        | $$  \ $$| $$  \ $$
	| $$ $$ $$| $$ /$$$$ /$$$$$$| $$$$$$$/| $$$$$$$/
	| $$  $$$$| $$|_  $$|______/| $$__  $$| $$____/
	| $$\  $$$| $$  \ $$        | $$  \ $$| $$
	| $$ \  $$|  $$$$$$/        | $$  | $$| $$
	|__/  \__/ \______/         |__/  |__/|__/

						Weapons System

				Next Generation Gaming, LLC
	(created by Next Generation Gaming Development Team)
					
	* Copyright (c) 2014, Next Generation Gaming, LLC
	*
	* All rights reserved.
	*
	* Redistribution and use in source and binary forms, with or without modification,
	* are not permitted in any case.
	*
	*
	* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	* A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
	* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
	* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
	* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
	* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
	* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

CMD:myguns(playerid, params[])
{
	new string[128], myweapons[13][2], weaponname[50], encryption[256], name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, sizeof(name));
	SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
	format(string, sizeof(string), "Weapons on %s:", name);
	SendClientMessageEx(playerid, COLOR_WHITE, string);
	for (new i = 0; i < 13; i++)
	{
		GetPlayerWeaponData(playerid, i, myweapons[i][0], myweapons[i][1]);
		if(myweapons[i][0] > 0)
		{
			if(PlayerInfo[playerid][pGuns][i] == myweapons[i][0])
			{
				GetWeaponName(myweapons[i][0], weaponname, sizeof(weaponname));
				format(string, sizeof(string), "%s (%d)", weaponname, myweapons[i][0]);
				SendClientMessageEx(playerid, COLOR_GRAD1, string);
				format(encryption, sizeof(encryption), "%s%d", encryption, myweapons[i][0]);
			}
		}
	}
	new year, month, day;
	getdate(year, month, day);
	format(encryption, sizeof(encryption), "%s%s%d%d%d%d%d6524", encryption, name, month, day, year, hour, minuite);
	new encrypt = crc32(encryption);
	format(string, sizeof(string), "[%d/%d/%d %d:%d:%d] - [%d]", month, day, year, hour, minuite,second, encrypt);
	SendClientMessageEx(playerid, COLOR_GREEN, string);
	SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
	return 1;
}

CMD:giveweapon(playerid, params[])
{
	if(HungerPlayerInfo[playerid][hgInEvent] != 0) return SendClientMessageEx(playerid, COLOR_GREY, "   You cannot do this while being in the Hunger Games Event!");
	if(GetPVarInt(playerid, "IsInArena") >= 0)
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now, you are in an arena!");
		return 1;
	}
	if(GetPVarInt( playerid, "EventToken") != 0)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "You can't use this while you're in an event.");
		return 1;
	}
	new Float:health;
	GetPlayerHealth(playerid, health);
	if (health < 80)
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "You can not give weapons if your health is below 80!");
		return 1;
	}

	if(GetPVarInt(playerid, "Injured") != 0||PlayerCuffed[playerid]!=0||PlayerInfo[playerid][pHospital]!=0||GetPlayerState(playerid) == 7)
	{
		SendClientMessageEx (playerid, COLOR_GRAD2, "You cannot do this at this time.");
		return 1;
	}
	if(IsPlayerInAnyVehicle(playerid))
	{
		SendClientMessageEx (playerid, COLOR_GRAD2, "You can not give weapons in a vehicle!");
		return 1;
	}

	if (GetPVarInt(playerid, "GiveWeaponTimer") > 0)
	{
		new string[58];
		format(string, sizeof(string), "You must wait %d seconds before giving another weapon.", GetPVarInt(playerid, "GiveWeaponTimer"));
		SendClientMessageEx(playerid,COLOR_GREY,string);
		return 1;
	}

	new string[128], giveplayerid, weapon[64];
	if(sscanf(params, "us[64]", giveplayerid, weapon))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /giveweapon [player] [weapon name]");
		SendClientMessageEx(playerid, COLOR_GRAD2, "Available Names: sdpistol, shotgun, 9mm, mp5, uzi, tec9, rifle, deagle, ak47, m4, spas12, sniper");
		SendClientMessageEx(playerid, COLOR_GRAD2, "Available Names: flowers, knuckles, baseballbat, cane, shovel, poolcue, golfclub, katana, dildo, parachute");
		return 1;
	}
	if (!IsPlayerConnected(giveplayerid)) {
		return SendClientMessageEx(playerid, COLOR_GRAD1, "Invalid player specified.");
	}
	if(IsPlayerInAnyVehicle(giveplayerid))
	{
		SendClientMessageEx (playerid, COLOR_GRAD2, "You can not give weapons to players in vehicles!");
		return 1;
	}
	if(giveplayerid == playerid)
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "You can not give a weapon to yourself!");
		return 1;
	}
	if(!ProxDetectorS(3.0, playerid, giveplayerid))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "That person isn't near you.");
		return 1;
	}
	if(PlayerInfo[playerid][pMember] != PlayerInfo[giveplayerid][pMember] && PlayerInfo[playerid][pMember] != INVALID_GROUP_ID)
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "You can not give weapons to players outside your faction!");
		return 1;
	}
	if(PlayerInfo[giveplayerid][pConnectHours] < 2 || PlayerInfo[giveplayerid][pWRestricted] > 0) return SendClientMessageEx(playerid, COLOR_GRAD2, "That person is currently restricted from possessing weapons");
	if(IsPlayerInAnyVehicle(giveplayerid)) return SendClientMessageEx(playerid, COLOR_GRAD2, "Please exit the vehicle, before using this command.");
	if(strcmp(weapon, "sdpistol", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 2 ] == 23)
		{
			if(PlayerInfo[giveplayerid][pGuns][ 2 ] != 23 && PlayerInfo[giveplayerid][pGuns][ 2 ] != 24)
			{
				if(PlayerInfo[playerid][pDonateRank] > 2 || PlayerInfo[playerid][pFamed] > 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "You can not give away weapons if you're Gold+ VIP/Famed+!");

				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your silenced pistol.");
				format(string, sizeof(string), "* %s has given %s their silenced pistol.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				RemovePlayerWeapon(playerid, 23);
				GivePlayerValidWeapon(giveplayerid, 23, 60000);
				/*new ip[32], ipex[32];
				GetPlayerIp(playerid, ip, sizeof(ip));
				GetPlayerIp(giveplayerid, ipex, sizeof(ipex));
				GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s(IP:%s) has given %s (IP:%s) their silenced pistol.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
				Log("logs/pay.log", string);*/
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "That person already has a silenced pistol or Desert Eeagle!");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	if(strcmp(weapon, "9mm", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 2 ] == 22)
		{
			if(PlayerInfo[giveplayerid][pGuns][ 2 ] != 22 && PlayerInfo[giveplayerid][pGuns][ 2 ] != 24)
			{
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your 9mm pistol.");
				format(string, sizeof(string), "* %s has given %s their 9mm pistol.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				RemovePlayerWeapon(playerid, 22);
				GivePlayerValidWeapon(giveplayerid, 22, 60000);
				/*new ip[32], ipex[32];
				GetPlayerIp(playerid, ip, sizeof(ip));
				GetPlayerIp(giveplayerid, ipex, sizeof(ipex));
				GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their 9mm pistol.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
				Log("logs/pay.log", string);*/
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "That person already has a silenced pistol or Desert Eeagle!");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "shotgun", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 3 ] == 25)
		{
			if(PlayerInfo[giveplayerid][pGuns][ 3 ] != 25 && PlayerInfo[giveplayerid][pGuns][ 3 ] != 27)
			{
				if(PlayerInfo[playerid][pDonateRank] > 2 || PlayerInfo[playerid][pFamed] > 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "You can not give away weapons if you're Gold+ VIP/Famed+!");

				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your shotgun.");
				format(string, sizeof(string), "* %s has given %s their shotgun.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				RemovePlayerWeapon(playerid, 25);
				GivePlayerValidWeapon(giveplayerid, 25, 60000);
				/*new ip[32], ipex[32];
				GetPlayerIp(playerid, ip, sizeof(ip));
				GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s(IP:%s) has given %s (IP:%s) their shotgun.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
				Log("logs/pay.log", string);*/
				SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "That person already has a MP5, Micro SMG or Tec-9!");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "mp5", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 4 ] == 29)
		{
			if(PlayerInfo[giveplayerid][pGuns][ 4 ] != 28 && PlayerInfo[giveplayerid][pGuns][ 4 ] != 29 && PlayerInfo[giveplayerid][pGuns][ 4 ] != 32)
			{
				if(PlayerInfo[playerid][pDonateRank] > 2 || PlayerInfo[playerid][pFamed] > 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "You can not give away weapons if you're Gold+ VIP/Famed+!");

				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your MP5.");
				format(string, sizeof(string), "* %s has given %s their MP5.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				RemovePlayerWeapon(playerid, 29);
				GivePlayerValidWeapon(giveplayerid, 29, 60000);
				/*new ip[32], ipex[32];
				GetPlayerIp(playerid, ip, sizeof(ip));
				GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their MP5.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
				Log("logs/pay.log", string);*/
				SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "That person already has a MP5!");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "uzi", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 4 ] == 28)
		{
			if(PlayerInfo[giveplayerid][pGuns][ 4 ] != 28 && PlayerInfo[giveplayerid][pGuns][ 4 ] != 29 && PlayerInfo[giveplayerid][pGuns][ 4 ] != 32)
			{
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your Micro SMG.");
				format(string, sizeof(string), "* %s has given %s their Micro SMG.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				RemovePlayerWeapon(playerid, 28);
				GivePlayerValidWeapon(giveplayerid, 28, 60000);
				/*new ip[32], ipex[32];
				GetPlayerIp(playerid, ip, sizeof(ip));
				GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their Micro SMG.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
				Log("logs/pay.log", string);*/
				SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "That person already has a MP5, Micro SMG or Tec-9!");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "tec9", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 4 ] == 32)
		{
			if(PlayerInfo[giveplayerid][pGuns][ 4 ] != 28 && PlayerInfo[giveplayerid][pGuns][ 4 ] != 29 && PlayerInfo[giveplayerid][pGuns][ 4 ] != 32)
			{
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your Tec-9.");
				format(string, sizeof(string), "* %s has given %s their Tec-9.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				RemovePlayerWeapon(playerid, 32);
				GivePlayerValidWeapon(giveplayerid, 32, 60000);
				/*new ip[32], ipex[32];
				GetPlayerIp(playerid, ip, sizeof(ip));
				GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their Tec-9.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
				Log("logs/pay.log", string);*/
				SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "That person already has a MP5, Micro SMG or Tec-9!");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "deagle", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 2 ] == 24)
		{
			if(PlayerInfo[giveplayerid][pGuns][ 2 ] != 24)
			{
				if(PlayerInfo[playerid][pDonateRank] > 2 || PlayerInfo[playerid][pFamed] > 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "You can not give away weapons if you're Gold+ VIP/Famed+!");

				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your Desert Eagle.");
				format(string, sizeof(string), "* %s has given %s their Desert Eagle.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				RemovePlayerWeapon(playerid, 24);
				GivePlayerValidWeapon(giveplayerid, 24, 60000);
				/*new ip[32], ipex[32];
				GetPlayerIp(playerid, ip, sizeof(ip));
				GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their Desert Eagle.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
				Log("logs/pay.log", string);*/
				SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "That person already has a Desert Eeagle!");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "rifle", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 6 ] == 33)
		{
			if(PlayerInfo[giveplayerid][pGuns][ 6 ] != 33 && PlayerInfo[giveplayerid][pGuns][ 6 ] != 34)
			{
				if(PlayerInfo[playerid][pFamed] > 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "You can not give away this weapon as you're Famed+!");
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your rifle.");
				format(string, sizeof(string), "* %s has given %s their rifle.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				RemovePlayerWeapon(playerid, 33);
				GivePlayerValidWeapon(giveplayerid, 33, 60000);
				/*new ip[32], ipex[32];
				GetPlayerIp(playerid, ip, sizeof(ip));
				GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their rifle.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
				Log("logs/pay.log", string);*/
				SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "That person already has a rifle!");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "ak47", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 5 ] == 30)
		{
			if(PlayerInfo[giveplayerid][pGuns][ 5 ] != 30 && PlayerInfo[giveplayerid][pGuns][ 5 ] != 31)
			{
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your AK-47.");
				format(string, sizeof(string), "* %s has given %s their AK-47.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				RemovePlayerWeapon(playerid, 30);
				GivePlayerValidWeapon(giveplayerid, 30, 60000);
				/*new ip[32], ipex[32];
				GetPlayerIp(playerid, ip, sizeof(ip));
				GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their AK-47.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
				Log("logs/pay.log", string);*/
				SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "That person already has a AK-47 or M4!");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "m4", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 5 ] == 31)
		{
			if(PlayerInfo[giveplayerid][pGuns][ 5 ] != 31)
			{
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your M4.");
				format(string, sizeof(string), "* %s has given %s their M4.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				RemovePlayerWeapon(playerid, 31);
				GivePlayerValidWeapon(giveplayerid, 31, 60000);
				/*new ip[32], ipex[32];
				GetPlayerIp(playerid, ip, sizeof(ip));
				GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their M4.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
				Log("logs/pay.log", string);*/
				SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "That person already has a M4!");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "spas12", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 3 ] == 27)
		{
			if(PlayerInfo[giveplayerid][pGuns][ 3 ] != 27)
			{
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your SPAS-12.");
				format(string, sizeof(string), "* %s has given %s their SPAS-12.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				RemovePlayerWeapon(playerid, 27);
				GivePlayerValidWeapon(giveplayerid, 27, 60000);
				/*new ip[32], ipex[32];
				GetPlayerIp(playerid, ip, sizeof(ip));
				GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their SPAS-12.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
				Log("logs/pay.log", string);*/
				SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "That person already has a SPAS-12!");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "sniper", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 6 ] == 34)
		{
			if(PlayerInfo[giveplayerid][pGuns][ 6 ] != 34)
			{
				SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your sniper rifle.");
				format(string, sizeof(string), "* %s has given %s their sniper rifle.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				RemovePlayerWeapon(playerid, 34);
				GivePlayerValidWeapon(giveplayerid, 34, 60000);
				/*new ip[32], ipex[32];
				GetPlayerIp(playerid, ip, sizeof(ip));
				GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their sniper rifle.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
				Log("logs/pay.log", string);*/
				SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
			}
			else
			{
				SendClientMessageEx(playerid, COLOR_GREY, "That person already has a sniper rifle!");
			}
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "flowers", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 10 ] == 14)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your flowers.");
			format(string, sizeof(string), "* %s has given %s their flowers.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 14);
			GivePlayerValidWeapon(giveplayerid, 14, 60000);
			/*new ip[32], ipex[32];
			GetPlayerIp(playerid, ip, sizeof(ip));
			GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their flowers.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
			Log("logs/pay.log", string);*/
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "knuckles", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 0 ] == 1)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your brass knuckles.");
			format(string, sizeof(string), "* %s has given %s their brass knuckles.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 1);
			GivePlayerValidWeapon(giveplayerid, 1, 60000);
			/*new ip[32], ipex[32];
			GetPlayerIp(playerid, ip, sizeof(ip));
			GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their brass knuckles.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
			Log("logs/pay.log", string);*/
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "baseballbat", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 1 ] == 5)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your baseball bat.");
			format(string, sizeof(string), "* %s has given %s their baseball bat.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 5);
			GivePlayerValidWeapon(giveplayerid, 5, 60000);
			/*new ip[32], ipex[32];
			GetPlayerIp(playerid, ip, sizeof(ip));
			GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their baseball bat.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
			Log("logs/pay.log", string);*/
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "cane", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 10 ] == 15)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your cane.");
			format(string, sizeof(string), "* %s has given %s their cane.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 15);
			GivePlayerValidWeapon(giveplayerid, 15, 60000);
			/*new ip[32], ipex[32];
			GetPlayerIp(playerid, ip, sizeof(ip));
			GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their cane.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
			Log("logs/pay.log", string);*/
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "shovel", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 6 ] == 6)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your shovel.");
			format(string, sizeof(string), "* %s has given %s their shovel.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 6);
			GivePlayerValidWeapon(giveplayerid, 6, 60000);
			/*new ip[32], ipex[32];
			GetPlayerIp(playerid, ip, sizeof(ip));
			GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their shovel.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
			Log("logs/pay.log", string);*/
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "golfclub", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 1 ] == 2)
		{
			if(PlayerInfo[playerid][pDonateRank] > 2 || PlayerInfo[playerid][pFamed] > 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "You can not give away weapons if you're Gold+ VIP/Famed+!");

			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your golf club.");
			format(string, sizeof(string), "* %s has given %s golf club.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 2);
			GivePlayerValidWeapon(giveplayerid, 2, 60000);
			/*new ip[32], ipex[32];
			GetPlayerIp(playerid, ip, sizeof(ip));
			GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their golf club.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
			Log("logs/pay.log", string);*/
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "katana") == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 1 ] == 8)
		{
			if(PlayerInfo[playerid][pDonateRank] > 2 || PlayerInfo[playerid][pFamed] > 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "You can not give away weapons if you're Gold+ VIP/Famed+!");

			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your katana.");
			format(string, sizeof(string), "* %s has given %s their katana.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 8);
			GivePlayerValidWeapon(giveplayerid, 8, 60000);
			/*new ip[32], ipex[32];
			GetPlayerIp(playerid, ip, sizeof(ip));
			GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their katana.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
			Log("logs/pay.log", string);*/
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "dildo", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 10 ] == 10)
		{
			if(PlayerInfo[playerid][pDonateRank] > 2 || PlayerInfo[playerid][pFamed] > 2) return SendClientMessageEx(playerid, COLOR_GRAD1, "You can not give away weapons if you're Gold+ VIP/Famed+!");

			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your dildo.");
			format(string, sizeof(string), "* %s has given %s their dildo.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 10);
			GivePlayerValidWeapon(giveplayerid, 10, 60000);
			/*new ip[32], ipex[32];
			GetPlayerIp(playerid, ip, sizeof(ip));
			GetPlayerIp(giveplayerid, ipex, sizeof(ipex));format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their dildo.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
			Log("logs/pay.log", string);*/
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(weapon, "parachute", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 11 ] == 46)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have given away your parachute.");
			format(string, sizeof(string), "* %s has given %s their parachute.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 46);
			GivePlayerValidWeapon(giveplayerid, 46, 60000);
			/*new ip[32], ipex[32];
			GetPlayerIp(playerid, ip, sizeof(ip));
			GetPlayerIp(giveplayerid, ipex, sizeof(ipex));
			format(string, sizeof(string), "%s (IP:%s) has given %s (IP:%s) their parachute.", GetPlayerNameEx(playerid), ip, GetPlayerNameEx(giveplayerid), ipex);
			Log("logs/pay.log", string);*/
			SetPVarInt(playerid, "GiveWeaponTimer", 10); SetTimerEx("OtherTimerEx", 1000, false, "ii", playerid, TYPE_GIVEWEAPONTIMER);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "You have entered an invalid weapon name.");
	}
	return 1;
}

CMD:dropgun(playerid, params[])
{
	if(isnull(params))
	{
		SendClientMessageEx(playerid, COLOR_GREY, "USAGE: /dropgun [weapon name]");
		SendClientMessageEx(playerid, COLOR_GRAD2, "Available Names: sdpistol, shotgun, 9mm, mp5, uzi, tec9, rifle, deagle, ak47, m4, spas12, sniper, camera");
		SendClientMessageEx(playerid, COLOR_GRAD2, "Available Names: flowers, knuckles, baseballbat, cane, shovel, poolcue, golfclub, katana, dildo, parachute, goggles");
		if (IsAHitman(playerid))
		{
			SendClientMessageEx(playerid, COLOR_GRAD2, "Available Names: knife");
		}
		if(IsACop(playerid))
		{
			SendClientMessageEx(playerid, COLOR_GRAD2, "Available Names: nitestick, mace, smoke, chainsaw, fire");
		}

		return 1;
		}

	if(IsPlayerInAnyVehicle(playerid))
	{
		SendClientMessageEx (playerid, COLOR_GRAD2, "You can not drop weapons in a vehicle!");
		return 1;
	}
	if(GetPVarInt(playerid, "IsInArena") >= 0)
	{
		SendClientMessageEx(playerid, COLOR_WHITE, "You can't do this right now, you are in an arena!");
		return 1;
	}
	if(GetPVarInt( playerid, "EventToken") != 0)
	{
		SendClientMessageEx(playerid, COLOR_GREY, "You can't use this while you're in an event.");
		return 1;
	}
	new string[128];
	if(strcmp(params, "sdpistol", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 2 ] == 23)
		{
			if(pTazer{playerid} == 1) return SendClientMessageEx(playerid, COLOR_RED, "You cannot drop your tazer.");
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your silenced pistol.");
			format(string, sizeof(string), "* %s has dropped their silenced pistol.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 23);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "camera", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 9 ] == 43)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your camera.");
			format(string, sizeof(string), "* %s has dropped their camera.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 43);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "nitestick", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][1] == 3)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your nitestick.");
			format(string, sizeof(string), "* %s has dropped their nitestick.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 3);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "mace", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][9] == 41)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your mace.");
			format(string, sizeof(string), "* %s has dropped their mace.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 41);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "knife", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 1 ] == 4)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your knife.");
			format(string, sizeof(string), "* %s has dropped their knife.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 4);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "9mm", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 2 ] == 22)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your 9mm pistol.");
			format(string, sizeof(string), "* %s has dropped their 9mm pistol.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 22);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "shotgun", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 3 ] == 25)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your shotgun.");
			format(string, sizeof(string), "* %s has dropped their shotgun.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 25);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "mp5", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 4 ] == 29)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your MP5.");
			format(string, sizeof(string), "* %s has dropped their MP5.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 29);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "uzi", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 4 ] == 28)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your Micro SMG.");
			format(string, sizeof(string), "* %s has dropped their Micro SMG.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 28);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "uzi", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 4 ] == 32)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your Tec-9.");
			format(string, sizeof(string), "* %s has dropped their Tec-9.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 32);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "deagle", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 2 ] == 24)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your Desert Eagle.");
			format(string, sizeof(string), "* %s has dropped their Desert Eagle.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 24);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "rifle", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 6 ] == 33)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your rifle.");
			format(string, sizeof(string), "* %s has dropped their rifle.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 33);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "ak47", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 5 ] == 30)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your AK-47.");
			format(string, sizeof(string), "* %s has dropped their AK-47.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 30);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "m4", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 5 ] == 31)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your M4.");
			format(string, sizeof(string), "* %s has dropped their M4.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 31);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "spas12", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 3 ] == 27)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your SPAS-12.");
			format(string, sizeof(string), "* %s has dropped their SPAS-12.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 27);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "sniper", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 6 ] == 34)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your sniper rifle.");
			format(string, sizeof(string), "* %s has dropped their sniper rifle.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 34);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "flowers", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 10 ] == 14)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your flowers.");
			format(string, sizeof(string), "* %s has dropped their flowers.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 14);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "knuckles", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 0 ] == 1)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your brass knuckles.");
			format(string, sizeof(string), "* %s has dropped their brass knuckles.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 1);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "baseballbat", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 1 ] == 5)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your baseball bat.");
			format(string, sizeof(string), "* %s has dropped their baseball bat.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 5);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "cane", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 10 ] == 15)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your cane.");
			format(string, sizeof(string), "* %s has dropped their cane.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			PlayerInfo[playerid][pGuns][ 10 ] = 0;
			RemovePlayerWeapon(playerid, 15);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "shovel", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 1 ] == 6)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your shovel.");
			format(string, sizeof(string), "* %s has dropped their shovel.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 6);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "golfclub", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 1 ] == 2)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your golf club.");
			format(string, sizeof(string), "* %s has dropped their golf club.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 2);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "katana") == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 1 ] == 8)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your katana.");
			format(string, sizeof(string), "* %s has dropped their katana.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 8);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "dildo", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 10 ] == 10)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your dildo.");
			format(string, sizeof(string), "* %s has dropped their dildo.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 10);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "parachute", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 11 ] == 46)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your parachute.");
			format(string, sizeof(string), "* %s has dropped their parachute.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 46);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "smoke", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 8 ] == 17)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your smoke grenade.");
			format(string, sizeof(string), "* %s has dropped their smoke grenade.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 17);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "chainsaw", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 1 ] == 9)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your chainsaw.");
			format(string, sizeof(string), "* %s has dropped their chainsaw.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 9);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "fire", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 9 ] == 42)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your fire extinguisher.");
			format(string, sizeof(string), "* %s has dropped their fire extinguisher.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 42);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "minigun", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 7 ] == 38)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your minigun.");
			format(string, sizeof(string), "* %s has dropped their minigun.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 38);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "poolcue", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][ 1 ] == 7)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your pool cue.");
			format(string, sizeof(string), "* %s has dropped their pool cue.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 7);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else if(strcmp(params, "goggles", true) == 0)
	{
		if(PlayerInfo[playerid][pGuns][11] == 44 || PlayerInfo[playerid][pGuns][11] == 45)
		{
			SendClientMessageEx(playerid, COLOR_LIGHTBLUE, "You have dropped your goggles.");
			format(string, sizeof(string), "* %s has dropped their goggles.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			RemovePlayerWeapon(playerid, 44);
		}
		else
		{
			SendClientMessageEx(playerid, COLOR_GREY, "You do not have that weapon!");
		}
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_GRAD1, "You have entered an invalid weapon name.");
	}
	return 1;
}

CMD:holster(playerid, params[])
{
	new string[128];
    if(!GetPVarType(playerid, "WeaponsHolstered"))
    {
        SetPlayerArmedWeapon(playerid, 0);
        SetPVarInt(playerid, "WeaponsHolstered", 1);
    	format(string, sizeof(string), "* %s holsters their weapon.", GetPlayerNameEx(playerid));
		ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		return 1;
    }
	else
	{
	    if(GetPVarInt(playerid, "TackleMode") == 0)
		{
			DeletePVar(playerid, "WeaponsHolstered");
			format(string, sizeof(string), "* %s unholsters their weapon.", GetPlayerNameEx(playerid));
			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			return 1;
		}
		else
		{
			return SendClientMessageEx(playerid, COLOR_GRAD2, "You must disable tackling before unholstering");
		}
	}
}