//+------------------------------------------------------------------+
//|                                      cam_H1_H5_Historical_V4.mq4 |
//|                      Copyright � 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//| Modified to chart historical camarilla pivots by MrPip           |
//| 3/28/06 Fixed problem of Sunday/Monday pivots                    |
//|         and added some ideas from goodtiding5 (Kenneth Z.)       |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Green
#property indicator_color3 Green
#property indicator_color4 Green
#property indicator_color5 Green
#property indicator_color6 Yellow
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 1

//---- input parameters

extern int  GMTshift=0;
extern color HColor = Green;
extern int fontsize=10;
extern int LabelShift=20;

double H5Buffer[];
double H4Buffer[];
double H3Buffer[];
double H2Buffer[];
double H1Buffer[];
double PivotBuffer[];

double P, H1, H2, H3, H4, H5;

double D1=0.091667;
double D2=0.183333;
double D3=0.2750;
double D4=0.55;

double prev_high=0;
double prev_low=0;
double prev_close=0;
double cur_day=0;
double prev_day=0;
double day_high=0;
double day_low=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(6);
//---- indicators
   SetIndexStyle(0,DRAW_LINE, 0,2,Green);
   SetIndexBuffer(0,H5Buffer);
   SetIndexStyle(1,DRAW_LINE, 0,2,Green);
   SetIndexBuffer(1,H4Buffer);
   SetIndexStyle(2,DRAW_LINE, 0,2,Green);
   SetIndexBuffer(2,H3Buffer);
   SetIndexStyle(3,DRAW_LINE, 0,2,Green);
   SetIndexBuffer(3,H2Buffer);
   SetIndexStyle(4,DRAW_LINE, 0,2,Green);
   SetIndexBuffer(4,H1Buffer);
   SetIndexStyle(5,DRAW_LINE, STYLE_DASH, 1, Yellow);
   SetIndexBuffer(5,PivotBuffer);
   
   SetIndexLabel(0,"H5");
   SetIndexLabel(1,"H4");
   SetIndexLabel(2,"H3");
   SetIndexLabel(3,"H2");
   SetIndexLabel(4,"H1");
   SetIndexLabel(5,"Pivot");

   
//----
//   IndicatorShortName("Cam H Pivots");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   ObjectDelete("CamPivot");
   ObjectDelete("ResH1");
   ObjectDelete("ResH2");
   ObjectDelete("ResH3");
   ObjectDelete("ResH4");
   ObjectDelete("ResH5");   
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int cnt, limit;

//---- exit if period is greater than 4 hr charts
   if(Period() > 240)
   {
      Alert("Error - Chart period is greater than 4 Hr.");
      return(-1); // then exit
   }
   if(counted_bars<0) return(-1);

//---- last counted bar will be recounted
//   if(counted_bars>0) counted_bars--;

//   limit=(Bars-counted_bars)-1;
   limit=counted_bars;

//---- Get new daily prices & calculate pivots

   for (cnt=limit;cnt >=0;cnt--)
   {
   	if (TimeDayOfWeek(Time[cnt]) == 0)
	   {
        cur_day = prev_day;
	   }
	   else
	   {
        cur_day = TimeDay(Time[cnt]- (GMTshift*3600));
	   }
	   
   	if (prev_day != cur_day)
   	{
	   	prev_close = Close[cnt+1];
		   prev_high = day_high;
		   prev_low = day_low;

	      day_high = High[cnt];
 	      day_low  = Low[cnt];

P = (prev_high + prev_low + prev_close)/3;//Pivot
//---- To display all 8 Camarilla pivots remove comment symbols below and
// add the appropriate object functions below
H5 = (prev_high/prev_low)*prev_close;
H4 = ((prev_high - prev_low)* D4) + prev_close;
H3 = ((prev_high - prev_low)* D3) + prev_close;
H2 = ((prev_high - prev_low) * D2) + prev_close;
H1 = ((prev_high - prev_low) * D1) + prev_close;


		   prev_day = cur_day;
	   }
      if (High[cnt]>day_high)
      {
         day_high = High[cnt];
      }
      if (Low[cnt]<day_low)
      {
         day_low = Low[cnt];
      }
      
      
      
//         day_low=Open[cnt]; day_high=Open[cnt];
      
      

//---  Draw  Pivot lines on chart

      PivotBuffer[cnt]=P;
      H5Buffer[cnt]=H5;
      H4Buffer[cnt]=H4;
      H3Buffer[cnt]=H3;
      H2Buffer[cnt]=H2;
      H1Buffer[cnt]=H1;
      
   }

   if (cur_day == TimeDay(CurTime()))   DisplayLabels();
//----
   return(0);
  }

void DisplayLabels()
{
      datetime LabelShiftTime;
      
      LabelShiftTime = Time[LabelShift];
      if(ObjectFind("CamPivot") != 0)
      {
        ObjectCreate("CamPivot", OBJ_TEXT, 0, 0,0);
        ObjectSetText("CamPivot", "                 Pivot",fontsize,"Arial",Yellow);
      }
      else
      {
        ObjectMove("CamPivot", 0, LabelShiftTime,P);
      }
      
      if(ObjectFind("ResH1") != 0)
      {
      ObjectCreate("ResH1", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("ResH1", "      H 1",fontsize,"Arial",HColor);
      }
      else
      {
         ObjectMove("ResH1", 0, LabelShiftTime,H1);
      }

      if(ObjectFind("ResH2") != 0)
      {
      ObjectCreate("ResH2", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("ResH2", "      H 2",fontsize,"Arial",HColor);
      }
      else
      {
         ObjectMove("ResH2", 0, LabelShiftTime,H2);
      }
      
      if(ObjectFind("ResH3") != 0)
      {
      ObjectCreate("ResH3", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("ResH3", "      H 3",fontsize,"Arial",HColor);
      }
      else
      {
         ObjectMove("ResH3", 0, LabelShiftTime,H3);
      }
      
      if(ObjectFind("ResH4") != 0)
      {
      ObjectCreate("ResH4", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("ResH4", "      H 4",fontsize,"Arial",HColor);
      }
      else
      {
         ObjectMove("ResH4", 0, LabelShiftTime,H4);
      }
      
      if(ObjectFind("ResH5") != 0)
      {
      ObjectCreate("ResH5", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("ResH5", "      H 5",fontsize,"Arial",HColor);
      }
      else
      {
         ObjectMove("ResH5", 0, LabelShiftTime, H5);
      }
}
//+------------------------------------------------------------------+