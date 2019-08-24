//+------------------------------------------------------------------+
//|                                                       MA_ATR.mq4 |
//+------------------------------------------------------------------+
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue   //ATR color
#property indicator_color2 Yellow   //MA color

//--- input parameters
extern int ATR_Period    = 24;
extern int MA_Period  = 24; 
extern int MA_Type = 0;      // 0 SMA , 1 EMA , 2 SMMA , 3 LWMA

//--- buffers
double ATR[];
double MA[];

int init()
{
IndicatorShortName("ATR("+IntegerToString(ATR_Period,0,' ')+") with MA("+IntegerToString(MA_Period,0,' ')+")");
IndicatorBuffers(2);

//---- drawing settings ATR  
SetIndexBuffer(0,ATR);
SetIndexLabel(0,"ATR");                    
SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);  

//---- drawing settings of Moving Average
SetIndexBuffer(1,MA);
SetIndexLabel(1,"MA of ATR");                    
SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1);        

return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int start()
{
int counted_bars=IndicatorCounted();
int limit = Bars-counted_bars-1;
for(int i=limit; i>=0; i--) ATR[i] = iATR(NULL,0,ATR_Period,i); 
for(int i=limit; i>=0; i--) MA[i] = iMAOnArray(ATR,0,MA_Period,0,MA_Type,i);

//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//----

//----
return(0);
}
//+------------------------------------------------------------------+
