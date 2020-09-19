#include "SStafeGuardMethod.sp"

enum struct SStrafeGuardCircle
{
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    float           Angle_Current;
    float           Angle_Last;
    float           Angle_Speed;

    float           Angle_Difference_Current;
    float           Angle_Difference_Last;
    float           Angle_Acceleration;

    float           Angle_CircleSpeed[STRAFE_GUARD_MAX_CIRCLE];
    float           Angle_CircleAcceleration[STRAFE_GUARD_MAX_CIRCLE];

    bool            Angle_CircleChange[STRAFE_GUARD_MAX_CIRCLE];

    int             PikStartPosition[STRAFE_GUARD_COUNT_PIK];

    SStafeGuardMethod StafeGuardMethod;
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    void 
    Refresh()
    {
        this.Angle_Current = 0.0;
        this.Angle_Last = 0.0;
        this.Angle_Speed = 0.0;

        this.Angle_Difference_Current = 0.0;
        this.Angle_Difference_Last = 0.0;
        this.Angle_Acceleration = 0.0;
        
        for(int i = 0 ; i < STRAFE_GUARD_MAX_CIRCLE ; i++)
        {
            this.Angle_CircleSpeed[i] = 0.0;
            this.Angle_CircleAcceleration[i] = 0.0;
            this.Angle_CircleChange[i] = false;
        }

        for(int i = 0 ; i < STRAFE_GUARD_COUNT_PIK ; i++)
        {
            this.PikStartPosition[i] = 0;
        }
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
    float
    UpdateAngleDifference(
        float       AngleDifference)
    {
        this.Angle_Difference_Last = this.Angle_Difference_Current;

        this.Angle_Difference_Current = AngleDifference;
  
        return this.Angle_Difference_Current - this.Angle_Difference_Last;
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    void
    UpdateCircle()
    {
        for(int i = 1 ; i < STRAFE_GUARD_MAX_CIRCLE ; i++)
        {
            this.Angle_CircleSpeed[i-1] = this.Angle_CircleSpeed[i];
            this.Angle_CircleAcceleration[i-1] = this.Angle_CircleAcceleration[i];
            this.Angle_CircleChange[i-1] = this.Angle_CircleChange[i];
        }

        this.Angle_CircleSpeed[STRAFE_GUARD_MAX_CIRCLE-1] = this.Angle_Speed;
        this.Angle_CircleAcceleration[STRAFE_GUARD_MAX_CIRCLE-1] = this.Angle_Acceleration;

        if(GetSignFloat(this.Angle_Difference_Current) != GetSignFloat(this.Angle_Difference_Last))
        {
            this.Angle_CircleChange[STRAFE_GUARD_MAX_CIRCLE-1] = true;
        }
        else
        {
            this.Angle_CircleChange[STRAFE_GUARD_MAX_CIRCLE-1] = false;
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    bool
    CheckValidPik(
        int         start)
    {
        int         end = start + STRAFE_GUARD_LEN_PIK;
        
        int         pik = start + STRAFE_GUARD_CENTER_PIK;

        int         SignCheck[2]={0, 0};
        int         iFlag = 0;

        for(int i = start ; i < end ; i++)
        {
            if(FloatAbs(this.Angle_CircleSpeed[i]) < STRAFE_GUARD_MINSPEED_ANGLE)
                return false;  

            if(i == pik)
            {
                if(!this.Angle_CircleChange[i])
                    return false;  

                iFlag++;
            }
            else
            {
                if(this.Angle_CircleChange[i])
                    return false;
            }  

            SignCheck[iFlag] += GetSignFloat(this.Angle_CircleSpeed[i]);
        }

        if(Abs(SignCheck[0])==STRAFE_GUARD_CENTER_PIK &&
        Abs(SignCheck[1]) == (STRAFE_GUARD_CENTER_PIK + 1))
            return true;

        return false;   
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    bool
    CheckPik(
        int         start)
    {
        int         end = start + STRAFE_GUARD_LEN_PIK;
        
        int         pik = start + STRAFE_GUARD_CENTER_PIK;

        for(int i = start ; i < end ; i++)
        {
  
            if(i == pik)
            {
                if(!this.Angle_CircleChange[i])
                    return false;  
            }
            else
            {
                if(this.Angle_CircleChange[i])
                    return false;
            }  
        }

        return true;   
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    bool
    CheckDataIntegrity()
    {
        int         PikStartPosition[STRAFE_GUARD_COUNT_PIK];

        int         iCountPik = STRAFE_GUARD_COUNT_PIK - 1;

        int         minlen = STRAFE_GUARD_LEN_PIK + STRAFE_GUARD_MINLEN_LINE;
        int         maxlen = STRAFE_GUARD_LEN_PIK + STRAFE_GUARD_MAXLEN_LINE;

        int         start = 0;
        int         last = STRAFE_GUARD_MAX_CIRCLE - STRAFE_GUARD_LEN_PIK;
        int         end = last;

        if(!this.CheckValidPik(last))
            return false;
    
        for(int i = end ; i >= start; i--)
        {
            if(this.CheckPik(i))
            {
                if(!this.CheckValidPik(i))
                    return false;

                PikStartPosition[iCountPik] = i;
                iCountPik--;

                if(iCountPik == -1)
                    break;         
            }
        }

        for(int i = 0 ; i < STRAFE_GUARD_COUNT_PIK ; i++)
        {
            for(int j = i ; j < STRAFE_GUARD_COUNT_PIK ; j++)
            {
                if(i!=j)
                {
                    int first = PikStartPosition[i] + STRAFE_GUARD_CENTER_PIK;
                    int two = PikStartPosition[j] + STRAFE_GUARD_CENTER_PIK;
                    
                    float ffirst = FloatAbs(this.Angle_CircleAcceleration[first]) ;
                    float ftwo = FloatAbs(this.Angle_CircleAcceleration[two]);

                    float diff = FloatAbs(ffirst - ftwo);

                    if(diff > STRAFE_GUARD_MINDIFF_PIK)
                        return false;                 
                }
            }
        }

        //данные не соответствуют константам
        for(int i = 1 ; i < STRAFE_GUARD_COUNT_PIK ; i++)
        {
            //длина между пиками слишком мала относительно введенных констант
            if((PikStartPosition[i] - PikStartPosition[i-1]) < minlen)
                return false;

            //длина между пиками слишком велика относительно введенных констант
            if((PikStartPosition[i] - PikStartPosition[i-1]) >= maxlen)
                return false;
        }
      
        //нашлись не все пики
        if(iCountPik!=-1)
            return false;

        for(int i = 0 ; i < STRAFE_GUARD_COUNT_PIK ; i++)
        {
            this.PikStartPosition[i] = PikStartPosition[i];
        }
        
        //если дошло до этого места , значит можно проводить анализ
        this.StafeGuardMethod.CalcMethod(PikStartPosition, 
                                    this.Angle_CircleSpeed, 
                                    this.Angle_CircleAcceleration);

        return true;
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    bool 
    EnterNextData(
        float       Angle)
    {  
        //годен ли угол для записи
        float check = FloatAbs(NormalizeAngle(Angle - this.Angle_Current));

        if(check > STRAFE_GUARD_MAXSPEED_ANGLE)
        {
            this.Refresh();
            this.Angle_Current = Angle;
            return false;
        }

        //если угол нулевой
        if(check < STRAFE_GUARD_MINSPEED_ANGLE)
            return false;

        this.Angle_Speed = this.UpdateAngle(Angle);
        this.Angle_Acceleration = this.UpdateAngleDifference(this.Angle_Speed);
        this.UpdateCircle();    

        return true;
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////   

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    void 
    WriteLog(
        int         iSize,
        char[]      buffer)
    {  
        int     start = this.PikStartPosition[0];
        int     end = this.PikStartPosition[STRAFE_GUARD_COUNT_PIK-1] + STRAFE_GUARD_LEN_PIK;

        int     iCount=0;

        for(int j = start ; j < end ; j++)
        {
            Format(buffer,iSize,"%s%d %.3f %.3f %d\n",buffer,j,
                this.Angle_CircleSpeed[j],this.Angle_CircleAcceleration[j], this.Angle_CircleChange[j]);

            iCount++;
        }

        Format(buffer,iSize,"%s[end]",buffer);
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////   
}