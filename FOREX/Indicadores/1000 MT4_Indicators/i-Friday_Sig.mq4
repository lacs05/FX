//+------------------------------------------------------------------+
//|                                                 i-Friday_Sig.mq4 |
//|                                           ��� ����� �. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//| 09.10.2005  Enter and exit signals on Friday effect   |
//+------------------------------------------------------------------+
#property copyright "��� ����� �. aka KimIV"
#property link      "http://www.kimiv.ru"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 LightBlue
#property indicator_color2 Salmon
#property indicator_color3 LightBlue
#property indicator_color4 Salmon

//------- ������� ��������� ���������� -------------------------------
extern int HourOpenPos  = 7;      // ����� �������� �������
extern int HourClosePos = 19;     // ����� �������� �������

//------- ���������� ���������� --------------------------------------
int ArrowInterval;

//------- ���������� ������� ������� ---------------------------------

//------- ������� ��������� ���������� -------------------------------
extern int NumberOfBars = 10000;  // ���������� ����� ������� (0-���)

//------- ������ ���������� ------------------------------------------
double SigBuy[];
double SigSell[];
double SigExitBuy[];
double SigExitSell[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  SetIndexBuffer(0, SigBuy);
  SetIndexStyle (0, DRAW_ARROW);
  SetIndexArrow (0, 233);
  SetIndexEmptyValue(0, EMPTY_VALUE);

  SetIndexBuffer(1, SigSell);
  SetIndexStyle (1, DRAW_ARROW);
  SetIndexArrow (1, 234);
  SetIndexEmptyValue(1, EMPTY_VALUE);

  SetIndexBuffer(2, SigExitBuy);
  SetIndexStyle (2, DRAW_ARROW);
  SetIndexArrow (2, 251);
  SetIndexEmptyValue(2, EMPTY_VALUE);

  SetIndexBuffer(3, SigExitSell);
  SetIndexStyle (3, DRAW_ARROW);
  SetIndexArrow (3, 251);
  SetIndexEmptyValue(3, EMPTY_VALUE);

  ArrowInterval = GetArrowInterval();
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start() {
  double ms[4];
  int    loopbegin, shift, ids;

 	if (NumberOfBars==0) loopbegin = Bars - 1;
  else loopbegin = NumberOfBars - 1;

  for (shift=loopbegin; shift>=0; shift--) {
    ms[0] = EMPTY_VALUE;
    ms[1] = EMPTY_VALUE;
    ms[2] = EMPTY_VALUE;
    ms[3] = EMPTY_VALUE;
    GetSignals(shift, ms);
    SigBuy[shift] = ms[0];
    SigSell[shift] = ms[1];
    SigExitBuy[shift+1] = ms[2];
    SigExitSell[shift+1] = ms[3];
  }
}

//+------------------------------------------------------------------+
//| ���������� �������� ��������� ���������� ����������              |
//+------------------------------------------------------------------+
int GetArrowInterval() {
  int p = Period();

  switch (p) {
    case 1:     return(5);
    case 5:     return(7);
    case 15:    return(10);
    case 30:    return(15);
    case 60:    return(20);
    case 240:   return(30);
    case 1440:  return(80);
    case 10080: return(150);
    case 43200: return(250);
  }
}

//+------------------------------------------------------------------+
//| ���������� �������� ��������� ���������� ����������              |
//+------------------------------------------------------------------+
void GetSignals(int nb, double& ms[]) {
  int    nsb=iBarShift(NULL, PERIOD_D1, Time[nb]);
  double Op1=iOpen (NULL, PERIOD_D1, nsb+1);
  double Cl1=iClose(NULL, PERIOD_D1, nsb+1);

  if (TimeDayOfWeek(Time[nb])==5 && TimeMinute(Time[nb])==0) {
    if (TimeHour(Time[nb])==HourOpenPos) {
      if (Op1>Cl1) ms[0]=Low[nb]-ArrowInterval*Point;
      if (Op1<Cl1) ms[1]=High[nb]+ArrowInterval*Point;
    }
    if (TimeHour(Time[nb])==HourClosePos) {
      if (Op1>Cl1) ms[2]=Close[nb+1];
      if (Op1<Cl1) ms[3]=Close[nb+1];
    }
  }
}
//+------------------------------------------------------------------+

