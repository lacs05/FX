//+------------------------------------------------------------------+
//|                                                   ^Dyn_Pivot.mq4 |
//|                                      Modest, Rosh conversed only |
//|                           http://forexsystems.ru/phpBB/index.php |
//+------------------------------------------------------------------+
#property copyright "Modest, Rosh conversed only"
#property link      "http://forexsystems.ru/phpBB/index.php"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern int       Formula=0;
int i=1, j=1, shift=0;
double FP=0.0;
double FH=0.0, FL=0.0;
bool result;
//---- buffers
double ExtMapBuffer1[];
double FR1Buffer[];
double FS1Buffer[];
//+------------------------------------------------------------------+
//| �������� ������ ���                                              |
//+------------------------------------------------------------------+
bool isNewDay(int _shift)
  {
//---- 
   result=false;
   if (  (TimeHour(Time[_shift])==0)  && (TimeMinute(Time[_shift])==0)   ) result=true;
   //Print("����=",TimeToStr(Time[_shift]),"  isNewDay=",result);
//----
   return(result);
  }
//+------------------------------------------------------------------+
//| ���������� ������ FP, FR1 � FS1 ���������� ���                   |
//+------------------------------------------------------------------+
void SetLevels1(int _shift)
  {
  int prevDay=TimeDay(Time[_shift+1]);
//---- 
   i=1;
   while (TimeDay(Time[_shift+i])==prevDay) i++;
   i--;
   FH=High[Highest(NULL,0,MODE_HIGH,i,_shift+1)];
   FL=Low[Lowest(NULL,0,MODE_LOW,i,_shift+1)];
   if (Formula==0) FP=NormalizeDouble((FH+FL+Close[_shift+1])/3.0,Digits); else FP=NormalizeDouble((FH+FL+2*Close[_shift+1])/4.0,Digits);
//----
   ExtMapBuffer1[_shift]=FP;
   FR1Buffer[_shift]=NormalizeDouble(FP+(FP-FL),Digits);
   FS1Buffer[_shift]=NormalizeDouble(FP-(FH-FP),Digits);
  }

//+------------------------------------------------------------------+
//| ���������� ������ FP, FR1 � FS1 � ����                           |
//+------------------------------------------------------------------+
void SetLevels1Empty(int _shift)
  {
   ExtMapBuffer1[_shift]=0.0;
   FR1Buffer[_shift]=0.0;
   FS1Buffer[_shift]=0.0;
  }
//+------------------------------------------------------------------+
//| ��������� ������� � ������� ����                                 |
//+------------------------------------------------------------------+
void SetNullBarLevels(int _shift)
  {
  int cnt;
  int currDay=TimeDay(Time[_shift]);
//---- 
   i=1;
   while (TimeDay(Time[_shift+i])==currDay) i++;
   if (i>=2)
      {
      i=i-2;
      for (cnt=i;cnt>0;cnt--) 
         {
         ExtMapBuffer1[shift+cnt]=0.0;
         FR1Buffer[_shift]=0.0;
         FS1Buffer[_shift]=0.0;
         }
      FH=High[Highest(NULL,0,MODE_HIGH,i+1,_shift)];
      FL=Low[Lowest(NULL,0,MODE_LOW,i+1,_shift)];
      if (Formula==0) FP=NormalizeDouble((FH+FL+Close[_shift+1])/3.0,Digits); else FP=NormalizeDouble((FH+FL+2*Close[_shift+1])/4.0,Digits);
      ExtMapBuffer1[_shift]=FP;
      FR1Buffer[_shift]=NormalizeDouble(FP+(FP-FL),Digits);
      FS1Buffer[_shift]=NormalizeDouble(FP-(FH-FP),Digits);
      }
//----
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(2);
   if (Formula!=0)Formula=1;
   string label1="FR1("+Formula+")";
   string label2="FS1("+Formula+")";
//---- indicators
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,FR1Buffer);
   SetIndexEmptyValue(0,0.0);
   SetIndexLabel(0,label1);

   SetIndexStyle(1,DRAW_SECTION);
   SetIndexBuffer(1,FS1Buffer);
   SetIndexEmptyValue(1,0.0);
   SetIndexLabel(1,label2);

   SetIndexBuffer(2,ExtMapBuffer1);
   SetIndexEmptyValue(2,0.0);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit,firstDay;
   int counted_bars=IndicatorCounted();
   if (counted_bars<0) return(-1);
   if (counted_bars==0) 
      {
      limit=Bars-1;
      i=1;
      firstDay=TimeDay(Time[limit]);
      while (TimeDay(Time[limit-i])==firstDay) i++;
      limit=limit-i-PERIOD_D1/Period();
      }
   if (counted_bars>0) limit=Bars-counted_bars;
//---- 
   if (Period()>PERIOD_H4) return;
   for (shift=limit;shift>=0;shift--)
      {
      if (isNewDay(shift)) SetLevels1(shift); else  SetLevels1Empty(shift);
      if (shift==0) SetNullBarLevels(shift);
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+