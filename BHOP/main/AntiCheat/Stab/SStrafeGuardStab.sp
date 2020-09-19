enum struct SStrafeGuardStab
{
	////////////////////////////////////////////////////////////////////////////////////////////////////
	float           Angle_Current;
	float           Angle_Last;

	float           TurnLast;

	float           Angle_Difference_Last;

	bool            AllowCalc;
	int             TickCount;
	int             Count;
	int             CountTickTurnPre;
	int             CountTickTurnPost;
	int             CountTickAngle;

	int             Number[STRAFE_GUARD_MAX_STAB];

	int 			PerfectStrafes;
	int				StrafesOverZero;

	bool            IsCheater;
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	void
	Refresh()
	{
		this.TickCount=0;
		this.Angle_Current = 0.0;
		this.Angle_Last = 0.0;

		this.TurnLast = 0.0;

		this.Angle_Difference_Last = 0.0;

		this.AllowCalc = false;

		this.Count = 0;
		this.CountTickTurnPre = 0;
		this.CountTickTurnPost = 0;
		this.CountTickAngle = 0;

		this.PerfectStrafes = 0;
		this.StrafesOverZero = 0;

		for(int i = 0 ; i < STRAFE_GUARD_MAX_STAB ; i++)
			this.Number[i] = 0;

		this.IsCheater = false;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	void
	CheckDataIntegrity()
	{
		this.PerfectStrafes = 0;
		this.StrafesOverZero = 0;

		for(int i = 0 ; i < STRAFE_GUARD_MAX_STAB ; i++)
		{
			if(this.Number[i] >= -1 && this.Number[i] <= 0)
				this.PerfectStrafes++;

			if(this.Number[i] >= 0 && this.Number[i] <= 3)
				this.StrafesOverZero++;
		}

		if(this.AllowCalc)
		{
			if(this.PerfectStrafes >= STRAFE_GUARD_MAX_STAB_SMOTH || 
				this.StrafesOverZero == STRAFE_GUARD_MAX_STAB)
			//if(this.PerfectStrafes >= STRAFE_GUARD_MAX_STAB_SMOTH)
				this.IsCheater = true;
			else
				this.IsCheater = false;
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	bool
	UpdateAngleDifference(
		float       AngleDifference)
	{
		bool        bReuslt;

		if(GetSignFloat(AngleDifference)!=GetSignFloat(this.Angle_Difference_Last))
			bReuslt = true;
		else
			bReuslt = false;

		this.Angle_Difference_Last = AngleDifference;

		return bReuslt;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	void
	UpdateCircle(
		bool        bAngleTurn,
		bool        bVelTurn)
	{    
		if(bVelTurn)
		{
			this.CountTickTurnPost = this.CountTickTurnPre;
			this.CountTickTurnPre = this.TickCount;
		}

		if(bAngleTurn)
		{
			int pre = this.CountTickAngle - this.CountTickTurnPre;
			int post = this.CountTickAngle - this.CountTickTurnPost;
	
			this.Number[this.Count] = Abs(pre) > Abs(post) ? post : pre;

			this.Count = (this.Count + 1) % STRAFE_GUARD_MAX_STAB;

			if(this.Count == (STRAFE_GUARD_MAX_STAB-1))
				this.AllowCalc = true;

			this.CountTickAngle = this.TickCount;
		}

		this.TickCount++;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	float
	UpdateAngle(
		float       Angle)
	{
		this.Angle_Last = this.Angle_Current;

		this.Angle_Current = Angle;
  
		return NormalizeAngle(this.Angle_Current - this.Angle_Last);
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	bool
	UpdateTurn(
		float       vel[3])
	{
		bool        bReuslt;
		float       Turn;
			 
		Turn = vel[0];
		
		if(Turn == 0)
			Turn = vel[1];

		if(GetSignFloat(Turn)!=GetSignFloat(this.TurnLast))
			bReuslt = true;
		else
			bReuslt = false;

		this.TurnLast = Turn;

		return bReuslt;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	bool 
	EnterNextData(
		float       Angle,
		float       vel[3])
	{  
		float check = FloatAbs(NormalizeAngle(Angle - this.Angle_Current));

		//если угол нулевой
		if(check < STRAFE_GUARD_MINSPEED_ANGLE)
			return false;

		float AngleSpeed = this.UpdateAngle(Angle);

		bool bAnglesTurn = this.UpdateAngleDifference(AngleSpeed);
		bool bVelTurn = this.UpdateTurn(vel);

		this.UpdateCircle(bAnglesTurn,bVelTurn);  

		return bAnglesTurn;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
    void 
    WriteLog(
        int         iSize,
        char[]      buffer)
    {  
        for(int i = 0 ; i < STRAFE_GUARD_MAX_STAB ; i++)
			 Format(buffer,iSize,"%s%d ",buffer,this.Number[i]);
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////   
}