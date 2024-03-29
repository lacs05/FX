//+------------------------------------------------------------------+
//|                                                      TSI-Osc.mq4 |
//|                      Copyright � 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_color2 Coral
#property indicator_maximum 100
#property indicator_minimum -100
#property indicator_level1 0
#property indicator_level2 50
#property indicator_level3 -50
//---- input parameters
// M5 and M15 , 8,8,8
// M30 7,7,7
// H1 and H4 6,6,6
extern int       First_R=7;
extern int       Second_S=7;
extern int       SignalPeriod=7;
//---- buffers
double TSI_Buffer[];
double SignalBuffer[];
double MTM_Buffer[];
double EMA_MTM_Buffer[];
double EMA2_MTM_Buffer[];
double ABSMTM_Buffer[];
double EMA_ABSMTM_Buffer[];
double EMA2_ABSMTM_Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexBuffer(2, MTM_Buffer);
   SetIndexBuffer(3, EMA_MTM_Buffer);
   SetIndexBuffer(4, EMA2_MTM_Buffer);
   SetIndexBuffer(5, ABSMTM_Buffer);
   SetIndexBuffer(6, EMA_ABSMTM_Buffer);
   SetIndexBuffer(7, EMA2_ABSMTM_Buffer);

   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TSI_Buffer);
   SetIndexLabel(0,"Ergodic");
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,SignalBuffer);
   SetIndexLabel(1,"Signal");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int limit,i;
   limit=Bars-counted_bars-1;//Bars
   for (i=Bars-1;i>=0;i--)//Bars
      {
      MTM_Buffer[i]=(Close[i]-Close[i+1]);
      //MTM_Buffer[i]=((High[i]+Low[i])/2)-((High[i+1]+Low[i+1])/2);
      //MTM_Buffer[i]=(((Close[i]-Close[i+1])/Close[i+1])+Point);
      //MTM_Buffer[i]=iMomentum(NULL,0,1,PRICE_CLOSE,i)-iMomentum(NULL,0,1,PRICE_CLOSE,i+1);
      //MTM_Buffer[i]=iMomentum(NULL,0,1,PRICE_CLOSE,i)-iMomentum(NULL,0,1,PRICE_CLOSE,i+1);
      //MTM_Buffer[i]=iMomentum(NULL,0,1,PRICE_CLOSE,i)-iMomentum(NULL,0,1,PRICE_CLOSE,i+1);
      ABSMTM_Buffer[i]=MathAbs(MTM_Buffer[i]);
      }
      
   for (i=Bars-1;i>=0;i--)//Bars
      {
      EMA_MTM_Buffer[i]=iMAOnArray(MTM_Buffer,0,First_R,0,MODE_EMA,i);
      EMA_ABSMTM_Buffer[i]=iMAOnArray(ABSMTM_Buffer,0,First_R,0,MODE_EMA,i);
      }

   for (i=Bars-1;i>=0;i--)//Bars
      {
      EMA2_MTM_Buffer[i]=iMAOnArray(EMA_MTM_Buffer,0,Second_S,0,MODE_EMA,i);
      EMA2_ABSMTM_Buffer[i]=iMAOnArray(EMA_ABSMTM_Buffer,0,Second_S,0,MODE_EMA,i);
      }

   for (i=limit;i>=0;i--)//limit
      {
      TSI_Buffer[i]=100.0*EMA2_MTM_Buffer[i]/EMA2_ABSMTM_Buffer[i];
      }
   for (i=limit;i>=0;i--)//limit
      {
      SignalBuffer[i]=iMAOnArray(TSI_Buffer,0,SignalPeriod,0,MODE_EMA,i);
      }
      
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+