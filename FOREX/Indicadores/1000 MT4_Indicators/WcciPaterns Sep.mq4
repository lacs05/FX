#property copyright "(C)2005, Yuri Ershtad"
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 MediumSeaGreen
#property indicator_color2 OrangeRed
#property indicator_color3 DeepSkyBlue
#property indicator_color4 IndianRed
#property indicator_color5 Tomato
#property indicator_color6 LimeGreen
#property indicator_color7 Coral
#property indicator_color8 Red

//////////////////////////////////////////////////////////////////////
// ��������
//////////////////////////////////////////////////////////////////////

extern int fastPeriod  = 6;
extern int slowPeriod  = 14;

//////////////////////////////////////////////////////////////////////
// ������ ������
//////////////////////////////////////////////////////////////////////
 
double ZlrBuffer[];     // 1. Zero-line Reject (ZLR)      -- trend 
double ShamuBuffer[];   // 2. Shamu Trade                 -- counter
double TlbBuffer[];     // 3. Trend Line Break (TLB/HTLB) -- both
double VegasBuffer[];   // 4. Vegas Trade (VT)			    -- counter
double GhostBuffer[];   // 5. Ghost Trade                 -- counter
double RevdevBuffer[];  // 6. Reverse Divergence          -- trend
double HooksBuffer[];   // 7. Hook from Extremes (HFE)    -- counter
double ExitBuffer[];    // 8. Exit signals

//////////////////////////////////////////////////////////////////////
// �������������
//////////////////////////////////////////////////////////////////////

int init()
{
   string short_name;
   IndicatorBuffers(8);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   ///////////////////////////////////////////////////////////////
   // ������� ������������� ������� �� 1 �� 8.  
   // ��� �������� � �������� �� ������ ������������ ������� �����, 
   // ������ ������ �������, ����� - ��� TLB � HTLB
   // ----
   short_name="Woodies CCI Paterns ("+fastPeriod+","+slowPeriod+")";
   IndicatorShortName(short_name);
   // Zero-line Reject (ZLR), trend
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, MediumSeaGreen);
   SetIndexBuffer(0, ZlrBuffer);    
   SetIndexArrow(0, 140);
   SetIndexLabel(0,"Zero-line Reject (ZLR), trend");
   SetIndexEmptyValue(0, EMPTY_VALUE);      
   SetIndexDrawBegin(0, slowPeriod);
   // Shamu Trade, counter-trend
   SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, OrangeRed);
   SetIndexBuffer(1, ShamuBuffer);    
   SetIndexArrow(1, 141);
   SetIndexLabel(1,"Shamu Trade, counter-trend");
   SetIndexEmptyValue(1, EMPTY_VALUE);      
   SetIndexDrawBegin(1, slowPeriod);
   // Trend Line Break (TLB), both
   SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, DeepSkyBlue);
   SetIndexBuffer(2, TlbBuffer);    
   SetIndexArrow(2, 142);
   SetIndexLabel(2,"Trend Line Break (TLB), both");
   SetIndexEmptyValue(2, EMPTY_VALUE);      
   SetIndexDrawBegin(2, slowPeriod);
   // Vegas Trade (VT), counter-trend
   SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, IndianRed);
   SetIndexBuffer(3, VegasBuffer);    
   SetIndexArrow(3, 143);
   SetIndexLabel(3,"Vegas Trade (VT), counter-trend");
   SetIndexEmptyValue(3, EMPTY_VALUE);      
   SetIndexDrawBegin(3, slowPeriod);
   // Ghost Trade, counter-trend
   SetIndexStyle(4, DRAW_ARROW, EMPTY, 1, Tomato);
   SetIndexBuffer(4, GhostBuffer);    
   SetIndexArrow(4, 144);
   SetIndexLabel(4,"Ghost Trade, counter-trend");
   SetIndexEmptyValue(4, EMPTY_VALUE);      
   SetIndexDrawBegin(4, slowPeriod);
   // Reverse Divergence, trend
   SetIndexStyle(5, DRAW_ARROW, EMPTY, 1, LimeGreen);
   SetIndexBuffer(5, RevdevBuffer);    
   SetIndexArrow(5, 145);
   SetIndexLabel(5,"Reverse Divergence, trend");
   SetIndexEmptyValue(5, EMPTY_VALUE);      
   SetIndexDrawBegin(5, slowPeriod);
   // Hook from Extremes (HFE), counter-trend
   SetIndexStyle(6, DRAW_ARROW, EMPTY, 1, Coral);
   SetIndexBuffer(6, HooksBuffer);    
   SetIndexArrow(6, 146);
   SetIndexLabel(6,"Hook from Extremes (HFE), counter-trend");
   SetIndexEmptyValue(6, EMPTY_VALUE);      
   SetIndexDrawBegin(6, slowPeriod);
   // Exit signal
   SetIndexStyle(7, DRAW_ARROW, EMPTY, 1, RoyalBlue);
   SetIndexBuffer(7, ExitBuffer);    
   SetIndexArrow(7, 251);
   SetIndexLabel(7,"Exit signal");
   SetIndexEmptyValue(7, EMPTY_VALUE);      
   SetIndexDrawBegin(7, slowPeriod);
   //----
   return(0);
}
  
//////////////////////////////////////////////////////////////////////
// Custor indicator deinitialization function                       
//////////////////////////////////////////////////////////////////////

int deinit()
{
   // TODO: add your code here
   return(0);
}

//////////////////////////////////////////////////////////////////////
// Custom indicator iteration function                              
//////////////////////////////////////////////////////////////////////

int start()
{
   string symbolName;
   int i, shift, checksum, counted_bars=IndicatorCounted();
   if (Bars<slowPeriod) return(0); 
   // check for possible errors
   if (counted_bars<0) return(-1);
   // last counted bar will be recounted
   if (counted_bars>0) counted_bars++;
   int limit=Bars-slowPeriod-counted_bars;
   if (counted_bars<1 || checksum!=(fastPeriod+slowPeriod+Period()) || symbolName!=Symbol())
   {
      // ��������� ��������, �������� ��������������� 
      for(i=1;i<=slowPeriod;i++) ZlrBuffer[Bars-i]=EMPTY_VALUE;
      for(i=1;i<=slowPeriod;i++) ShamuBuffer[Bars-i]=EMPTY_VALUE;
      for(i=1;i<=slowPeriod;i++) TlbBuffer[Bars-i]=EMPTY_VALUE;  
      for(i=1;i<=slowPeriod;i++) VegasBuffer[Bars-i]=EMPTY_VALUE;
      for(i=1;i<=slowPeriod;i++) GhostBuffer[Bars-i]=EMPTY_VALUE;
      for(i=1;i<=slowPeriod;i++) RevdevBuffer[Bars-i]=EMPTY_VALUE;
      for(i=1;i<=slowPeriod;i++) HooksBuffer[Bars-i]=EMPTY_VALUE;
      for(i=1;i<=slowPeriod;i++) ExitBuffer[Bars-i]=EMPTY_VALUE;      
      checksum = fastPeriod+slowPeriod+Period(); 
      symbolName=Symbol();
      limit=Bars-slowPeriod; 
   }
   for (shift=limit; shift>=0; shift--)
   {
      ///////////////////////////////////////////////////////////////
      //	���������� ������� ����� � ����������� ������
      ///////////////////////////////////////////////////////////////

      int delta=25,level=100;
      double slowCCI[20], fastCCI[20];        
      int a, up=0, dn=0, upnt=5,dpnt=5;
      for (a=0;a<20;a++)
      {  
         fastCCI[a]=iCCI(NULL,0,fastPeriod,PRICE_TYPICAL,shift+a);       
         slowCCI[a]=iCCI(NULL,0,slowPeriod,PRICE_TYPICAL,shift+a);      
         if (a<8) {
            if (slowCCI[a]>0) up++;
            if (slowCCI[a]<=0) dn++;
         }
		}
	   
      ///////////////////////////////////////////////////////////////
      // ������� � 1 - ������ �� ������� ����� (ZLR)
      // -----------------------------------------------------------
      // ������� "������ �� ������� �����" (ZLR)" ������������ ����� 
      // ������� ������ CCI �� ������� ����� (ZL) ��� �� ������, 
      // ������������ ������ � ���. ��� ���� CCI ����� ����������� �� 
      // �������� � �������� �� +100 �� -100  ���  ���  �������,  
      // ��� � ��� �������� �������. ��������� �������� ����� ������ 
      // �������� �� +/-50, ������, ��� �� ����� ���������� ������ 
      // ������. ������� ����������� �� ������ ����, ������� ����������� 
      // ��� ����������� �� ������� �����.
      // �������� ���������� � ������������� �������� ZLR �������� 
      // Woodies CCI ������� � ���, ��� ���� ������� ��������� ��������� 
      // �������� ��� ������� � ��������� �� �������. �� ���� �� 
      // �����������, ������������ ��� ��������, �� ����� ����� �������, 
      // ����� CCI.
      // ��� ������� �������������, ����� ������� ������ �� ����, 
      // �� ������ ���������� ������������� �������� ZLR � ��������� 
      // "������ ����� ������ (TLB)". ��� ������������� ZLR ��������� 
      // � TLB ��� �������� ������� �� ����� ����������� ������ CCI 
      // �������� TLB. �������� � �������������� �������� 
      // ZLR - �������� �� ������. ���������� ���� ������ �������� 
      // ����� ���� ������������ �������� ��������� ������� Woodies CCI, 
      // ������� ������������ ���������, ����� ��� ���� ������������ 
      // �������.
      // ----
      delta=20;  // ������ ������ (|��I[1]-��I[2]|>delta)
      level=80; // ������ ������� �������
      ZlrBuffer[shift]=EMPTY_VALUE;
      // ---- ZLR � ���������� ������
      if ( dn>=6 && 
      slowCCI[0]<slowCCI[1] && slowCCI[2]<slowCCI[1] && 
      MathAbs(slowCCI[0])<level && MathAbs(slowCCI[1])<level &&
      MathAbs(slowCCI[1]-slowCCI[2])>delta )
	   {
         ZlrBuffer[shift]=High[shift]+upnt*Point; 
         upnt=upnt+5;
	   }
	   // ZLR � ���������� ������
      if ( up>=6 	   
      && slowCCI[0]>slowCCI[1] && slowCCI[2]>slowCCI[1] && 
      MathAbs(slowCCI[0])<level && MathAbs(slowCCI[1])<level &&
      MathAbs(slowCCI[1]-slowCCI[2])>delta )
	   {
         ZlrBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;
	   }	   

      ///////////////////////////////////////////////////////////////
      // ������� � 2 - ���� (shamu trade) 
      // -----------------------------------------------------------      
      // ������� "���� (shamu trade)" �����������, ����� CCI ���������� 
      // ������� ����� (ZL), ����� ��������������� ����� � ����� 
      // ���������� ������� ����� (ZL) � ��������������� �����������, 
      // ����� ��� ��� ��������������� � ���������� ������� �����, 
      // ��������� �������� � �������������� �����������. 
      // ��� - ��� ���������������� �������� ������ ZL. 
      // �� �� ����������� ��������� ��������������� �� ������� �����, 
      // �� ������ �������� ���� ����������� ��� ������������� ������� 
      // CCI � �������� �������� +/-50.
      // �������� ������� ���� - ��� ����������� ������� ZLR. 
      // ������������� ��� ��� ������� ZLR. �� ZLR ����������� � 
      // ��������������� ����������� � �� �������������, ��� ��� �� 
      // ������ ��������. ��� ������ �� �� ����� ��������� � ������� �� ��, 
      // ��� �������� �������� � ������ �����. ���� �� ���� ���� �������� 
      // ������� �� ���������� ���������� ������� �� �������� ZLR, 
      // �� ������� �� ���, � ���� �� ������� �� �����, �� ������ ������� 
      // ������������ ������� ������. 
      // �������� � �������������� �������� ���� - �� ���� �������� 
      // ����������������, � ���� ������� ��� ������ �������� �� �������� 
      // stop-and-reverse (SAR) � ������������ ZLR. �������, ������ 
      // �������� ������� ������� Woodies CCI, �� ������ ������������ 
      // ���� ������ ��������. ������ �������� �� ���� �������� � 
      // �������� �� ���� ����������� � �������� �������.
      // ----
      delta=15; level=50;
      ShamuBuffer[shift]=EMPTY_VALUE;
      // ���� � ���������� ������
      if (dn>=6 &&
	   slowCCI[0]>slowCCI[1]+delta && 
	   slowCCI[1]<slowCCI[2] && slowCCI[2]>slowCCI[3] && 
	   slowCCI[1]<=level && slowCCI[1]>=-level && 
	   slowCCI[2]<=level && slowCCI[2]>=-level) 
	   {
         ShamuBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;
	   }
	   // ���� � ���������� ������
	   if (up>=6 && 
	   slowCCI[0]<slowCCI[1]-delta && 
	   slowCCI[1]>slowCCI[2] && slowCCI[2]<slowCCI[3] && 
	   slowCCI[1]>=-level && slowCCI[1]<=level && 
	   slowCCI[2]>=-level && slowCCI[2]<=level)
	   {
         ShamuBuffer[shift]=High[shift]+upnt*Point; 
         upnt=upnt+5;
	   }

      ///////////////////////////////////////////////////////////////
      // ������� � 3 - ������ ����� ������ (TLB)
      // -----------------------------------------------------------  
      // ������� "������ ����� ������ (TLB)" ���������� ��� ��� ����� 
      // ��������� �������� ���� ��� �������, ���������� CCI ��� TCCI 
      // ��� ����, ����� �������� ����� ��� ����� ������. ��� ����������� 
      // ��� �������� CCI ���� ����� ������ (tl), ��������� ������ ��� 
      // �������� �������. ��� ����, ����� ������ ��� ��������������, 
      // ���� ����� ����� ������ ������ ������������� �� ������ +/-100 
      // CCI ��� �����. ��� ������ ����� ������� ����� ����� ����� ������, 
      // ��� ����� �������� ��� ��������. ������������� ������ ���� ����� 
      // ������� �������� ���������� � ������� ������� ����������� 
      // ������� TLB. ����� �������� ���������� ������������� ������� 
      // CCI � TCCI ��� ������ ����� ������. ���� ������� ����� ������������ 
      // ��� ���� �� �������� ������ ��� ��� CCI ������ �������������. 
      // ��� ������ ������ � ������ ������������ � ������� Woodies CCI.
      // �������� � �������������� �������� TLB ����� ����������� ��� 
      // �� ������, ��� � ������ ������. �������, ������������ ������� 
      // Woodies CCI, ������ ��������� � ������� �������� TLB ������ �� 
      // ������. ������ ������������� � ���� � �������� ��� �� ���� 
      // ����������� � �������� �������.
      // �� ������ ������������� ������������� �������� "����� �� 
      // ������� ����� (ZLR)" � �������� "�������� ����������� (rev diver)" 
      // � ��������� "������ ����� ������ (TLB)" ��� �������� ������� � 
      // ������� ����������� ������. ��� �� ���������� ������������� �� 
      // ���������� ������� ��� ������� ����� ������, ��������� ��� 
      // ���������� � ��������� �������.
      // ������ ����� ����� � �������� �� TLB ������� � ������������� 
      // ������� ������������� �� CCI, - ����������� �� ������ +/-100. 
      // ��� ���� ������� ���� ���������� ������. �� ������ �� ������������ 
      // ���� ����� �, ��� �� �����, �������� ������� ������� ��� �������� 
      // �� TLB, ���� �� ������� ������� �� ����� ������. ������ ���� �� 
      // �� �������� ������������� CCI � ���� ����������� �� ������ +/-100, 
      // ����� ���� �������� �� TLB ����� ����� �� �����������. �������� 
      // ������ ����� � ��������������� ���. �� ������� ��� ���������.
      // �� ����� ����� ������ �������� ������������ ��������� �������� TLB � 
      // ZLR. ������ ������ � ���� ����� ����� ���������� ������� "rev diver". 
      // �� ������ ������ ���������, ����� CCI �������� ������� ���� �� ������, 
      // � ����� ����������� ������, ��� ��������� �������. ����� ��� ��� �� 
      // �������. ��� ��������� ������ ���� CCI �������, ����� ������� �������. 
      // ������ ���� ��������� ���������� �� ���������� ��������, �� ����������� 
      // ������ ���� ������ �������������.
      // -----------------------------------------------------------        
      // ������ �������������� ����� ������ (HTLB)
      // -----------------------------------------------------------        
      // ��� �������� �� ������ �������������� ����� ������ (HTLB) - 
      // ����� ������ ���������� ������������� ����� ������� �������� 
      // CCI � TCCI �� ������� �������������� �����, ������� ������������� 
      // � ������� ������ ���, �� �������� ����� � ���� ��������� 
      // ������������ CCI.
      // ����� ������ ����� �������� ����� ���������� ��� ������� ����� 
      // ������ �� ����� ������� �� ������� �����. ������ ��� ����� ������ 
      // ������ ������������� �� ����� ������� �� ������� �����. ������ 
      // ��������� ����� ���� ��������� ��� ������ �������������� 
      // ����� ������, ������������� � �������� +/-50.
      // � ������ �������������� ����� ������ �������� ����� ��� � ����� 
      // ����� ������, �� ����� ���� ��������� � ����� ��� �����. 
      // ������ ����� �� ���� � ��� �� �������������� ������� ����������, 
      // ��� � ���� ������� ������������� ������ ���� ���� ��������� ��� 
      // �������������. ��� ������� ���� ����� ����� ������� ������� 
      // �������� �, ��������������, ������� �������. ���� ������� ����� 
      // ����� ��������� �� ����������������� �����. 
      // �������� �� ������ �������������� ����� ������ ����� ������� 
      // ��� �� ������, ��� � ������ ������. ������� �� ����� �� �� �����, 
      // ��� � ��� ����� ������ ������� ��������. 
      // ----           
      
      delta=25; level=100;
      // ----
      TlbBuffer[shift]=EMPTY_VALUE;      
      int min1=0,min2=0,min3=0,max1=0,max2=0,max3=0;        // �������� ���/��� 
      int tmin1=0,tmin2=0,tmin3=0,tmax1=0,tmax2=0,tmax3=0;  // ����� ���/���
      double kmin=0,kmax=0; // �������� �����������
      double line; 
      //	����������� ���/���� � ���������� ����� ������
      for (a=0;a<=17;a++)
      { 
         // ����������� ����������
         if (slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2])
			{
            if (max1!=0 && max2==0)
				{
					max2=slowCCI[a+1];
					tmax2=Time[a+1+shift];
					kmax=100*(max2-max1)/(tmax2-tmax1);
				}
				if (max1==0)
				{
					max1=slowCCI[a+1];
					tmax1=Time[a+1+shift];
				}
			}
         // ����������� ���������
         if (slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2])
			{
				if (min1!=0 && min2==0)
				{
					min2=slowCCI[a+1];
					tmin2=Time[a+1+shift];
					kmin=100*(min2-min1)/(tmin2-tmin1);
				}
				if (min1==0)
				{
					min1=slowCCI[a+1];
					tmin1=Time[a+1+shift];
				}
			}
      }

      // TLB ctr � ���������� ������
      if (kmax!=0 && dn>=6 && (max1<-level || max2<-level))
      {
		   line=(Time[shift]-tmax1)*kmax/100+max1;
		   if (slowCCI[1]<line && slowCCI[0]>=line) 
		   {
		      TlbBuffer[shift]=Low[shift]-dpnt*Point;
            dpnt=dpnt+5;
		   }
      }
      //  TLB ctr � ���������� ������
      if (kmin!=0 && up>=6 && (min1>level || min2>level))	
      {
		   line=(Time[shift]-tmin1)*kmin/100+min1;
         if (slowCCI[1]>line && slowCCI[0]<=line) 
         {
            TlbBuffer[shift]=High[shift]+upnt*Point;
            upnt=upnt+5;
         }
      }
      // TLB tr � ���������� ������
	   if (kmin!=0 && dn >=6 && (min1<-level || min2<-level))
      {
         line=(Time[shift]-tmin1)*kmin/100+min1;
         if (slowCCI[1]>line && slowCCI[0]<line) 
         {
            TlbBuffer[shift]=High[shift]+upnt*Point;
            upnt=upnt+5;
         }
		}	
      //  TLB tr � ���������� ������
      if (kmax!=0 && up>=6 && (max1>level || max2>level))
      {
		   line=(Time[shift]-tmax1)*kmax/100+max1;
         if (slowCCI[1]<line && slowCCI[0]>line) 
         {
            TlbBuffer[shift]=Low[shift]-dpnt*Point;
            dpnt=dpnt+5;
         }
      } 
      
      ///////////////////////////////////////////////////////////////
      // ������� � 4 - ����� (VT)
      // -----------------------------------------------------------  
      // ������� ����� (VT) �������� ����������� ���������� �����. 
      // ��-������, ������ ���������� CCI ������� "������������� ���� (HFE)", 
      // ����� ����� ������ ��������� ����� CCI ����� � ���� �������� 
      // ������������� ��� ��������� ��������. ����� �������� ����� ������ 
      // ���� ��� ������� 3 ���� �� ����������� � ������� ����� ��� �� ���. 
      // ������� �������, ����������� ����� ���� � ����� ����������� � 
      // ����������� �� ����, �� ����� ������� �� ������� ����� (ZL) ����������� 
      // ������� �������. ������ ������� ������� VT ������ �������������� 
      // ������ �� ����� ������� �� ������� �����. ��� ��������, ��� ������ 
      // ����� (�� ����� CCI) ��������� �������� high/low �� �������� ������������ 
      // ������ ��������. ����� ������� ������ ���������, ����� ��������� 
      // �������� high/low ���������� ������������ ������. ����� ������� ����� 
      // ����� ��������� ��������� high/low. ����������� ����� ����� ��� 
      // �������� � ����� � ��������� �� ������, ������� ������ ����� �������� 
      // � �������� ��������� ������.
      // ��������� ����� �������� - ����� ������, ����������� ����� ����� 
      // ���� ��� ��� ��������� ���������. ������ ����� ��� ���� ����� ������ - 
      // ��� ���� � ��������.
      // ----
      // ������ ������ ������� "����� (VT)" ����������� ���-������ �� ������ 
      // �� 8 �� 12 ����� � �����, �� ���� �� ���������� ������� ������� �� 
      // ��������� ������� �� ����, ����� ����������� ������ ���������, � ���� 
      // �������� ����� ���� ������. ������� "����� (VT)"  ��������� �� 
      // ������������� ����������� ����� �������� ��������� ������.
      // Woodie ������������ ����������� ������������ 25-lsma ��������� 
      // ��� �������������� �������� ����� �� �������� "����� (VT)". 
      // ����� 25-lsma ��������� ����������, ��� ���� ��������� �� ������� 
      // ����������� ����� �� �������� "����� (VT)", ���������� ������� 
      // ����������� ����, ��� �������� ����� ��������. ������������ 
      // ���������� ������� LSMA �������� Least Squares Moving Average, 
      // � ����� ���������� ������� ����� ���� ������� � ��������� 
      // ����������� ������� ��� ������ "������ �������� ���������" 
      // (Linear Regression Curve).
      // ������� �������, ���� ������� "����� (VT)" ����������� ��� 
      // �������� �����, ����������, ����� ���� ���� ���� 25-lsma ���������� 
      // �, �� �����������, 25-lsma ����� ��� ��������� �����. ���� ������� 
      // VT ����������� ��� ��������� �����, ����������, ����� ���� ���� 
      // ���� 25-lsma �, ����������, ����� 25-lsma ����� ��� ��������� ����. 
      // ��� ��� �� �� ���������� ����, ����� ��������� �� ������� Woodies CCI, 
      // �� ������������� �� ������� ���� ���������� ������ 25-lsma ���������. 
      // � ����� ������������ 25-lsma ���������, ����������� �� ����� ������� 
      // � CCI, ����� ��������� ������ �������� ��� ������ �������.
      // �������� � �������������� �������� "�����" �� ���� - �������� 
      // ������ ������. 
      // ----      
      delta=10; limit=200;
      // ----  
      max1=0; max2=0; tmax1=0; tmax2=0;
      min1=0; min2=0; tmin1=0; tmin2=0;
      VegasBuffer[shift]=EMPTY_VALUE;        
      // ����������� �����
      if  (dn>=6)
      {
         for (a=13;a>=1;a--)
         {
            if (slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2] && 
            min1!=0 && max1==0)
            {
               max1=slowCCI[a+1];
					tmax1=a+1;
			   }
            if (slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2] &&
             min1==0 && slowCCI[a+1]<=-limit && a+1>=5)
            {				
					min1=slowCCI[a+1];
					tmin1=a+1;
            }
         }
	   }
      //  ����������� �����.
      if (up>=6) 
      {
         for (a=13;a>=1;a--)
         {
			   if (slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2] && 
			   min2!=0 && max2==0)
            {
					min2=slowCCI[a+1];
					tmin2=a+1;
            }
            if (slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2] && 
            max2==0 && slowCCI[a+1]>=limit && a+1>=5)
            {				
               max2=slowCCI[a+1];
               tmax2=a+1;
            }
         }
      }      

      // Vegas � ���������� ������
      if (dn>=6 && max1!=0 && slowCCI[1]<max1 && slowCCI[0]>=max1 && 
      slowCCI[0]-delta>slowCCI[1] /* && slowCCI[0]>slowCCI[1] && !(slowCCI[1]-delta>slowCCI[2]) */)
      {
		   VegasBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;	
      }
      //  Vegas � ���������� ������
      if (up >=6 && min2!=0 && slowCCI[1]>min2 && slowCCI[0]<=min2 &&
      slowCCI[0]+delta<slowCCI[1] 
		/* && slowCCI[0]<slowCCI[1] && !(slowCCI[1]+delta<slowCCI[2]) */)
      {
			VegasBuffer[shift]=High[shift]+upnt*Point;
         upnt=upnt+5;			
      }
      
      ///////////////////////////////////////////////////////////////
      // ������� � 5 - ������� (Ghost)
      // -----------------------------------------------------------  
      // ������� "�������" ����������� 3 ���������, ������� ��������������� 
      // ��������: ���� ����, ������ � ����� ������ ����. (��������, 
      // ������ ����� �������: "������ � �����"). ��� ������ ����� ���� 
      // ������������ ��� CCI, ��� � TCCI. ��� �� �����, ����������� 
      // ��������� ���������� CCI ��� ����������� ����� ��������. 
      // ����������, ����� ������ ���� ������ ����. ��� ����������� 
      // ����� ����� �� ������ ������ �������� "�������" - ����� 
      // ��� - ���������� ����� ������.
      // �� ������ ���������� ��������� �������� CCI ��� �������� "�������", 
      // ������� ���������� �� ������� ������ �� ����� ���, � ��� ����� 
      // ����� ���������� �� ����� ��� �� ������ � ��������������� 
      // �����������. � �������� �� ������ �� ����������� ��������� 
      // ������������� �������� CCI �� ����� ���, ��� ��� �� ������ 
      // ������� �������, ��� ������ CCI ���� ������ �� �����. ���, 
      // ��� �� ������ ������ - ��������� �� ��������� ������, 
      // ������������� �������� Woodies CCI.
      // ��������, ���, ����� �� ��������� ����� ��� (����� ������) 
      // �� �������� "�������", �� ����������� ������� "������ ����� 
      // ������ (TLB)" � ��������� "�������", ��� ��������� ������ � 
      // ����������� ����������� ������. ������ ����� ��� ��������� 
      // �� ����������� � ������� �����. ��� - ����� ���������������� 
      // ������� �������� "�������" �� ��������� � ���, ��� ������� 
      // ����� ��� ����������� �� ������� �����. � ����� ������ ��� 
      // �������� ����� ���� ������������ ��� ��������.
      // �������� � �������������� �������� "�������" �� ���� - �������� 
      // ������ ������. 
      // -----
      delta=15; level=50;
      max1=0; max2=0; max3=0; tmax1=0; tmax2=0; tmax3=0;
      min1=0; min2=0; min3=0; tmin1=0; tmin2=0; tmin3=0;
      // -----  
      GhostBuffer[shift]=EMPTY_VALUE;        
      // ����������� ����������
      if (up>=6) for (a=0;a<=17;a++)
      { 
         if (slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2])
			{
				if (max2!=0 && max3==0) max3=slowCCI[a+1];
				if (max1!=0 && max2==0) max2=slowCCI[a+1];
				if (max1==0) max1=slowCCI[a+1];
			}
      }
      // ����������� ���������
      if (dn>=6) for (a=0;a<=17;a++) 
      {     
         if (slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2])
			{
				if (min2!=0 && min3==0) min3=slowCCI[a+1];
				if (min1!=0 && min2==0) min2=slowCCI[a+1];
				if (min1==0) min1=slowCCI[a+1];
			}
      }
      // Ghost � ���������� ������
	   if (dn>=6 && 
	   min3!=0 && min1>min2 && min3>min2+delta && min1<0 &&
		slowCCI[0]-delta>min1 && slowCCI[0]>slowCCI[1] && 
   /* min3<0 && max1<=0 && max1>=-level && max2<=level && max2>=-level */
      !(slowCCI[1]-delta>min1))
      {		
		   GhostBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;			
      }
      // Ghost � ���������� ������
      if (up>=6 && 
      max3!=0 && max1<max2 && max3<max2-delta && max1>0 && 
      slowCCI[0]+delta<max1 && slowCCI[0]<slowCCI[1] && 
   /* max3>0 && min1<=level && min1>=0 && min2<=level && min2>=-level */
		!(slowCCI[1]+delta<max1))
      {
         GhostBuffer[shift]=High[shift]+upnt*Point;
         upnt=upnt+5;			
      }

      ///////////////////////////////////////////////////////////////
      // ������� � 6 - ����������� ����������� Woodies CCI (Rev Diver)
      // -----------------------------------------------------------  
      // ����������� ����������� Woodies CCI (Rev Diver) - ����� ������� 
      // ������� �������� �� ������, ������� ������������ ����� 
      // ��������� CCI, ��������� �� ������� ��������� ����� � ������� �����. 
      // ��� ������ ������ �� ������������� ���� � �������, ���������� 
      // ��������� CCI ����� � ����. �� ������� ���������� �������, 
      // ���� � ���� ���� � �������, ������� ����������� ����� � ������� �����. 
      // �� ������� �� ���������� ����������, ����� ���������� ������� Rev Diver.
      // ---- 
      // ��������� ��� ������� - ��� ���, ��� ���������� ��� ����������� 
      // �������� Rev Diver:
      // * Rev Diver �� ������� - CCI ���� ������� ����� � ������� ��������� 
      //   6 � ����� �����, ��� �� ������� - ������������ ������� �������
      // * Rev Diver �� ������� - CCI ���� ������� ����� � ������� ��������� 
      //   6 � ����� �����, ��� �� ������� - ������������ ���� � ������� �����
      // ---- 
      // ������� "����������� �����������" - ������� �������� �� ������. 
      // �� ������ ���������� �������� � �������������� Rev Diver � ���������� 
      // "������ �� ������� ����� (ZLR)" ��� "������ ����� ������ (TLB)" 
      // ��� ����������� � ��������� ������� ������������ ������. �� ����������� 
      // ������ ������ �������� ��������� �������� ZLR � ��������� Rev Diver. 
      // ���������� � ��� ������ ����� ��� �������� ZLR, ������� �������� Rev Diver, 
      // ��� ��� ������ ���� ��� ������� ���������� � �������� +/-100  ����� CCI. 
      // ���������� ���� ��� ������� ���������� ������������ ������� CCI ZLR. 
      // ���������� ������� �����������, � �� ������� �� ��� �� ������ �������.
      // ---- 
      delta=20; level=70;
      // ----       
      max1=0; max2=0; tmax1=0; tmax2=0;
      min1=0; min2=0; tmin1=0; tmin2=0;
      // -----  
      RevdevBuffer[shift]=EMPTY_VALUE;        
      // ����������� ����������
      if (dn>=6) for (a=0;a<=17;a++)
      { 
         if (slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2])
			{
				if (max1!=0 && tmax1<3 && max2==0)
				{
					max2=slowCCI[a+1];
					tmax2=a+1;
				}
				if (max1==0)
				{
					max1=slowCCI[a+1];
					tmax1=a+1;
				}
			}
      }
      // ����������� ���������
      if (up>=6) for (a=0;a<=17;a++) 
      {     
         if (slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2])
			{
				if (min1!=0 && tmin1<3 && min2==0)
				{
					min2=slowCCI[a+1];
					tmin2=a+1;
				}
				if (min1==0)
				{
					min1=slowCCI[a+1];
					tmin1=a+1;
				}
			}
      }
      // Revdiv � ���������� ������
	   if (dn>=6 && 
	   max1<=0 && max2!=0 && max1>max2 && max1>=-level && tmax2-tmax1>=3 &&
   /* max2<=level && max2>=-level && */
	   slowCCI[0]+delta<max1 && slowCCI[0]<slowCCI[1] && !(slowCCI[1]+delta<max1) )
      {
         RevdevBuffer[shift]=High[shift]+upnt*Point;
         upnt=upnt+5;			
      }
      // Revdiv � ���������� ������
	   if (up>=6 && 
	   min1>=0 && min2!=0 && min1<min2 && min1<=level && tmin2-tmin1>=3 &&
   /* pmn2<=level && pmn2>=-level && */
      slowCCI[0]-delta>min1 && slowCCI[0]>slowCCI[1] && !(slowCCI[1]-delta>min1) )
      {	
         RevdevBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;
      }

      ///////////////////////////////////////////////////////////////
      // ������� � 7 - ������������� ���� (HFE)
      // -----------------------------------------------------------        
      // ���� ������� �����������, ����� CCI ������ �� ������� +/-200, 
      // � ����� ��������������� ����� � ������� �����. ��� - ����� 
      // ������� ������ ��������. ������� HFE �������� ����� ����� �� 
      // Woodies CCI �������� ������.
      // ----      
      // �������� �� ����� �������� ���������� ����� ������. ��� ������ 
      // ���� ��������������� ����� � ������� �����, �������. ���������� 
      // ������� ������ ����-���� ����� �� ��� ����� � �����, ��������� 
      // �������� ������ ����� ������������ ����� ������. ��� ������ 
      // �������� ������ � ������ - �������� ����������.
      // �������� ����� ��������������� �����, � ��� ����� ���������, 
      // ���� ���� ��� CCI ������� �� �����. ����������� �������� 
      // �������� ���������� �������������� 50%, ���� ��������� ��� 
      // ������ ������� HFE. ������ ������������� ������� ����� ������ 
      // �������, ���� �� ������ ������������ ������� ����-���� ������.
      // �������� ��� ��������� �� ����������� �� ���� �������� 
      // ����������������, ������� � ������������� ����������� � 
      // ����� ��������. 
      // ----      
      // ��� ������� ������������� �� ������ ���������� �������� �� 
      // HFE-�������� � �������� ����� ������ ��� � ������������ CCI 
      // ������ +/-100, ������� �������� ��������� �������������. 
      // ----
      delta=10; level=200;
      HooksBuffer[shift]=EMPTY_VALUE;        
      // HFE � ���������� ������
      if (dn>=6 && 
      slowCCI[1]<=-level && slowCCI[0]>-level && slowCCI[1]<slowCCI[0]-delta)
      {
         HooksBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;
      }
      // HFE ���������� ������
      if (up>=6 && 
      slowCCI[1]>=level && slowCCI[0]<level && slowCCI[1]>slowCCI[0]-delta)
      {
         HooksBuffer[shift]=High[shift]+upnt*Point;
         upnt=upnt+5;
      } 
     
      ///////////////////////////////////////////////////////////////
      // ������ �� �����
      // -----------------------------------------------------------
      // 1. �������� (CCI(14) �������� ����) ��� ������� �������� CCI	
      // 2. ������ CCI ����� ������ (TLB)		
      // 3. CCI(6) ���������� CCI(14) ��������		
      // 4. CCI ���������� ������� ����� (ZLC).
      // 5. ����� CCI 14 �������� ���� ����� ������ +/-200 ��� �� ���
      // 6. CCI (��� �������� ��� ������)
      // -----------------------------------------------------------

      // 1. �������� (CCI(14) �������� ����) ��� ������� �������� CCI
	   if (HooksBuffer[shift]!=EMPTY_VALUE)
      { 	
         if (up>=6)
	      { 
		      ExitBuffer[shift]=High[shift]+upnt*Point;
            upnt=upnt+5;
		   }
	      if (dn>=6)
	      { 
		      ExitBuffer[shift]=Low[shift]-dpnt*Point;
            dpnt=dpnt+5;
		   }
		}
      // 2. ������ CCI ����� ������ (������ ������)
      if (TlbBuffer[shift]!=EMPTY_VALUE) 
      { 	
         if (up>=6 && TlbBuffer[shift]>High[shift])
	      { 
		      ExitBuffer[shift]=High[shift]+upnt*Point;
            upnt=upnt+5;
		   }
	      if (dn>=6 && TlbBuffer[shift]<Low[shift])
	      { 
		      ExitBuffer[shift]=Low[shift]-dpnt*Point;
            dpnt=dpnt+5;
		   }
		}
		/*
      // 3. CCI(6) ���������� CCI(14) ��������	
      if (up>=6 && fastCCI[1]>=slowCCI[1] && fastCCI[0]<=slowCCI[0])
	   { 
		   ExitBuffer[shift]=High[shift]+upnt*Point;
         upnt=upnt+5;
		}
	   if (dn>=6 && TlbBuffer[shift]<Low[shift])
	   { 
		   ExitBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;
		} */     
      
/*
      delta=10; level=100;
      // ----
      ExitBuffer[shift]=EMPTY_VALUE;  
      min1=0; max1=0; // �������� ���/��� 
      //	����������� ���/���� � ���������� ����� ������
      for (a=0;a<=17;a++)
      { 
         // ����������� ����������
         if (slowCCI[a]<=slowCCI[a+1] && slowCCI[a+1]>=slowCCI[a+2])
			{
				if (max1==0) max1=slowCCI[a+1];
			}
         // ����������� ���������
         if (slowCCI[a]>=slowCCI[a+1] && slowCCI[a+1]<=slowCCI[a+2])
			{
				if (min1==0) min1=slowCCI[a+1];
			}
      }
      // ����� � ���������� ������
	   if (min1!=0 && slowCCI[0]-delta>min1 && !(slowCCI[1]-delta>min1) && MathAbs(slowCCI[0])>level)
      {
		   ExitBuffer[shift]=Low[shift]-dpnt*Point;
         dpnt=dpnt+5;
	   }
      // ����� � ���������� ������
      if (max1!=0 && slowCCI[0]+delta<max1 && !(slowCCI[1]+delta<max1) && MathAbs(slowCCI[0])>level) 
      {
		   ExitBuffer[shift]=High[shift]+upnt*Point;
         upnt=upnt+5;
      }
*/
   }    
   return(0);
}


