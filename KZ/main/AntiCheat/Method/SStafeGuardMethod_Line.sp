enum struct SStafeGuardMethod_Line
{
	////////////////////////////////////////////////////////////////////////////////////////////////////
	float 		Result;
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	void 
	LineRegression(
		int 		iCount, 
		float[] 	mas, 
		float&		pA, 
		float& 		pB)
	{
		float 		xi = 0.0;
		float 		xxi = 0.0;

		float 		yi = 0.0;

		float 		xiyi = 0.0;

		for (int i = 0; i < iCount; i++)
		{
			float x = (i + 1.0);
			xi += x;
			xxi += x * x;
			yi += mas[i];
			xiyi += x * mas[i];
		}

		pA = (xi * yi - iCount * xiyi) / (xi * xi - iCount * xxi);
		pB = (xi * xiyi - xxi * yi) / (xi * xi - iCount * xxi);
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	void 
	SquareRegression(
		int 		iCount, 
		float[] 	mas, 
		float&		pA,
		float&		pB,
		float&		pC)
	{
		float 		xi = 0.0;
		float 		xxi = 0.0;
		float 		xxxi = 0.0;
		float 		xxxxi = 0.0;

		float 		yi = 0.0;

		float 		xiyi = 0.0;
		float 		xxiyi = 0.0;

		for (int i = 0; i < iCount; i++)
		{
			float x = (i + 1.0);
			float y = mas[i];
			xi += x;
			xxi += x * x;
			xxxi += x * x * x;
			xxxxi += x * x * x * x;
			yi += y;
			xiyi += x * y;
			xxiyi += x * x * y;
		}

		float a[3]; 
		a[0] = xxi;
		a[1] = xxxi;
		a[2] = xxxxi;
		float b[3];
		b[0] = xi;
		b[1] = xxi;
		b[2] = xxxi;
		float c[3];
		c[0] = float(iCount);
		c[1] = xi;
		c[2] = xxi;
		float vec[3];
		vec[0] = yi;
		vec[1] = xiyi;
		vec[2] = xxiyi;

		float tmp = 0.0;
		//убираем a1 в 0
		tmp = a[1] / a[0];

		a[1] -= a[0] * tmp;
		b[1] -= b[0] * tmp;
		c[1] -= c[0] * tmp;
		vec[1] -= vec[0] * tmp;

		//убираем a2 в 0
		tmp = a[2] / a[0];

		a[2] -= a[0] * tmp;
		b[2] -= b[0] * tmp;
		c[2] -= c[0] * tmp;
		vec[2] -= vec[0] * tmp;

		//убираем b2 в 0
		tmp = b[2] / b[1];

		b[2] -= b[1] * tmp;
		c[2] -= c[1] * tmp;
		vec[2] -= vec[1] * tmp;

		/*(*pC)= vec[2] / c[2];
		(*pB)*/
		//убираем c1 в 0
		tmp = c[1] / c[2];

		c[1] -= c[2] * tmp;
		vec[1] -= vec[2] * tmp;

		//убираем c0 в 0
		tmp = c[0] / c[2];

		c[0] -= c[2] * tmp;
		vec[0] -= vec[2] * tmp;

		//убираем b0 в 0
		tmp = b[0] / b[1];

		b[0] -= b[1] * tmp;
		vec[0] -= vec[1] * tmp;

		pA = vec[0] / a[0];
		pB = vec[1] / b[1];
		pC = vec[2] / c[2];
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	float 
	CalcDif(
		int 		iCount,
		float 		ALine, 
		float 		BLine,
		float 		ASquare, 
		float 		BSquare, 
		float 		CSquare)
	{
		float 		res[512];
		float 		avg = 0.0;

		for (int i = 0; i < iCount; i++)
		{
			float x = i + 1.0;

			float yLine = ALine * x + BLine;
			float ySquare = ASquare * x * x + BSquare * x + CSquare;
			res[i] = FloatAbs(FloatAbs(yLine) - FloatAbs(ySquare));

			avg += res[i];
		}

		//посчет среднего
		avg /= float(iCount);

		float displine = 0.0;
		for (int i = 0; i < iCount; i++)
		{
			displine += Pow(avg - res[i], 2.0);
		}
		displine = SquareRoot(displine / float(iCount));

		return displine;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	float 
	CalcMethod(
		int 		iCount,
		float[] 	mas)
	{
		float 		a1=0.0;
		float 		b1=0.0;
		
		float 		a2=0.0;
		float 		b2=0.0;
		float 		c2=0.0;

		this.LineRegression(iCount,mas,a1,b1);
		this.SquareRegression(iCount,mas,a2,b2,c2);

		return this.CalcDif(iCount, a1,b1,a2,b2,c2);
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	void
	Create(
		int 		iCount,
		float[] 	mas)
	{
		this.Result = this.CalcMethod(iCount, mas);
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////////////////
	float 
	GetResult()
	{
		return this.Result;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////
}