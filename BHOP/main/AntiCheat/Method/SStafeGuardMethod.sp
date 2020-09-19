#include "SStafeGuardMethod_Line.sp"

enum struct SStafeGuardMethod
{
	////////////////////////////////////////////////////////////////////////////////////////////////////
	float           Only;
	float           All;

	float           OnlyDivAll;

	float           LineSmooth[STRAFE_GUARD_COUNT_LINE];

	bool 			IsCheater;
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	void 
	CalcMethod(
		int[]       PikStartPosition,
		float[]     AngleSpeed,
		float[]     AngleAcceleration)
	{
		//считаем пики
		this.Only = 0.0;
		this.All = 0.0;
		this.IsCheater = false;

		int iOnlyCount = 0;
		int iAllCount = 0;

		for(int i = 0 ; i < STRAFE_GUARD_COUNT_PIK ; i++)
		{
			int     start = PikStartPosition[i];
			int     end = PikStartPosition[i] + STRAFE_GUARD_LEN_PIK;

			int     iCount=0;
			for(int j = start ; j < end ; j++)
			{
				if(iCount == STRAFE_GUARD_CENTER_PIK)
				{
					//чентр пики
					this.Only += FloatAbs(AngleAcceleration[j]);
					iOnlyCount++;
				}
				else
				{
					//оконечные значения пики
					this.All += FloatAbs(AngleAcceleration[j]);
					iAllCount++;
				}

				iCount++;
			}
		}

		this.Only /= float(iOnlyCount);
		this.All /= float(iAllCount);
		this.OnlyDivAll = this.Only / this.All;

		//считаем линии
		for(int i = 0 ; i < STRAFE_GUARD_COUNT_PIK - 1 ; i++)
		{
			int     start = PikStartPosition[i] + STRAFE_GUARD_CENTER_PIK + 1;
			int     end = PikStartPosition[i + 1] + 1;
			int     iCount = end - start;

			SStafeGuardMethod_Line StafeGuardMethod_Line;

			StafeGuardMethod_Line.Create(iCount, AngleSpeed[start]);
			this.LineSmooth[i] = StafeGuardMethod_Line.GetResult();
		}

		if(this.Only > STRAFE_GUARD_CHEATER_ONLY &&
			this.OnlyDivAll > STRAFE_GUARD_CHEATER_ONLYDIVALL)
			this.IsCheater = true;

		for(int i = 0 ; i < STRAFE_GUARD_COUNT_LINE ; i++)
		{
			if(this.LineSmooth[i] > STRAFE_GUARD_CHEATER_LINE)
				this.IsCheater = false;
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

}