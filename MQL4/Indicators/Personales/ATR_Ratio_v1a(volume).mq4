//+------------------------------------------------------------------+
//|                                                ATR_Ratio_v1a.mq4 |
//+------------------------------------------------------------------+

//---- indicator settings

#property  indicator_separate_window

#property  indicator_buffers 2

#property  indicator_color1  Purple

#property  indicator_color2  LightSeaGreen

//---- indicator parameters

extern int FastATR_Period      = 14;
extern int SlowATR_Period      = 28;
extern int SignalLine_Period   = 9;
extern int SignalLineShift     =  3;
extern int SignalLineMa_Method =  0; // 0 SMA , 1 EMA , 2 SMMA , 3 LWMA
extern int ShowBars = 500;

//---- indicator buffers

double preatrbuffer[];
double finalatrbuffer[];

int    draw_begin0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
 {

//---- indicator buffers mapping
  
//---- drawing settings
  
  draw_begin0 = SlowATR_Period;
  
  SetIndexEmptyValue(1,0.0000);
  SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1);
  SetIndexBuffer(1,preatrbuffer);
  SetIndexLabel(1,"FastATR/SlowATR");
  SetIndexDrawBegin(1,draw_begin0);
  
  SetIndexEmptyValue(0,0.0000);
  SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
  SetIndexBuffer(0,finalatrbuffer);
  SetIndexLabel(0," ("+SignalLine_Period+") Period Ma of ATRRatio");
  SetIndexDrawBegin(0,draw_begin0);
  
  
//---- name for DataWindow and indicator subwindow label
  
  IndicatorShortName("ATR_Ratio_v1a");
  
  
//---- initialization done
  return(0);
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
 {
  int limit,i,shift;
  int counted_bars=IndicatorCounted();

//---- check for possible errors
  if(counted_bars<1)
   {
     for(i=1;i<=draw_begin0;i++) { finalatrbuffer[Bars-i]=0; preatrbuffer[Bars-i]=0; }
   }

//---- last counted bar will be recounted
  if(counted_bars>0) counted_bars--;
  //limit=Bars-counted_bars;
  limit = ShowBars;
  if (ShowBars >= Bars) limit = Bars - 1;

//-----------------------------------------------------------------------------------------------------------------

//---- preadxbuffer
  
  for(i=0; i<limit; i++)
    { preatrbuffer[i] = (iATR(Symbol(), 0, FastATR_Period, i)/Point) / (iATR(Symbol(), 0, SlowATR_Period, i)/Point); }

//---- finaladxbuffer
  
  for(i=0; i<limit; i++)
    { finalatrbuffer[i]=iMAOnArray(preatrbuffer,0,SignalLine_Period,SignalLineShift,SignalLineMa_Method,i); }

//-----------------------------------------------------------------------------------------------------------------

//---- done
  return(0);
 }

