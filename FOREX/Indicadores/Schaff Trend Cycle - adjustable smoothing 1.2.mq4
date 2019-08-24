//+------------------------------------------------------------------+
//|                                           Schaff Trend Cycle.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1  clrDodgerBlue
#property indicator_color2  clrSilver
#property indicator_color3  clrSandyBrown
#property indicator_color4  clrSilver
#property indicator_color5  clrDodgerBlue
#property indicator_color6  clrDodgerBlue
#property indicator_color7  clrSandyBrown
#property indicator_color8  clrSandyBrown
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
#property indicator_width8  2
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property strict

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};

extern ENUM_TIMEFRAMES TimeFrame    = PERIOD_CURRENT; // Time frame
extern int             STCPeriod    = 10;             // Schaff period
extern enPrices        Price        = pr_close;       // Price
extern int             FastMAPeriod = 23;             // Fast macd period
extern int             SlowMAPeriod = 50;             // Slow macd period
extern double          SmoothPeriod = 3;              // Smoothing period
extern int             FloatPeriod  = 0;              // Levels period (<0, fixed levels, <=1 for same as Shaff period)
extern double          FloatUp      = 90;             // Levels up %
extern double          FloatDown    = 10;             // Levels down %
extern bool            Interpolate  = true;           // Interpolate in multi time frame mode?

double stcBuffer[],stcBufferUA[],stcBufferUB[],stcBufferDA[],stcBufferDB[],levup[],levmi[],levdn[],macdBuffer[],fastKBuffer[],fastDBuffer[],fastKKBuffer[],slope[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,STCPeriod,Price,FastMAPeriod,SlowMAPeriod,SmoothPeriod,FloatPeriod,FloatUp,FloatDown,_buff,_y)

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
   IndicatorBuffers(14);
      SetIndexBuffer( 0,levup);
      SetIndexBuffer( 1,levmi);
      SetIndexBuffer( 2,levdn);
      SetIndexBuffer( 3,stcBuffer);
      SetIndexBuffer( 4,stcBufferUA);
      SetIndexBuffer( 5,stcBufferUB);
      SetIndexBuffer( 6,stcBufferDA);
      SetIndexBuffer( 7,stcBufferDB);
      SetIndexBuffer( 8,macdBuffer);
      SetIndexBuffer( 9,fastKBuffer);
      SetIndexBuffer(10,fastDBuffer);
      SetIndexBuffer(11,fastKKBuffer);
      SetIndexBuffer(12,slope);
      SetIndexBuffer(13,count);
       indicatorFileName = WindowExpertName();
       TimeFrame         = MathMax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" Schaff Trend Cycle ("+(string)STCPeriod+","+(string)FastMAPeriod+","+(string)SlowMAPeriod+","+(string)SmoothPeriod+","+(string)FloatPeriod+")");
   return(0);
}

int deinit()
{
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

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1); count[0] = limit;
         if (TimeFrame!=_Period)
         {
            limit = (int)MathMax(limit,MathMin(Bars-1,_mtfCall(13,0)*TimeFrame/Period()));
            if (slope[limit] ==-1) CleanPoint(limit,stcBufferDA,stcBufferDB);
            if (slope[limit] == 1) CleanPoint(limit,stcBufferUA,stcBufferUB);
            for(int i=limit; i>=0; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
                  slope[i]       = _mtfCall(12,y);
                  levup[i]       = _mtfCall(0,y);
                  levmi[i]       = _mtfCall(1,y);
                  levdn[i]       = _mtfCall(2,y);
                  stcBuffer[i]   = _mtfCall(3,y);
                  stcBufferDA[i] = EMPTY_VALUE;
                  stcBufferDB[i] = EMPTY_VALUE;
                  stcBufferUA[i] = EMPTY_VALUE;
                  stcBufferUB[i] = EMPTY_VALUE;
                  
                  //
                  //
                  //
                  //
                  //
                  
                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  #define _interpolate(_buff) _buff[i+k] = _buff[i]+(_buff[i+n]-_buff[i])*k/n
                     int n,k; datetime time = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                        for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++)
                        {
                            _interpolate(stcBuffer);
                            _interpolate(levup);
                            _interpolate(levmi);
                            _interpolate(levdn);
                        }                            
               }
               for(int i=limit; i>=0; i--)
               {
                  if (slope[i]==-1) PlotPoint(i,stcBufferDA,stcBufferDB,stcBuffer);
                  if (slope[i]== 1) PlotPoint(i,stcBufferUA,stcBufferUB,stcBuffer);
               }                  
               return(0);
         }
         
   //
   //
   //
   //
   //
   
   double alpha = 2.0/(1.0+SmoothPeriod);
   int floatPeriod = (FloatPeriod>0) ? FloatPeriod : STCPeriod;
   if (slope[limit] == 1) CleanPoint(limit,stcBufferUA,stcBufferUB);
      for(int i = limit; i >= 0 && !_StopFlag; i--)
      {
         double price = getPrice(Price,Open,Close,High,Low,i,Bars);
         macdBuffer[i] = iEma(price,FastMAPeriod,i,Bars,0)-iEma(price,SlowMAPeriod,i,Bars,1);

            //
            //
            //
            //
            //
      
            double lowMacd  = macdBuffer[ArrayMinimum(macdBuffer,STCPeriod,i)];
            double highMacd = macdBuffer[ArrayMaximum(macdBuffer,STCPeriod,i)]-lowMacd;
                              fastKBuffer[i] = (highMacd > 0) ? 100*((macdBuffer[i]-lowMacd)/highMacd) : (i<Bars-1) ? fastKBuffer[i+1] : 0;
                              fastDBuffer[i] = (i<Bars-1) ? fastDBuffer[i+1]+alpha*(fastKBuffer[i]-fastDBuffer[i+1]) : fastKBuffer[i];
               
            double lowStoch  = fastDBuffer[ArrayMinimum(fastDBuffer,STCPeriod,i)];
            double highStoch = fastDBuffer[ArrayMaximum(fastDBuffer,STCPeriod,i)]-lowStoch;
                               fastKKBuffer[i] = (highStoch > 0) ? 100*((fastDBuffer[i]-lowStoch)/highStoch) : (i<Bars-1) ? fastKKBuffer[i+1] : 0;
                               stcBuffer[i]    = (i<Bars-1) ? stcBuffer[i+1]+alpha*(fastKKBuffer[i]-stcBuffer[i+1]) : fastKKBuffer[i];
                               stcBufferUA[i]  = EMPTY_VALUE;
                               stcBufferUB[i]  = EMPTY_VALUE;
                               stcBufferDA[i]  = EMPTY_VALUE;
                               stcBufferDB[i]  = EMPTY_VALUE;
                               if (FloatPeriod<0)
                               {
                                 levdn[i] = FloatDown;
                                 levmi[i] = EMPTY_VALUE;
                                 levup[i] = FloatUp;
                               }
                               else
                               {
                                 double min = stcBuffer[ArrayMinimum(stcBuffer,floatPeriod,i)];
                                 double max = stcBuffer[ArrayMaximum(stcBuffer,floatPeriod,i)];
                                 double rng = max-min;
                                 levdn[i] = min+rng*FloatDown/100;
                                 levmi[i] = min+rng*0.5;
                                 levup[i] = min+rng*FloatUp/100;
                               }
                               slope[i] = (stcBuffer[i]>levup[i]) ? 1 : (stcBuffer[i]<=levdn[i]) ? -1 : (stcBuffer[i]<levup[i] && (stcBuffer[i]>levdn[i])) ? 0 : (i<Bars-1) ? slope[i+1] : 0;
            if (slope[i]==-1) PlotPoint(i,stcBufferDA,stcBufferDB,stcBuffer);
            if (slope[i]== 1) PlotPoint(i,stcBufferUA,stcBufferUB,stcBuffer);
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
//

#define _emaInstances 2
double workEma[][_emaInstances];
double iEma(double price, double period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= bars) ArrayResize(workEma,bars); r=bars-r-1;

   //
   //
   //
   //
   //
      
   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

#define _priceInstances     1
#define _priceInstancesSize 4
double workHa[][_priceInstances*_priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= bars) ArrayResize(workHa,bars); instanceNo*=_priceInstancesSize; int r = bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                                workHa[r][instanceNo+2] = haOpen;
                                workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}   