//+------------------------------------------------------------------+
//|                                             Schaff Trend RSX.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers    3
#property indicator_color1     DeepSkyBlue
#property indicator_color2     PaleVioletRed
#property indicator_color3     PaleVioletRed
#property indicator_width1     2
#property indicator_width2     2
#property indicator_width3     2
#property indicator_minimum    -5
#property indicator_maximum    105
#property indicator_level1     20
#property indicator_level2     80
#property indicator_levelcolor DimGray


//
//
//
//
//

extern ENUM_TIMEFRAMES    TimeFrame    = PERIOD_CURRENT;
extern int                FastMAPeriod = 23;
extern int                SlowMAPeriod = 50;
extern ENUM_APPLIED_PRICE MacdPrice    = PRICE_CLOSE;
extern int                RsxLength    = 9;
extern bool               Interpolate  = true;

//
//
//
//
//

double strBuffer[];
double stRsxDa[];
double stRsxDb[];
double macd[];
double slope[];
double wrkBuffer[][12];
string indicatorFileName;
bool   returnBars;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(5);
   SetIndexBuffer(0,strBuffer);
   SetIndexBuffer(1,stRsxDa);
   SetIndexBuffer(2,stRsxDb);
   SetIndexBuffer(3,macd);
   SetIndexBuffer(4,slope);
   
   indicatorFileName = WindowExpertName();
   returnBars        = TimeFrame==-99;
   TimeFrame         = MathMax(TimeFrame,_Period);

   IndicatorShortName(timeFrameToString(TimeFrame)+" Schaff Trend Rsx ("+FastMAPeriod+","+SlowMAPeriod+","+RsxLength+")");
return(0);
}

int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { strBuffer[0] = MathMin(limit+1,Bars-1); return(0); }
      

   //
   //
   //
   //
   //

   if (TimeFrame == Period())
   {
      if (ArrayRange(wrkBuffer,0) != Bars) ArrayResize(wrkBuffer,Bars);
      if (slope[limit]==-1) CleanPoint(limit,stRsxDa,stRsxDb);
      double Kg = (3.0)/(2.0+RsxLength);
      double Hg = 1.0-Kg;
      for(i=limit, r=Bars-i-1; i>=0; i--, r++)
      {
         macd[i] = iMA(NULL,0,FastMAPeriod,0,MODE_EMA,MacdPrice,i)-iMA(NULL,0,SlowMAPeriod,0,MODE_EMA,MacdPrice,i);               
         if (i==(Bars-1)) { for (int c=0; c<12; c++) wrkBuffer[r][c] = 0; continue; }  

        //
        //
        //
        //
        //
      
        double roc = macd[i]-macd[i+1];
        double roa = MathAbs(roc);
        for (int k=0; k<3; k++)
        {
            int kk = k*2;
               wrkBuffer[r][kk+0] = Kg*roc                + Hg*wrkBuffer[r-1][kk+0];
               wrkBuffer[r][kk+1] = Kg*wrkBuffer[r][kk+0] + Hg*wrkBuffer[r-1][kk+1]; roc = 1.5*wrkBuffer[r][kk+0] - 0.5 * wrkBuffer[r][kk+1];
               wrkBuffer[r][kk+6] = Kg*roa                + Hg*wrkBuffer[r-1][kk+6];
               wrkBuffer[r][kk+7] = Kg*wrkBuffer[r][kk+6] + Hg*wrkBuffer[r-1][kk+7]; roa = 1.5*wrkBuffer[r][kk+6] - 0.5 * wrkBuffer[r][kk+7];
        }
        if (roa != 0)
             strBuffer[i] = MathMax(MathMin((roc/roa+1.0)*50.0,100.00),0.00); 
        else strBuffer[i] = 50.0; 
        
         //
         //
         //
         //
         //
            
         stRsxDa[i] = EMPTY_VALUE;
         stRsxDb[i] = EMPTY_VALUE;
         slope[i] = slope[i+1];
            if (strBuffer[i]<strBuffer[i+1]) slope[i] = -1;
            if (strBuffer[i]>strBuffer[i+1]) slope[i] =  1;
            if (slope[i] == -1) PlotPoint(i,stRsxDa,stRsxDb,strBuffer);                       
      }         
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   if (slope[limit]==-1) CleanPoint(limit,stRsxDa,stRsxDb);
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         strBuffer[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,FastMAPeriod,SlowMAPeriod,MacdPrice,RsxLength,0,y); 
         slope[i]     = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,FastMAPeriod,SlowMAPeriod,MacdPrice,RsxLength,4,y); 
         stRsxDa[i]   = EMPTY_VALUE;
         stRsxDb[i]   = EMPTY_VALUE;
         
         //
         //
         //
         //
         //
               
         if (!Interpolate || y==iBarShift(NULL,TimeFrame,Time[i-1])) continue;

         //
         //
         //
         //
         //
 
         datetime time = iTime(NULL,TimeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(int j = 1; j < n; j++) strBuffer[i+j] = strBuffer[i] + (strBuffer[i+n] - strBuffer[i]) * j/n;
    }
    if (slope[i] == -1) PlotPoint(i,stRsxDa,stRsxDb,strBuffer); 
return(0);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
