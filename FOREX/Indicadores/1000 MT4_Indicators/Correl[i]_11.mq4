//+------------------------------------------------------------------+
//|                                                       MIndex.mq4 |
//|                                  Copyright � 2005, Yuri Makarov. |
//|                                       http://mak.tradersmind.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2005, Yuri Makarov."
#property link      "http://mak.tradersmind.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 OrangeRed

extern string Curency = "USD";

double EurUsd[],UsdChf[],GbpUsd[],UsdJpy[],AudUsd[],UsdCad[];
double Idx[];

int init()
{
   IndicatorShortName(Curency);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Idx);
   return(0);
}

void start()
{
   ArrayCopySeries(EurUsd,MODE_CLOSE,"EURUSD");
   ArrayCopySeries(GbpUsd,MODE_CLOSE,"GBPUSD");
   ArrayCopySeries(AudUsd,MODE_CLOSE,"AUDUSD");
   ArrayCopySeries(UsdChf,MODE_CLOSE,"USDCHF");
   ArrayCopySeries(UsdJpy,MODE_CLOSE,"USDJPY");
   ArrayCopySeries(UsdCad,MODE_CLOSE,"USDCAD");

   int counted_bars=IndicatorCounted();
   double USD;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   for(int i=0; i<limit; i++)
   {
      USD = MathPow(UsdChf[i]*UsdJpy[i]*UsdCad[i]/EurUsd[i]/GbpUsd[i]/AudUsd[i],1./7.);
      if (Curency == "USD") Idx[i] = USD; 
      if (Curency == "EUR") Idx[i] = USD*EurUsd[i];
      if (Curency == "GBP") Idx[i] = USD*GbpUsd[i];
      if (Curency == "AUD") Idx[i] = USD*AudUsd[i];
      if (Curency == "CHF") Idx[i] = USD/UsdChf[i];
      if (Curency == "JPY") Idx[i] = USD/UsdJpy[i];
      if (Curency == "CAD") Idx[i] = USD/UsdCad[i];
   }
}


