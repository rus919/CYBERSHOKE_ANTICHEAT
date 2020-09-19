////////////////////////////////////////////////////////////////////////////////////////////////////
//константы для Method
#define STRAFE_GUARD_METHOD_CATCH "Strafe(Ahk|Opti|MSL)"

#define IS_STRAFE_GUARD_METHOD_CATCH (!strcmp(CatchReason,STRAFE_GUARD_METHOD_CATCH))

#define STRAFE_GUARD_MAX_CIRCLE 100

#define STRAFE_GUARD_COUNT_PIK 4
#define STRAFE_GUARD_COUNT_LINE 3

#define STRAFE_GUARD_LEN_PIK 5
#define STRAFE_GUARD_CENTER_PIK 2
#define STRAFE_GUARD_MINDIFF_PIK 1.3

#define STRAFE_GUARD_MINLEN_LINE 1
#define STRAFE_GUARD_MAXLEN_LINE 30

#define STRAFE_GUARD_MAXSPEED_ANGLE 8.0
#define STRAFE_GUARD_MINSPEED_ANGLE 0.001

#define STRAFE_GUARD_CHEATER_ONLY 3.0
#define STRAFE_GUARD_CHEATER_ONLYDIVALL 3.0
#define STRAFE_GUARD_CHEATER_LINE 0.3
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//константы для Stab
#define STRAFE_GUARD_STAB_CATCH "StrafeStabilizer"

#define IS_STRAFE_GUARD_STAB_CATCH (!strcmp(CatchReason,STRAFE_GUARD_STAB_CATCH))

#define STRAFE_GUARD_MAX_STAB_SMOTH 37
#define STRAFE_GUARD_MAX_STAB 40
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//константы для Silent
#define STRAFE_GUARD_SILENT_CATCH "Silent"

#define IS_STRAFE_GUARD_SILENT_CATCH (!strcmp(CatchReason,STRAFE_GUARD_SILENT_CATCH))

#define STRAFE_GUARD_MAX_SILENT_COUNT 64
#define STRAFE_GUARD_MAX_SILENT_DETECT 0.25
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//путь для общего логирования
char            g_AntiCheatPath[PLATFORM_MAX_PATH];

char            g_AdminTestPath[PLATFORM_MAX_PATH];

char            g_StrafeGuardPathMethod[PLATFORM_MAX_PATH];
char            g_StrafeGuardPathMethodStab[PLATFORM_MAX_PATH];
char            g_StrafeGuardPathMethodSilent[PLATFORM_MAX_PATH];
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//подключение библиотек
#include "main\Lib\Lib.sp"

#include "main\AntiCheat\SStrafeGuard.sp"
#include <NOP_Core>
#undef REQUIRE_PLUGIN
#include <cs_admin>

////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//Объявление глобальный кастомных переменных
SStrafeGuard    StrafeGuard;
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//прописываем описание плагина
public Plugin myinfo = 
{
	name = "AntiCheat",
	author = PLUGIN_AUTHOR,
	description = "AntiCheat StrafeGuard",
	version = PLUGIN_VERSION,
}
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
int        	g_CatchCheater[MAXPLAYERS  + 1];
bool        g_CatchCheaterWork[MAXPLAYERS  + 1] = {true, ...};

static Action Timer_CatchCheater(Handle timer, int client)
{
	g_CatchCheater[client]++;
	g_CatchCheaterWork[client] = true;

	return Plugin_Stop;
}
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//обнаружен читер
void 
CatchCheater(
	int 		client,
	char[]      CatchReason,
	char[]      CatchLog)
{
	//к админу не применятся данные команды
	if(!GetAdminFlag(GetUserAdmin(client),  Admin_Root , Access_Effective))
	{	
		if(g_CatchCheaterWork[client])
		{
			g_CatchCheaterWork[client] = false;
			StrafeGuard.ConnectPlayer(client);
			CreateTimer(5.0, Timer_CatchCheater, client);

			char 		map[128];
			char 		steam[32];
			char 		buffer[1024];

			char ip[64];
			NOP_GetVar(0, VAR_SIP, ip);
			int port = NOP_GetVar(0, VAR_SPORT);

			//узнаем стимид
			GetClientAuthId(client, AuthId_Engine, steam, sizeof(steam));

			//узнаем текущую карту
			GetCurrentMap(map, sizeof(map));

			//формируем общий лог
			Format(buffer, sizeof(buffer),"\n**************************");
			Format(buffer, sizeof(buffer),"%s\n%s %N %s %s",buffer,map,client,steam,CatchReason);
			Format(buffer, sizeof(buffer),"%s\n**************************",buffer);

			//предупреждение
			if(g_CatchCheater[client] == 0)
			{
				//PrintToChatAll("\x01\04 \x03[AntiCheat] \x02%N detected \x04%s",client, CatchReason);	
			}
			
			//баним
			if(g_CatchCheater[client] > 0)
			{
				char ReasonBuffer[256];
				FormatEx(ReasonBuffer, sizeof(ReasonBuffer), "%s | %s:%i", CatchReason, ip, port);
				//FormatEx(ReasonBuffer, sizeof(ReasonBuffer), "%s", CatchReason);

				ServerCommand("sm_delstats #%d", GetClientUserId(client));
				if(IS_STRAFE_GUARD_METHOD_CATCH)
				{
					CS_Admin_SetBan(0, client, 259200, ReasonBuffer);
					//ServerCommand("sm_ban #%d %d \"%s | %s:%i\"", GetClientUserId(client), 43200, CatchReason, ip, port);
				}
				else if(IS_STRAFE_GUARD_STAB_CATCH)
				{
					CS_Admin_SetBan(0, client, 259200, ReasonBuffer);
					//ServerCommand("sm_ban #%d %d \"%s | %s:%i\"", GetClientUserId(client), 43200, CatchReason, ip, port);
				}
				else if(IS_STRAFE_GUARD_SILENT_CATCH)
				{
					CS_Admin_SetBan(0, client, 0, ReasonBuffer);
					//ServerCommand("sm_ban #%d %d \"%s | %s:%i\"", GetClientUserId(client), 0, CatchReason, ip, port);
				}
				PrintToChatAll("\x01\04 \x03[AntiCheat] \x02banned \x04%N \x04%s", client, CatchReason);
			}
			
			//пишем в зависимости от причины в разные логи
			if(IS_STRAFE_GUARD_METHOD_CATCH)
				LogToFile(g_StrafeGuardPathMethod, CatchLog);
			else if(IS_STRAFE_GUARD_STAB_CATCH)
				LogToFile(g_StrafeGuardPathMethodStab, CatchLog);
			else if(IS_STRAFE_GUARD_SILENT_CATCH)
				LogToFile(g_StrafeGuardPathMethodSilent, CatchLog);

			//пишем общий лог
			LogToFile(g_AntiCheatPath, buffer);
		}
	}
	else
	{
		//PrintToChatAll("\x01\04 \x04[AntiCheat] \x01Admin \x02%N \x01detected \x04%s", client, CatchReason);
		//LogToFile(g_AdminTestPath, CatchLog);
	}	
}
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//точка входа в плагин
public void 
OnPluginStart()
{	
	//подключаем файл переводов
	LoadTranslations("common.phrases");

	//точка входа для StrafeGuard
	StrafeGuard.Start();

	//команда для просмотра значений анализа
	RegAdminCmd("sm_strafecheck", Client_StrafeCheck, ADMFLAG, "sm_strafecheck <#userid|name>");

	//вкл/выкл античита 
	RegAdminCmd("sm_strafeguard", Cmd_StrafeGuard, ADMFLAG, "sm_strafeguard <1|0>");

	//путь к общим, кратким логам
	BuildPath(Path_SM, 
		g_AntiCheatPath, 
		sizeof(g_AntiCheatPath), 
		"logs/MultiServer/AntiCheatNew.log");

	//лог с детектами админа
	BuildPath(Path_SM, 
		g_AdminTestPath, 
		sizeof(g_AdminTestPath), 
		"logs/MultiServer/AntiCheatAdminTest.log");

	//путь к логам Method
	BuildPath(Path_SM, 
		g_StrafeGuardPathMethod, 
		sizeof(g_StrafeGuardPathMethod), 
		"logs/MultiServer/StrafeLogNewMethod.log");

	//путь к логам Stab
	BuildPath(Path_SM, 
		g_StrafeGuardPathMethodStab, 
		sizeof(g_StrafeGuardPathMethodStab), 
		"logs/MultiServer/StrafeLogNewMethodStab.log");

	//путь к логам Silent
	BuildPath(Path_SM, 
		g_StrafeGuardPathMethodSilent, 
		sizeof(g_StrafeGuardPathMethodSilent), 
		"logs/MultiServer/StrafeLogNewMethodSilent.log");
}
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//калбэк команды sm_strafecheck
public Action 
Client_StrafeCheck(
	int         client, 
	int         args)
{
	SCmd        Cmd;

	//создаем переменную введенной команды
	if(Cmd.Create(client,args))
	{
		//выключение или включение просмотра значений анализа
		StrafeGuard.Client_StrafeCheck(Cmd);

		return Plugin_Handled;
	}  
	
	ReplyToCommand(client, "[SM] Usage: sm_strafecheck <#userid|name>");
	return Plugin_Handled;
}
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//калбэк команды sm_strafeguard
public Action 
Cmd_StrafeGuard(
	int         client, 
	int         args)
{
	SCmd        Cmd;

	//создаем переменную введенной команды
	if(Cmd.Create(client,args))
	{
		//выключение или включение просмотра значений анализа
		StrafeGuard.Cmd_StrafeGuard(Cmd);

		return Plugin_Handled;
	}  
	
	ReplyToCommand(client, "[SM] Usage: sm_strafeguard <0|1>");
	return Plugin_Handled;
}
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//подключился игрок
public void 
OnClientPostAdminCheck(
	int         client)
{
	g_CatchCheater[client] = 0;
	g_CatchCheaterWork[client] = true;

	StrafeGuard.ConnectPlayer(client);
}
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
//обработка действий игрока
public Action 
OnPlayerRunCmd(
	int         client, 
	int&        buttons, 
	int&        impulse, 
	float       vel[3], 
	float       angles[3], 
	int&        weapon, 
	int&        subtype, 
	int&        cmdnum, 
	int&        tickcount, 
	int&        seed, 
	int         mouse[2])
{
	//проверка что игрок действительно на сервере
	if(!IsValidClient(client)) 
		return Plugin_Continue;
	
	StrafeGuard.PlayerRunCmd(client,vel,angles,mouse,buttons); 
	
	return Plugin_Continue;
}
////////////////////////////////////////////////////////////////////////////////////////////////////