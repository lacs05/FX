//+------------------------------------------------------------------+
//|                                              Indicator: VHTC.mq4 |
//|                                       Created with EABuilder.com |
//|                                             http://eabuilder.com |
//+------------------------------------------------------------------+
#property copyright "Created with EABuilder.com"
#property link      "http://eabuilder.com"
#property version   "1.00"
#property description "Vincent Hofman Trend Catcher"

#include <stdlib.mqh>
#include <stderror.mqh>

//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2

#property indicator_type1 DRAW_HISTOGRAM
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_color1 0x04FF00
#property indicator_label1 "BUY"

#property indicator_type2 DRAW_HISTOGRAM
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
#property indicator_color2 0x0000FF
#property indicator_label2 "SELL"

//--- indicator buffers
double Buffer1[];
double Buffer2[];

double myPoint; //initialized in OnInit

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | VHTC @ "+Symbol()+","+Period()+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {   
   IndicatorBuffers(2);
   SetIndexBuffer(0, Buffer1);
   SetIndexEmptyValue(0, 0);
   SetIndexBuffer(1, Buffer2);
   SetIndexEmptyValue(1, 0);
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, 0);
      ArrayInitialize(Buffer2, 0);
     }
   else
      limit++;
   
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(5000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      //Indicator Buffer 1
      if(Close[i] > iBands(NULL, PERIOD_CURRENT, 20, 0.382, 0, PRICE_CLOSE, MODE_UPPER, i) //Candlestick Close > Bollinger Bands
      )
        {
         Buffer1[i] = Close[i]; //Set indicator value at Candlestick Close
        }
      else
        {
         Buffer1[i] = 0;
        }
      //Indicator Buffer 2
      if(Close[i] < iBands(NULL, PERIOD_CURRENT, 20, 0.382, 0, PRICE_CLOSE, MODE_LOWER, i) //Candlestick Close < Bollinger Bands
      )
        {
         Buffer2[i] = Close[i]; //Set indicator value at Candlestick Close
        }
      else
        {
         Buffer2[i] = 0;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+