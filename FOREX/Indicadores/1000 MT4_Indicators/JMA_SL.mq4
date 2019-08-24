//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                       JMA_SL.mq4 | 
//|                      JMA: Copyright � 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|                         MQL4: Copyright � 2005, Nikolay Kositsin | 
//|                                   Khabarovsk, violet@mail.kht.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Weld" 
#property link "http://weld.torguem.net" 
#property indicator_chart_window 
#property indicator_buffers 1 
#property indicator_color1 Red 
//---- input parameters 
extern int Length = 5; // ������� ����������� 
extern int Phase  = 5; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int Shift  = 0; // c���� ���������� ����� ��� ������� 
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-"Close", 1-"Open", 2-"(High+Low)/2", 3-"High", 4-"Low", 5-"Heiken Ashi Close", 6-"(Open+Close)/2") 
//---- indicator buffers 
double JMA_Buffer[]; 
double MEMORY1[8];
int    MEMORY2[7];
double MEMORY3[128]; 
//---- temporary double buffers 
double list[128], ring1[128], ring2[11], buffer[62],RING1[1],RING2[1],LIST[128]; 
//---- double vars 
double Kg,Dr,Ds,Dl,Pf,series,vv,v1,v2,v3,v4,s20,s10,fB0,fD0;
double f8, f60,f20,f28,f30,f40,f48,f58,f68,f70,f90,f78,f88,f98,JMA;
//---- integer vars 
int countR1,countR2,countL,S48[1],S50[1],Sjj[128],temp;
int ii,jj,s28,s30,f0,v5,v6,fE0,fD8,fE8,val,s48,s58,s60,s68,IPC,count,size,aa;
int IntPortion(double param){if(param>0)return(MathFloor(param));if(param<0)return(MathCeil (param));return(0.0);}
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JMA iteration function                                           | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{ 
SetIndexStyle(0, DRAW_LINE); 
SetIndexShift(0, Shift); 
//---- 1 indicator buffers mapping 
IndicatorBuffers(1);
SetIndexBuffer (0, JMA_Buffer); 
SetIndexEmptyValue(0,0.0); 
//---- 
IndicatorShortName ("JMA Star Light( Length="+Length+", Phase="+Phase+", Shift="+Shift+")"); 
SetIndexLabel (0, "JMA Star Light"); 
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));IPC=Input_Price_Customs;
//+================================================================================================================================+ 
if(Phase<-100){Alert("�������� Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase+  " ����� ������������ -100");}
if(Phase> 100){Alert("�������� Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase+  " ����� ������������  100");}
if(Length<  1){Alert("�������� Length ������ ���� �� ����� 1"     + " �� ����� ������������ " +Length+ " ����� ������������  1"  );}
if(IPC<0){Alert("�������� Input_Price_Customs ������ ���� �� ����� 0" + " �� ����� ������������ "+IPC+ " ����� ������������ 0"   );}
if(IPC>6){Alert("�������� Input_Price_Customs ������ ���� �� ����� 6" + " �� ����� ������������ "+IPC+ " ����� ������������ 0"   );}
//+================================================================================================================================+ 
if (Length < 1.0000000002) Dr = 0.0000000001; //{1.0e-10} 
else Dr = (Length - 1.0) / 2.0; 
if((Phase >= -100)&&(Phase <= 100)) Pf = Phase / 100.0 + 1.5; 
if (Phase >   100) Pf = 2.5; 
if (Phase <  -100) Pf = 0.5; 
Dr = Dr * 0.9; Kg = Dr / (Dr + 2.0); 
Ds=MathSqrt(Dr); Dl=MathLog(Ds);
v1 = Dl; v2 = v1; 
if ((v1 / MathLog(2.0)) + 2.0 < 0.0) v3 = 0.0; else v3 = (v2 / MathLog(2.0)) + 2.0; 
f98 = v3; 
if ( f98 >= 2.5 ) f88 = f98 - 2.0; else f88 = 0.5; 
f78 = Ds * f98; f90 = f78 / (f78 + 1.0); 
//----==========================+ 
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JMA iteration function                                           | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//---- get already counted bars 
int counted_bars = IndicatorCounted(); 
//---- check for possible errors 
if (counted_bars<0) return (-1);
int limit=Bars-counted_bars-1; 
//----
if(limit==Bars-1)          
{
//----+==========================================================================+
double f18,f38,fA0,fA8,fC0,fC8,s8,s18; int s38,s40,s50,s70,LP2,LP1;
ArrayInitialize(ring2,0.0);ArrayInitialize(ring1,0.0);ArrayInitialize(buffer,0.0);
ArrayInitialize(LIST, 0.0);ArrayInitialize(RING1,0.0);ArrayInitialize(RING2, 0.0);
ArrayInitialize(Sjj,  0  );ArrayInitialize(S48,  0  );ArrayInitialize(S50,   0  );
//----+==========================================================================+
f0=1; s28=63; s30=64;
for (ii=0;   ii<=s28; ii++)list[ii]=-1000000.0; 
for (ii=s30; ii<=127; ii++)list[ii]= 1000000.0;
//----+#########################################+
}
fA0=0.0; vv=0.0; v4=0.0;s20=0.0;s10=0.0;fB0=0.0;fD0=0.0;f60=0.0;f20=0.0;f30=0.0;f40=0.0;f48=0.0;f58=0.0;
f68=0.0;f70=0.0; v4=0.0;s20=0.0;s10=0.0; v5=0;   v6=0;  fE0=0;  fE8=0;  s58=0;  s60=0;  s68=0; 

if((limit<Bars-1)&&(Time[limit+1]!=MEMORY2[00]))
{   
if(Time[limit+1]!=MEMORY2[01])return(-1);   
//+--- <<< �������������� ���������� >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+                                      
s38=MEMORY2[02];s48=MEMORY2[03];s50=MEMORY2[04];LP1=MEMORY2[05];LP2=MEMORY2[06];                                       
fC0=MEMORY1[00];fC8=MEMORY1[01];fA8=MEMORY1[02];s8 =MEMORY1[03];f18=MEMORY1[04];
f38=MEMORY1[05];s18=MEMORY1[06];JMA=MEMORY1[07];
for(ii=countL-1; ii>=0;ii--){temp=Sjj[ii];list [temp]=LIST [ii];}
for(ii=countR1-1;ii>=0;ii--){temp=S48[ii];ring1[temp]=RING1[ii];}
for(ii=countR2-1;ii>=0;ii--){temp=S50[ii];ring2[temp]=RING2[ii];}
//+--- SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
}
for(int bar = limit; bar >= 0; bar--) 
{
//---+ main cycle -------------------------+ 
countR1=0;countR2=0;countL=0;

switch(IPC)
{
case 0 : series=Close[bar];break;
case 1 : series= Open[bar];break;
case 2: {series=(High[bar]+Low  [bar])/2;}break;
case 3:  series= High[bar];break;
case 4:  series=  Low[bar];break;
case 5: {series=(Open[bar]+High [bar]+Low[bar]+Close[bar])/4;}break;
case 6: {series=(Open[bar]+Close[bar])/2;}break;
default: series=Close[bar];break;
}
//---- 
if (LP1<61){LP1++; buffer[LP1]=series;} 
if (LP1>30)
{ 
//++++++++++++++++++ 
if (f0 != 0) 
{ 
f0 = 0; v5 = 0; 
for( ii=0; ii<=29; ii++) {if (buffer[ii+1] != buffer[ii]) v5 = 1; break; } 
fD8 = v5*30; 
if (fD8 == 0) f38 = series; else f38 = buffer[1]; 
f18 = f38; 
if (fD8 > 29) fD8 = 29; 
} 
else fD8 = 0; 
for(ii=fD8; ii>=0; ii--) 
{ 
val=31-ii; 
if (ii == 0) f8 = series; else f8 = buffer[val]; 
f28 = f8 - f18; f48 = f8 - f38; 
if (MathAbs(f28) > MathAbs(f48)) v2 = MathAbs(f28); else v2 = MathAbs(f48); 
fA0 = v2; vv = fA0 + 0.0000000001; //{1.0e-10;} 
if (s48 <= 1) s48 = 127; else s48 = s48 - 1; 
if (s50 <= 1) s50 = 10;  else s50 = s50 - 1; 
if (s70 < 128) s70 = s70 + 1; 
s8 = s8 + vv - ring2[s50]; 
//+--- <<< ������ ��������� � ������, ��������� �� 0 ���� >>> ============================================================+
if(bar==0){ArrayResize(RING2,countR2+1);ArrayResize(S50,countR2+1);RING2[countR2+1]=ring2[s50];S50[countR2]=s50;countR2++;}
//---+ +==================================================================================================================+
ring2[s50] = vv; 
if (s70 > 10) s20 = s8 / 10.0; else s20 = s8 / s70; 
if (s70 > 127) 
{ 
s10 = ring1[s48]; 
//+--- <<< ������ ��������� � ������, ��������� �� 0 ���� >>> ============================================================+
if(bar==0){ArrayResize(RING1,countR1+1);ArrayResize(S48,countR1+1);RING1[countR1+1]=ring1[s48];S48[countR1]=s48;countR1++;}
//---+ +==================================================================================================================+
ring1[s48] = s20; s68 = 64; s58 = s68; 
while (s68 > 1) 
{ 
if (list[s58] < s10){s68 = s68 *0.5; s58 = s58 + s68;} 
else if (list[s58] <= s10) s68 = 1; else{s68 = s68 *0.5; s58 = s58 - s68;} 
} 
} 
else 
{ 
//+--- <<< ������ ��������� � ������, ��������� �� 0 ���� >>> ============================================================+
if(bar==0){ArrayResize(RING1,countR1+1);ArrayResize(S48,countR1+1);RING1[countR1+1]=ring1[s48];S48[countR1]=s48;countR1++;}
//---+ +==================================================================================================================+
ring1[s48] = s20; 
if (s28 + s30 > 127){s30 = s30 - 1; s58 = s30;} 
else {s28 = s28 + 1; s58 = s28;} 
if (s28 > 96) s38 = 96; else s38 = s28; 
if (s30 < 32) s40 = 32; else s40 = s30; 
} 
s68 = 64; s60 = s68; 
while (s68 > 1) 
{ 
if (list[s60] >= s20) 
{ 
if (list[s60 - 1] <= s20) s68 = 1; else {s68 = s68 *0.5; s60 = s60 - s68; } 
} 
else{s68 = s68 *0.5; s60 = s60 + s68;} 
if ((s60 == 127) && (s20 > list[127])) s60 = 128; 
} 
if (s70 > 127) 
{ 
if (s58 >= s60) 
{ 
if ((s38 + 1 > s60) && (s40 - 1 < s60)) s18 = s18 + s20; 
else if ((s40 + 0 > s60) && (s40 - 1 < s58)) s18 = s18 + list[s40 - 1]; 
} 
else 
if (s40 >= s60) {if ((s38 + 1 < s60) && (s38 + 1 > s58)) s18 = s18 + list[s38 + 1]; } 
else if (s38 + 2 > s60) s18 = s18 + s20; else if ((s38 + 1 < s60) && (s38 + 1 > s58)) s18 = s18 + list[s38 + 1]; 
if (s58 > s60) 
{ 
if ( (s40 - 1 < s58) && (s38 + 1 > s58)) s18 = s18 - list[s58]; 
else if ((s38 < s58) && (s38 + 1 > s60)) s18 = s18 - list[s38]; 
} 
else 
{ 
if ((s38 + 1 > s58) && (s40 - 1 < s58)) s18 = s18 - list[s58]; 
else 
if ((s40 + 0 > s58) && (s40 - 0 < s60)) s18 = s18 - list[s40]; 
} 
} 
if (s58 <= s60) 
{ 
if(bar==0)
{
//--+ <<< ���������� �������� ��� �������������� ������ >>> 
LIST[countL]=list[s60];Sjj[countL]=s60;countL++;
//--++ssssssssssssssssssssssssssssssssssssssssssssssssssss+
}
if (s58 >= s60) list[s60] = s20; 
else 
{
if(bar==0)
{ 
//--+ <<< ���������� �������� ��� �������������� ������ >>> +ssssssssssssssssssssssssssssssss+
size=s60-s58;for(aa=0; aa<=size-2;aa++){LIST[countL+aa]=list[s58+aa];Sjj[countL+aa]=s58+1+aa;}
countL=countL+size;LIST[countL]=list[s60-1];Sjj[countL]=s60-1;countL++;
//--++sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss+
}
for( jj = s58 + 1; jj<=s60 - 1 ;jj++)list[jj - 1] = list[jj]; 
list[s60 - 1] = s20; 
} 
} 
else 
{ 
if(bar==0)
{
//--+ <<< ���������� �������� ��� �������������� ������ >>> +sssssssssssssssssssssssssssssssssss+
size=s58-s60+1;for(aa=0; aa<=size-2;aa++){LIST[countL+aa]=list[s58-aa];Sjj[countL+aa]=s58-1-aa;}
countL=countL+size;LIST[countL]=list[s60];Sjj[countL]=s60;countL++;
//--++ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss+
}
for( jj = s58 - 1; jj>=s60 ;jj--) list[jj + 1] = list[jj]; 
list[s60] = s20; 
} 
if (s70 <= 127) 
{ 
s18 = 0; 
for( jj = s40 ; jj<=s38 ;jj++) s18 = s18 + list[jj]; 
} 
f60 = s18 / (s38 - s40 + 1.0); 
if (LP2 + 1 > 31) LP2 = 31; else LP2 = LP2 + 1; 
if (LP2 <= 30) 
{ 
if (f28 > 0.0) f18 = f8; else f18 = f8 - f28 * f90; 
if (f48 < 0.0) f38 = f8; else f38 = f8 - f48 * f90; 
JMA = series; 
if (LP2!=30) continue; 
if (LP2==30) 
{ 
fC0 = series; 
if ( MathCeil(f78) >= 1) v4 = MathCeil(f78); else v4 = 1.0; 
fE8 = IntPortion(v4); 
if (MathFloor(f78) >= 1) v2 = MathFloor(f78); else v2 = 1.0; 
fE0 = IntPortion(v2); 
if (fE8== fE0) f68 = 1.0; else {v4 = fE8 - fE0; f68 = (f78 - fE0) / v4;} 
if (fE0 <= 29) v5 = fE0; else v5 = 29; 
if (fE8 <= 29) v6 = fE8; else v6 = 29; 
fA8 = (series - buffer[LP1 - v5]) * (1.0 - f68) / fE0 + (series - buffer[LP1 - v6]) * f68 / fE8; 
} 
} 
else 
{ 
if (f98 >= MathPow(fA0/f60, f88)) v1 = MathPow(fA0/f60, f88); 
else v1 = f98; 
if (v1 < 1.0) v2 = 1.0; 
else 
{if(f98 >= MathPow(fA0/f60, f88)) v3 = MathPow(fA0/f60, f88); 
else v3 = f98; v2 = v3;} 
f58 = v2; f70 = MathPow(f90, MathSqrt(f58)); 
if (f28 > 0.0) f18 = f8; else f18 = f8 - f28 * f70; 
if (f48 < 0.0) f38 = f8; else f38 = f8 - f48 * f70; 
} 
} 
if (LP2 >30) 
{ 
f30 = MathPow(Kg, f58); 
fC0 =(1.0 - f30) * series + f30 * fC0; 
fC8 =(series - fC0) * (1.0 - Kg) + Kg * fC8; 
fD0 = Pf * fC8 + fC0; 
f20 = f30 *(-2.0); 
f40 = f30 * f30; 
fB0 = f20 + f40 + 1.0; 
fA8 =(fD0 - JMA) * fB0 + f40 * fA8; 
JMA = JMA + fA8; 
} 
} 
//++++++++++++++++++ 
if (LP1 <=30)JMA=0.0; 

JMA_Buffer[bar]=JMA;

if (bar==1)
{
//+--- <<< ���������� ���������� >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
MEMORY1[00]=fC0;MEMORY1[01]=fC8;MEMORY1[02]=fA8;MEMORY1[03]= s8;MEMORY1[04]=f18;MEMORY1[05]=f38;MEMORY1[06]=s18;MEMORY1[07]=JMA;
MEMORY2[02]=s38;MEMORY2[03]=s48;MEMORY2[04]=s50;MEMORY2[05]=LP1;MEMORY2[06]=LP2;MEMORY2[00]=Time[0];MEMORY2[01]=Time[1];                     
//+--- SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
}
}
//----+  done --------------------------+ 
return(0);  
} 