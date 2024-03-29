//+------------------------------------------------------------------+
//|                                       Waddah_Attar_Explosion.mq4 |
//|                              Copyright © 2006, Eng. Waddah Attar |
//|                                          waddahattar@hotmail.com |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2006, Eng. Waddah Attar"
#property  link      "waddahattar@hotmail.com"
//----
#property  indicator_separate_window
#property  indicator_buffers 6
#property  indicator_color1  Green
#property  indicator_color2  Red
#property  indicator_color3  Gold
#property  indicator_color4  Blue
#property  indicator_color5  Lime
#property  indicator_color6  Magenta
#property  indicator_minimum 0.0
//----
extern int  Sensetive = 150;
extern bool UseATRdeadzone = True;
extern int  DeadZonePip = 3000;
extern int  ATR_Period  = 14;
extern double ATR_Multiplier = 4.0;
extern int  ExplosionPower = 15;
extern int  TrendPower = 15;
extern int  FastMA = 20;
extern int  FastMAShift = 0;
extern ENUM_MA_METHOD  FastMA_Method = MODE_SMMA;
extern ENUM_APPLIED_PRICE  FastMA_Applied_Price;
extern int  SlowMA = 40;
extern int  SlowMAShift = 0;
extern ENUM_MA_METHOD  SlowMA_Method = MODE_SMMA;
extern ENUM_APPLIED_PRICE  SlowMA_Applied_Price;
extern int  BBandPeriod = 20;
extern double BBandDeviation = 4.0;
extern int  BBandShift  = 0;
extern ENUM_MA_METHOD  BBand_MA_Method = MODE_EMA;
extern ENUM_APPLIED_PRICE  BBand_Applied_Price;
extern bool UseVolumeCalculation = True;
extern int  VolumePeriod = 365;
extern int  SignalMAperiod = 14;
extern int  SignalMAshift = 0;
extern ENUM_MA_METHOD  SignalMAmethod = MODE_LWMA;

extern bool AlertWindow = true;
extern int  AlertCount = 500;
extern bool AlertLong = true;
extern bool AlertShort = true;
extern bool AlertExitLong = true;
extern bool AlertExitShort = true;
//----
double   ind_buffer1[];
double   ind_buffer2[];
double   ind_buffer3[];
double   ind_buffer4[];
double   ind_buffer5[];
double   ind_buffer6[];

//----
int LastTime1 = 1;
int LastTime2 = 1;
int LastTime3 = 1;
int LastTime4 = 1;
int Status = 0, PrevStatus = -1;
double bask, bbid;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexStyle(3, DRAW_LINE, STYLE_DOT, 1);
   SetIndexStyle(4, DRAW_LINE, STYLE_DASHDOTDOT, 1);
   SetIndexStyle(5, DRAW_LINE, STYLE_DASHDOTDOT, 1);
//----   
   SetIndexBuffer(0, ind_buffer1);
   SetIndexBuffer(1, ind_buffer2);
   SetIndexBuffer(2, ind_buffer3);
   SetIndexBuffer(3, ind_buffer4);
   SetIndexBuffer(4, ind_buffer5);
   SetIndexBuffer(5, ind_buffer6);
//----   
   IndicatorShortName("Waddah Attar Explosion: [S(" + Sensetive + 
                      ") - DZ(" + ((iATR(NULL, 0, ATR_Period, 1))*ATR_Multiplier) + ") - EP(" + ExplosionPower + 
                      ") - TP(" + TrendPower + ")]");
   //Comment("copyright waddahwttar@hotmail.com");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double Trend1, Trend2, Explo1, Explo2, Dead, ATR_price, MAG, MAR;
   double pwrt, pwre;
   int    limit, i, counted_bars = IndicatorCounted();
//----
   if(counted_bars < 0) 
       return(-1);
//----
   if(counted_bars > 0) 
       counted_bars--;
   limit = Bars - counted_bars;
//----
   for(i = limit - 1; i >= 0; i--)
     {
 //      ma1 = iCustom(Symbol(),0,"H4kl0n\AllVolumeAverage_v2_600",0,14,8,28,11,8,5,i);
 //      ma2 = iCustom(Symbol(),0,"H4kl0n\AllVolumeAverage_v2_600",0,14,8,28,11,8,6,i);
       Trend1 = ((iMA(NULL, 0, FastMA, FastMAShift, FastMA_Method, FastMA_Applied_Price, i) - 
                 iMA(NULL, 0, SlowMA, SlowMAShift, SlowMA_Method, SlowMA_Applied_Price, i)) -
                (iMA(NULL, 0, FastMA, FastMAShift, FastMA_Method, FastMA_Applied_Price, i + 1) - 
                 iMA(NULL, 0, SlowMA, SlowMAShift, SlowMA_Method, SlowMA_Applied_Price, i + 1)))     *Sensetive *NormalizedVolume(i);
       Trend2 = ((iMA(NULL, 0, FastMA, FastMAShift, FastMA_Method, FastMA_Applied_Price, i + 2) - 
                 iMA(NULL, 0, SlowMA, SlowMAShift, SlowMA_Method, SlowMA_Applied_Price, i + 2)) -
                (iMA(NULL, 0, FastMA, FastMAShift, FastMA_Method, FastMA_Applied_Price, i + 3) - 
                 iMA(NULL, 0, SlowMA, SlowMAShift, SlowMA_Method, SlowMA_Applied_Price, i + 3)))     *Sensetive *NormalizedVolume(i);
       Explo1 = (iStdDev(NULL, 0, BBandPeriod, BBandShift, BBand_MA_Method, BBand_Applied_Price, i))*BBandDeviation;
       Explo2 = (iStdDev(NULL, 0, BBandPeriod, BBandShift, BBand_MA_Method, BBand_Applied_Price, i + 1))*BBandDeviation;
       
       
       ATR_price = (iATR(NULL, 0, ATR_Period, i))*ATR_Multiplier;
       Dead = Point * DeadZonePip;

       
       ind_buffer1[i] = 0;
       ind_buffer2[i] = 0;
       ind_buffer3[i] = 0;
       ind_buffer4[i] = 0;
       if(Trend1 >= 0)
           ind_buffer1[i] = Trend1;
       if(Trend1 < 0)
           ind_buffer2[i] = (-1*Trend1);
       ind_buffer3[i] = Explo1;
       if(UseATRdeadzone) ind_buffer4[i] = ATR_price; else ind_buffer4[i] = Dead;
       
       MAG = iMAOnArray(ind_buffer1,0,SignalMAperiod,SignalMAshift,SignalMAmethod,i);
       MAR = iMAOnArray(ind_buffer2,0,SignalMAperiod,SignalMAshift,SignalMAmethod,i);
       ind_buffer5[i] = MAG;
       ind_buffer6[i] = MAR;       
       
       if(i == 0)
         {
           if(Trend1 > 0 && Trend1 > Explo1 && Trend1 > Dead && 
              Explo1 > Dead && Explo1 > Explo2 && Trend1 > Trend2 && 
              LastTime1 < AlertCount && AlertLong == true && Ask != bask)
             {
               pwrt = 100*(Trend1 - Trend2) / Trend1;
               pwre = 100*(Explo1 - Explo2) / Explo1;
               bask = Ask;
               if(pwre >= ExplosionPower && pwrt >= TrendPower)
                 {
                   if(AlertWindow == true)
                     {
                       Alert(LastTime1, "- ", Symbol(), " - BUY ", " (", 
                             DoubleToStr(bask, Digits) , ") Trend PWR " , 
                             DoubleToStr(pwrt,0), " - Exp PWR ", DoubleToStr(pwre, 0));
                     }
                   else
                     {
                       Print(LastTime1, "- ", Symbol(), " - BUY ", " (", 
                             DoubleToStr(bask, Digits), ") Trend PWR ", 
                             DoubleToStr(pwrt, 0), " - Exp PWR ", DoubleToStr(pwre, 0));
                     }
                   LastTime1++;
                 }
               Status = 1;
             }
           if(Trend1 < 0 && MathAbs(Trend1) > Explo1 && MathAbs(Trend1) > Dead && 
              Explo1 > Dead && Explo1 > Explo2 && MathAbs(Trend1) > MathAbs(Trend2) && 
              LastTime2 < AlertCount && AlertShort == true && Bid != bbid)
             {
               pwrt = 100*(MathAbs(Trend1) - MathAbs(Trend2)) / MathAbs(Trend1);
               pwre = 100*(Explo1 - Explo2) / Explo1;
               bbid = Bid;
               if(pwre >= ExplosionPower && pwrt >= TrendPower)
                 {
                   if(AlertWindow == true)
                     {
                       Alert(LastTime2, "- ", Symbol(), " - SELL ", " (", 
                             DoubleToStr(bbid, Digits), ") Trend PWR ", 
                             DoubleToStr(pwrt,0), " - Exp PWR ", DoubleToStr(pwre, 0));
                     }
                   else
                     {
                       Print(LastTime2, "- ", Symbol(), " - SELL ", " (", 
                             DoubleToStr(bbid, Digits), ") Trend PWR " , 
                             DoubleToStr(pwrt, 0), " - Exp PWR ", DoubleToStr(pwre, 0));
                     }
                   LastTime2++;
                 }
               Status = 2;
             }
           if(Trend1 > 0 && Trend1 < Explo1 && Trend1 < Trend2 && Trend2 > Explo2 && 
              Trend1 > Dead && Explo1 > Dead && LastTime3 <= AlertCount && 
              AlertExitLong == true && Bid != bbid)
             {
               bbid = Bid;
               if(AlertWindow == true)
                 {
                   Alert(LastTime3, "- ", Symbol(), " - Exit BUY ", " ", 
                         DoubleToStr(bbid, Digits));
                 }
               else
                 {
                   Print(LastTime3, "- ", Symbol(), " - Exit BUY ", " ", 
                         DoubleToStr(bbid, Digits));
                 }
               Status = 3;
               LastTime3++;
             }
           if(Trend1 < 0 && MathAbs(Trend1) < Explo1 && 
              MathAbs(Trend1) < MathAbs(Trend2) && MathAbs(Trend2) > Explo2 && 
              Trend1 > Dead && Explo1 > Dead && LastTime4 <= AlertCount && 
              AlertExitShort == true && Ask != bask)
             {
               bask = Ask;
               if(AlertWindow == true)
                 {
                   Alert(LastTime4, "- ", Symbol(), " - Exit SELL ", " ", 
                         DoubleToStr(bask, Digits));
                 }
               else
                 {
                   Print(LastTime4, "- ", Symbol(), " - Exit SELL ", " ", 
                         DoubleToStr(bask, Digits));
                 }
               Status = 4;
               LastTime4++;
             }
           PrevStatus = Status;
         }
       if(Status != PrevStatus)
         {
           LastTime1 = 1;
           LastTime2 = 1;
           LastTime3 = 1;
           LastTime4 = 1;
         }
     }
   return(0);
  }
//+------------------------------------------------------------------+


double NormalizedVolume(int i)
  {double result = 0;
  if(UseVolumeCalculation){
   double nv=0;
   for(int j=i; j<(i+VolumePeriod); j++)
      nv=nv+Volume[j];
   nv=nv/VolumePeriod;
   result = Volume[i]/nv;
   }
   else
   {
   result = 1;
   }
   return(result);
  }

