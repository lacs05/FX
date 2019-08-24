//+------------------------------------------------------------------+
//|                                           Schaff Trend Cycle.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  clrDarkGreen
#property indicator_color2  clrMaroon
#property indicator_color3  clrMaroon
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
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
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT; // Time frame
extern int             STCPeriod       = 10;             // Schaff period
extern int             GaussPeriod     = 50;             // Gaussian period
extern int             GaussOrder      = 4;              // Gaussian order
extern enPrices        GaussPrice      = pr_close;       // Price to use
extern double          SignalPeriod    = 3;              // Signal period
extern bool            alertsOn        = true;           // Turn alerts on?
extern bool            alertsOnCurrent = false;          // Alerts on current bar?
extern bool            alertsMessage   = true;           // Alerts should display a message?
extern bool            alertsSound     = true;           // Alerts should play a sound?
extern bool            alertsEmail     = false;          // Alerts should send an email?
extern bool            alertsNotify    = false;          // Alerts should send notification?
extern string          soundFile       = "alert2.wav";   // Sound file to use for sounds:
extern bool            Interpolate     = true;           // Interpolate in multi time frame mode?

//
//
//
//
//

double stcBuffer[];
double stcBufferUA[];
double stcBufferUB[];
double vel[];
double fastKBuffer[];
double fastDBuffer[];
double fastKKBuffer[];
double slope[];

string indicatorFileName;
bool   returnBars;

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
   IndicatorBuffers(8);
      SetIndexBuffer(0,stcBuffer);
      SetIndexBuffer(1,stcBufferUA);
      SetIndexBuffer(2,stcBufferUB);
      SetIndexBuffer(3,vel);
      SetIndexBuffer(4,fastKBuffer);
      SetIndexBuffer(5,fastDBuffer);
      SetIndexBuffer(6,fastKKBuffer);
      SetIndexBuffer(7,slope);
       indicatorFileName = WindowExpertName();
       returnBars        = TimeFrame==-99;
       TimeFrame         = fmax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" Schaff Trend Cycle gaussian velocity ("+(string)STCPeriod+","+(string)GaussPeriod+","+(string)SignalPeriod+")");
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
         int limit = fmin(Bars-counted_bars,Bars-1);
         if (returnBars) { stcBuffer[0] = limit+1;  return(0); }
         if (TimeFrame!=_Period)
         {
            #define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,STCPeriod,GaussPeriod,GaussOrder,GaussPrice,SignalPeriod,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,soundFile,_buff,_y)
            limit = (int)fmax(limit,fmin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
            if (slope[limit] == 1) CleanPoint(limit,stcBufferUA,stcBufferUB);
            for(int i=limit; i>=0; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
                  stcBuffer[i]   = _mtfCall(0,y);
                  slope[i]       = _mtfCall(7,y);
                  stcBufferUA[i] = EMPTY_VALUE;
                  stcBufferUB[i] = EMPTY_VALUE;
                  
                  //
                  //
                  //
                  //
                  //
                  
                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
                  //
                  //
                  //
                  //
                  //
                  
                  #define _interpolate(buff,i,k,n) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                     int n,k; datetime time = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                        for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) _interpolate(stcBuffer,i,k,n);
               }
               for(int i=limit; i>=0; i--) if (slope[i]==-1) PlotPoint(i,stcBufferUA,stcBufferUB,stcBuffer);
               return(0);
         }
         
         

   //
   //
   //
   //
   //
   
   if (slope[limit] == 1) CleanPoint(limit,stcBufferUA,stcBufferUB);
   double alpha = 2.0/(1.0+SignalPeriod);
   for(int i = limit; i >= 0; i--)
   {
      double price  = getPrice(GaussPrice,Open,Close,High,Low,i);
             vel[i] = iGFilter(price,GaussPeriod,GaussOrder,i,0)-iGFilter(price,GaussPeriod,GaussOrder+1,i,1);
                      if (i>=Bars-1) continue;

      //
      //
      //
      //
      //
      
      double lowMacd  = minValue(vel,i);
      double highMacd = maxValue(vel,i)-lowMacd;
         if (highMacd > 0)
               fastKBuffer[i] = 100*((vel[i]-lowMacd)/highMacd);
         else  fastKBuffer[i] = fastKBuffer[i+1];
               fastDBuffer[i] = fastDBuffer[i+1]+alpha*(fastKBuffer[i]-fastDBuffer[i+1]);
               
      //
      //
      //
      //
      //
                     
      double lowStoch  = minValue(fastDBuffer,i);
      double highStoch = maxValue(fastDBuffer,i)-lowStoch;
         if (highStoch > 0)
               fastKKBuffer[i] = 100*((fastDBuffer[i]-lowStoch)/highStoch);
         else  fastKKBuffer[i] = fastKKBuffer[i+1];
               stcBuffer[i]    = stcBuffer[i+1]+alpha*(fastKKBuffer[i]-stcBuffer[i+1]);
      
         //
         //
         //
         //
         //
      
         stcBufferUA[i] = EMPTY_VALUE;
         stcBufferUB[i] = EMPTY_VALUE;
         slope[i] = (stcBuffer[i]>stcBuffer[i+1]) ? 1 : (stcBuffer[i]<stcBuffer[i+1]) ? -1 : (i<Bars-1) ? slope[i+1] : 0;
         if (slope[i]==-1) PlotPoint(i,stcBufferUA,stcBufferUB,stcBuffer);
   }  
   
   //
   //
   //
   //
   //
   
   if (alertsOn)
   {
     int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
     if (slope[whichBar] != slope[whichBar+1])
     if (slope[whichBar] == 1)
           doAlert("sloping up");
     else  doAlert("sloping down");       
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

#define gfInstances 2
int    periods[gfInstances];
double coeffs[][gfInstances*3];
double filters[][gfInstances];
double iGFilter(double price, int period, int order, int i, int instanceNo=0)
{
   if (ArrayRange(filters,0)!=Bars)  ArrayResize(filters,Bars);
   if (ArrayRange(coeffs,0)<order+1) ArrayResize(coeffs,order+1);
   if (periods[instanceNo]!=period)
   {
      periods[instanceNo]=period;
         double b = (1.0 - MathCos(2.0*M_PI/period))/(MathPow(MathSqrt(2.0),2.0/order) - 1.0);
         double a = -b + MathSqrt(b*b + 2.0*b);
         for(int r=0; r<=order; r++)
         {
             coeffs[r][instanceNo*3+0] = fact(order)/(fact(order-r)*fact(r));
             coeffs[r][instanceNo*3+1] = MathPow(    a,r);
             coeffs[r][instanceNo*3+2] = MathPow(1.0-a,r);
         }
   }

   //
   //
   //
   //
   //
   
   i = Bars-i-1;
   filters[i][instanceNo] = price*coeffs[order][instanceNo*3+1];
      double sign = 1;
         for (int r=1; r <= order && i-r>=0; r++, sign *= -1.0)
                  filters[i][instanceNo] += sign*coeffs[r][instanceNo*3+0]*coeffs[r][instanceNo*3+2]*filters[i-r][instanceNo];
   return(filters[i][instanceNo]);
}

//
//
//
//
//

double fact(int n)
{
   double a=1;
         for(int i=1; i<=n; i++) a*=i;
   return(a);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

double minValue(double& array[],int shift)
{
   double minValue = array[shift];
            for (int i=1; i<STCPeriod && shift+i<Bars; i++) minValue = fmin(minValue,array[shift+i]);
   return(minValue);
}
double maxValue(double& array[],int shift)
{
   double maxValue = array[shift];
            for (int i=1; i<STCPeriod && shift+i<Bars; i++) maxValue = fmax(maxValue,array[shift+i]);
   return(maxValue);
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

#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=4;
         int r = Bars-i-1;
         
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
         double haHigh  = fmax(high[i], fmax(haOpen,haClose));
         double haLow   = fmin(low[i] , fmin(haOpen,haClose));

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

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," ",timeFrameToString(_Period)+" Schaff Trend Cycle ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Schaff Trend Cycle "),message);
             if (alertsNotify)  SendNotification(message);
             if (alertsSound)   PlaySound(soundFile);
      }
}
 