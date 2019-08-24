//+------------------------------------------------------------------+
//|                                                  wlxFractals.mq4 |
//|         Copyright � 2004, by konKop, GOODMAN, Mstera, af + wellx |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2004, by wellx"
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Red
//---- input parameters
extern int       Equals=5;
extern int       nLeftUp=2;
extern int       nRightUp=2;
extern int       nLeftDown=2;
extern int       nRightDown=2;
//---- buffers
double FractalsUp[];
double FractalsDown[];

int pos=0, cntup=0, cntdown=0, cnt=0;
int r=0,l=0,e=0;
int fup=0,fdown=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,217);
   SetIndexBuffer(0,FractalsUp);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,218);
   SetIndexBuffer(1,FractalsDown);
   SetIndexEmptyValue(1,0.0);
   
   cntup=nLeftUp+nRightUp+Equals+1;
   cntdown=nLeftDown+Equals+1;
   if (cntup>=cntdown) cnt=cntup;
   if (cntup<cntdown)  cnt=cntdown; 
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
   int i=0, j=0;
   int cbars=IndicatorCounted();
   if  (cbars<0) return(-1);
   if  (cbars>0) cbars--;
   
   pos=0;
    
   if (cbars > (Bars-cnt-1)) pos=(Bars-cnt-1);
   else pos=cbars+nRightUp;
      
   while (pos>=nRightUp)
    {
     FractalsUp[pos]  =NULL;
     FractalsDown[pos]=NULL;
     
     //������� �����
     r=nRightUp; //��������� ������ ������� ��������
     for (i=1;i<=r;i++)
     {
      if (High[pos]<=High[pos-i]) break;
     }
     
     //���� ������ ��� �� �� i ������ ���� ����� r+1
     if (i==r+1) //FractalsUp[pos]=High[pos];
     {
      l=nLeftUp;  //��������� ����� ������� ��������
      e=Equals;
      for (j=1;j<=l+Equals;j++)
       {
      
        if (High[pos] < High[pos+j]) break;
        if (High[pos] > High[pos+j]) l--;
        if (High[pos] == High[pos+j])e--;
        if (l==0) 
         {
           FractalsUp[pos]=High[pos];
           break;
         }
        if (e<0) break;
       }
     }
     
     //������� ����
     r=nRightDown; //��������� ������ ������� ��������
     for (i=1;i<=r;i++)
     {
      if (Low[pos]>=Low[pos-i]) break;
     }  
   
     if (i==r+1) //FractalsUp[pos]=High[pos];
     {
      l=nLeftDown;  //��������� ����� ������� ��������
      e=Equals;
      for (j=1;j<=l+Equals;j++)
       {
      
        if (Low[pos] > Low[pos+j]) break;
        if (Low[pos] < Low[pos+j]) l--;
        if (Low[pos] == Low[pos+j])e--;
        if (l==0) 
         {
           FractalsDown[pos]=Low[pos];
           break;
         }
        if (e<0) break;
       }
     }
    pos--;
    }
//----
   return(0);
  }
//+------------------------------------------------------------------+