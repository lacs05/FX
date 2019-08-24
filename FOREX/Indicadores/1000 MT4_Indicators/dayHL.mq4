//+------------------------------------------------------------------+
//| dayHL_Average.mq4 |
//+------------------------------------------------------------------+
/*
Name := dayHL_Average
Author := KCBT
Link := http://www.kcbt.ru/forum/index.php?
*/

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color3 Red
//---- input parameters5
extern int show_comment=1; // comments on the chart (0 - no, 1 - yes)
extern int how_long=1000; // bars to be counted (-1 - all the bars)
//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
SetIndexBuffer(0, ExtMapBuffer1);
SetIndexStyle(0, DRAW_LINE);
SetIndexBuffer(1, ExtMapBuffer2);
SetIndexStyle(1, DRAW_LINE);
SetIndexBuffer(2, ExtMapBuffer3);
SetIndexStyle(2, DRAW_LINE);
return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
Comment("");
return(0);
}

int start()
{
int cnt=0; // ������� �����
int begin_bar=0; // ���, � �������� �������� ������ ���������
int prev_day, cur_day; // �������������� �������� � ����������� ���
double day_high=0; // ������� high
double day_low=0; // ������� low
double yesterday_high=0; // ���������� ���� ����������� ���
double yesterday_low=0; // ���������� ���� ����������� ���
double yesterday_close=0; // ���� �������� ����������� ���
double P, S, R;

// ���������� ��������� ��� ������ ���������� - ���, ��� ������ D1
if (Period() >= PERIOD_D1) {
Comment("WARNING: Invalid timeframe! Valid value < D1.");
return(0);
}

// ������ � ������ ���� �� ������ ������� ��� ���������
if (how_long == -1) {
begin_bar = Bars;
} else {
begin_bar = how_long;
}

// ������� ���� ����� ������� (0-� ��� ���� ����������, �.�. �� ���� �� ���� ������ high � low)
for (cnt = begin_bar; cnt >= 0; cnt--) {
cur_day = TimeDay(Time[cnt]);
if (prev_day != cur_day) {
yesterday_close = Close[cnt+1];
yesterday_high = day_high;
yesterday_low = day_low;
P = (yesterday_high + yesterday_low ) / 2;
R = yesterday_high;
S = yesterday_low;

// �.�. ������� ����� ����, �� ���������� ����. � ���. �������� (���) ���
day_high = High[cnt];
day_low = Low[cnt];

// �������� ������ ����, ��� �������
prev_day = cur_day;
}

// ���������� ����������� ������
day_high = MathMax(day_high, High[cnt]);
day_low = MathMin(day_low, Low[cnt]);

// ������ pivot-����� �� ��������, ������������ �� ���������� ���������� ���
ExtMapBuffer2[cnt] = P;
// ������ ����� ������������� � ��������� ������ 1,2 ��� 3
ExtMapBuffer1[cnt] = R; // �������������
ExtMapBuffer3[cnt] = S; // ���������
}

if (show_comment == 1) {
P = (yesterday_high + yesterday_low ) / 2;
R = yesterday_high;
S = yesterday_low;

Comment("Current H=", R, ", L=", S, ", HL/2=", P, ", H-L=", (R-S)/Point );
}
return(0);
}
//+------------------------------------------------------------------+