//+------------------------------------------------------------------+
//|                                              i-BigBarsFromH1.mq4 |
//|                                           ��� ����� �. aka KimIV |
//|                                              http://www.kimiv.ru |
//| �� ������� ������� ���������� ����� ������� ��                   |
//+------------------------------------------------------------------+
#property copyright "��� ����� �. aka KimIV"
#property link      "http://www.kimiv.ru"

#property indicator_chart_window

//---- ������� ��������� ---------------------------------------------
extern int TFBar       = 3;      // ������ ������� ������
extern int NumberOfBar = 50;     // ���������� ������� ������
extern int offsetHour  = -2;     // �������� �����
extern color ColorUp   = Aqua;   // ���� ���������� �����
extern color ColorDown = Pink;   // ���� ���������� �����

//------- ���������� ���������� --------------------------------------

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  int i;

  for (i=0; i<NumberOfBar; i++) {
    ObjectDelete("BodyH"+TFBar+"Bar" + i);
    ObjectDelete("ShadowH"+TFBar+"Bar" + i);
  }
  for (i=0; i<NumberOfBar; i++) {
    ObjectCreate("BodyH"+TFBar+"Bar" + i, OBJ_RECTANGLE, 0, 0,0, 0,0);
    ObjectCreate("ShadowH"+TFBar+"Bar" + i, OBJ_TREND, 0, 0,0, 0,0);
  }
  Comment("");
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
  // �������� ��������
  for (int i=0; i<NumberOfBar; i++) {
    ObjectDelete("BodyH"+TFBar+"Bar" + i);
    ObjectDelete("ShadowH"+TFBar+"Bar" + i);
  }
  Comment("");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start() {
  int shb=0, sh1=1, d;
  double   po, pc;       // ���� �������� � �������� ������� ������
  double   ph=0, pl=500; // ���� ��� � ��� ������� ������
  datetime to, tc, ts;   // ����� ��������, �������� � ����� ������� ������

  if (Period()!=60) Comment("��������� i-BigBarsFromH1 ������������ �� ������ �1!");
  else {
    if (MathMod(TFBar,2)==0) d=TFBar/2; else d=TFBar/2+1;
    pc = Close[0];
    tc = Time[0];
    // ����� �� ������� �������
    while (shb<NumberOfBar) {
      // ����� �� ������� �������
      ph = MathMax(ph, High[sh1-1]);
      pl = MathMin(pl, Low[sh1-1]);
      ts = StrToTime(TimeToStr(Time[sh1-d], TIME_DATE)+" "+TimeHour(Time[sh1-d])+":30");
      if (MathMod(TimeHour(Time[sh1])+1+offsetHour, TFBar)==0/* || TimeDay(Time[sh1])!=TimeDay(Time[sh1-1])*/) {
        po = Open[sh1-1];
        to = Time[sh1-1];
        ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_TIME1, to);
        ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_PRICE1, po);
        ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_TIME2, tc);
        ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_PRICE2, pc);
        ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_BACK, True);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_TIME1, ts);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_PRICE1, ph);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_TIME2, ts);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_PRICE2, pl);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_WIDTH, 3);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_BACK, True);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_RAY, False);
        if (po<pc) {
          ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_COLOR, ColorUp);
          ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_COLOR, ColorUp);
        } else {
          ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_COLOR, ColorDown);
          ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_COLOR, ColorDown);
        }
        pc = Close[sh1];
        tc = Time[sh1];
        ph = 0;
        pl = 500;
        ph = MathMax(ph, High[sh1]);
        pl = MathMin(pl, Low[sh1]);
        shb++;
      }
      sh1++;
    }
  }
}
//+------------------------------------------------------------------+

