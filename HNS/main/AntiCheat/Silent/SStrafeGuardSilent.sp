enum struct SStrafeGuardSilent
{
	////////////////////////////////////////////////////////////////////////////////////////////////////
	int         CurrentTick;

	int         TurnCount[2];

	float       LastVel[2];

	float       LastCalc[2];

	bool        IsCheater;
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	void
	Refresh()
	{
		this.CurrentTick = 0;

		for(int i = 0 ; i < 2 ; i++)
		{
			this.TurnCount[i] = 0;
			this.LastVel[i] = 0.0;
			this.LastCalc[i] = 0.0;
		}

		this.IsCheater = false;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	bool
	UpdateTurn0(
		float       vel)
	{
		bool        bResult;

		if(GetSignFloat(vel)!=GetSignFloat(this.LastVel[0]) && FloatAbs(this.LastVel[0])>100 && FloatAbs(vel)>100)
			bResult = true;
		else
			bResult = false;

		this.LastVel[0] = vel;

		return bResult;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////
 
	////////////////////////////////////////////////////////////////////////////////////////////////////
	bool
	UpdateTurn1(
		float       vel)
	{
		bool        bResult;
		
		if(GetSignFloat(vel)!=GetSignFloat(this.LastVel[1]) && FloatAbs(this.LastVel[1])>100 && FloatAbs(vel)>100)
			bResult = true;
		else
			bResult = false;

		this.LastVel[1] = vel;

		return bResult;
	}    
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	void
	CheckDataIntegrity()
	{
		for(int i = 0 ; i < 2 ; i++)
			this.LastCalc[i] = float(this.TurnCount[i])/float(STRAFE_GUARD_MAX_SILENT_COUNT);
		

		if(this.LastCalc[0] > STRAFE_GUARD_MAX_SILENT_DETECT ||
			this.LastCalc[1] > STRAFE_GUARD_MAX_SILENT_DETECT)
			this.IsCheater = true;
		else
			this.IsCheater = false;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	bool 
	EnterNextData(
		float       vel[3])
	{  
		if(this.CurrentTick==STRAFE_GUARD_MAX_SILENT_COUNT)
			this.Refresh();

		bool bTurn0 = this.UpdateTurn0(vel[0]);
		bool bTurn1 = this.UpdateTurn1(vel[1]);

		if(bTurn0)
			this.TurnCount[0]++;

		if(bTurn1)
			this.TurnCount[1]++;

		this.CurrentTick++;

		if(this.CurrentTick==STRAFE_GUARD_MAX_SILENT_COUNT)
			return true;

		return false;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////
}