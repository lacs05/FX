//+------------------------------------------------------------------+
//|                                           SHI_SilverTrendSig.mq4 |
//|       Copyright � 2003, VIAC.RU, OlegVS, GOODMAN, � 2005, Shurka |
//|                                                 shforex@narod.ru |
//|                                                                  |
//|                                                                  |
//| ���� ��������� �� �����                                          |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2005, Shurka"
#property link      "http://shforex.narod.ru"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
#define  SH_BUY   1
#define  SH_SELL  -1

//---- ������� ���������
extern int     AllBars=0;//��� ������� ����� �������. 0 - ��� ����.
extern int     Otstup=30;//������.
extern int     Per=9;//������.
int            SH,NB,i,UD;
double         R,SHMax,SHMin;
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
   IndicatorShortName("SHI_SilverTrendSig");
   SetIndexStyle(0,DRAW_ARROW,0,1);
   SetIndexStyle(1,DRAW_ARROW,0,1);
   SetIndexArrow(0,159);
   SetIndexArrow(1,159);
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
   for (SH=1;SH<NB;SH++)//����������� ������ �� 1 �� NB
   {
      for (R=0,i=SH;i<SH+10;i++) {R+=(10+SH-i)*(High[i]-Low[i]);}      R/=55;

      SHMax = High[Highest(NULL,0,MODE_HIGH,Per,SH)];
      SHMin = Low[Lowest(NULL,0,MODE_LOW,Per,SH)];
      if (Close[SH]<SHMin+(SHMax-SHMin)*Otstup/100 && UD!=SH_SELL) { BufD[SH]=High[SH]+R*0.5; UD=SH_SELL; }
      if (Close[SH]>SHMax-(SHMax-SHMin)*Otstup/100 && UD!=SH_BUY) { BufU[SH]=Low[SH]-R*0.5; UD=SH_BUY; }
   }
   return(0);
}