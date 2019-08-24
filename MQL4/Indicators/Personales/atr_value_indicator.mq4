//+------------------------------------------------------------------+
//|                                           ATR Value Indicator.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Hossein Nouri."
#property link      "https://www.mql5.com/en/users/hsnnouri"
#property version   "1.00"
#property description "Displaying ATR(Average True Range) value in pips or points." 
#property strict
#property indicator_chart_window
//--- input parameters
enum valueType
{
   Points=0,
   Pips=1,
};
input int      ATRPeriod=14;
input double   Multiplier=2.0;
input valueType display=0;
input color    labelColor=clrRed;
input int      fontSize=10;
#define OBJ_NAME "ATRIndicatorObj"
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   ShowATR();
//---
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
{
   ObjectDelete(OBJ_NAME);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   ShowATR();
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void ShowATR()
{
   static double ATR;
   
   ATR = iATR(Symbol(),0,ATRPeriod,0);
   ATR = (ATR * Multiplier) * MathPow(10,Digits - display);
   DrawATROnChart(ATR);
}
void DrawATROnChart(double ATR)
{
   string Dis;
   if(display==0) Dis=" Points";
   if(display==1) Dis=" Pips";
   string s = (string)(Multiplier * 100) + "% of ATR ("+(string)ATRPeriod+"):"+DoubleToStr(ATR,0)+ Dis;
   
   if(ObjectFind(OBJ_NAME) < 0)
   {
      ObjectCreate(OBJ_NAME, OBJ_LABEL, 0, 0, 0);
      ObjectSet(OBJ_NAME, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSet(OBJ_NAME, OBJPROP_YDISTANCE, 30);
      ObjectSet(OBJ_NAME, OBJPROP_XDISTANCE, 0);
      ObjectSet(OBJ_NAME,OBJPROP_SELECTABLE,false);
      ObjectSetText(OBJ_NAME, s, fontSize, "Arial", labelColor);
   }
   
   ObjectSetText(OBJ_NAME, s);
   
   WindowRedraw();
}