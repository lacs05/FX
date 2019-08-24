//+------------------------------------------------------------------+
//|                                                          ADX.mq4 |
//|                      Copyright � 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 LightSeaGreen
#property indicator_color2 YellowGreen
//#property indicator_color3 Wheat
//---- input parameters
extern int DMIPeriod=10;
//---- buffers
//double ADXBuffer[];
double PlusDiBuffer[];
double MinusDiBuffer[];
double PlusSdiBuffer[];
double MinusSdiBuffer[];
double TempBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 3 additional buffers are used for counting.
   IndicatorBuffers(5);
//---- indicator buffers
//   SetIndexBuffer(0,ADXBuffer);
   SetIndexBuffer(0,PlusDiBuffer);
   SetIndexBuffer(1,MinusDiBuffer);
   SetIndexBuffer(2,PlusSdiBuffer);
   SetIndexBuffer(3,MinusSdiBuffer);
   SetIndexBuffer(4,TempBuffer);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("DMI("+DMIPeriod+")");
//   SetIndexLabel(0,"ADX");
   SetIndexLabel(0,"+DI");
   SetIndexLabel(1,"-DI");
//----
//   SetIndexDrawBegin(0,DMIPeriod);
   SetIndexDrawBegin(0,DMIPeriod);
   SetIndexDrawBegin(1,DMIPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Average Directional Movement Index                               |
//+------------------------------------------------------------------+
int start()
  {
   double pdm,mdm,tr;
   double price_high,price_low;
   double pr=1.0/(DMIPeriod);
   int    starti,i,counted_bars=IndicatorCounted();
//----
   i=Bars-2;
   PlusSdiBuffer[i+1]=0;
   MinusSdiBuffer[i+1]=0;
   if(counted_bars>=i) i=Bars-counted_bars-1;
   starti=i;
//----
   while(i>=0)
     {
      price_low=Low[i];
      price_high=High[i];
      //----
      pdm=price_high-High[i+1];
      mdm=Low[i+1]-price_low;
      if(pdm<0) pdm=0;  // +DM
      if(mdm<0) mdm=0;  // -DM
      if(pdm==mdm) { pdm=0; mdm=0; }
      else if(pdm<mdm) pdm=0;
           else if(mdm<pdm) mdm=0;
      //---- ��������� �������� ��������
      double num1=MathAbs(price_high-price_low);
      double num2=MathAbs(price_high-Close[i+1]);
      double num3=MathAbs(price_low-Close[i+1]);
      tr=MathMax(num1,num2);
      tr=MathMax(tr,num3);
      //---- counting plus/minus direction
      if(tr==0) { PlusSdiBuffer[i]=0; MinusSdiBuffer[i]=0; }
      else      { PlusSdiBuffer[i]=100.0*pdm/tr; MinusSdiBuffer[i]=100.0*mdm/tr; }
      //----
      i--;
     }
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
//---- apply EMA to +DI
   for(i=0; i<=limit; i++)
//---- main calculation loop
      PlusDiBuffer[i]=PlusSdiBuffer[i]*pr+PlusDiBuffer[i+1]*((DMIPeriod-1)/DMIPeriod);

//---- apply EMA to -DI
   for(i=0; i<=limit; i++)
      MinusDiBuffer[i]=PlusSdiBuffer[i]*pr+MinusDiBuffer[i+1]*((DMIPeriod-1)/DMIPeriod);
//---- Directional Movement (DX)
   i=Bars-2;
   TempBuffer[i+1]=0;
   i=starti;
   while(i>=0)
     {
      double div=MathAbs(PlusDiBuffer[i]+MinusDiBuffer[i]);
      if(div==0.00) TempBuffer[i]=0;
      else TempBuffer[i]=100*(MathAbs(PlusDiBuffer[i]-MinusDiBuffer[i])/div);
      i--;
     }
//---- ADX is exponential moving average on DX
//   for(i=0; i<limit; i++)
//      ADXBuffer[i]=iMAOnArray(TempBuffer,Bars,DMIPeriod,0,MODE_EMA,i);
//----
   return(0);
  }
//+------------------------------------------------------------------+