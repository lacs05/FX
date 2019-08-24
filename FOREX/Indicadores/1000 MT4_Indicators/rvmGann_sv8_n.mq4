//+------------------------------------------------------------------+
//|                                                  rvmGann_sv8.mq4 |
//|                      Copyright � 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 DeepSkyBlue
#property indicator_color2 DeepSkyBlue
//#property indicator_color3 DeepSkyBlue
//#property indicator_color4 DeepSkyBlue
//#property indicator_color5 DeepSkyBlue
//#property indicator_color6 DeepSkyBlue
//#property indicator_color7 DeepSkyBlue
//#property indicator_color8 DeepSkyBlue
//---- input parameters
extern int GSv_tend=2;
//---- buffers
double Upz[];
double Dnz[];
double sH[];
double sL[];
double aH[];
double aL[];
double fB[];
double lB[];
//----------
double CurH,CurL;
int lb,sp,lbars;
bool draw_up,draw_dn;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_ZIGZAG,STYLE_SOLID);
   SetIndexStyle(1,DRAW_ZIGZAG,STYLE_SOLID);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexStyle(6,DRAW_NONE);
   SetIndexStyle(7,DRAW_NONE);
   SetIndexBuffer(0,Upz);
   SetIndexBuffer(1,Dnz);
   SetIndexBuffer(2,sH);
   SetIndexBuffer(3,sL);
   SetIndexBuffer(4,aH);
   SetIndexBuffer(5,aL);
   SetIndexBuffer(6,fB);
   SetIndexBuffer(7,lB);
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0);
   SetIndexEmptyValue(3,0);
   SetIndexEmptyValue(4,-1);
   SetIndexEmptyValue(5,-1);
   SetIndexEmptyValue(6,-1);
   SetIndexEmptyValue(7,-1);
   SetIndexLabel(0,"z1");
   SetIndexLabel(1,"z2");
   SetIndexLabel(2,"sH");
   SetIndexLabel(3,"sL");
   SetIndexLabel(4,"aH");
   SetIndexLabel(5,"aL");
   SetIndexLabel(6,"fB");
   SetIndexLabel(7,"lB");
//----
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   int cb,index,limit,ai,i;
//---- 
   if( !counted_bars<0 )
   {
      index=Bars-1;
      if( index-counted_bars<2 )
      {
         limit=0;
      }
      else
      {
         limit=index-counted_bars-1;
      }
   }
   else
   {
      Alert("���� ������� ���������� rvmGSv_mt");
      return(-1);
   }
//----
for( cb=limit; cb>=0; cb-- )
{
   ai=index-cb;
   if( lbars!=Bars && lb==ai )
   {
      lbars=Bars;
      continue;
   }
   if( lb!=ai )
   {
      lb=ai;
      if( Upz[cb+1]>0 || Dnz[cb+1]>0 )
      {
         aH[cb]=High[cb+1];
         aL[cb]=Low[cb+1];
      }
      else
      {
         if( High[cb+1]<=aH[cb+1] && Low[cb+1]>=aL[cb+1] )
         {
            aH[cb]=aH[cb+1];
            aL[cb]=aL[cb+1];
            sH[cb]=sH[cb+1];
            sL[cb]=sL[cb+1];
         }
         else
         {
            if( High[cb+1]>aH[cb+1] )
            {
               aH[cb]=High[cb+1];
            }
            else
            {
               aH[cb]=aH[cb+1];
            }
            if( aL[cb+1]>0 )
            {
               if( Low[cb+1]<aL[cb+1] )
               {
                  aL[cb]=Low[cb+1];
               }
               else
               {
                  aL[cb]=aL[cb+1];
               }
            }
            else
            {
               aL[cb]=Low[cb+1];
            }
         }
      }
      if( draw_up!=0 )
      {
         if( fB[cb+1]==1 )
         {
            sH[cb]=sH[cb+1]+1;
            if( lB[cb+1]==0 )
            {
               sH[cb]=0;
               sL[cb]=1;
            }
         }
         else
         {
            if( fB[cb+1]==0 )
            {
               sL[cb]=sL[cb+1]+1;
               if( lB[cb+1]==1 )
               {
                  sH[cb]=1;
                  sL[cb]=0;
               }
            }
         }
      }
      else
      {
         if( draw_dn!=0 )
         {
            if( fB[cb+1]==0 )
            {
               sL[cb]=sL[cb+1]+1;
               if( lB[cb+1]==1 )
               {
                  sH[cb]=1;
                  sL[cb]=0;
               }
            }
            else
            {
               if( fB[cb+1]==1 )
               {
                  sH[cb]=sH[cb+1]+1;
                  if( lB[cb+1]==0 )
                  {
                     sH[cb]=0;
                     sL[cb]=1;
                  }
               }
            }
         }
         else
         {
            if( fB[cb+1]==1 )
            {
               sH[cb]=sH[cb+1]+1;
               sL[cb]=sL[cb+1];
               if( lB[cb+1]==0 )
               {
                  sL[cb]++;
               }
            }
            else
            {
               if( fB[cb+1]==0 )
               {
                  sH[cb]=sH[cb+1];
                  sL[cb]=sL[cb+1]+1;
                  if( lB[cb+1]==1 )
                  {
                     sH[cb]++;
                  }
               }
            }
         }
      }
      if( GSv_tend>1 )
      {
         //���� �� ���������� ����� ���� ����������� ����� � ��� ������� �� ��������� � ���������� + ��������� �������
         if( sH[cb]==GSv_tend && Upz[cb+1]>0 && High[cb+1]>High[cb+2] && Low[cb+1]<Low[cb+2] && fB[cb+1]==1 )
         {
            sL[cb]=1;
         }
         else //����� ���� �� ���������� ����� ������� ���� ����������� �����
         {
            //���� �� ���������� ����� ���� ����������� ���� � ��� ������� �� ��������� � ���������� + ��������� ��������
            if( sL[cb]==GSv_tend && Dnz[cb+1]>0 && High[cb+1]>High[cb+2] && Low[cb+1]<Low[cb+2] && fB[cb+1]==0 )
            {
               sH[cb]=1;
            }
         }
      }
      //��������
      CurH=0;
      CurL=Low[cb];
   }
   if( High[cb]<=aH[cb] && Low[cb]>=aL[cb] )
   {
      continue;
   }
   if( High[cb]<=CurH && Low[cb]>=CurL )
   {
      continue;
   }
   if( High[cb]>CurH ) CurH=High[cb];
   if( Low[cb] <CurL ) CurL=Low[cb];
   Extr_seq(cb);
   //���� ����� ���� � ����� �������, �� ���� ������ ���-�������� ������� ��������, � ���� ������-���, �������� ������� ����������
   if( GSv_tend>1 )
   {
      if( fB[cb]>0 && sH[cb]==GSv_tend-1 && sL[cb]>0 )
      {
         sL[cb]=0;
      }
      else
      {
         if( fB[cb]>-1 && sL[cb]==GSv_tend-1 && sH[cb]>0 )
         {
            sH[cb]=0;
         }
      }
   }
   if( draw_up!=0 )
   {
      if( fB[cb]==1 )
      {
         if( sp!=ai )
         {
            Upz[index-sp]=0;
            sp=ai;
         }
         Upz[cb]=High[cb];
         if( lB[cb]==0 && (sL[cb]+1)>=GSv_tend && GSv_tend<2 )
         {
            Dnz[cb]=Low[cb];
            draw_up=0;
            draw_dn=1;
         }
      }
      else
      {
         if( fB[cb]==0 )
         {
            if( (sL[cb]+1)>=GSv_tend )
            {
               Dnz[cb]=Low[cb];
               sp=ai;
               draw_up=0;
               draw_dn=1;
               if( lB[cb]==1 && (sH[cb]+1)>=GSv_tend )
               {
                  Upz[cb]=High[cb];
                  draw_up=1;
                  draw_dn=0;
               }
            }
            else
            {
               if( lB[cb]==1 )
               {
                  Upz[index-sp]=0;
                  sp=ai;
                  Upz[cb]=High[cb];
               }
            }
         }
      }
   }
   else
   {
      if( draw_dn!=0 )
      {
         if( fB[cb]==1 )
         {
            if( (sH[cb]+1)>=GSv_tend )
            {
               Upz[cb]=High[cb];
               sp=ai;
               draw_up=1;
               draw_dn=0;
               if( lB[cb]==0 && (sL[cb]+1)>=GSv_tend )
               {
                  Dnz[cb]=Low[cb];
                  draw_up=0;
                  draw_dn=1;
               }
            }
            else
            {
               if( lB[cb]==0 )
               {
                  Dnz[index-sp]=0;
                  sp=ai;
                  Dnz[cb]=Low[cb];
               }
            }
         }
         else
         {
            if( fB[cb]==0 )
            {
               if( sp!=ai )
               {
                  Dnz[index-sp]=0;
                  sp=ai;
               }
               Dnz[cb]=Low[cb];
               if( lB[cb]==1 && (sH[cb]+1)>=GSv_tend && GSv_tend<2 )
               {
                  Upz[cb]=High[cb];
                  draw_up=1;
                  draw_dn=0;
               }
            }
         }
      }
      else
      {
         if( fB[cb]==1 && (sH[cb]+1)>=GSv_tend )
         {
            Dnz[index]=Low[index];
            Upz[cb]=High[cb];
            draw_up=1;
            sp=ai;
            if( lB[cb]==0 && (sL[cb]+1)>=GSv_tend )
            {
               Dnz[cb]=Low[cb];
               draw_up=0;
               draw_dn=1;
            }
         }
         else
         {
            if( fB[cb]==0 && (sL[cb]+1)>=GSv_tend )
            {
               Upz[index]=High[index];
               Dnz[cb]=Low[cb];
               draw_dn=1;
               sp=ai;
               if( lB[cb]==1 && (sH[cb]+1)>=GSv_tend )
               {
                  Upz[cb]=High[cb];
                  draw_up=1;
                  draw_dn=0;
               }
            }
         }
      }
   }
}
//----
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ������� ���������� ������������������ ��������� �����������      |
//+------------------------------------------------------------------+
void Extr_seq(int curb)
  {
//---- 
   if( fB[curb]<0 )
   {
      //���� ��� �������������� �� ������� � �� ����� �������
      if( High[curb]>aH[curb] && Low[curb]<aL[curb] )
      {
         //���� �������� �� ����� ���������
         if( Open[curb]>aH[curb] )
         {
            fB[curb]=1;
            lB[curb]=0;
         }
         else //����� ���� �������� �� ����� ���������
         {
            //���� �������� �� ����� ��������
            if( Open[curb]<aL[curb] )
            {
               fB[curb]=0;
               lB[curb]=1;
            }
            else
            {
               //���� �������� �� ����� ��������� � ��� ���� ��� ����� ��������
               if( Close[curb]>aH[curb] && Close[curb]>=Open[curb] )
               {
                  fB[curb]=0;
                  lB[curb]=1;
               }
               else //����� ���� �������� �� ����� ��������� � ��� ���� ��� ����� ��������
               {
                  //���� �������� �� ����� �������� � ���� ��� ����� ��������
                  if( Close[curb]>aL[curb] && Close[curb]<=Open[curb] )
                  {
                     fB[curb]=1;
                     lB[curb]=0;
                  }
                  else //����� ���� �������� �� ����� �������� � ���� ��� ����� ��������
                  {
                     //���� ���� ���� �����
                     if( Close[curb]>Open[curb] )
                     {
                        fB[curb]=0;
                        lB[curb]=1;
                     }
                     else //����� ���� ���� ���� �����
                     {
                        //���� ���� ���� �����
                        if( Close[curb]<Open[curb] )
                        {
                           fB[curb]=1;
                           lB[curb]=0;
                        }
                        else //����� ���� ���� ���� �����
                        {
                           //���� ���� ����� � ��������� ��������
                           if( MathAbs(Open[curb]-aL[curb])<MathAbs(Open[curb]-aH[curb]) )
                           {
                              fB[curb]=0;
                              lB[curb]=1;
                           }
                           else //����� ���� ���� ����� � ��������� ��������
                           {
                              //���� ���� ����� � ��������� ���������
                              if( MathAbs(Open[curb]-aL[curb])>MathAbs(Open[curb]-aH[curb]) )
                              {
                                 fB[curb]=1;
                                 lB[curb]=0;
                              }
                              else //����� ����� ���� ���� ����� � ��������� ���������
                              {
                                 //���� ���� ����� ��� ����������� �� ��������
                                 if( MathAbs(Open[curb]-Low[curb])>=MathAbs(Open[curb]-High[curb]) )
                                 {
                                    fB[curb]=0;
                                    lB[curb]=1;
                                 }
                                 else
                                 {
                                    fB[curb]=1;
                                    lB[curb]=0;
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      else
      {
         if( High[curb]>aH[curb] )
         {
            fB[curb]=1;
         }
         else
         {
            fB[curb]=0;
         }
      }
   }
   else
   {
      //���� ������� ���� ����� ��������� �� ���� ��� ��� �������� � ��� ���� ��������-�����
      if( (Low[curb]>=aL[curb] || Close[curb]==High[curb] ) && High[curb]>aH[curb] )
      {
         lB[curb]=1;
      }
      else //����� ���� ���� ����� ��������� �� ����
      {
         //���� ���� ����� �������� �� ���� ��� ��� ������ ��������� � ��� ���� ������� - �����
         if( (High[curb]<=aH[curb] || Close[curb]==Low[curb]) && Low[curb]<aL[curb] )
         {
            lB[curb]=0;
         }
      }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+

