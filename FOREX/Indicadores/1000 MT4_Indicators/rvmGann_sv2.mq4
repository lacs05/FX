//+------------------------------------------------------------------+
//|                                                  rvmGann_sv2.mq4 |
//|                      Copyright � 2005, MetaQuotes Software Corp. |
//|                                      rvm_fam �� fromru ����� ��� |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2005, MetaQuotes Software Corp."
#property link      "rvm_fam �� fromru ����� ���"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 DodgerBlue
//---- input parameters
extern int       GSv_tend=2;
//---- buffers
double GSv_sl[];
double GSv_Up[];
bool initfl,draw_up,draw_dn;
bool curH,curL;
int sH,sL,lb,lhi,lli,fpoint,spoint;
int idFile;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_SECTION,STYLE_DOT);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID);
   SetIndexBuffer(0,GSv_sl);
   SetIndexBuffer(1,GSv_Up);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexLabel(0,"Dawn trend");
   SetIndexLabel(1,"Up trend");

   //FileDelete("GSv.txt");
   //idFile=FileOpen("GSv.txt",FILE_WRITE);
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
   int cb,ai,i,limit,index;
//---- 
   if( initfl!=1 )
   {
      myInit();
      if( initfl!=1 )
      {
         Alert("���� ������������� ����������!");
         return(-1);
      }
   }
   index=Bars-1;
   if( counted_bars>=0 )
   {
      if( index-counted_bars<=0 )
      {
         limit=0;
      }
      else
      {
         limit=index-counted_bars;
         if( limit>index-GSv_tend )
         {
            limit=index-GSv_tend;
         }
      }
   }
   else
   {
      Alert("���� ������� ����������!");
      return(-1);
   }
//FileWrite(idFile,"  Bars="+Bars+" index="+index+" limit="+limit+" counted_bars="+counted_bars);
//-------------------->> ������ ����� �� ����� -------------------------------
for( cb=limit;cb>=0;cb-- )
{
   ai=index-cb;
//-------------------->> �������� ����������� ���� �������� ����� ��� --------
if( lb!=ai )
{
   //FileWrite(idFile,"**����� ���, ai="+ai+" "+TimeToStr(Time[cb]));
   lb=ai;
   //���� ���������� ��� ���������� - �������� ��������
   if( High[cb+1]<=High[cb+2] && Low[cb+1]>=Low[cb+2] )
   {
      sH=0;
      sL=0;
      //FileWrite(idFile,"  ���������� ��� ����������, �������� �������� "+sH+"  "+sL);
   }
   else
   {
      //���� ���������� ������ ��������
      if( High[cb+1]>High[cb+2] && Low[cb+1]>=Low[cb+2] )
      {
         sL=0;
         //FileWrite(idFile,"  ����������-������ ��������, ������� ��������� ������� "+sL);
      }
      else
      {
         //���� ���������� ������ �������
         if( High[cb+1]<=High[cb+2] && Low[cb+1]<Low[cb+2] )
         {
            sH=0;
            //FileWrite(idFile,"  ����������-������ �������, ������� ���������� ������� "+sH);
         }
      }
   }
   //���� ��������� ��������� �����
   if( draw_up==1 )
   {
      //FileWrite(idFile,"  ��������� ��������� �����");
      //���� ������� ��������� ������ ������� ��������
      if( sL==GSv_tend )
      {
         //FileWrite(idFile,"  ������� ��������� ������ ������� ��������");
         // � ��������� ������� ��� ������� ���������� �� ����� ������� ��������
         if( curL==1 || sH!=GSv_tend )
         {
            draw_up=0;
            draw_dn=1;
            fpoint=spoint;
            spoint=ai-1;
            //FileWrite(idFile,"  ��������� ��� �������, draw_up="+draw_up+" draw_dn="+draw_dn+" fpoint="+fpoint+" spoint="+spoint+" ��� ������� ���������� �� ����� ������� ��������");
         }
      }
      else
      {
         //����� ���� ������� ��������� �� ������ ������� ��������
         //���� �� ���������� ������ ��� �������� � �� ���� ����������� �������������
         if( High[cb+1]>High[cb+2] && High[cb+1]>High[index-spoint] )
         {
            spoint=ai-1;
            //FileWrite(idFile,"  �������� �� ����.������ ���� ����������� �������������, ������ spoint="+spoint);
         }
      }
   }
   else
   {
      //����� ���� ��������� ��������� ����
      if( draw_dn==1 )
      {
         //FileWrite(idFile,"  ��������� ��������� ����");
         //���� ������� ���������� ������ ������� ��������
         if( sH==GSv_tend )
         {
            //FileWrite(idFile,"  ������� ���������� ������ ������� ��������");
            //� ��������� - �������� ��� ������� ��������� �� ����� ������� ��������
            if( curH==1 || sL!=GSv_tend )
            {
               draw_up=1;
               draw_dn=0;
               fpoint=spoint;
               spoint=ai-1;
               //FileWrite(idFile,"  ��������� ��� ��������, draw_up="+draw_up+" draw_dn="+draw_dn+" fpoint="+fpoint+" spoint="+spoint+" ��� ������� ��������� �� ����� ������� ��������");
            }
         }
         else
         {
            //����� ���� ������� ���������� �� ������ ������� ��������
            //���� �� ���������� ������ ��� ������� � �� ���� ����������� �������������
            if( Low[cb+1]<Low[cb+2] && Low[cb+1]<Low[index-spoint] )
            {
               spoint=ai-1;
               //FileWrite(idFile,"  ������� �� ����.������ ���� ����������� �������������, ������ spoint="+spoint);
            }
         }
      }
   }
   //FileWrite(idFile,"  ����� �����, �������� ������� ���������, ��������");
   curH=0;
   curL=0;
}
//--------------------<< ����� �������� ����������� ���� �������� ����� ��� --
//���� ������� ��� "����������" ��������� � ���������� �����
if( High[cb]<=High[cb+1] && Low[cb]>=Low[cb+1] )
{
   //FileWrite(idFile,"  ��� ����������, ��������� � ��������� �����");
   continue;
}
//-------------------->> ��������� �������� ��������� ���� -------------------
//���� ��� �������
if( cb!=0 || counted_bars==0 )
{
   //FileWrite(idFile,"  �� �������...");
   if( High[cb]>High[cb+1] )
   {
      if( sH<GSv_tend ) sH++;
      curH=1;
      //FileWrite(idFile,"  ������� ���������� ��������, ��������� �������� "+sH);
   }
   if( Low[cb]<Low[cb+1] )
   {
      if( sH<GSv_tend ) sL++;
      curL=1;
      //FileWrite(idFile,"  ������� ��������� ��������, ��������� ������� "+sL);
   }
   if( curH==curL && curH==1 )
   {
      if( Close[cb]>=(High[cb]+Low[cb])/2 )
      {
         curL=0;
         //FileWrite(idFile,"  ������� ���, ���������, ��������� ��������");
      }
      else
      {
         curH=0;
         //FileWrite(idFile,"  ������� ���, ���������, ��������� �������");
      }
   }
}
else
{
   //FileWrite(idFile,"  ����-����...");
   if( Close[cb]==High[cb] )
   {
      if( sH<GSv_tend && lhi!=ai )
      {
         lhi=ai;
         sH++;
      }
      curH=1;
      curL=0;
      //FileWrite(idFile,"  ��������� ��������");
   }
   else
   {
      if( Close[cb]==Low[cb] )
      {
         if( sL<GSv_tend && lli!=ai )
         {
            lli=ai;
            sL++;
         }
         curH=0;
         curL=1;
         //FileWrite(idFile,"  ��������� �������");
      }
   }
}
//--------------------<< ����� ��������� �������� ��������� ���� -------------
//FileWrite(idFile,"  ��������� ����������...");
//���� ��������� ��� ��������
if( draw_up!=draw_dn )
{
   //FileWrite(idFile,"  ��������� ��� �������� "+draw_up+"  "+draw_dn);
   //���� ��������� �������������� �����
   if( draw_dn!=1 )
   {
      //���� ������� ��������� ������ ������� �������� � ��������� ������� ��� ������� ���������� �� ����� ������� ��������
      if( (sL==GSv_tend && curL==1) || (sL==GSv_tend && sH!=GSv_tend) )
      {
         //FileWrite(idFile,"  ������� ��������� ������ ������� �������� � ��������� ������� ��� ������� ���������� �� ����� ������� ��������");
         GSv_sl[cb]=Low[cb];
      }
      else
      {
         //���� ��������� �������� ���� ���������� �������������
         if( High[cb]>High[index-spoint] )
         {
            GSv_sl[cb]=High[cb];
            for( i=cb+1;i<index-fpoint;i++ )
            {
               GSv_sl[i]=0;
            }
         }
      }
   }
   else
   {
      //����� ���� �������������� ����
      //���� ������� ���������� ������ ������� �������� � �������� ��������� ��� ������� ��������� �� ����� ������� ��������
      if( (sH==GSv_tend && curH==1) || (sH==GSv_tend && sL!=GSv_tend) )
      {
         //FileWrite(idFile,"  ������� ���������� ������ ������� �������� � ��������� �������� ��� ������� ��������� �� ����� ������� ��������");
         GSv_sl[cb]=High[cb];
      }
      else
      {
         //���� ��������� ������� ���� ���������� �������������
         if( Low[cb]<Low[index-spoint] )
         {
            GSv_sl[cb]=Low[cb];
            for( i=cb+1;i<index-fpoint;i++ )
            {
               GSv_sl[i]=0;
            }
         }
      }
   }
}
else
{
   //FileWrite(idFile,"  ��������� ���� �� ������������� "+draw_up+"  "+draw_dn);
   //����� ���� ��������� ��� �� ��������
   //���� ������� ���������� ������ ������� ��������
   if( sH==GSv_tend )
   {
      //FileWrite(idFile,"  ������� ���������� ������ ������� ��������");
      if( sL!=GSv_tend || curH==1 )
      {
         //FileWrite(idFile,"  ��������� �������� ��� ������� ��������� ������ �������");
         GSv_sl[index-fpoint]=Low[index-fpoint];
         GSv_sl[cb]=High[cb];
         draw_up=1;
         draw_dn=0;
         //FileWrite(idFile,"  ��������� ����� "+fpoint+" "+GSv_sl[index-fpoint]+" �������� ����� "+ai+" "+GSv_sl[cb]);
      }
   }
   //���� ������� ��������� ������ ������� ��������
   if( sL==GSv_tend )
   {
      //FileWrite(idFile,"  ������� ��������� ������ ������� ��������");
      if( sH!=GSv_tend || curL==1 )
      {
         //FileWrite(idFile,"  ��������� ������� ��� ������� ���������� ������ �������");
         GSv_sl[index-fpoint]=High[index-fpoint];
         GSv_sl[cb]=Low[cb];
         draw_up=0;
         draw_dn=1;
         //FileWrite(idFile,"  ��������� ����� "+fpoint+" "+GSv_sl[index-fpoint]+" �������� ����� "+ai+" "+GSv_sl[cb]);
      }
   }
}
//--------------------<< ����� ����� �� ����� --------------------------------
}
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   //FileClose(idFile);
//----
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ������� ��������� ������������� ����������                       |
//+------------------------------------------------------------------+
int myInit()
  {
//---- 
   //���� ������������ ������
   if( Bars<GSv_tend+1 )
   {
      Alert("������������ ������ �� �������!");
      return(-1);
   }
   if( GSv_tend<1 )
   {
      Alert("�������� �������� ����������!");
      return(-1);
   }
   if( High[Bars-2]>High[Bars-1] ) sH++;
   if( Low[Bars-2]<Low[Bars-1] ) sL++;
   initfl=1;
   //FileWrite(idFile,TimeToStr(CurTime())+" ��������� ���������������");
   //FileWrite(idFile,"  ����� �� ������� = "+Bars+", ����� ������� ���� = "+TimeToStr(Time[Bars-1]));
   //FileWrite(idFile,"  ������� ���������� = "+sH+", ������� ��������� = "+sL);
//----
   return(0);
  }
//+------------------------------------------------------------------+


