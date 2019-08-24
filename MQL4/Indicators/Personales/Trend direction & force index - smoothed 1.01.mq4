//+------------------------------------------------------------------+
//|                                Trend direction & force index.mq4 |
//|                                                           mladen |
//|                                                                  |
//|                                                                  |
//| original metastock indicator made by Piotr Wojdylo               |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers  8
#property indicator_maximum  1
#property indicator_minimum -1
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame              = PERIOD_CURRENT; // Time frame
extern int             trendPeriod            = 20;             // Trend period
extern double          TriggerUp              =  0.05;          // Upper trigger
extern double          TriggerDown            = -0.05;          // Lower trigger
extern double          SmoothLength           = 5;              // Smoothe period
extern double          SmoothPhase            = 0;              // Smooth phase
extern bool            ColorChangeOnZeroCross = false;          // Color change on zero line cross?
extern color           ColorNeutral           = clrDarkGray;    // Color for neutral
extern color           ColorUp                = clrDeepSkyBlue; // Color for up
extern color           ColorDn                = clrSandyBrown;  // Color for down
extern int             LinesWidth             = 2;              // Lines width
extern int             HistoWidth             = 2;              // Histogram width
extern bool            Interpolate            = true;           // Interpolate in multi time frame mode?

//
//
//
//
//

double  TrendBuffer[],TrendBufferUa[],TrendBufferUb[],TrendBufferDa[],TrendBufferDb[],histou[],histod[],histom[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,0,trendPeriod,TriggerUp,TriggerDown,SmoothLength,SmoothPhase,ColorChangeOnZeroCross,_buff,_ind)


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(10);
   SetIndexBuffer(0,histou);        SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,HistoWidth,ColorUp);
   SetIndexBuffer(1,histod);        SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,HistoWidth,ColorDn);
   SetIndexBuffer(2,histom);        SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,HistoWidth);
   SetIndexBuffer(3,TrendBuffer);   SetIndexStyle(3,EMPTY,EMPTY,LinesWidth,ColorNeutral);
   SetIndexBuffer(4,TrendBufferUa); SetIndexStyle(4,EMPTY,EMPTY,LinesWidth,ColorUp);
   SetIndexBuffer(5,TrendBufferUb); SetIndexStyle(5,EMPTY,EMPTY,LinesWidth,ColorUp);
   SetIndexBuffer(6,TrendBufferDa); SetIndexStyle(6,EMPTY,EMPTY,LinesWidth,ColorDn);
   SetIndexBuffer(7,TrendBufferDb); SetIndexStyle(7,EMPTY,EMPTY,LinesWidth,ColorDn);
   SetIndexBuffer(8,trend);
   SetIndexBuffer(9,count);
      for (int i=0; i<8; i++) SetIndexLabel(i,"Trend direction & force("+(string)trendPeriod+")");
                              SetLevelValue(0,TriggerUp);
                              SetLevelValue(1,TriggerDown);
                              SetLevelStyle(STYLE_DOT,0,ColorNeutral);
                              

      //
      //
      //
      //
      //
         
         indicatorFileName = WindowExpertName();
         TimeFrame         = MathMax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" trend direction & force ("+(string)trendPeriod+")");
   return(0);
}
int deinit() { return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double workTrend[][3];
#define _MMA   0
#define _SMMA  1
#define _TDF   2

//
//
//
//
//

int start()
{
   SetIndexStyle(2,EMPTY,EMPTY,HistoWidth,(color)ChartGetInteger(0,CHART_COLOR_BACKGROUND));
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1); count[0] = limit;
         if (TimeFrame!=_Period)
         {
            limit = (int)MathMax(limit,MathMin(Bars-1,_mtfCall(9,0)*TimeFrame/Period()));
            if (trend[limit]== 1) CleanPoint(limit,TrendBufferUa,TrendBufferUb);
            if (trend[limit]==-1) CleanPoint(limit,TrendBufferDa,TrendBufferDb);
            for (int i=limit; i>=0; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
                  TrendBuffer[i]   = _mtfCall(3,y);
                  trend[i]         = _mtfCall(8,y);
                  TrendBufferUa[i] = EMPTY_VALUE;
                  TrendBufferUb[i] = EMPTY_VALUE;
                  TrendBufferDa[i] = EMPTY_VALUE;
                  TrendBufferDb[i] = EMPTY_VALUE;
                  histou[i]        = EMPTY_VALUE;
                  histod[i]        = EMPTY_VALUE;
                  histom[i]        = EMPTY_VALUE;
                  
                  //
                  //
                  //
                  //
                  //
                  
                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                   #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                   int n,k; datetime time = iTime(NULL,TimeFrame,y);
                      for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                      for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++)
                        _interpolate(TrendBuffer);
            }
            for (int i=limit; i>=0; i--)
            {
                  if (trend[i] ==  1) { PlotPoint(i,TrendBufferUa,TrendBufferUb,TrendBuffer); histou[i] = TrendBuffer[i]; histom[i] = TriggerUp; }
                  if (trend[i] == -1) { PlotPoint(i,TrendBufferDa,TrendBufferDb,TrendBuffer); histod[i] = TrendBuffer[i]; histom[i] = TriggerDown; }
            }                  
            return(0);
         }            

   //
   //
   //
   //
   //
   
      if (ArrayRange(workTrend,0)!=Bars) ArrayResize(workTrend,Bars);
      if (trend[limit]== 1) CleanPoint(limit,TrendBufferUa,TrendBufferUb);
      if (trend[limit]==-1) CleanPoint(limit,TrendBufferDa,TrendBufferDb);
      
      //
      //
      //
      //
      //
      
      double alpha = 2.0 /(trendPeriod+1.0); 
      for (int i=limit, r=Bars-i-1; i>=0; i--, r++)
      {
               workTrend[r][_MMA]  =         iMA(NULL,0,trendPeriod,0,MODE_EMA,PRICE_CLOSE,i);
               workTrend[r][_SMMA] = (r>0) ? workTrend[r-1][_SMMA]+alpha*(workTrend[r][_MMA]-workTrend[r-1][_SMMA]) : workTrend[r][_MMA];
                     double impetmma  = (r>0) ? workTrend[r][_MMA]  - workTrend[r-1][_MMA]  : workTrend[r][_MMA];
                     double impetsmma = (r>0) ? workTrend[r][_SMMA] - workTrend[r-1][_SMMA] : workTrend[r][_SMMA];
                     double divma     = MathAbs(workTrend[r][_MMA]-workTrend[r][_SMMA])/Point;
                     double averimpet = (impetmma+impetsmma)/(2*Point);
               workTrend[r][_TDF]  = divma*MathPow(averimpet,3);

               //
               //
               //
               //
               //
               
               double absValue = absHighest(workTrend,_TDF,trendPeriod*3,r);
               if (absValue > 0)
                     TrendBuffer[i]  = iSmooth(workTrend[r][_TDF]/absValue,SmoothLength,SmoothPhase,i);
               else  TrendBuffer[i]  = iSmooth(                       0.00,SmoothLength,SmoothPhase,i);

               //
               //
               //
               //
               //
               
               TrendBufferUa[i] = EMPTY_VALUE;
               TrendBufferUb[i] = EMPTY_VALUE;
               TrendBufferDa[i] = EMPTY_VALUE;
               TrendBufferDb[i] = EMPTY_VALUE;
               trend[i]         = (i<Bars-1) ? trend[i+1] : 0;
                  if (ColorChangeOnZeroCross)
                  {
                     if (TrendBuffer[i]>0) trend[i] =  1;
                     if (TrendBuffer[i]<0) trend[i] = -1;
                  }
                  else
                  {
                     if (TrendBuffer[i]>TriggerUp)                                   trend[i] =  1;
                     if (TrendBuffer[i]<TriggerDown)                                   trend[i] = -1;
                     if (TrendBuffer[i]>TriggerDown && TrendBuffer[i]<TriggerUp) trend[i] =  0;
                  }                     
                  if (trend[i] ==  1) { PlotPoint(i,TrendBufferUa,TrendBufferUb,TrendBuffer); histou[i] = TrendBuffer[i]; histom[i] = TriggerUp; }
                  if (trend[i] == -1) { PlotPoint(i,TrendBufferDa,TrendBufferDb,TrendBuffer); histod[i] = TrendBuffer[i]; histom[i] = TriggerDown; }
      }
      return(0);         
   }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double absHighest(double& array[][], int index, int length, int shift)
{
   double result = 0.00;
   
   for (int i = length-1; i>=0 && shift-i>=0; i--)
      if (result < MathAbs(array[shift-i][index]))
          result = MathAbs(array[shift-i][index]);
   return(result);          
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
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

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

double wrk[][10];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9


//
//
//
//
//

double iSmooth(double price, double length, double phase, int i, int s=0)
{
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { int k=0; for(; k<7; k++) wrk[r][k+s]=price; for(; k<10; k++) wrk[r][k+s]=0; return(price); }

   //
   //
   //
   //
   //
   
      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - wrk[r-1][bsmax+s];
      double del2   = price - wrk[r-1][bsmin+s];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = MathMin(r,10);
	
         wrk[r][volty+s] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
         wrk[r][vsum+s] =	wrk[r-1][vsum+s] + (wrk[r][volty+s]-wrk[r-forBar][volty+s])*div;
         
         //
         //
         //
         //
         //
   
         wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
               double dVolty = (wrk[r][avolty+s] > 0) ? wrk[r][volty+s]/wrk[r][avolty+s] : 0;
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

      //
      //
      //
      //
      //
	        
   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;
	
   //
   //
   //
   //
   //
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
         wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
         wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   //
   //
   //
   //
   //

   return(wrk[r][4+s]);
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
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}
