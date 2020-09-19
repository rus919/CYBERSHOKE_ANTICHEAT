#include "Method\SStrafeGuardCircle.sp"
#include "Silent\SStrafeGuardSilent.sp"
#include "Stab\SStrafeGuardStab.sp"

enum struct SStrafeGuardCycle
{
	////////////////////////////////////////////////////////////////////////////////////////////////////
	int 		    client;
	
	bool            showstats;

	SStrafeGuardCircle 	StrafeGuardCircle;
	SStrafeGuardSilent 	StrafeGuardSilent;
	SStrafeGuardStab 	StrafeGuardStab;
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	void 
	CreateClient(
		int         client)
	{
		this.client = client;
		this.showstats = false;
		this.StrafeGuardCircle.Refresh();
		this.StrafeGuardSilent.Refresh();
		this.StrafeGuardStab.Refresh();
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	void
	PlayerRunCmd(
		float       vel[3],
		float       angles[3],
		int         mouse[2],
		int&        buttons)
	{
		if(!IsValidClient(this.client)) 
			return;

		if(!IsPlayerAlive(this.client))
			return;
		
		//отлов AHK OPTI MSL
		if(this.StrafeGuardCircle.EnterNextData(angles[1]))
		{
			if(this.StrafeGuardCircle.CheckDataIntegrity())
			{
				//данные проанализированы
				SStafeGuardMethod StafeGuardMethod; 
				StafeGuardMethod = this.StrafeGuardCircle.StafeGuardMethod;
				float Only = StafeGuardMethod.Only;
				float OnlyDivAll = StafeGuardMethod.OnlyDivAll;

				float l1 = StafeGuardMethod.LineSmooth[0];
				float l2 = StafeGuardMethod.LineSmooth[1];
				float l3 = StafeGuardMethod.LineSmooth[2];

				if(this.showstats)
				{
					char bufferchat[1024];
					char buffeconsole[1024];

					Format(bufferchat,sizeof(bufferchat),
						"(only = %.3f onlydivall = %.3f) %.3f %.3f %.3f",Only,OnlyDivAll,l1,l2,l3);

					this.StrafeGuardCircle.WriteLog(sizeof(buffeconsole),buffeconsole);

					for(int i = 0 ; i < MAXPLAYERS ; i++)
					{
						if(IsValidClient(i)) 
						{
							if(IsClientAdmin(i))
							{
								PrintToChat(i,bufferchat);
			  
								PrintToConsole(i,buffeconsole);
							}
						}
					}                  
				}

				if(StafeGuardMethod.IsCheater)
				{
					char buffelog[4096];
					char buffeconsole[4096];
					
					this.StrafeGuardCircle.WriteLog(sizeof(buffeconsole), buffeconsole);

					Format(buffelog,sizeof(buffelog),
						"%N(only = %.3f onlydivall = %.3f) (%.3f %.3f %.3f)\n%s",
						this.client,Only,OnlyDivAll,l1,l2,l3,buffeconsole);

					CatchCheater(this.client,STRAFE_GUARD_METHOD_CATCH,buffelog);
				}
			}
		}       

		//отлов стабилизатора  
		if(this.StrafeGuardStab.EnterNextData(angles[1],vel))
		{
			this.StrafeGuardStab.CheckDataIntegrity();
	  
			if(this.showstats)
			{
				char buffeconsole[4096];
					
				this.StrafeGuardStab.WriteLog(sizeof(buffeconsole), buffeconsole);
  
				for(int i = 0 ; i < MAXPLAYERS ; i++)
				{
					if(IsValidClient(i)) 
					{
						if(IsClientAdmin(i))
						{
							PrintToConsole(i,buffeconsole);
						}
					}
				}                  
			}  

			if(this.StrafeGuardStab.IsCheater)
			{
				char buffelog[4096];
				char buffeconsole[4096];
					
				this.StrafeGuardStab.WriteLog(sizeof(buffeconsole), buffeconsole);

				Format(buffelog,sizeof(buffelog),
					"%N(%s)",
					this.client,buffeconsole);

				CatchCheater(this.client,STRAFE_GUARD_STAB_CATCH, buffelog);
			}  
		} 

		//отлов сайленстрефа
		if(this.StrafeGuardSilent.EnterNextData(vel))
		{
			this.StrafeGuardSilent.CheckDataIntegrity();
	  
			if(this.showstats)
			{
				char bufferchat[1024];
  
				Format(bufferchat,sizeof(bufferchat),
					"%.3f %.3f",
					this.StrafeGuardSilent.LastCalc[0],
					this.StrafeGuardSilent.LastCalc[1]);

				for(int i = 0 ; i < MAXPLAYERS ; i++)
				{
					if(IsValidClient(i)) 
					{
						if(IsClientAdmin(i))
						{
							PrintToChat(i,bufferchat);
						}
					}
				}                  
			}  

			if(this.StrafeGuardSilent.IsCheater)
			{
				char buffelog[4096];

				Format(buffelog,sizeof(buffelog),
					"%N (%.3f %.3f)",
					this.client,
					this.StrafeGuardSilent.LastCalc[0],
					this.StrafeGuardSilent.LastCalc[1]);

				CatchCheater(this.client,STRAFE_GUARD_SILENT_CATCH,buffelog);
			}
		} 
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////
}