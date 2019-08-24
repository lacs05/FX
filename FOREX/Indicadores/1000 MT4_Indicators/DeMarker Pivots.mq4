//| DialyPivot.mq4 |
//| These are the main pivots used by Thomas DeMark |
//| Written by: Ice |
//| |
//+------------------------------------------------------------------+
#property copyright "2005 Free software for trader"

#property indicator_chart_window
#property indicator_buffers 7

#property indicator_color1 Blue
#property indicator_color2 Yellow
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_color5 Lime

//---- input parameters\

datetime BT[];
double YesterdayHigh[50];
double YesterdayLow[50];
double YesterdayClose[50];
//---- buffers

double PivotArray[];
double R1Array[];
double S1Array[];
double R2Array[];
double S2Array[];
double R3Array[];
double S3Array[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
// Pivot
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,PivotArray);
IndicatorShortName("TDPivot");
SetIndexLabel(0,"Pivot");

// Resistance 1
SetIndexStyle(1,DRAW_LINE);
SetIndexBuffer(1,R1Array);
SetIndexLabel(1,"R1");

// Support 1
SetIndexStyle(2,DRAW_LINE);
SetIndexBuffer(2,S1Array);
SetIndexLabel(2,"R1");

// Resistance 2
SetIndexStyle(3,DRAW_LINE);
SetIndexBuffer(3,R2Array);
SetIndexLabel(3,"R2");

// Support 2
SetIndexStyle(4,DRAW_LINE);
SetIndexBuffer(4,S2Array);
SetIndexLabel(4,"S2");


return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
int counted_bars=IndicatorCounted();

ArrayResize(BT, Bars); Print("Bars = " + Bars);
// Fill BT with bar open TIME
ArrayCopySeries(BT, MODE_TIME);
// Fill temp arrays with High, Low and Close prices per day
ArrayCopySeries(YesterdayHigh, MODE_HIGH, Symbol(), PERIOD_D1);
ArrayCopySeries(YesterdayLow, MODE_LOW, Symbol(), PERIOD_D1);
ArrayCopySeries(YesterdayClose, MODE_CLOSE, Symbol(), PERIOD_D1);

int od = 0;
int dd = 0;


double Pivot;
double R1; 
double S1;
double R2;
double S2;

//Cycle through all the bars and fill the indicator bars with the Pivot point values
for (int i = 0; i <= Bars; i++) {
if (TimeDay(BT[i]) != od) {
dd++;
Pivot = (YesterdayHigh[dd] + YesterdayLow[dd] + YesterdayClose[dd])/3;
R1 = (2*Pivot)-YesterdayLow[dd]; 
S1 = (2*Pivot)-YesterdayHigh[dd];
R2 = Pivot-S1+R1;
S2 = Pivot-R1+S1; 
od = TimeDay(BT[i]);
}

PivotArray[i] = Pivot; 
R1Array[i]=R1;
S1Array[i]=S1;
R2Array[i]=R2;
S2Array[i]=S2;
}
//----
return(0);
}
//+------------------------------------------------------------------+