//+------------------------------------------------------------------+
//|                                    SHI_SilverTrendColourBars.mq4 |
//|          Copyright � 2003, VIAC.RU, OlegVS, GOODMAN, 2005 Shurka |
//|                                                 shforex@narod.ru |
//|                                                                  |
//|                                                                  |
//| ���� ��������� �� �����                                          |
//+------------------------------------------------------------------+
/*
   �����!!! ��� ����������� ����������� ���������� ��������� � ����
   "�������" ("Charts") ����� "������ ������" ("Foreground Chart")
   ����� ���� ����� ������������ ������ ���������� �������� ��.
*/
#property copyright "Copyright � 2005, Shurka"
#property link      "http://shforex.narod.ru"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- ������� ���������
extern int     AllBars=0;//��� ������� ����� �������. 0 - ��� ����.
extern int     Otstup=30;//������.
extern double  Per=9;//������.
int            SH,NB;
double         SHMax,SHMin;
double         BufD[];
double         BufU[];
//+------------------------------------------------------------------+
//| ������� �������������                                            |
//+------------------------------------------------------------------+
int init()
{
   //� NB ���������� ���������� ����� ��� ������� ������� ���������
   if (Bars<AllBars+Per || AllBars==0) NB=Bars-Per; else NB=AllBars;
   IndicatorBuffers(2);
   IndicatorShortName("SHI_SilverTrendColourBars");
   SetIndexStyle(0,DRAW_HISTOGRAM,0,1);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,1);
   SetIndexBuffer(0,BufU);
   SetIndexBuffer(1,BufD);
   SetIndexDrawBegin(0,Bars-NB);//��������� ����������������� ������ ��� NB �����
   SetIndexDrawBegin(1,Bars-NB);
   ArrayInitialize(BufD,0.0);//������ ��� ������ ��������. ����� ����� ����� ��� ����� ����������.
   ArrayInitialize(BufU,0.0);
   return(0);
}
//+------------------------------------------------------------------+
//| ������� ���������������                                          |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}
//+------------------------------------------------------------------+
//| ������ ���������                                                 |
//+------------------------------------------------------------------+
int start()
{
   int CB=IndicatorCounted();
   /* ��� ��� �� ����� ��������������� �����. � ���� ������� �������, ������� ���������� ����������
   ����������� �����, ������ ����� �����. ��� ������ ������ ���������� ��� 0, �� �������, ��� ������
   �� ���������, � ����� ����� ���������� ����������� ����� ����� ����. �.�. ���� ����� ����� 100,
   �� ������� ����� 99. � ��� ����� ���, ���� � ���� ������������ NB - ���-�� ����� ����������
   �������. � �������� ���� �������� ����� � ��������, ������ ��� ��� ��� � ����� (I80286) �����
   � ��������. ��� ���, �����, ��� ������ ������ NB ������� �������, � ��� ����������� �����������
   �� ���������� ����, �.�. 1 ��� 2, �� ��� ������� ��� �������� ���������*/
   if(CB<0) return(-1); else if(NB>Bars-CB) NB=Bars-CB;
   for (SH=0;SH<NB;SH++)//����������� ������ �� 0 �� NB
   {
      SHMax = High[Highest(NULL,0,MODE_HIGH,Per,SH)];
      SHMin = Low[Lowest(NULL,0,MODE_LOW,Per,SH)];
      if (Close[SH]<SHMin+(SHMax-SHMin)*Otstup/100) {BufU[SH]=High[SH]; BufD[SH]=Low[SH];}
      if (Close[SH]>SHMax-(SHMax-SHMin)*Otstup/100) {BufD[SH]=High[SH]; BufU[SH]=Low[SH];}
   }
   return(0);
}