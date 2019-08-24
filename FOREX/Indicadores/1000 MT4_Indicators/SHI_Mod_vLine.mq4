//+------------------------------------------------------------------+
//|                                                SHI_Mod_vLine.mq4 |
//|                               Copyright � 2004,   Shurka & Kevin |
//|                            Corrected&Upgraded by  Modest         |
//|                                  Additional idea  Rosh           |
//+------------------------------------------------------------------+
// Modest- ��������� �������� ���������� ������� ����� ����� 
// ������������� ���������� ��� ���������� ����� ������
// ��������� ����������� ������������ �� ������� ��� ������ ��������� MetaClick.
// ��� ������������ ����� ������ ������������ � �������
// ������ SHI_Mod_vLine: ����������� ����� ���������� ����� �������������� VLINE -���� Rosh'a
#property copyright "Copyright � 2004, Shurka & Kevin "
#property link      ""
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
double ExtMapBuffer1[];
double UpLabel[];

extern int       BarsForFract=0;
extern bool      DOT_Line_Ray=True;
int CurrentBar=0;
double Step=0;
int B1=-1,B2=-1,iB1=0,iB2=0,flag=0;
int UpDown=0;
double P1=0,P2=0,PP=0,P1f=0,PPf=0;
int i=0,AB=300,BFF=0;
int ishift=0;
double iprice=0;
datetime T1,T2,Tf,myTime;
string fileNAME;
int myYear,myMonth,myDay,myHour,myMinute;

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

    SetIndexStyle(1,DRAW_ARROW,EMPTY,1,Blue);
    SetIndexBuffer(1,UpLabel);
    SetIndexArrow(1, 251);
    SetIndexEmptyValue(1,0);
	
	   
	
	
	
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   FileDelete(fileNAME);
//----
   return(0);
  }

void DelObj()
{
	ObjectDelete("TL1");	ObjectDelete("TL2");	ObjectDelete("MIDL");
   ObjectDelete("Lab1");ObjectDelete("Lab2");ObjectDelete("Lab3");
   ObjectDelete("TL1f");ObjectDelete("TL2f");
   //ObjectDelete("MyBarLine");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
  {
   double iPP,Lab1Val,Lab2Val,Lab3Val;
   int MyBar,lastBarTime,h1,ii;
   string v1,fileFrame;
      
      ObjectCreate("MyBarLine",OBJ_VLINE,0,Time[1],High[1]); 
      ObjectSet("MyBarLine",OBJPROP_COLOR,Aqua); 
		ObjectSet("MyBarLine",OBJPROP_WIDTH,1); 
		ObjectSet("MyBarLine",OBJPROP_STYLE,STYLE_DOT);    
   
   
//****************************************************************************************  
//   ������ ������ (������)  �� �������� �����, ��������������� ���������� MetaClick,    
//   ���� ���� � ��� (Z+LeftMouse) ����������� �����, �� �������� �������� ���������.
//   ���� ������ ����� ����
//**************************************************************************************** 
 /*   // ����� ������ MetaClick �� ������������
        switch (Period())  // ������������ ����� ����� �������� �����
      {
      case PERIOD_M1:     fileFrame=",M1";break;
      case PERIOD_M5:     fileFrame=",M5";break;
      case PERIOD_M15:    fileFrame=",M15";break;
      case PERIOD_M30:    fileFrame=",M30";break;
      case PERIOD_H1:     fileFrame=",H1";break;
	   case PERIOD_H4:     fileFrame=",H4";break;
	   case PERIOD_D1:     fileFrame=",Daily";break;
	   case PERIOD_W1:     fileFrame=",Weekly";break;
	   case PERIOD_MN1:    fileFrame=",Monthly";break;   
      }
      fileNAME=Symbol()+fileFrame+".csv";
      h1=FileOpen(Symbol()+fileFrame+".csv",FILE_CSV,";");
      v1 = FileReadString(h1);
      FileClose(h1);
      Comment(v1);
      lastBarTime=StrToTime(v1);
      i=0;
      while (i<=Bars-1 )
      {if (lastBarTime==Time[i])
         { MyBar=i;break;}
      i++;
      }
*/
//**^^^*****^^ ��������� ������ ��������� ��� ��� ���������� ���������� **************** 
   
   
   
   
   myTime=ObjectGet("MyBarLine",OBJPROP_TIME1);
   if(myTime>Time[0] || myTime< Time[Bars-1])  
   {ObjectDelete("MyBarLine"); Alert("SHI_Mod_vLine: TimeFrames are not correct");  return(0);  }
   myYear=TimeYear(myTime); myMonth=TimeMonth(myTime);myDay=TimeDay(myTime);
   myHour=TimeHour(myTime); myMinute=TimeMinute(myTime);
   
   // ��� ���������� ������������ ����������� ������ � ���� �� ������� ���� ���������
   // ����� ������������ ������������ ����� �� ������� �������� ����������.
   if (Period()==PERIOD_MN1 || Period()==PERIOD_W1) 
      {Alert("SHI_Mod_vLine can''t work with Weekly and Monthly charts"); 
        ObjectDelete("MyBarLine"); return(0);}
   
   switch (Period())  // 
      {
      case PERIOD_M1:     break;
      case PERIOD_M5:     myMinute=MathFloor(myMinute/5)*5; break;
      case PERIOD_M15:    myMinute=MathFloor(myMinute/15)*15; break;
      case PERIOD_M30:    myMinute=MathFloor(myMinute/30)*30; break;
      case PERIOD_H1:     myMinute=0; break;
	   case PERIOD_H4:     myHour=MathFloor(myHour/4)*4; myMinute=0; break;
	   case PERIOD_D1:     myHour=0; myMinute=0; break;
	   case PERIOD_W1:     /*i=0; while(i<=Bars-1) 
	                       {
	                          if (TimeYear(Time[i])==myYear && TimeMonth(Time[i])==myMonth &&
	                              myDay-TimeDay(Time[i])<=6 && myDay-TimeDay(Time[i])>=0)
	                              myDay=TimeDay(Time[i]);  break; 
	                          i++;  //�����������!!
	                       }*/
	                       break;
	   case PERIOD_MN1:    break;   
      }
      
      ObjectDelete("MyBarLine");
      
   
   myTime=StrToTime(myYear + "." + myMonth + "." + myDay + " "  + myHour + ":" + myMinute);
      
      ObjectCreate("MyBarLine",OBJ_VLINE,0,myTime,High[0]); 
      ObjectSet("MyBarLine",OBJPROP_COLOR,Aqua); 
		ObjectSet("MyBarLine",OBJPROP_WIDTH,1); 
		ObjectSet("MyBarLine",OBJPROP_STYLE,STYLE_DOT);  
   //�������
   /*
   Alert(myYear + "." + myMonth + "." + myDay + " "  + myHour + ":" + myMinute);
   myYear=TimeYear(myTime); myMonth=TimeMonth(myTime);myDay=TimeDay(myTime);
   myHour=TimeHour(myTime); myMinute=TimeMinute(myTime);
   Alert(myYear + "." + myMonth + "." + myDay + " "  + myHour + ":" + myMinute);
   */
   
   //return(0);
   
   
   i=0;
   while(Time[i]!=myTime) {i++;}
   MyBar=i;
   
   ArrayInitialize(UpLabel,0.0);
   if (Bars<MyBar+303) {Alert("Too little history");return(-1);}
   int    counted_bars=IndicatorCounted();
//---- 
	//if(Bars<AllBars)  AllBars=Bars;                 //return(-1);
	//if(AllBars<AB) {Comment("���� �����"); return(-1);}
	//Alert("MyBar=",MyBar);
	//if ((AllBars==0) || (Bars<AllBars)) AB=Bars; else AB=AllBars; //AB-���������� ������������� �����
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
	CurrentBar=2+MyBar; //������� � �������� ����, ����� ������� "����������
	B1=-1; B2=-1; UpDown=0; flag=0;
	
	while(((B1==-1) || (B2==-1)) && (CurrentBar<(AB+MyBar)))
	{
		//UpDown=1 ������ ������ ������� ������ ������, UpDown=-1 ������ ������ �������
		//������ �����, UpDown=0 ������ ������� ��� �� ������.
		//�1 � �2 - ������ ����� � ����������, ����� ��� ������ ������� �����.
		//�1 � �2 - �������������� ���� ����� ������� ����� ����� ���������
     // if (CurrentBar==4 ) Alert("CurrentBar=",CurrentBar," ","BFF=",BFF);
		
		if((UpDown<1) && (CurrentBar==Lowest(Symbol(),Period(),MODE_LOW,BFF*2+1,CurrentBar-BFF))) 
	// ��������� CurrentBar-BFF ����� ���� � ��� ������ �������������. �� ����� ��������
	
		{
		  if(UpDown==0) { UpDown=-1; B1=CurrentBar; iB1=CurrentBar; P1=Low[B1];}
			else { B2=CurrentBar; iB2=CurrentBar; P2=Low[B2];}
		}
		if((UpDown>-1) && (CurrentBar==Highest(Symbol(),Period(),MODE_HIGH,BFF*2+1,CurrentBar-BFF))) 
	
		{
			if(UpDown==0) { UpDown=1; B1=CurrentBar; iB1=CurrentBar; P1=High[B1];}
			else { B2=CurrentBar; iB2=CurrentBar; P2=High[B2];}
		}
		CurrentBar++;
	}
	if((B1==-1) || (B2==-1)) {DelObj(); return(-1);} // ������ �� ����� ��������� ����� 300 ����� 8-)
	Step=(P2-P1)/(B2-B1);//��������� ���, ���� �� �������������, �� ����� ����������
	P1=P1-(B1-MyBar)*Step; B1=0+MyBar;//������������ ���� � ������ ��� � ���� (�������� ������� ����� �� 0 ����)
	
	//� ������ ������� ����� ��������������� ����� ������.
	ishift=0+MyBar; iprice=0;
	
	//Alert(UpDown);
	if(UpDown==1)
	{ 
		//  ����������!!  ������� ����� ����� ������ ����� ������������� ����������,
		//  � �� � 0-�� (MyBar) ����. iB1-��� �� ���������� B1
		
		//PP=Low[2+MyBar]-(2)*Step;
				
		PP=Low[2+iB1]-(2)*Step;
		iPP=Low[2+iB1]-(2)*Step;
		ii=2+iB1;
		//for(i=3+MyBar;i<=B2;i++) 
		for(i=3+iB1;i<=B2;i++) 
		{
			//if(Low[i]<PP+Step*(i-MyBar)) { PP=Low[i]-(i-MyBar)*Step; ii=i;}
		    if(Low[i]<iPP+Step*(i-iB1)) 
		       //PP-�������� ����� �� ��������� ����
		       // iPP-�������� ����� �� ���� iB1 -������ �������
		       { PP=Low[i]-(i-MyBar)*Step; ii=i;
		        iPP=Low[i]-(i-iB1)*Step;  
		       }
		}
		
		//Alert(iB1,"  ",iB2,"  ",ii,"  ","Step=",Step,"  ","PP=",PP);
		//Lab1Val=(High[iB1]+5*Point); 	Lab2Val=(High[iB2]+5*Point); 	Lab3Val=(Low[ii]-5*Point);
		UpLabel[iB1]=High[iB1]+5*Point;
		UpLabel[iB2]=High[iB2]+5*Point;
		UpLabel[ii]=Low[ii]-5*Point;
		
		//Alert(iB1,"  ",ii,"  ",iB2,"  ","Step=",Step,"  ","PP=",PP,"  ","Lab1Val=",Lab1Val);

		
		if(Low[0+MyBar]<PP) {ishift=0+MyBar; iprice=PP;}
		if(Low[1+MyBar]<PP+Step) {ishift=1+MyBar; iprice=PP+Step;}
		if(High[0+MyBar]>P1) {ishift=0+MyBar; iprice=P1;}
		if(High[1+MyBar]>P1+Step) {ishift=1+MyBar; iprice=P1+Step;}
	} 
	else  //����� ����
	{ 
		PP=High[2+MyBar]-(2)*Step;
		iPP=High[2+iB1]-(2)*Step;
		ii=2+iB1;
		//for(i=3+MyBar;i<=B2;i++) 
		for(i=3+iB1;i<=B2;i++)  
		{
			if(High[i]>iPP+Step*(i-iB1)) { PP=High[i]-(i-MyBar)*Step;ii=i;
			                                 iPP=High[i]-(i-iB1)*Step;
			                               } //���� �������� ������� ����� �� 0 ����
		}
		
		//Lab1Val=(Low[iB1]-5*Point);Lab2Val=(Low[iB2]-5*Point);Lab3Val=(High[ii]+5*Point);
		UpLabel[iB1]=Low[iB1]-5*Point;
		UpLabel[iB2]=Low[iB2]-5*Point;
		UpLabel[ii]=High[ii]+5*Point;
		
		
		
		//Alert(iB1,"  ",iB2,"  ","ii=",ii,"  ","Step=",Step,"  ","PP=",PP,"  ",
		//       "Lab1Val=",Lab1Val,"Lab3Val=",Lab3Val);
		
		// ����������, ���� �� ����������� ����� ������ �� 0 ��� 1 �����(����� ������� �����)
		if(Low[0+MyBar]<P1) {ishift=0+MyBar; iprice=P1;}
		if(Low[1+MyBar]<P1+Step) {ishift=1+MyBar; iprice=P1+Step;}
		if(High[0+MyBar]>PP) {ishift=0+MyBar; iprice=PP;}
		if(High[1+MyBar]>PP+Step) {ishift=1+MyBar; iprice=PP+Step;}
	}
	//������ ���������� �������� ���� � ��� �� ��, ����� ����� ������ ���������� ���������
	P2=P1+AB*Step;
	T1=Time[B1]; T2=Time[AB+MyBar];

	//���� �� ���� ����������� ������, �� 0, ����� ������ �����.
	//if(iprice!=0) ExtMapBuffer1[ishift]=iprice;
	DelObj();
	
	//Alert("B1=",B1,"  ","B2=",AB+MyBar,"    ","AB=",AB,"  ","MyBar=",MyBar);
//	Alert("T1=",T1,"  ","T2=",T2);

//***************************************** ������ ����� ������ ************************
	ObjectCreate("TL1",OBJ_TREND,0,T2,PP+Step*(AB),T1,PP); 
		ObjectSet("TL1",OBJPROP_COLOR,Tomato); 
		ObjectSet("TL1",OBJPROP_WIDTH,2); 
		ObjectSet("TL1",OBJPROP_STYLE,STYLE_SOLID); 
      ObjectSet("TL1",OBJPROP_RAY,False); 
	ObjectCreate("TL2",OBJ_TREND,0,T2,P2,T1,P1); 
		ObjectSet("TL2",OBJPROP_COLOR,Tomato); 
		ObjectSet("TL2",OBJPROP_WIDTH,2); 
		ObjectSet("TL2",OBJPROP_STYLE,STYLE_SOLID); 
	   ObjectSet("TL2",OBJPROP_RAY,False); 
	ObjectCreate("MIDL",OBJ_TREND,0,T2,(P2+PP+Step*AB)/2,T1,(P1+PP)/2);
		ObjectSet("MIDL",OBJPROP_COLOR,Tomato); 
		ObjectSet("MIDL",OBJPROP_WIDTH,1); 
		ObjectSet("MIDL",OBJPROP_STYLE,STYLE_DOT); 
      ObjectSet("MIDL",OBJPROP_RAY,DOT_Line_Ray); 

//*********************************** ������ ����������� ������ ************************
     if (MyBar>30) {Tf=Time[MyBar-30]; 
                     PPf=PP-Step*30; P1f=P1-Step*30;
                   }
     else          {Tf=Time[0];PPf=PP-Step*MyBar; P1f=P1-Step*MyBar; 
                   }
    ObjectCreate("TL1f",OBJ_TREND,0,T1,PP,Tf,PPf); 
		ObjectSet("TL1f",OBJPROP_COLOR,Lime); 
		ObjectSet("TL1f",OBJPROP_WIDTH,1); 
		ObjectSet("TL1f",OBJPROP_STYLE,STYLE_DOT); 
      ObjectSet("TL1f",OBJPROP_RAY,DOT_Line_Ray); 
    ObjectCreate("TL2f",OBJ_TREND,0,T1,P1,Tf,P1f); 
		ObjectSet("TL2f",OBJPROP_COLOR,Lime); 
		ObjectSet("TL2f",OBJPROP_WIDTH,1); 
		ObjectSet("TL2f",OBJPROP_STYLE,STYLE_DOT); 
      ObjectSet("TL2f",OBJPROP_RAY,DOT_Line_Ray); 
    
//************************* �������� ��������� ���  ************************************    
   /*if (MyBar>0)    
      {
      ObjectCreate("MyBarLine",OBJ_VLINE,0,Time[MyBar],High[MyBar]); 
      ObjectSet("MyBarLine",OBJPROP_COLOR,MediumOrchid); 
		ObjectSet("MyBarLine",OBJPROP_WIDTH,1); 
		ObjectSet("MyBarLine",OBJPROP_STYLE,STYLE_DOT); 
      }
   */
   
//----
   return(0);
  }
//+------------------------------------------------------------------+