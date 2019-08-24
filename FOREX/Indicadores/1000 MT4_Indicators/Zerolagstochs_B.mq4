//+------------------------------------------------------------------+
//|                                                   PriceVSwma.mq4 |
//|                      Copyright � 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2004, MetaQuotes Software Corp."
#property link      "perky_z@yahoo.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_color2 Red

extern int  smoothing=13;
extern int  timeframe=0;
//---- input parameters


double stok1=0,stok2=0,stok3=0,stok4=0,stok5=0,mov=0,stoksmoothed=0;
int shift=0, MAType=1, cnt=0,  prevbars=0,loopbegin=0;

bool first=true;
//---- buffers
double TrendBuffer[];
double LoBuffer[];
double HiBuffer[];
double PlusSdiBuffer[];
double MinusSdiBuffer[];
double TempBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 3 additional buffers are used for counting.
   IndicatorBuffers(3);
//---- indicator buffers
   SetIndexBuffer(0,TrendBuffer);
   SetIndexBuffer(1,LoBuffer);
   
    SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2,White);
    SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2,Red);
    IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("ZLS("+smoothing+")");
   
   SetIndexDrawBegin(0,TrendBuffer);
   SetIndexDrawBegin(1,LoBuffer);
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Average Directional Movement Index                               |
//+------------------------------------------------------------------+
int start()
  {
  // initial checkings
// check for additional bars loading or total reloading
if (Bars < prevbars )  first = true;
if (Bars-prevbars>1) first = true;
prevbars = Bars;
if (first) 
{
	// loopbegin prevent couning of counted bars exclude current
	loopbegin = Bars-1;
	if (loopbegin < 0) return(0);      // not enough bars for counting
	
	
	first = False;
   }
  
 
  loopbegin = loopbegin+1; 
 // Comment( loopbegin);            // current bar is to be recounted too
  for (shift = loopbegin; shift>= 0 ;shift--)
	{


stok5 = (iStochastic(NULL,timeframe,52,12,3,MODE_LWMA,NULL,MODE_MAIN,shift))*0.00;
stok4 = (iStochastic(NULL,timeframe,34,8,3,MODE_LWMA,NULL,MODE_MAIN,shift))*0.0;
stok3 = (iStochastic(NULL,timeframe,21,5,3,MODE_LWMA,NULL,MODE_MAIN,shift))*0.10;
stok2 = (iStochastic(NULL,timeframe,12,4,3,MODE_LWMA,NULL,MODE_MAIN,shift))*0.65;
stok1 = (iStochastic(NULL,timeframe,8,3,3,MODE_LWMA,NULL,MODE_MAIN,shift))*0.25;
mov   = stok1+stok2+stok3+stok4+stok5;
stoksmoothed = mov/smoothing + LoBuffer[shift+1]*(smoothing-1)/smoothing;

	TrendBuffer[shift]=mov;
	LoBuffer[shift]=	stoksmoothed;
	
	loopbegin = loopbegin-1;     
	}}
	return(0);
	    // prevent to previous bars recounting

