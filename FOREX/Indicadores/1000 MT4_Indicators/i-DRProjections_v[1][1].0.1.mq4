//+------------------------------------------------------------------+
//|                                              i-DRProjections.mq4 |
//|                                           ��� ����� �. aka KimIV |
//|                                              http://www.kimiv.ru |
//|   27.08.2005 v.0.0 �� ������� $anto$'�                           |
//| ��������� Daily Range Projections                                |
//| ��������������� ������� ���������� ���                           |
//| ����� ���� ����� ������                                          |
//|   29.08.2005 v.0.1 ��������� Aleks78                             |
//+------------------------------------------------------------------+
#property copyright "��� ����� �. aka KimIV"
#property link      "http://www.kimiv.ru"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LightBlue
#property indicator_color2 LightSalmon

//------- ������� ��������� ------------------------------------------
extern int  NumberOfDay  = 10;   // ���������� ����
extern bool ShowTomorrow = True; // ���������� ������

//------- ������ ���������� ------------------------------------------
double MaxDay[];
double MinDay[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  if (ShowTomorrow) {
    ObjectCreate("LineHi", OBJ_TREND, 0, 0,0, 0,0);
    ObjectCreate("LineLo", OBJ_TREND, 0, 0,0, 0,0);
  }

  SetIndexBuffer(0, MaxDay);
  SetIndexStyle (0, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexBuffer(1, MinDay);
  SetIndexStyle (1, DRAW_LINE, STYLE_SOLID, 1);
  Comment("");
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
  ObjectDelete("LineHi");
  ObjectDelete("LineLo");
  Comment("");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  double po, ph, pl, pc, x;
  double MaxDay1, MinDay1, OpenDay1, CloseDay1; //+++
  int    currDay, i=0, j=0;

  if (Period()>240) {
    Comment("��������� i-DRProjections �� ������������ �� ����� �4 !");
    return;
  }

  while (i<=NumberOfDay) {
    if (currDay!=TimeDay(Time[j])) {
      po = iOpen (NULL, 1440, i+1);
      ph = iHigh (NULL, 1440, i+1);
      pl = iLow  (NULL, 1440, i+1);
      pc = iClose(NULL, 1440, i+1);
      if (pc<po) x = (ph + pl + pc + pl) / 2;
      if (pc>po) x = (ph + pl + pc + ph) / 2;
      if (pc==po) x = (ph + pl + pc + pc) / 2;
      i++;
    }
    currDay = TimeDay(Time[j]);
    MaxDay[j] = x - pl;
    MinDay[j] = x - ph;
    j++;
  }
  
  //++++++++++++++++++++++++++++++++++++++++++++++++
  if (ShowTomorrow) {
    MaxDay1   = MarketInfo(Symbol(),MODE_HIGH);
    MinDay1   = MarketInfo(Symbol(),MODE_LOW);
    OpenDay1  = iOpen (NULL, 1440, 0);           
    CloseDay1 = Bid;   
     
    if (CloseDay1<OpenDay1) x = (MaxDay1 + MinDay1 + CloseDay1 + MinDay1) / 2;
    if (CloseDay1>OpenDay1) x = (MaxDay1 + MinDay1 + CloseDay1 + MaxDay1) / 2;
    if (CloseDay1==OpenDay1) x = (MaxDay1 + MinDay1 + CloseDay1 + CloseDay1) / 2;

    ObjectSet("LineHi",OBJPROP_TIME1, Time[1]);
    ObjectSet("LineLo",OBJPROP_TIME1, Time[1]);
    ObjectSet("LineHi",OBJPROP_PRICE1, x - MinDay1);
    ObjectSet("LineLo",OBJPROP_PRICE1, x - MaxDay1);
    ObjectSet("LineHi",OBJPROP_TIME2, CurTime());
    ObjectSet("LineLo",OBJPROP_TIME2, CurTime());
    ObjectSet("LineHi",OBJPROP_PRICE2, x - MinDay1);
    ObjectSet("LineLo",OBJPROP_PRICE2, x - MaxDay1);
    ObjectSet("LineHi",OBJPROP_COLOR, indicator_color1);
    ObjectSet("LineLo",OBJPROP_COLOR, indicator_color2);
    ObjectSet("LineHi",OBJPROP_RAY, True);
    ObjectSet("LineLo",OBJPROP_RAY, True);
    ObjectSet("LineHi",OBJPROP_STYLE, STYLE_DOT);
    ObjectSet("LineLo",OBJPROP_STYLE, STYLE_DOT);
  }
  //++++++++++++++++++++++++++++++++++++++++++++++++
}
//+------------------------------------------------------------------+

