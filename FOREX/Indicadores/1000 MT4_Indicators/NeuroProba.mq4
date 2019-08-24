//+------------------------------------------------------------------+
//|                                                   NeuroProba.mq4 |
//|                      Copyright � 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Blue
#property indicator_color3 Red
//---- input parameters
extern int       BeginBar=300; // ��������� ��� � ��������� �������
extern int       EndBar=201; // �������� ��� � ��������� �������
extern int       StudyNumber=100; // ���������� ��������� ������
extern double    Betta=0.5; // �������� ������������� �������
extern double    StudyCoeff=0.1; // ����������� ��������
extern double    MaxRandom=0.66;//2.0/MathSqrt(9);
//---- buffers
double NeuroExitBuffer[]; // �������� �������� ���������
double TeacherBuffer[]; // ��������� �������� ��������� (��������� �������)
double ErrorBuffer[]; // ���������� �� ������ ����
//---- 
double deviation; // ���������� �� ������ ���� �������� 
double GradientFirstLay[9][9];// ��� ������� ��������� 1-�� ����
double GradientSecondLay[9]; //  ��� ������� ��������� 2-�� ����
double OutputFirstLay[9]; // ����� ������ ������� �������
double SecondSum;// ����� ��������� ���� - �������� ������������� �������
double FirstLayWeights[9][9]; // ���� �������� ������� (�������� ����)
double OutputSecondWeights[9]; // ���� ��������� �������
double InputNormalX[100][9]; // ��������������� ������� ������� ��������
double InputX[9]; // ������� ������� ������ (�����������������)
double Norm�;// ����� �������� �������� �������
double U_First[9];// �������� �� ������ ���� ������� (�������) ��������
double U_Second;//  �������� �� ������ ��������� ������� (�������� ������������� �������)
double SigmaCurr;
double Differ;
//+----------------------------------------------
//  ��������������� ��������� ������� �� ��������� (0,MaxValue), ���� �������� �������� - �� (0,1)
//+----------------------------------------------
double NormalRand(double MaxValue=1.0)
   {
   double answer;
   answer=MathRand()/32767.0;
   answer=MaxValue*answer;
   return(answer);
   }
//+----------------------------------------------
//  ��������������� ��������� �������
//+----------------------------------------------


//------------------------------------------
// ����������� ������������� �������  (������� ���������������)
//------------------------------------------
double Sigma(double argument)
   {
   double help;
   help=(MathExp(argument)-MathExp(-argument))/(MathExp(argument)+MathExp(-argument));
   return(help);
   }
//------------------------------------------
// ����������� ������������� �������
//------------------------------------------

//------------------------------------------
// ���������� ��������� ������������� �������
//------------------------------------------
double GetArgument()
   {
   int j;
   double answer=0.0;
   for (j=0;j<9;j++)
      {
      answer=answer+OutputSecondWeights[j]*OutputFirstLay[j];
      }
   return(answer);
   }
//------------------------------------------
// ���������� ��������� ������������� �������
//------------------------------------------

//------------------------------------------
// ���������� ������� �������� ������� ����
//------------------------------------------
void GetFirstLayOutput()
   {
   int j,t;
   for (j=0;j<9;j++)
      {
      OutputFirstLay[j]=0.0;      
      for (t=0;t<9;t++)
         {
         OutputFirstLay[j]=OutputFirstLay[j]+FirstLayWeights[j,t]*InputX[t];
         }
      }
   return(0);
   }
//------------------------------------------
// ���������� ������� �������� ������� ����
//------------------------------------------

//------------------------------------------
// ���������� ��������� ����� �������� 
//------------------------------------------
void SetGradientWeights()
   {
   int j,t;
   for (j=0;j<9;j++)
      {
      //GradientFirstLay[j,t]=0.0;
      for (t=0;t<9;t++)
         {
         GradientFirstLay[j,t]=OutputSecondWeights[j]*InputX[t]*deviation*Differ;
         //GradientFirstLay[j,t]=GradientFirstLay[j,t]+OutputSecondWeights[j]*InputX[t];
         }
      //GradientFirstLay[j,t]=GradientFirstLay[j,t]*deviation*Differ;
      GradientSecondLay[j]=OutputFirstLay[j]*deviation*Differ;
      }
   }
//------------------------------------------
// ���������� ��������� ����� �������� 
//------------------------------------------

//------------------------------------------
// ��������� ����� �������� 
//------------------------------------------
void ChangeWeigts()
   {
   int i,k;
   for (i=0;i<9;i++)
      {
      for (k=0;k<9;k++)
         {
         FirstLayWeights[i,k]=FirstLayWeights[i,k]-StudyCoeff*GradientFirstLay[i,k];
         }
      OutputSecondWeights [i]=OutputSecondWeights [i]-StudyCoeff*GradientSecondLay[i];// ��������� ����� ��������� �������
      } 
   }
//------------------------------------------
// ��������� ����� ��������
//------------------------------------------

//------------------------------------------
// ����� � ������ ����� ��������
//------------------------------------------
void PrintWeights()
   {
   int i,k;
   for (i=0;i<9;i++)
      {
      for (k=0;k<9;k++)   
         {
//         Print("W1["+i+","+k+"]=",FirstLayWeights[i,k]);
         }
//      Print("W2["+i+"]=",OutputSecondWeights[i]);
      }
   }
//------------------------------------------
// ����� � ������ ����� ��������
//------------------------------------------

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,NeuroExitBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,TeacherBuffer);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ErrorBuffer);
   SetIndexLabel(0,"Answer");
   SetIndexLabel(1,"Teacher");
   SetIndexLabel(2,"Error");
   ArrayInitialize(NeuroExitBuffer,0.0);      
   ArrayInitialize(TeacherBuffer,0.0);      
   ArrayInitialize(ErrorBuffer,0.0); 
//------------------------------------------
// ���������� ������� ������� ��������
//------------------------------------------
   int i,k,m,n,p; // m - ������ ����� ��������� �������, p - ������� ����� ��������
   for (i=BeginBar;i>=EndBar;i--)
      {
      Norm�=0.0;
      for (k=0;k<=8;k++)
         {InputX[k]=Close[i]-Close[i+k+1];
         Norm�=Norm�+InputX[k]*InputX[k];
         }
      Norm�=MathSqrt(Norm�);   
      for (k=0;k<=8;k++)
         {      
         InputNormalX[BeginBar-i,k]=InputX[k]/Norm�;
         TeacherBuffer[BeginBar-i]=0.0;
         if (iCustom(NULL,0,"Kaufman2",1,i)>0) TeacherBuffer[BeginBar-i]=1;
         if (iCustom(NULL,0,"Kaufman2",2,i)>0) TeacherBuffer[BeginBar-i]=-1;
      //TeacherBuffer[BeginBar-i]=iCustom(NULL,0,"KaufmanTrend",0,BeginBar);      
         }
       }
//------------------------------------------
// ���������� ������� ������� ��������
//------------------------------------------
   MathSrand(LocalTime());
//------------------------------------------
// ���������� ����� �������� ���������� ����������
//------------------------------------------
   for (i=0;i<9;i++)
      {
      for (k=0;k<9;k++)
         {
         FirstLayWeights[i,k]=NormalRand(MaxRandom);
//         Print("FirstLayWeights["+i+","+k+"]=",FirstLayWeights[i,k]);
         }
      OutputSecondWeights[i]=NormalRand(MaxRandom);
      }
//------------------------------------------
// ���������� ����� �������� ���������� ����������
//------------------------------------------
   PrintWeights();
//   Print("Sigma=",Sigma(NormalRand()));
   Print("������������� ���������");

//------------------------------------------
// ��������
//------------------------------------------
for (p=1;p<=StudyNumber;p++) // ���� �������� - p-����� ��������
   {
   for (n=0;n<100;n++) // ������ �� ������� ������� �������� -  n-����� ���������� �������
      {
      for (int z=0;z<9;z++) InputX[z]=InputNormalX[n,z]; // �������� ������� ������ �� ������� �������������� ��������������� ��������
      GetFirstLayOutput();
      U_Second=GetArgument();
      Print("p=",p," n=",n," U_Second=",U_Second);
      PrintWeights();
      SigmaCurr=Sigma(Betta*U_Second);
      Differ=Betta*(1-SigmaCurr*SigmaCurr); // ����������� �� �������� ����������������
      deviation=TeacherBuffer[BeginBar-n]-SigmaCurr; //������ ��������, ������ ���� ����������������� ����
      SetGradientWeights();
      ChangeWeigts();
      }// ������ �� ������� ������� ��������   
   }// ���� ��������
//------------------------------------------
// ��������
//------------------------------------------
   PrintWeights();
   Comment("�������� ���������");

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i,m;
   int counted_bars=IndicatorCounted();
   if (counted_bars<0) return(-1);
   int limit;
   //limit=Bars-10-counted_bars;
   limit=300;
   for (i=limit;i>=0;i--) 
      {
      if (iCustom(NULL,0,"Kaufman2",1,i)>0) TeacherBuffer[i]=1;
      if (iCustom(NULL,0,"Kaufman2",2,i)>0) TeacherBuffer[i]=-1;
      Norm�=0.0;
      for (m=0;m<9;m++)
         {
         InputX[m]=Close[i]-Close[i+m+1];
         Norm�=Norm�+InputX[m]*InputX[m];
         }
      Norm�=MathSqrt(Norm�);
      Print("Norm�=",Norm�);
      for (m=0;m<9;m++)
         {
         InputX[m]=InputX[m]/Norm�;
         }
      GetFirstLayOutput();
      U_Second=GetArgument();
      Print("U_Second=",U_Second);
      NeuroExitBuffer[i]=Sigma(Betta*U_Second);
      //Print("NeuroExitBuffer["+i+"]=",NeuroExitBuffer[i]);
      ErrorBuffer[i]=TeacherBuffer[i]-NeuroExitBuffer[i];
      }
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+