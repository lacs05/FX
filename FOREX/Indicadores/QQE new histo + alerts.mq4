//+------------------------------------------------------------------+
//|                                                      QQE new.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  Green
#property indicator_color2  Gold
#property indicator_color3  Red
#property indicator_color4  DimGray
#property indicator_color5  Lime
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_levelcolor DimGray

//
//
//
//
//

extern int    SF         = 5;
extern int    RSIPeriod  = 14;
extern double WP         = 4.236;
extern double UpperBound = 60; 
extern double LowerBound = 40; 

//
//
//
//
//

extern bool alertsOn              = true;
extern bool alertsSignalLineCross = false;
extern bool alertsOnCurrent       = true;
extern bool alertsMessage         = true;
extern bool alertsSound           = false;
extern bool alertsEmail           = false;

//
//
//
//
//

double RsiMa[];
double Trend[];
double HistoU[];
double HistoM[];
double HistoD[];
double work[][6];

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
   SetIndexBuffer(0,HistoU); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,HistoM); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,HistoD); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,RsiMa);  SetIndexLabel(0, "QQE");
   SetIndexBuffer(4,Trend);  SetIndexLabel(1, "QQE trend");
      SetLevelValue(0,UpperBound-50);
      SetLevelValue(1,LowerBound-50);
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

#define iEma 0
#define iEmm 1
#define iQqe 2
#define iRsi 3
#define tQqe 4
#define tQqs 5

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,r,limit;
   
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
           limit = MathMin(Bars-counted_bars,Bars-1);
           if (ArrayRange(work,0) != Bars) ArrayResize(work,Bars); 

   //
   //
   //
   //
   //

   double alpha1 = 2.0/(SF+1.0);
   double alpha2 = 2.0/(RSIPeriod*2.0);
      
   for (i=limit, r=Bars-i-1; i>=0; i--,r++)
   {  
      work[r][iRsi] = work[r-1][iRsi] + alpha1*(iRSI(NULL,0,RSIPeriod,PRICE_CLOSE,i)   - work[r-1][iRsi]);
      work[r][iEma] = work[r-1][iEma] + alpha2*(MathAbs(work[r-1][iRsi]-work[r][iRsi]) - work[r-1][iEma]);
      work[r][iEmm] = work[r-1][iEmm] + alpha2*(work[r][iEma] - work[r-1][iEmm]);

      //
      //
      //
      //
      //

         double rsi0 = work[r  ][iRsi];
         double rsi1 = work[r-1][iRsi];
         double dar  = work[r  ][iEmm]*WP;
         double tr   = work[r-1][iQqe];
         double dv   = tr;
   
            if (rsi0 < tr) { tr = rsi0 + dar; if ((rsi1 < dv) && (tr > dv)) tr = dv; }
            if (rsi0 > tr) { tr = rsi0 - dar; if ((rsi1 > dv) && (tr < dv)) tr = dv; }
         
      //
      //
      //
      //
      //
         
         work[r][iQqe] = tr;
         work[r][tQqe] = work[r-1][tQqe];
         work[r][tQqs] = work[r-1][tQqs];
         RsiMa[i]      = work[r][iRsi]-50;
         Trend[i]      = tr           -50;
         HistoU[i]     =  EMPTY_VALUE;
         HistoM[i]     =  EMPTY_VALUE;
         HistoD[i]     =  EMPTY_VALUE;
   
         if (RsiMa[i] > (UpperBound-50))                           HistoU[i] = RsiMa[i];
         if (RsiMa[i] < (LowerBound-50))                           HistoD[i] = RsiMa[i];
         if (HistoU[i] == EMPTY_VALUE && HistoD[i] == EMPTY_VALUE) HistoM[i] = RsiMa[i];

      //
      //
      //
      //
      //
               
         if (RsiMa[i] > 0)        work[r][tQqe] =  1;
         if (RsiMa[i] < 0)        work[r][tQqe] = -1;
         if (RsiMa[i] > Trend[i]) work[r][tQqs] =  1;
         if (RsiMa[i] < Trend[i]) work[r][tQqs] = -1;
   }    
   
   //
   //
   //
   //
   //
   
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = Bars-1;
      else     whichBar = Bars-2;

      //
      //
      //
      //
      //
         
      if (alertsSignalLineCross)
      {
         if (work[whichBar][tQqs] != work[whichBar-1][tQqs])
         {
            if (work[whichBar][tQqs] ==  1) doAlert(" qqe line crossed signal line UP");
            if (work[whichBar][tQqs] == -1) doAlert(" qqe line crossed signal line DOWN");
         }         
      }
      else
      {
         if (work[whichBar][tQqe] != work[whichBar-1][tQqe])
         {
            if (work[whichBar][tQqe] ==  1) doAlert(" qqe line crossed 50 line UP");
            if (work[whichBar][tQqe] == -1) doAlert(" qqe line crossed 50 line DOWN");
         }         
      }
   }
   
   //
   //
   //
   //
   //
   
   return(0);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
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

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," QQE - ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"QQE"),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}


