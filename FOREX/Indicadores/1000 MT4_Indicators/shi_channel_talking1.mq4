//+------------------------------------------------------------------+
//|                                                  SHI_Channel.mq4 |
//|                                 Copyright � 2004, Shurka & Kevin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2004, Shurka & Kevin"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
double ExtMapBuffer1[];
//---- input parameters
extern int       AllBars=240;
extern int       BarsForFract=0;
extern int       ChannelAlert=50;
extern int       SlopeAlert=25;
extern bool      ChannelTalk=true;
int CurrentBar=0;
int alertTag;
double Step=0;
int B1=-1,B2=-1;
int UpDown=0;
double P1=0,P2=0,PP=0;
double OldChannelWidth,OldSlopeAngle;
int i=0,AB=300,BFF=0;
int ishift=0;
double iprice=0;
datetime T1,T2;
int firsttime=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,164);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
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

void DelObj()
{
	ObjectDelete("TL1");
	ObjectDelete("TL2");
	ObjectDelete("MIDL");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   
   string symbolTxt;
   string WhatTxt;
if (Symbol()=="EURUSD") { symbolTxt = "Euro Dollar"; }
if (Symbol()=="EURJPY") { symbolTxt = "Euro Yen "; }
if (Symbol()=="EURAUD") { symbolTxt = "Euro Aussie "; }
if (Symbol()=="EURCAD") { symbolTxt = "Euro Canadian"; }
if (Symbol()=="EURCHF") { symbolTxt = "Euro Swiss"; }
if (Symbol()=="GBPUSD") { symbolTxt = "Cable Dollar"; }
if (Symbol()=="GBPJPY") { symbolTxt = "Cable Yen "; }
if (Symbol()=="GBPCHF") { symbolTxt = "Cable Swiss"; }
if (Symbol()=="AUDUSD") { symbolTxt = "Aussie"; }
if (Symbol()=="USDCHF") { symbolTxt = "Swiss Dollar"; }
if (Symbol()=="USDCAD") { symbolTxt = "Canada"; }
if (Symbol()=="USDJPY") { symbolTxt = "Yen Dollar"; } 
if (Symbol()=="CHFJPY") { symbolTxt = "Swiss Yen "; }
if (Symbol()=="GOLD")   { symbolTxt = "Gold"; }
   
//---- 
	if ((AllBars==0) || (Bars<AllBars)) AB=Bars; else AB=AllBars; //AB-���������� ������������� �����
	if (BarsForFract>0) 
		BFF=BarsForFract; 
	else
	{
		switch (Period())
		{
			case 1: BFF=12; break;
			case 5: BFF=48; break;
			case 15: BFF=24; break;
			case 30: BFF=24; break;
			case 60: BFF=12; break;
			case 240: BFF=15; break;
			case 1440: BFF=10; break;
			case 10080: BFF=6; break;
			default: DelObj(); return(-1); break;
		}
	}
	CurrentBar=2; //������� � �������� ����, ����� ������� "����������
	B1=-1; B2=-1; UpDown=0;
	while(((B1==-1) || (B2==-1)) && (CurrentBar<AB))
	{
		//UpDown=1 ������ ������ ������� ������ ������, UpDown=-1 ������ ������ �������
		//������ �����, UpDown=0 ������ ������� ��� �� ������.
		//�1 � �2 - ������ ����� � ����������, ����� ��� ������ ������� �����.
		//�1 � �2 - �������������� ���� ����� ������� ����� ����� ���������

		if((UpDown<1) && (CurrentBar==Lowest(Symbol(),Period(),MODE_LOW,BFF*2+1,CurrentBar-BFF))) 
		{
			if(UpDown==0) { UpDown=-1; B1=CurrentBar; P1=Low[B1]; }
			else { B2=CurrentBar; P2=Low[B2];}
		}
		if((UpDown>-1) && (CurrentBar==Highest(Symbol(),Period(),MODE_HIGH,BFF*2+1,CurrentBar-BFF))) 
		{
			if(UpDown==0) { UpDown=1; B1=CurrentBar; P1=High[B1]; }
			else { B2=CurrentBar; P2=High[B2]; }
		}
		CurrentBar++;
	}
	if((B1==-1) || (B2==-1)) {DelObj(); return(-1);} // ������ �� ����� ��������� ����� 300 ����� 8-)
	Step=(P2-P1)/(B2-B1);//��������� ���, ���� �� �������������, �� ����� ����������
	P1=P1-B1*Step; B1=0;//������������ ���� � ������ ��� � ����
	//� ������ ������� ����� ��������������� ����� ������.
	ishift=0; iprice=0;
	if(UpDown==1)
	{ 
		PP=Low[2]-2*Step;
		for(i=3;i<=B2;i++) 
		{
			if(Low[i]<PP+Step*i) { PP=Low[i]-i*Step; }
		}
		if(Low[0]<PP) {ishift=0; iprice=PP;}
		if(Low[1]<PP+Step) {ishift=1; iprice=PP+Step;}
		if(High[0]>P1) {ishift=0; iprice=P1;}
		if(High[1]>P1+Step) {ishift=1; iprice=P1+Step;}
	} 
	else
	{ 
		PP=High[2]-2*Step;
		for(i=3;i<=B2;i++) 
		{
			if(High[i]>PP+Step*i) { PP=High[i]-i*Step;}
		}
		if(Low[0]<P1) {ishift=0; iprice=P1;}
		if(Low[1]<P1+Step) {ishift=1; iprice=P1+Step;}
		if(High[0]>PP) {ishift=0; iprice=PP;}
		if(High[1]>PP+Step) {ishift=1; iprice=PP+Step;}
	}
	//������ ���������� �������� ���� � ��� �� ��, ����� ����� ������ ���������� ���������
	P2=P1+AB*Step;
	T1=Time[B1]; T2=Time[AB];

	//���� �� ���� ����������� ������, �� 0, ����� ������ �����.
	if(iprice!=0) ExtMapBuffer1[ishift]=iprice;
	DelObj();
	
	double ChannelWidth=MathAbs(PP - P1)/Point;
	double SlopeAngle=MathFloor((-Step/Point)*100);
	ObjectCreate("TL1",OBJ_TREND,0,T2,PP+Step*AB,T1,PP);
	// Channel is Green if width is greater than ChannelAlert (Default 50), otherwise it is Red
      if(ChannelWidth >= ChannelAlert) {ObjectSet("TL1",OBJPROP_COLOR,Lime);}
	      else {ObjectSet("TL1",OBJPROP_COLOR,Red); }
		ObjectSet("TL1",OBJPROP_WIDTH,2); 
		ObjectSet("TL1",OBJPROP_STYLE,STYLE_SOLID); 
	ObjectCreate("TL2",OBJ_TREND,0,T2,P2,T1,P1); 	
		if(ChannelWidth >= ChannelAlert) {ObjectSet("TL2",OBJPROP_COLOR,Lime); }
   	  else{ObjectSet("TL2",OBJPROP_COLOR,Red);}
      ObjectSet("TL2",OBJPROP_WIDTH,2); 
		ObjectSet("TL2",OBJPROP_STYLE,STYLE_SOLID); 
	   ObjectCreate("MIDL",OBJ_TREND,0,T2,(P2+PP+Step*AB)/2,T1,(P1+PP)/2);
	 // Mid line is Green if Slope is greater than SlopeAlert (Default 25), otherwise it is Red
		if(ChannelWidth >= ChannelAlert && MathAbs(SlopeAngle) >= SlopeAlert) {ObjectSet("MIDL",OBJPROP_COLOR,Lime); }
		   else{ObjectSet("MIDL",OBJPROP_COLOR,Red);}
		ObjectSet("MIDL",OBJPROP_WIDTH,1); 
		ObjectSet("MIDL",OBJPROP_STYLE,STYLE_DOT); 
		WhatTxt="Change";
		if (OldChannelWidth<ChannelWidth) WhatTxt="is widening";
		if (OldChannelWidth>ChannelWidth) WhatTxt="is narrowing";
		if (OldSlopeAngle<0 && SlopeAngle>0 )WhatTxt="Changed direction to up";
		if (OldSlopeAngle>0 && SlopeAngle<0 )WhatTxt="Changed direction to down";
		
		
		if(firsttime && ChannelTalk && alertTag != Time[0]&& OldChannelWidth!=ChannelWidth || OldSlopeAngle!=SlopeAngle)
		{
	//Alert("Shi Channel Change");
		SpeechText("chee channel"+ WhatTxt+" "+symbolTxt);
                  alertTag = Time[0];
                  
		}
		
			
		
		
		OldChannelWidth=ChannelWidth;
		OldSlopeAngle=SlopeAngle;
		firsttime=firsttime+1;
		Comment(" Channel size = ", DoubleToStr(ChannelWidth,0), " Slope = ", DoubleToStr(SlopeAngle,0));
//----
   return(0);
  }
//+------------------------------------------------------------------+