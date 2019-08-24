//+------------------------------------------------------------------+
//|                                             Schaff Trend RSX.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers    3
#property indicator_color1     clrDeepSkyBlue
#property indicator_color2     clrSandyBrown
#property indicator_color3     clrSandyBrown
#property indicator_width1     3
#property indicator_width2     3
#property indicator_width3     3
#property indicator_minimum    -5
#property indicator_maximum    105
#property indicator_level1     20
#property indicator_level2     80
#property strict

//
//
//
//
//

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
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased   // Heiken ashi trend biased price
};
enum enTimeFrames
{
   tf_cu  = 0,              // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_d1  = PERIOD_D1,      // Daily
   tf_w1  = PERIOD_W1,      // Weekly
   tf_mb1 = PERIOD_MN1,     // Monthly
   tf_cus = 12345678        // Custom time frame
};

extern enTimeFrames       TimeFrame       = tf_cu;    // Time frame
extern int                TimeFrameCustom = 0;        // Custom time frame to use (if custom time frame used)
extern int                FastMAPeriod    = 23;       // Fast ma period
extern int                SlowMAPeriod    = 50;       // Slow ma period
extern enPrices           MacdPrice       = pr_close; // Price to use for calculation
extern int                RsxLength       = 9;        // RSX calculation period
extern double             RsxWeight       = 1.5;      // RSX "weight"
extern bool               alertsOn        = false;    // Turn alerts on
extern bool               alertsOnCurrent = true;     // Alerts on still opened bar
extern bool               alertsMessage   = true;     // Alerts should show popup message
extern bool               alertsSound     = false;    // Alerts should play a sound
extern bool               alertsEmail     = false;    // Alerts should send email
extern bool               alertsPushNotif = false;    // Alerts should send notification
extern bool               Interpolate     = true;

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
         if (TimeFrameCustom==0) TimeFrameCustom = MathMax(TimeFrameCustom,_Period);
         if (TimeFrame!=tf_cus)
               TimeFrame = MathMax(TimeFrame,_Period);
         else  TimeFrame = (enTimeFrames)TimeFrameCustom;

   IndicatorShortName(timeFrameToString(TimeFrame)+" Schaff Trend Rsx ("+(string)FastMAPeriod+","+(string)SlowMAPeriod+","+(string)RsxLength+","+(string)RsxWeight+")");
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
         double price = getPrice(MacdPrice,Open,Close,High,Low,i);
         macd[i] = iEma(price,FastMAPeriod,i,0)-iEma(price,SlowMAPeriod,i,1);               
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
               wrkBuffer[r][kk+1] = Kg*wrkBuffer[r][kk+0] + Hg*wrkBuffer[r-1][kk+1]; roc = RsxWeight*wrkBuffer[r][kk+0] - (2.0-RsxWeight) * wrkBuffer[r][kk+1];
               wrkBuffer[r][kk+6] = Kg*roa                + Hg*wrkBuffer[r-1][kk+6];
               wrkBuffer[r][kk+7] = Kg*wrkBuffer[r][kk+6] + Hg*wrkBuffer[r-1][kk+7]; roa = RsxWeight*wrkBuffer[r][kk+6] - (2.0-RsxWeight) * wrkBuffer[r][kk+7];
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
      manageAlerts();   
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   if (slope[limit]==-1) CleanPoint(limit,stRsxDa,stRsxDb);
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         strBuffer[i] = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,FastMAPeriod,SlowMAPeriod,MacdPrice,RsxLength,RsxWeight,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsPushNotif,0,y); 
         slope[i]     = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,FastMAPeriod,SlowMAPeriod,MacdPrice,RsxLength,RsxWeight,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsPushNotif,4,y); 
         stRsxDa[i]   = EMPTY_VALUE;
         stRsxDb[i]   = EMPTY_VALUE;
         
         //
         //
         //
         //
         //
               
         if (!Interpolate || (i>0 &&y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;

         //
         //
         //
         //
         //
 
         int n,j; datetime time = iTime(NULL,TimeFrame,y);
            for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(j = 1; i+n < Bars && i+j < Bars && j < n; j++) strBuffer[i+j] = strBuffer[i] + (strBuffer[i+n] - strBuffer[i]) * j/n;
    }
    for (i=limit; i>=0; i--) if (slope[i] == -1) PlotPoint(i,stRsxDa,stRsxDb,strBuffer); 
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

double workEma[][2];
double iEma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= Bars) ArrayResize(workEma,Bars); r=Bars-r-1;
   if (period<=1) { workEma[r][instanceNo]=price; return(price); }

   //
   //
   //
   //
   //
      
   workEma[r][instanceNo] = price;
   double alpha = 2.0 / (1.0+period);
   if (r>0)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
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

double workHa[][4];
double getPrice(int price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (price>=pr_haclose && price<=pr_hatbiased)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo *= 4;
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
         
         switch (price)
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
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (price)
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

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (slope[whichBar] != slope[whichBar+1])
      {
         if (slope[whichBar] ==  1) doAlert(whichBar,"slope changed up");
         if (slope[whichBar] == -1) doAlert(whichBar,"slope changed down");
      }
   }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Schaff trend rsx - "+doWhat;
          if (alertsMessage)   Alert(message);
          if (alertsEmail)     SendMail(StringConcatenate(Symbol()," Schaff trend rsx "),message);
          if (alertsPushNotif) SendNotification(StringConcatenate(Symbol()," Schaff trend rsx "+message));
          if (alertsSound)     PlaySound("alert2.wav");
   }
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
         if (tf!=tf_cu)
               return("m"+(string)tf);
         else  return("");
}
