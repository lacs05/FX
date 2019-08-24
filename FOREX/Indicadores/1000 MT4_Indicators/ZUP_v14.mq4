//compile//
//+----------------------------------------------------------------------+
//|ZigZag � ������ ���������                                             |
//|----------------------------------------------------------------------+
//|                                                                      |
//|ExtIndicator - ����� �������� ����������, �� ������ ��������          |
//|               �������� �������� ���������                            |
//|           0 - Zigzag �� ������������,                                |
//|           1 - Zigzag ������,                                         |
//|           2 - ��������� �������� ����������� � Ensign                |
//|                                                                      |
//|minBars - ������ ������� (�������� ���������� �����)                  |
//|minSize - ������ �� ���������� ������� (�������� ���������� �������)  |
//|                                                                      |
//|minPercent - ���������� ������ (�������� �������, �������� 0.5)       |
//|             ���� ����������� �������� - ������� �����, � minSize=0;  |
//|                                                                      |
//|                                                                      |
//|ExtHidden - 0 - ��� ����� ������. ������� ZigZag.                     |
//|            1 - ���������� ��� ����� ����� ����������, � �������      |
//|                ������� �������������� >0.21 � <5.                    |
//|            2 - ���������� ������ ��  �����, ��� ������� ��������-    |
//|                ������ ����� ������ ��������� (� 0.866 ��� ������-    |
//|                ���� ��������� Gartley)                               |
//|            3 - ���������� �����, ������������� � ������ 2            |
//|                � ��������������� �����                               |
//|            4 - ���������� ����� �� ��������� � ��������������� ����� |
//|                                                                      |
//|                                                                      |
//|ExtFractal - ���������� ��������� (����������, ���������),            |
//|             �� ������� ���� ����� � ������ ���������                 |
//|                                                                      |
//|ExtFractalEnd - ���������� ���������, � ������� ���� �����            |
//|                ������ ����� �������� ����������� ����� �� �����      |
//|                ���� ExtFractalEnd=0 �� ��������� ������� �����       |
//|                ������������� ����� ���������.                        |
//|                ����������� �������� ExtFractalEnd=5                  |
//|                                                                      |
//|ExtDelta - (������) ���������� � �������. ������ ��������             |
//|           ������������� ����������� ����.                            |
//|                  ������ ���� 0<ExtDelta<1                            |
//|                                                                      |
//|ExtDeltaType -    0 - ��������� �������� �������������� "��� ����"    |
//|                  1 - ������ ������� (%-����� ���������)<ExtDelta     |
//|                  2 - ((%-����� ���������)/����� ���������)<ExtDelta  |
//|                                                                      |
//|chHL     = true     - ���� ������ ���������� ������ �������������     |
//|PeakDet  = true     - ���� ������ ���������� ������ ����������        |
//|                                                                      |
//|ExtFiboDinamic - ��������� ����� ����������� ������� ����.            |
//|                 ������������ ������ ���� ��������� �� ������ ����    |
//|                 ZigZag-a.                                            |
//|                                                                      |
//|ExtFiboStatic - ��������� ����� ����������� ������� ����              |
//|                                                                      |
//|ExtFiboStaticNum - ����� ���� ZigZag-a, �� �������� ����� ����������  |
//|                   ����������� ������ ���������. 1<ExtFiboStaticNum<9 |
//|                                                                      |
//|ExtSizeTxt - ������ ������ ��� ������ �����                           |
//|                                                                      |
//|ExtLine - ����� ����� �������������� �����                            |
//|                                                                      |
//|ExtPesavento - ����� ����� ����� ���������                            |
//|                                                                      |
//|ExtGartley866 - ����� ����� ����� .866                                |
//|                                                                      |
//|ExtNotFibo - ����� ����� ���� ��������� �����                         |
//|                                                                      |
//|ExtFiboS � ExtFiboD - ����� ����� ����������� � ������������ ���.     |
//|                                                                      |
//|ExtDeleteObj = true - ���������� �������������� �������� ����         |
//|               ��������� ����� � ��������� ��������.                  |
//|                                                                      |
//|ExtDeviation � ExtBackstep - ��������� ���������� �� ZigZag �� MT4    |
//|                                                                      |
//+----------------------------------------------------------------------+
#property copyright "nen"
#property link      "http://onix-trade.net/forum/index.php?s=&showtopic=118&view=findpost&p=46508"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Orange
#property indicator_color4 LightSkyBlue
#property indicator_color5 LemonChiffon
//---- indicator parameters
extern int ExtIndicator=2;
extern int minBars=12;
extern int minSize = 15;
extern double minPercent = 0;
extern int ExtHidden=1;
extern int ExtFractal=8;
extern int ExtFractalEnd=8;
extern double ExtDelta=0.04;
extern int ExtDeltaType=2;
extern bool chHL = false;
extern bool PeakDet = false;
//-------------------------------------
extern bool ExtFiboDinamic=false;
extern bool ExtFiboStatic=false;
extern int ExtFiboStaticNum=2;
extern int ExtSizeTxt=7;
extern color ExtLine=DarkBlue;
extern color ExtNotFibo=SlateGray;
extern color ExtPesavento=Yellow;
extern color ExtGartley866=GreenYellow;
extern color ExtFiboS=Teal;
extern color ExtFiboD=Sienna;
// ���������� �� ZigZag �� ��
extern bool ExtDeleteObj=false;
extern int ExtDeviation=5;
extern int ExtBackstep=3;

// ������� ��� ZigZag 
// ������ ��� ��������� ZigZag
double zz[];
// ������ ��������� ZigZag
double zzL[];
// ������ ���������� ZigZag
double zzH[];

// ���������� ��� ���������
// ������ ����� ��������� (���� � ���������������� ����)
double fi[]={0.382, 0.5, 0.618, 0.707, 0.786, 0.841, 0.886, 1.0, 1.128, 1.272, 1.414, 1.5, 1.618, 2.0, 2.414, 2.618, 4.0};
string fitxt[]={ ".382", ".5", ".618", ".707", ".786", ".841", ".886", "1.0", "1.128", "1.272", "1.414", "1.5", "1.618", "2.0", "2.414", "2.618", "4.0" };
string nameObj,nameObjtxt;
// ������� ��� ������ ����������� ����� afr - ������ �������� ������� ���� ��������� ��������� � ��������� ������������ � ����������� ���
// afrl - ��������, afrh - ���������
int afr[]={0,0,0,0,0,0,0,0,0,0};
double afrl[]={0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0}, afrh[]={0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};
bool afrm=true;
double HL,HLp,kk,kj,Angle;
// LowPrim,HighPrim,LowLast,HighLast - �������� ��������� � ���������� �����
double LowPrim,HighPrim,LowLast,HighLast;
// numLowPrim,numHighPrim,numLowLast,numHighLast -������ �����
int numLowPrim,numHighPrim,numLowLast,numHighLast,k,k1,k2,ki,countLow1,countHigh1,shift,shift1;
// ����� ����� � ������ �� �������� ���� ���������
int timeFr1new;
// ������� ���������
int countFr;
// ���, �� �������� ���� �������� �������������� ����� �� �������� ����
int countBarEnd=0,TimeBarEnd;
// ���, �� �������� ���� ������������� �� �������� ����
int numBar=0;
// ����� �������
int numOb;
// flagFrNew=true - ����������� ����� ������� ��� ������ ������� ��������� �� ������ ���. =false - �� ���������.
bool flagFrNew=false;
// ������ �������� �������
int perTF;

int counted_bars;

// ���������� ��� ZigZag ������ � ���������� ��������� ����������� � Ensign
double ha[],la[],hi,li,si,sip,di,hm,lm,ham[],lam[],him,lim,LastBar0,lLast=0,hLast=0;
int fs,fsp,countBar;
int ai,aip,bi,bip,ai0,aip0,bi0,bip0,Last_Bar,last0;
datetime tai,tbi,taip,tbip,ti,ts0=0,t0=0,taiLast,tbiLast;
bool fh=false,fl=false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(7);
//---- drawing settings
// ZigZag
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,zz);
   SetIndexBuffer(5,zzL);
   SetIndexBuffer(6,zzH);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);
   SetIndexEmptyValue(6,0.0);
//   ArraySetAsSeries(zz,true);
//   ArraySetAsSeries(zzL,true);
//   ArraySetAsSeries(zzH,true);
// ������ ���������� �����
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT);
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT); 
   SetIndexBuffer(1,ham);
   SetIndexBuffer(2,lam);
// ������ �������������
   SetIndexStyle(3,DRAW_LINE,STYLE_DOT);
   SetIndexStyle(4,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(3,ha);
   SetIndexBuffer(4,la);
   if (ExtIndicator==1) if (minSize!=0) di=minSize*Point/2;
   if (ExtIndicator==2)
     {
      if (minSize!=0) {di=minSize*Point; countBar=minBars;}
     }
// �������� ������������ ��������� ������� ����������
   if (ExtDelta<=0) ExtDelta=0.001;
   if (ExtDelta>1) ExtDelta=0.999;

   if (ExtHidden<0) ExtHidden=0;
   if (ExtHidden>4) ExtHidden=4;
 
   if (ExtDeltaType<0) ExtDeltaType=0;
   if (ExtDeltaType>3) ExtDeltaType=3;

   if (ExtFractalEnd>0)
     {
      if (ExtFractalEnd<5) ExtFractalEnd=5;
     }
   if (ExtFiboStaticNum<2) ExtFiboStaticNum=2;
   if (ExtFiboStaticNum>9) ExtFiboStaticNum=9;

   perTF=Period();

   return(0);
  }
//+------------------------------------------------------------------+
//| ���������������. �������� ���� ��������� ����� � ��������� ��������
//+------------------------------------------------------------------+
int deinit()
  {
   if (ExtDeleteObj) {ObjectsDeleteAll(0,2); ObjectsDeleteAll(0,21);}
   else delete_objects1();

   ObjectDelete("fiboS");ObjectDelete("fiboD"); return(0);
  }
//********************************************************
// ������
int start()
  {
   counted_bars=IndicatorCounted();

   if( counted_bars<0 )
   {
      Alert("���� ������� ����������");
      return(-1);
   }

//-----------------------------------------
//
//     1.
//
// ���� ���������� �������. 
// zz[] - �����, ������ �� �������� ������� ��� ��������� ������ ZigZag-a
// zzL[] - ������ ��������� ��������
// zzH[] - ������ ���������� ��������
// ������. 
//-----------------------------------------   
//
// ���� ����� �������� ����� ����������,
// ������� ��������� ��� ���������������� ������.
// ��������� ����� ��������� �� ������ ������,
// ���������� �� ����� �����������.
//
// ��� ��� ���, ��� ������� �������������� ���������.
//
//-----------------------------------------

if (perTF!=Period())
  {
   delete_objects1();  
   perTF=Period();
  }

if (ExtIndicator==0) ZigZag_();
if (ExtIndicator==1) ang_AZZ_();
if (ExtIndicator==2) Ensign_ZZ();
//-----------------------------------------
// ���� ���������� �������. �����.
//-----------------------------------------   

if (ExtHidden>0) // ���������� �� ����� ��������. ������.
  {
//======================
//======================
//======================

//-----------------------------------------
//
//     2.
//
// ���� ���������� ������. ������.
//-----------------------------------------   

   if (Bars - counted_bars>2 || flagFrNew)
     {

      // ����� ������� � ������ ����, �� �������� ����� ���������� �������������� ����� 
      if (countBarEnd==0)
        {
         if (ExtFractalEnd>0)
           {
            k=ExtFractalEnd;
            for (shift=0; shift<Bars && k>0; shift++) 
              { 
               if (zz[shift]>0 && zzH[shift]>0) {countBarEnd=shift; TimeBarEnd=Time[shift]; k--;}
              }
           }
         else 
           {
            countBarEnd=Bars-3;
            TimeBarEnd=Time[Bars-3];
           }
        }
      else
        {
         countBarEnd=iBarShift(Symbol(),Period(),TimeBarEnd); 
        }

      // ������������� �������
      matriza();
     }
//-----------------------------------------
// ���� ���������� ������. �����.
//-----------------------------------------   


//-----------------------------------------
//
//     3.
//
// ���� �������� � �������� �����, 
// ���������� ������������. ������.
//-----------------------------------------   
// ��������� ����������� ����� � �����. ������.

if (Bars - counted_bars<3)
  {
   // ����� ������� ���� ������� ��������, ������ �� �������� ����
   for (shift1=0; shift1<Bars; shift1++) 
     {
      if (zz[shift1]>0.0 && (zzH[shift1]==zz[shift1] || zzL[shift1]==zz[shift1])) 
       {
        timeFr1new=Time[shift1];
        break;
       }
     }
   // ����� ����, �� ������� ������ ������� ��� �����.
   shift=iBarShift(Symbol(),Period(),afr[0]); 
 
 
   // ��������� �������� �������� �������� � ���, ������� ��� �����

   // ����������� ����� �������
   if (timeFr1new!=afr[0])
     {
      flagFrNew=true;
      if (shift>=shift1) numBar=shift; else  numBar=shift1;
      afrm=true;
     }

   // ������� �� ��������� ��������� �� ������ ���
   if (afrh[0]>0 && zz[shift]==0.0)
     {
      flagFrNew=true;
      if (numBar<shift) numBar=shift;
      afrm=true;
     }
   // ������� �� �������� ��������� �� ������ ���
   if (afrl[0]>0 && zz[shift]==0.0)
     {
      flagFrNew=true;
      if (numBar<shift) numBar=shift;
      afrm=true;
     }


//-----------3 ��������� �������� ��� �������, �� ������� �� ��� �� ����. ������.

//============= 1 ��������� ��������. ������.
if (afrh[0]-High[shift]!=0 && afrh[0]>0)
  {

   numLowPrim=0; numLowLast=0;
   numHighPrim=shift; numHighLast=0;

   LowPrim=0.0; LowLast=0.0;
   HighPrim=High[shift]; HighLast=0.0;
   
   Angle=-100;

   for (k=shift+1; k<=countBarEnd; k++)
     {

      if (zzL[k]>0.0 && LowPrim==0.0 && zzL[k]==zz[k]) {LowPrim=zzL[k]; numLowPrim=k;}
      if (zzL[k]>0.0 && zzL[k]<LowPrim && zzL[k]==zz[k]) {LowPrim=zzL[k]; numLowPrim=k;}
      if (zzH[k]>0.0  && zzH[k]==zz[k])
        {
         if (HighLast>0) 
           {
            HighLast=High[k]; numHighLast=k;
           }
         else {numHighLast=k; HighLast=High[k];}
         
         HL=High[numHighLast]-Low[numLowPrim];
         kj=(HighPrim-HighLast)*1000/(numHighLast-numHighPrim);
         if (HL>0 && (Angle>kj || Angle==-100))  // �������� ���� ������� �����
           {
            Angle=kj;
// �������� �����
            HLp=High[numHighPrim]-Low[numLowPrim];
            k1=MathCeil((shift+numHighLast)/2);
            kj=HLp/HL;
// ����� ������ �������������� �����                 

            nameObj="ph" + Time[numHighPrim] + "_" + Time[numHighLast];
            nameObjtxt="phtxt" + Time[numHighPrim] + "_" + Time[numHighLast];

            numOb=ObjectFind(nameObj);

            if (numOb>-1)
              {
               if (kj>0.21 && kj<=5)
                 {
                  // ����������� ��������
                  ObjectMove(nameObj,0,Time[numHighPrim],High[numHighPrim]);
                  ObjectMove(nameObjtxt,0,Time[k1],MathAbs((High[numHighPrim]+High[numHighLast])/2));

                  // �������� ���������� ������� (����� ���������). % �������������� ����� �����������
                  kk=kj;
                  k2=1;

                  if (ExtDeltaType==2) for (ki=0;ki<=16;ki++) {if (MathAbs((fi[ki]-kj)/fi[ki])<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}
                  if (ExtDeltaType==1) for (ki=0;ki<=16;ki++) {if (MathAbs(fi[ki]-kj)<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}

                  if (k2<0)

                    // ������� �������������� ����� ���������
                    if (ExtHidden!=4)
                      {
                       if (kk==0.886)
                         ObjectSetText(nameObjtxt,fitxt[ki],ExtSizeTxt,"Arial", ExtGartley866);
                       else
                         ObjectSetText(nameObjtxt,fitxt[ki],ExtSizeTxt,"Arial",ExtPesavento);
                      }
                    else
                    // ������� �������������� (�� ���������)
                      if (ExtHidden==1 || ExtHidden==4)
                        ObjectSetText(nameObjtxt,""+DoubleToStr(kk,2),ExtSizeTxt,"Arial",ExtNotFibo);
                 }
               else
                 {
                  ObjectDelete(nameObj); 
                  ObjectDelete(nameObjtxt);
                 }
              }
            else
              {
//******* ���������� ����� �����, ���� ��� ���������.
               if (kj>0.21 && kj<=5)
                 {
                  // �������� ���������� ������� (����� ���������). % �������������� ����� �����������
                  kk=kj;
                  k2=1;

                  if (ExtDeltaType==1) for (ki=0;ki<=16;ki++) {if (MathAbs(fi[ki]-kj)<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}
                  if (ExtDeltaType==2) for (ki=0;ki<=16;ki++) {if (MathAbs((fi[ki]-kj)/fi[ki])<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}

                  if (k2<0)
                    // ������� �������������� ����� ��������� � 0.866
                    {
                     if (ExtHidden!=4)                  
                       {
                        ObjectCreate(nameObjtxt,OBJ_TEXT,0,Time[k1],MathAbs((High[numHighPrim]+High[numHighLast])/2));
                        if (kk==0.886) // Gartley
                          ObjectSetText(nameObjtxt,fitxt[ki],ExtSizeTxt,"Arial", ExtGartley866);
                        else
                          ObjectSetText(nameObjtxt,fitxt[ki],ExtSizeTxt,"Arial",ExtPesavento);
                       }
                    }
                  else
                    // ������� �������������� (�� ��������� � 0.866)
                    {
                     if (ExtHidden==1 || ExtHidden==4)
                       {
                        ObjectCreate(nameObjtxt,OBJ_TEXT,0,Time[k1],MathAbs((High[numHighPrim]+High[numHighLast])/2));
                        ObjectSetText(nameObjtxt,""+DoubleToStr(kk,2),ExtSizeTxt,"Arial",ExtNotFibo);
                       }
                    }
                  if ((ExtHidden==2 && k2<0) || ExtHidden!=2)
                    {
                     ObjectCreate(nameObj,OBJ_TREND,0,Time[numHighPrim],High[numHighPrim],Time[numHighLast],High[numHighLast]);
                     ObjectSet(nameObj,OBJPROP_RAY,false);
                     ObjectSet(nameObj,OBJPROP_STYLE,STYLE_DOT);
                     ObjectSet(nameObj,OBJPROP_COLOR,ExtLine);
                    }
                 }
//*******
               }
             }
        }
     }
     afrh[0]=High[shift];
     if (ExtFiboDinamic)
       {
        screenFiboD();
       }
   }
//============= 1 ��������� ��������. �����.
//
//============= 1 ��������� �������. ������.
if (afrl[0]-Low[shift]!=0 && afrl[0]>0)
  {

   numLowPrim=0; numLowLast=0;
   numHighPrim=shift; numHighLast=0;

   LowPrim=Low[shift]; LowLast=0.0;
   HighPrim=0.0; HighLast=0.0;
   
   Angle=-100;
   for (k=shift+1; k<=countBarEnd; k++)
     {
      if (zzH[k]>HighPrim) {HighPrim=High[k]; numHighPrim=k;}
      if (zzL[k]>0.0 && zzL[k]==zz[k]) 
        {
         if (LowLast>0) 
           {
            LowLast=Low[k]; numLowLast=k;
           }
         else {numLowLast=k; LowLast=Low[k];}

         HL=High[numHighPrim]-Low[numLowLast];
         kj=(LowPrim-LowLast)*1000/(numLowLast-numLowPrim);
         if (HL>0 && (Angle<kj || Angle==-100))  // �������� ���� ������� �����
           {
            Angle=kj;

            HLp=High[numHighPrim]-Low[numLowPrim];
            k1=MathCeil((numLowPrim+numLowLast)/2);
            kj=HLp/HL;
// ����� ������ �������������� �����                 

            nameObj="pl" + Time[numLowPrim] + "_" + Time[numLowLast];
            nameObjtxt="pltxt" + Time[numLowPrim] + "_" + Time[numLowLast];

            numOb=ObjectFind(nameObj);
            if (numOb>-1)
              {
               if (kj>0.21 && kj<=5)
                 {
                  // ����������� ��������
                  ObjectMove(nameObj,0,Time[numLowPrim],Low[numLowPrim]);
                  ObjectMove(nameObjtxt,0,Time[k1],MathAbs((Low[numLowPrim]+Low[numLowLast])/2));

                  // �������� ���������� ������� (����� ���������). % �������������� ����� ����������
                  kk=kj;
                  k2=1;

                  if (ExtDeltaType==2) for (ki=0;ki<=16;ki++) {if (MathAbs((fi[ki]-kj)/fi[ki])<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}
                  if (ExtDeltaType==1) for (ki=0;ki<=16;ki++) {if (MathAbs(fi[ki]-kj)<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}

                  if (k2<0)
                  // ������� �������������� ����� ��������� � 0.866
                    {
                     if (ExtHidden!=4)                  
                       {
                        if (kk==0.886) // Gartley
                          ObjectSetText(nameObjtxt,fitxt[ki],ExtSizeTxt,"Arial", ExtGartley866);
                        else
                          ObjectSetText(nameObjtxt,fitxt[ki],ExtSizeTxt,"Arial",ExtPesavento);
                       }
                    }
                  else 
                    // ������� �������������� (�� ��������� � 0.866)
                    if (ExtHidden==1 || ExtHidden==4)
                      ObjectSetText(nameObjtxt,""+DoubleToStr(kk,2),ExtSizeTxt,"Arial",ExtNotFibo);
                 }           
               else
                 {
                  ObjectDelete(nameObj); 
                  ObjectDelete(nameObjtxt);
                 }
              }  
            else
              {
//******* ���������� ����� �����, ���� ��� ���������.
               if (kj>0.21 && kj<=5)
                 {
                  // �������� ���������� ������� (����� ���������). % �������������� ����� ����������
                  kk=kj;
                  k2=1;

                  if (ExtDeltaType==2) for (ki=0;ki<=16;ki++) {if (MathAbs((fi[ki]-kj)/fi[ki])<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}
                  if (ExtDeltaType==1) for (ki=0;ki<=16;ki++) {if (MathAbs(fi[ki]-kj)<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}

                  if (k2<0)
                    // ������� �������������� ����� ��������� � 0.866
                    {
                     if (ExtHidden!=4)                  
                       {
                        nameObj="pltxt" + Time[numLowPrim] + "_" + Time[numLowLast];
                     
                        ObjectCreate(nameObj,OBJ_TEXT,0,Time[k1],MathAbs((Low[numLowPrim]+Low[numLowLast])/2));
                        if (kk==0.886) // Gartley
                          ObjectSetText(nameObj,fitxt[ki],ExtSizeTxt,"Arial", ExtGartley866);
                        else
                          ObjectSetText(nameObj,fitxt[ki],ExtSizeTxt,"Arial",ExtPesavento);
                       }
                    }
                  else 
                    // ������� �������������� (�� ��������� � 0.866)
                    { 
                     if (ExtHidden==1 || ExtHidden==4)
                       nameObj="pltxt" + Time[numLowPrim] + "_" + Time[numLowLast];
                     
                       ObjectCreate(nameObj,OBJ_TEXT,0,Time[k1],MathAbs((Low[numLowPrim]+Low[numLowLast])/2));
                       ObjectSetText(nameObj,""+DoubleToStr(kk,2),ExtSizeTxt,"Arial",ExtNotFibo);
                    }
                  if ((ExtHidden==2 && k2<0) || ExtHidden!=2)
                    {
                     nameObj="pl" + Time[numLowPrim] + "_" + Time[numLowLast];
                     
                     ObjectCreate(nameObj,OBJ_TREND,0,Time[numLowPrim],Low[numLowPrim],Time[numLowLast],Low[numLowLast]);
                     ObjectSet(nameObj,OBJPROP_RAY,false);
                     ObjectSet(nameObj,OBJPROP_STYLE,STYLE_DOT);
                     ObjectSet(nameObj,OBJPROP_COLOR,ExtLine);
                    }
                 }           
//*******
               }
            }
        }
     }
     afrl[0]=Low[shift];
     if (ExtFiboDinamic)
       {
        screenFiboD();
       }
   }
//============= 1 ��������� �������. �����.
//-----------3 ��������� �������� ��� �������, �� ������� �� ��� �� ����. �����.


   // ����� ����������� ��������� � �������� �����, ��������� �� ���� ���������. ������.
   countBarEnd=iBarShift(Symbol(),Period(),TimeBarEnd); 
   for (k=0; k<5; k++)
     {

      // �������� ����������.
      if (afrh[k]>0)
        {
         // ����� ����, �� ������� ��� ���� �������
         shift=iBarShift(Symbol(),Period(),afr[k]); 
         if (zz[shift]==0)
           {
            flagFrNew=true;
            if (shift>numBar) numBar=shift;
            afrm=true;
            numHighPrim=shift; numHighLast=0;HighLast=0.0;
            for (k1=shift+1; k1<=countBarEnd; k1++)
              {
               if (zzH[k1]>0) 
                 {
                  HighLast=High[k1]; numHighLast=k1;

                  nameObj="ph" + Time[numHighPrim] + "_" + Time[numHighLast];

                  numOb=ObjectFind(nameObj);
                  if (numOb>-1)
                    {
                     ObjectDelete(nameObj); 

                     nameObjtxt="phtxt" + Time[numHighPrim] + "_" + Time[numHighLast];

                     ObjectDelete(nameObjtxt);
                    }
                 }
              }

           }
        }
      
      // �������� ���������.
      if (afrl[k]>0)
        {
         // ����� ����, �� ������� ��� ���� �������
         shift=iBarShift(Symbol(),Period(),afr[k]); 
         if (zz[shift]==0)
           {
            flagFrNew=true;
            if (shift>numBar) numBar=shift;

            afrm=true;
            numLowPrim=shift; numLowLast=0;LowLast=10000000;
            for (k1=shift+1; k1<=countBarEnd; k1++)
              {
               if (zzL[k1]>0) 
                 {
                  LowLast=Low[k1]; numLowLast=k1;

                  nameObj="pl" + Time[numLowPrim] + "_" + Time[numLowLast];

                  numOb=ObjectFind(nameObj);
                  if (numOb>-1)
                    {
                     ObjectDelete(nameObj); 

                     nameObjtxt="pltxt" + Time[numLowPrim] + "_" + Time[numLowLast];

                     ObjectDelete(nameObjtxt);
                    }
                 }
              }
           }
        }

     }
   // ����� ����������� ��������� � �������� �����, ��������� �� ���� ���������. �����.

   // ���������� �������. ������.
   matriza ();
   // ���������� �������. �����.

  }
// ��������� ����������� ����� � �����. �����.
//-----------------------------------------
// ���� �������� � �������� �����, 
// ���������� ������������. �����.
//-----------------------------------------   


      // ������� ���������� ���������. ������.
      countFractal();
      // ������� ���������� ���������. �����.

//-----------------------------------------
//
//     4.
//
// ���� ������ �������������� �����. ������.
//-----------------------------------------   
if (Bars - counted_bars>2)
  {
//-----------1 ��������� ����������. ������.
//+--------------------------------------------------------------------------+
//| ����� ����������� ����� � ����� ��������� � 0.866 ��� ���������� ZigZag-a
//| ��������� ���� �� �������� ����
//+--------------------------------------------------------------------------+

   numLowPrim=0; numLowLast=0;
   numHighPrim=0; numHighLast=0;

   LowPrim=0.0; LowLast=0.0;
   HighPrim=0.0; HighLast=0.0;
   
   Angle=-100;
   
   if (flagFrNew) countFr=1;
   else countFr=ExtFractal;

   for (k=0; (k<Bars-1 && countHigh1>0 && countFr>0); k++)
     {
      if (zzL[k]>0.0 && LowPrim==0.0 && HighPrim>0 && zzL[k]==zz[k]) {LowPrim=zzL[k]; numLowPrim=k;}
      if (zzL[k]>0.0 && zzL[k]<LowPrim && HighPrim>0 && zzL[k]==zz[k]) {LowPrim=zzL[k]; numLowPrim=k;}
      if (zzH[k]>0.0 && zzH[k]==zz[k])
        {
         if (HighPrim>0) 
           {
            if (HighLast>0) 
              {
               HighLast=High[k]; numHighLast=k;
              }
            else {numHighLast=k; HighLast=High[k];}

            HL=High[numHighLast]-Low[numLowPrim];
            kj=(HighPrim-HighLast)*10000/(numHighLast-numHighPrim);
            if (HL>0 && (Angle>kj || Angle==-100))  // �������� ���� ������� �����
              {
               Angle=kj;
               // �������� ����� � ���������� �������
               HLp=High[numHighPrim]-Low[numLowPrim];
               k1=MathCeil((numHighPrim+numHighLast)/2);
               kj=HLp/HL;

               if (kj>0.21 && kj<=5)
                 {
                  // �������� ���������� ������� (����� ���������). % �������������� ����� �����������
                  kk=kj;
                  k2=1;

                  if (ExtDeltaType==2) for (ki=0;ki<=16;ki++) {if (MathAbs((fi[ki]-kj)/fi[ki])<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}
                  if (ExtDeltaType==1) for (ki=0;ki<=16;ki++) {if (MathAbs(fi[ki]-kj)<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}

                  if (k2<0)
                    // ������� �������������� ����� ��������� � 0.866
                    {
                    if (ExtHidden!=4)                  
                      {
                       nameObj="phtxt" + Time[numHighPrim] + "_" + Time[numHighLast];

                       ObjectCreate(nameObj,OBJ_TEXT,0,Time[k1],MathAbs((High[numHighPrim]+High[numHighLast])/2));
                       if (kk==0.886) // Gartley
                         ObjectSetText(nameObj,fitxt[ki],ExtSizeTxt,"Arial", ExtGartley866);
                       else
                         ObjectSetText(nameObj,fitxt[ki],ExtSizeTxt,"Arial",ExtPesavento);
                      }
                     }
                  else
                    // ������� �������������� (�� ��������� � 0.866)
                    {
                     if (ExtHidden==1 || ExtHidden==4)
                       {
                        nameObj="phtxt" + Time[numHighPrim] + "_" + Time[numHighLast];

                        ObjectCreate(nameObj,OBJ_TEXT,0,Time[k1],MathAbs((High[numHighPrim]+High[numHighLast])/2));
                        ObjectSetText(nameObj,""+DoubleToStr(kk,2),ExtSizeTxt,"Arial",ExtNotFibo);
                       }
                    }

                  if ((ExtHidden==2 && k2<0) || ExtHidden!=2)
                    {
                     nameObj="ph" + Time[numHighPrim] + "_" + Time[numHighLast];

                     ObjectCreate(nameObj,OBJ_TREND,0,Time[numHighPrim],High[numHighPrim],Time[numHighLast],High[numHighLast]);
                     ObjectSet(nameObj,OBJPROP_RAY,false);
                     ObjectSet(nameObj,OBJPROP_STYLE,STYLE_DOT);
                     ObjectSet(nameObj,OBJPROP_COLOR,ExtLine);
                    }
                 }
              }
           }
         else 
            {numHighPrim=k; HighPrim=High[k];}
        }
       // ������� �� ��������� �������
       if (k>countBarEnd) 
         {
          k=numHighPrim+1; countHigh1--; countFr--;
          numLowPrim=0; numLowLast=0;
          numHighPrim=0; numHighLast=0;

          LowPrim=0.0; LowLast=0.0;
          HighPrim=0.0; HighLast=0.0;
   
          Angle=-100;
         }
     }
//-----------1 ��������� ����������. �����.

//-----------2 ��������� ���������. ������.
//+-------------------------------------------------------------------------+
//| ����� ����������� ����� � ����� ��������� � 0.866 ��� ��������� ZigZag-a
//| ��������� ���� �� �������� ����
//+-------------------------------------------------------------------------+

   numLowPrim=0; numLowLast=0;
   numHighPrim=0; numHighLast=0;

   LowPrim=0.0; LowLast=0.0;
   HighPrim=0.0; HighLast=0.0;
   
   Angle=-100;

   if (flagFrNew) countFr=1;
   else countFr=ExtFractal;

   for (k=0; (k<Bars-1 && countLow1>0 && countFr>0); k++)
     {
      if (zzH[k]>HighPrim && LowPrim>0) {HighPrim=High[k]; numHighPrim=k;}
      if (zzL[k]>0.0 && zzL[k]==zz[k]) 
        {
         if (LowPrim>0) 
           {
            if (LowLast>0) 
              {
               LowLast=Low[k]; numLowLast=k;
              }
            else {numLowLast=k; LowLast=Low[k];}

            // ����� ����������� ����� � ��������� ��������������(����� ���������)
            HL=High[numHighPrim]-Low[numLowLast];
            kj=(LowPrim-LowLast)*1000/(numLowLast-numLowPrim);
            if (HL>0 && (Angle<kj || Angle==-100))  // �������� ���� ������� �����
              {
               Angle=kj;

               HLp=High[numHighPrim]-Low[numLowPrim];
               k1=MathCeil((numLowPrim+numLowLast)/2);
               kj=HLp/HL;

               if (kj>0.21 && kj<=5)
                 {
                  // �������� ���������� ������� (����� ���������). % �������������� ����� ����������
                  kk=kj;
                  k2=1;

                  if (ExtDeltaType==2) for (ki=0;ki<=16;ki++) {if (MathAbs((fi[ki]-kj)/fi[ki])<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}
                  if (ExtDeltaType==1) for (ki=0;ki<=16;ki++) {if (MathAbs(fi[ki]-kj)<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}

                  if (k2<0)
                  // ������� �������������� ����� ��������� � 0.866
                    {
                     if (ExtHidden!=4)                  
                       {
                        nameObj="pltxt" + Time[numLowPrim] + "_" + Time[numLowLast];

                        ObjectCreate(nameObj,OBJ_TEXT,0,Time[k1],MathAbs((Low[numLowPrim]+Low[numLowLast])/2));
                        if (kk==0.886) // Gartley
                          ObjectSetText(nameObj,fitxt[ki],ExtSizeTxt,"Arial", ExtGartley866);
                        else
                          ObjectSetText(nameObj,fitxt[ki],ExtSizeTxt,"Arial",ExtPesavento);
                       }
                    }
                  else 
                    // ������� �������������� (�� ��������� � 0.866)
                    { 
                     if (ExtHidden==1 || ExtHidden==4)
                       {
                        nameObj="pltxt" + Time[numLowPrim] + "_" + Time[numLowLast];

                        ObjectCreate(nameObj,OBJ_TEXT,0,Time[k1],MathAbs((Low[numLowPrim]+Low[numLowLast])/2));
                        ObjectSetText(nameObj,""+DoubleToStr(kk,2),ExtSizeTxt,"Arial",ExtNotFibo);
                       }
                     }
                     
                   if ((ExtHidden==2 && k2<0) || ExtHidden!=2)
                     {
                      nameObj="pl" + Time[numLowPrim] + "_" + Time[numLowLast];

                      ObjectCreate(nameObj,OBJ_TREND,0,Time[numLowPrim],Low[numLowPrim],Time[numLowLast],Low[numLowLast]);
                      ObjectSet(nameObj,OBJPROP_RAY,false);
                      ObjectSet(nameObj,OBJPROP_STYLE,STYLE_DOT);
                      ObjectSet(nameObj,OBJPROP_COLOR,ExtLine);
                     }
                  }
               }
           }
         else {numLowPrim=k; LowPrim=Low[k];}
        }
       // ������� �� ��������� �������
       if (k>countBarEnd) 
         {
          k=numLowPrim+1; countLow1--; countFr--;

          numLowPrim=0; numLowLast=0;
          numHighPrim=0; numHighLast=0;

          LowPrim=0.0; LowLast=0.0;
          HighPrim=0.0; HighLast=0.0;
  
          Angle=-100;
         }
     }

//-----------2 ��������� ���������. �����.

  }
//-----------------------------------------
// ���� ������ �������������� �����. �����.
//-----------------------------------------   

//======================
//======================
//======================
  } // ���������� �� ����� ��������. �����.
// �����
  } // start



//----------------------------------------------------
//  ������������ � �������
//----------------------------------------------------

//--------------------------------------------------------
// ������� ���������� ���������. ��������� � ����������. ������.
//--------------------------------------------------------
void countFractal()
  {
   int shift;
   countLow1=0;
   countHigh1=0;
   if (flagFrNew)
     {
      for(shift=0; shift<=numBar; shift++)
        {
         if (zzL[shift]>0.0) {countLow1++;}
         if (zzH[shift]>0.0) {countHigh1++;}    
        }
      flagFrNew=false;
      numBar=0;  
      counted_bars=Bars-4;
     }
   else
     {
      for(shift=0; shift<=countBarEnd; shift++)
        {
         if (zzL[shift]>0.0) {countLow1++;}
         if (zzH[shift]>0.0) {countHigh1++;}
        }
     }
   return ;
  }
//--------------------------------------------------------
// ������� ���������� ���������. ��������� � ����������. �����.
//--------------------------------------------------------

//--------------------------------------------------------
// ������������ �������. ������.
//
// ������� ������������ ��� ������ ����������� ���������.
// ��� ���������� ����������� �������������� ��������� ������������ ZigZag-a.
//--------------------------------------------------------
void matriza()
  {
   if (afrm)
     {
      int shift,k;
      k=0;
      for (shift=0; shift<Bars && k<10; shift++)
        {
         if (zz[shift]>0)
           {
            afr[k]=Time[shift];
            if (zz[shift]==zzL[shift]) {afrl[k]=Low[shift]; afrh[k]=0.0;}
            if (zz[shift]==zzH[shift]) {afrh[k]=High[shift]; afrl[k]=0.0;}
            k++;
           }
        }
      afrm=false;
      // ����� ����������� � ������������ ���.
      if (ExtFiboStatic)
        {
         ExtFiboStatic=false;
         screenFiboS();
        }
      if (ExtFiboDinamic)
        {
         screenFiboD();
        }
     }
   return ;
  }
//--------------------------------------------------------
// ������������ �������. �����.
//--------------------------------------------------------

//--------------------------------------------------------
// ����� ��� �����������. ������.
//--------------------------------------------------------
void screenFiboS()
  {
   double fibo_0, fibo_100, fiboPrice, fiboPrice1;

   nameObj="fiboS";
   numOb=ObjectFind(nameObj);
   if (numOb>-1) ObjectDelete(nameObj);
   if (afrl[ExtFiboStaticNum-1]>0) 
     {
      fibo_0=afrh[ExtFiboStaticNum];fibo_100=afrl[ExtFiboStaticNum-1];
      fiboPrice=afrh[ExtFiboStaticNum]-afrl[ExtFiboStaticNum-1];fiboPrice1=afrl[ExtFiboStaticNum-1];
     }
   else 
     {
      fibo_0=afrl[ExtFiboStaticNum];fibo_100=afrh[ExtFiboStaticNum-1];
      fiboPrice=afrl[ExtFiboStaticNum]-afrh[ExtFiboStaticNum-1];fiboPrice1=afrh[ExtFiboStaticNum-1];
     }

   ObjectCreate(nameObj,OBJ_FIBO,0,afr[2],fibo_0,afr[1],fibo_100);
   ObjectSet(nameObj,OBJPROP_LEVELSTYLE,STYLE_DOT);
   ObjectSet(nameObj,OBJPROP_FIBOLEVELS,18);
   ObjectSet(nameObj,OBJPROP_LEVELCOLOR,ExtFiboS);

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL,0);
   ObjectSetFiboDescription(nameObj, 0, "0  -->  "+DoubleToStr(fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+1,0.382);
   ObjectSetFiboDescription(nameObj, 1, "38.2  -->  "+DoubleToStr(fiboPrice*0.382+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+2,0.5);
   ObjectSetFiboDescription(nameObj, 2, "50.0  -->  "+DoubleToStr(fiboPrice*0.5+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+3,0.618);
   ObjectSetFiboDescription(nameObj, 3, "61.8  -->  "+DoubleToStr(fiboPrice*0.618+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+4,0.707);
   ObjectSetFiboDescription(nameObj, 4, "70.7  -->  "+DoubleToStr(fiboPrice*0.707+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+5,0.786);
   ObjectSetFiboDescription(nameObj, 5, "78.6  -->  "+DoubleToStr(fiboPrice*0.786+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+6,0.841);
   ObjectSetFiboDescription(nameObj, 6, "84.1  -->  "+DoubleToStr(fiboPrice*0.841+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+7,0.886);
   ObjectSetFiboDescription(nameObj, 7, "88.6  -->  "+DoubleToStr(fiboPrice*0.886+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+8,1.0);
   ObjectSetFiboDescription(nameObj, 8, "100.0  -->  "+DoubleToStr(fiboPrice+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+9,1.127);
   ObjectSetFiboDescription(nameObj, 9, "112.8  -->  "+DoubleToStr(fiboPrice*1.128+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+10,1.272);
   ObjectSetFiboDescription(nameObj, 10, "127.2  -->  "+DoubleToStr(fiboPrice*1.272+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+11,1.414);
   ObjectSetFiboDescription(nameObj, 11, "141.4  -->  "+DoubleToStr(fiboPrice*1.414+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+12,1.618);
   ObjectSetFiboDescription(nameObj, 12, "161.8  -->  "+DoubleToStr(fiboPrice*1.618+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+13,2.0);
   ObjectSetFiboDescription(nameObj, 13, "200.0  -->  "+DoubleToStr(fiboPrice*2.0+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+14,2.414);
   ObjectSetFiboDescription(nameObj, 14, "241.4  -->  "+DoubleToStr(fiboPrice*2.414+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+15,2.618);
   ObjectSetFiboDescription(nameObj, 15, "261.8  -->  "+DoubleToStr(fiboPrice*2.618+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+16,4.236);
   ObjectSetFiboDescription(nameObj, 16, "423.6  -->  "+DoubleToStr(fiboPrice*4.236+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+17,6.854);
   ObjectSetFiboDescription(nameObj, 17, "685.4  -->  "+DoubleToStr(fiboPrice*6.854+fiboPrice1, 4) ); 

   return ;
  }
//--------------------------------------------------------
// ����� ��� �����������. �����.
//--------------------------------------------------------

//--------------------------------------------------------
// ����� ��� ������������. ������.
//--------------------------------------------------------
void screenFiboD()
  {
   double fibo_0, fibo_100, fiboPrice, fiboPrice1;

   nameObj="fiboD";
   numOb=ObjectFind(nameObj);
   if (numOb>-1) ObjectDelete(nameObj);
   if (afrh[1]>0) {fibo_0=afrh[1];fibo_100=afrl[0];fiboPrice=afrh[1]-afrl[0];fiboPrice1=afrl[0];}
   else {fibo_0=afrl[1];fibo_100=afrh[0];fiboPrice=afrl[1]-afrh[0];fiboPrice1=afrh[0];}

   ObjectCreate(nameObj,OBJ_FIBO,0,afr[2],fibo_0,afr[1],fibo_100);
   ObjectSet(nameObj,OBJPROP_LEVELSTYLE,STYLE_DOT);
   ObjectSet(nameObj,OBJPROP_FIBOLEVELS,18);
   ObjectSet(nameObj,OBJPROP_LEVELCOLOR,ExtFiboD);

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL,0);
   ObjectSetFiboDescription(nameObj, 0, "0  -->  "+DoubleToStr(fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+1,0.382);
   ObjectSetFiboDescription(nameObj, 1, "38.2  -->  "+DoubleToStr(fiboPrice*0.382+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+2,0.5);
   ObjectSetFiboDescription(nameObj, 2, "50.0  -->  "+DoubleToStr(fiboPrice*0.5+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+3,0.618);
   ObjectSetFiboDescription(nameObj, 3, "61.8  -->  "+DoubleToStr(fiboPrice*0.618+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+4,0.707);
   ObjectSetFiboDescription(nameObj, 4, "70.7  -->  "+DoubleToStr(fiboPrice*0.707+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+5,0.786);
   ObjectSetFiboDescription(nameObj, 5, "78.6  -->  "+DoubleToStr(fiboPrice*0.786+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+6,0.841);
   ObjectSetFiboDescription(nameObj, 6, "84.1  -->  "+DoubleToStr(fiboPrice*0.841+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+7,0.886);
   ObjectSetFiboDescription(nameObj, 7, "88.6  -->  "+DoubleToStr(fiboPrice*0.886+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+8,1.0);
   ObjectSetFiboDescription(nameObj, 8, "100.0  -->  "+DoubleToStr(fiboPrice+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+9,1.127);
   ObjectSetFiboDescription(nameObj, 9, "112.8  -->  "+DoubleToStr(fiboPrice*1.128+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+10,1.272);
   ObjectSetFiboDescription(nameObj, 10, "127.2  -->  "+DoubleToStr(fiboPrice*1.272+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+11,1.414);
   ObjectSetFiboDescription(nameObj, 11, "141.4  -->  "+DoubleToStr(fiboPrice*1.414+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+12,1.618);
   ObjectSetFiboDescription(nameObj, 12, "161.8  -->  "+DoubleToStr(fiboPrice*1.618+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+13,2.0);
   ObjectSetFiboDescription(nameObj, 13, "200.0  -->  "+DoubleToStr(fiboPrice*2.0+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+14,2.414);
   ObjectSetFiboDescription(nameObj, 14, "241.4  -->  "+DoubleToStr(fiboPrice*2.414+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+15,2.618);
   ObjectSetFiboDescription(nameObj, 15, "261.8  -->  "+DoubleToStr(fiboPrice*2.618+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+16,4.236);
   ObjectSetFiboDescription(nameObj, 16, "423.6  -->  "+DoubleToStr(fiboPrice*4.236+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+17,6.854);
   ObjectSetFiboDescription(nameObj, 17, "685.4  -->  "+DoubleToStr(fiboPrice*6.854+fiboPrice1, 4) ); 

   return ;
  }
//--------------------------------------------------------
// ����� ��� ������������. �����.
//--------------------------------------------------------


//Print (); 
//--------------------------------------------------------
// �������� ��������. ������.
// �������� �������������� ����� � �����.
//--------------------------------------------------------
void delete_objects1()
{
int i;
string txt;

for (i=ObjectsTotal(); i>=0; i--)
  {
   txt=ObjectName(i);
   if (StringFind(txt,"pl")>-1)ObjectDelete (txt);
   if (StringFind(txt,"ph")>-1) ObjectDelete (txt);
  }
return;
}
//--------------------------------------------------------
// �������� ��������. ������.
// �������� �������������� ����� � �����.
//--------------------------------------------------------
//----------------------------------------------------
//  ZigZag (�� ��4 ������� ����������). ������.
//----------------------------------------------------
void ZigZag_()
  {
//  ZigZag �� ��. ������.
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;

   for(shift=Bars-minBars; shift>=0; shift--)
     {
      val=Low[Lowest(NULL,0,MODE_LOW,minBars,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=zzL[shift+back];
               if((res!=0)&&(res>val)) zzL[shift+back]=0.0; 
              }
           }
        } 
      zzL[shift]=val;
      //--- high
      val=High[Highest(NULL,0,MODE_HIGH,minBars,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=zzH[shift+back];
               if((res!=0)&&(res<val)) zzH[shift+back]=0.0; 
              } 
           }
        }
      zzH[shift]=val;
     }

   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;

   for(shift=Bars-minBars; shift>=0; shift--)
     {
      curlow=zzL[shift];
      curhigh=zzH[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) zzH[lasthighpos]=0;
            else zzH[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow) zzL[lastlowpos]=0;
            else zzL[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           } 
         lasthigh=-1;
        }
     }
  
   for(shift=Bars-1; shift>=0; shift--)
     {
      zz[shift]=zzL[shift];
      if(shift>=Bars-minBars) {zzH[shift]=0.0;zzL[shift]=0.0; zz[shift]=0.0;}
      else
        {
         res=zzH[shift];
         if(res!=0.0) zz[shift]=res;
        }
     }

   return;
  }
//--------------------------------------------------------
// ZigZag �� ��. �����. 
//--------------------------------------------------------


//----------------------------------------------------
//  ZigZag ������ ������� ����������. ������.
//----------------------------------------------------
void ang_AZZ_()
 {
   int i,n,cbi;
//   double res;
   cbi=Bars-IndicatorCounted()-1;
//---------------------------------
   for (i=cbi; i>=0; i--) 
     {
//-------------------------------------------------
      // ���������� �������� ����������� ������ fs � ������� ���� si �� ���������� ����
      if (ti!=Time[i]) {fsp=fs; sip=si;} ti=Time[i];
      // ��������� �������� �������� ������� �� �������� ����������
      if (minSize==0 && minPercent!=0) di=minPercent*Close[i]/2/100;
//-------------------------------------------------
      // ������������� ������� ����
      if (High[i]>=si+di && Low[i]<si-di) // ������� ��� �� ��������� � �������� ������� di
        {
         if (High[i]-si>=si-Low[i]) si=High[i]-di;  // ���������� ��� �� ������� ���� ������ ���������� ����
         if (High[i]-si<si-Low[i]) si=Low[i]+di;  // ��������������, ������
        } 
      else  // �� ������� ���
        {
         if (High[i]>=si+di) si=High[i]-di;   // 
         if (Low[i]<=si-di) si=Low[i]+di;   // 
        }

      // ���������� ���������� �������� ������� ����
      if (i>Bars-2) {si=(High[i]+Low[i])/2;}
      // ��������� ������ ��� ������� �������������
      if (chHL) {ha[i]=si+di; la[i]=si-di;} 

      // ���������� ����������� ������ ��� ���������� ����
      if (si>sip) fs=1; // ����� ����������
      if (si<sip) fs=2; // ����� ����������

//-------------------------------------------------

      if (fs==1 && fsp==2) // ����� �������� � ����������� �� ����������
        {
         hm=High[i];
         Last_Bar=iBarShift(Symbol(),Period(),tbiLast);
         zz[Last_Bar]=Low[Last_Bar];
         zzL[Last_Bar]=Low[Last_Bar];
         zzH[Last_Bar]=0;
         if (PeakDet) for (n=bip; n>=bi; n--) {lam[n]=Low[bip];}
         aip=ai; ai=i; taiLast=Time[i];
         t0=Time[i];
         LastBar0=0;
         fsp=fs;
        }

      if (fs==2 && fsp==1) // ����� �������� � ����������� �� ����������
        {
         lm=Low[i]; 
         Last_Bar=iBarShift(Symbol(),Period(),taiLast); 
         zz[Last_Bar]=High[Last_Bar];
         zzH[Last_Bar]=High[Last_Bar];
         zzL[Last_Bar]=0;
         if (PeakDet) for (n=aip; n>=ai; n--) {ham[n]=High[aip];}
         bip=bi; bi=i; tbiLast=Time[i];
         t0=Time[i];
         LastBar0=0;
         fsp=fs;
        }

      // ����������� t�����. ������������ ������.
      if (fs==1 && High[i]>hm) 
        {hm=High[i]; ai=i; taiLast=Time[i];}
      if (fs==2 && Low[i]<lm) 
        {lm=Low[i]; bi=i; tbiLast=Time[i];}

//===================================================================================================
      // ������� ���.
      if (i==0) 
        {
         tai=Time[ai];
         tbi=Time[bi];
         taip=Time[aip];
         tbip=Time[bip];

         ai0=iBarShift(Symbol(),Period(),tai); 
         bi0=iBarShift(Symbol(),Period(),tbi);
         aip0=iBarShift(Symbol(),Period(),taip); 
         bip0=iBarShift(Symbol(),Period(),tbip);

         if (fs==1) 
           {

            if (LastBar0==0) // ����������� ��������� ��� "��������" ����. ������.
              {
               last0=iBarShift(Symbol(),Period(),tbiLast);
               LastBar0=High[last0];
               t0=Time[last0];
               for (n=bi;n>=0;n--)
                 {
                  if (LastBar0<High[n])
                    {
                     LastBar0=High[n];
                     t0=Time[n];
                     last0=n;
                    }
                 }
               zz[last0]=LastBar0;
               zzH[last0]=LastBar0;
               zzL[last0]=0;
              }             // ����������� ��������� ��� "��������" ����. �����.

            if (LastBar0<High[i])
              {
               if (t0<Time[i])
                 {
                  last0=iBarShift(Symbol(),Period(),t0);
                  zz[last0]=0;
                  zzH[last0]=0;
                 }
               LastBar0=High[i];
               t0=Time[i];
               zz[i]=High[i];
               zzH[i]=High[i];
               zzL[i]=0;
              }
           }

         if (fs==2) 
           {

            if (LastBar0==0) // ����������� �������� ��� "��������" ����. ������.
              {
               last0=iBarShift(Symbol(),Period(),taiLast);
               LastBar0=Low[last0];
               t0=Time[last0];
               for (n=ai;n>=0;n--)
                 {
                  if (LastBar0>Low[n])
                    {
                     LastBar0=Low[n];
                     t0=Time[n];
                     last0=n;
                    }
                 }
               zz[last0]=LastBar0;
               zzH[last0]=0;
               zzL[last0]=LastBar0;
              }             // ����������� �������� ��� "��������" ����. �����.

            if (LastBar0>Low[i])
              {
               if (t0<Time[i])
                 {
                  last0=iBarShift(Symbol(),Period(),t0); 
                  zz[last0]=0;
                  zzL[last0]=0;
                 }
               LastBar0=Low[i];
               t0=Time[i];
               zz[i]=Low[i];
               zzL[i]=Low[i];
               zzH[i]=0;
              }
           }

         if (PeakDet)
           {
            if (fs==1) {for (n=aip0; n>=0; n--) {ham[n]=High[aip0];} for (n=bi0; n>=0; n--) {lam[n]=Low[bi0];} }
            if (fs==2) {for (n=bip0; n>=0; n--) {lam[n]=Low[bip0];} for (n=ai0; n>=0; n--) {ham[n]=High[ai0];} } 
           }
//-------------------------------------------------------------
        }
//====================================================================================================
     }
//--------------------------------------------

  return(0);
 }

//--------------------------------------------------------
// ZigZag ������. �����. 
//--------------------------------------------------------



//----------------------------------------------------
// ��������� �������� ����������� � Ensign. ������.
//----------------------------------------------------
void Ensign_ZZ()
 {
   int i,n,cbi;

   cbi=Bars-IndicatorCounted()-1;
//---------------------------------
   for (i=cbi; i>=0; i--) 
     {
//-------------------------------------------------
      // ������������� ��������� �������� �������� � ��������� ����
      if (lLast==0) {lLast=Low[i];hLast=High[i];}
      // ���������� ����������� ������ �� ������ ����� ����� ������.
      // ��� �� ����� ������ ������� ���� �� ����� �����.
      if (fs==0)
        {
         if (lLast<Low[i] && hLast<High[i]) {fs=1; si=High[i]; ai=i;}  // ����� ����������
         if (lLast>Low[i] && hLast>High[i]) {fs=2; si=Low[i]; bi=i;}  // ����� ����������
        }
      
      if (ti!=Time[i])
        {
         // ���������� �������� ����������� ������ fs �� ���������� ����
         fsp=fs;
         ti=Time[i];
         // ���������. ����������� ����������� ����������� ������.
         if (fs==1 && hLast>High[i]) fh=true;
         if (fh && countBar>0) countBar--;
         if (fs==2 && lLast<Low[i]) fl=true;
         if (fl && countBar>0) countBar--;
        } 

      // ����������� ������
      if (fs==1 && High[i]>si) {ai=i; tai=Time[i]; hLast=High[i]; si=High[i]; countBar=minBars; fh=false;}
      if (fs==2 && Low[i]<si) {bi=i; tbi=Time[i]; lLast=Low[i]; si=Low[i]; countBar=minBars; fl=false;}

      if ((countBar==0 || Close[i]<lLast) && fh)
        {
         fh=false;
         if (si-di>Low[i] && High[i]<hLast) {fs=2; countBar=minBars; fh=false;}
        }

      if ((countBar==0 || Close[i]>hLast) && fl)
        {
         fl=false;
         if (si+di<High[i] && Low[i]>lLast) {fs=1; countBar=minBars; fl=false;}
        }
      
//-------------------------------------------------
      if (fs==1 && fsp==2) // ����� �������� � ����������� �� ����������
        {
         zz[bi]=Low[bi];
         zzL[bi]=Low[bi];
         if (PeakDet) for (n=bip; n>=bi; n--) {lam[n]=Low[bip];}
         hLast=High[i];
         si=High[i];
         aip=ai; 
         ai=i;
         tai=Time[i];
         taip=Time[i];
         fsp=fs;
        }

      if (fs==2 && fsp==1) // ����� �������� � ����������� �� ����������
        {
         zz[ai]=High[ai];
         zzH[ai]=High[ai];
         if (PeakDet) for (n=aip; n>=ai; n--) {ham[n]=High[aip];}
         lLast=Low[i];
         si=Low[i];
         bip=bi; 
         bi=i;
         tbi=Time[i];
         tbip=Time[i];
         fsp=fs;
        }

//===================================================================================================
      // ������� ���. ������ ������� ���� ZigZag-a

      if (i==0) 
        {
         ai0=iBarShift(Symbol(),Period(),tai); 
         bi0=iBarShift(Symbol(),Period(),tbi);
         aip0=iBarShift(Symbol(),Period(),taip); 
         bip0=iBarShift(Symbol(),Period(),tbip);

         if (fs==1) { for (n=bi0-1; n>ai0; n--) {zzH[n]=0; zz[n]=0;} zz[ai0]=High[ai0]; zzH[ai0]=High[ai0]; zzL[ai0]=0;}         
         if (fs==2) {for (n=ai0-1; n>bi0; n--) {zzL[n]=0; zz[n]=0;} zz[bi0]=Low[bi0]; zzL[bi0]=Low[bi0]; zzH[bi0]=0;}

         if (PeakDet)
           {
            if (fs==1) {for (n=aip0; n>=0; n--) {ham[n]=High[aip0];} for (n=bi0; n>=0; n--) {lam[n]=Low[bi0];} }
            if (fs==2) {for (n=bip0; n>=0; n--) {lam[n]=Low[bip0];} for (n=ai0; n>=0; n--) {ham[n]=High[ai0];} } 
           }
//-------------------------------------------------------------
        }

//====================================================================================================
     }
//--------------------------------------------
  return(0);
 }
//--------------------------------------------------------
// ��������� �������� ����������� � Ensign. �����. 
//--------------------------------------------------------

