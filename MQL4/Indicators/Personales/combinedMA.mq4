//+------------------------------------------------------------------+
//|                                                    SinoSidal.mq4 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

//ArbitrageCalculator
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Yellow
#property indicator_color4 Purple

#property indicator_level1 0
#property indicator_levelcolor LimeGreen
#property indicator_levelstyle STYLE_DASHDOTDOT



extern int ArbRing=0;
extern int MAPeriod=15;




string ArbitrageRings[12][3];

double Will1Buffer[];
double Will2Buffer[];
double Will3Buffer[];
double Will4Buffer[];

int windex;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
         //SetIndexDrawBegin(Bars,0);
         SetIndexBuffer(0,Will1Buffer);
         SetIndexStyle(0,DRAW_LINE);
         //SetIndexShift(0,100);
         
         //SetIndexDrawBegin(Bars,0);
         SetIndexBuffer(1,Will2Buffer);
         SetIndexStyle(1,DRAW_LINE);
         //SetIndexShift(1,100);
         
         //SetIndexDrawBegin(2,100);
         SetIndexBuffer(2,Will3Buffer);
         SetIndexStyle(2,DRAW_LINE);
         //SetIndexShift(2,100);
         
          SetIndexBuffer(3,Will4Buffer);
         SetIndexStyle(3,DRAW_LINE);
         
         
        
         
        
      //{"EURJPY","EURUSD","USDJPY"};
         ArbitrageRings[0][0]="EURJPY";
         ArbitrageRings[0][1]="EURUSD";
         ArbitrageRings[0][2]="USDJPY";
         // 2. GBPJPY,GBPUSD,USDJPY
         ArbitrageRings[1][0]="GBPJPY";
         ArbitrageRings[1][1]="GBPUSD";
         ArbitrageRings[1][2]="USDJPY";
         // 3. EURUSD,EURGBP,GBPUSD
         ArbitrageRings[2][0]="EURUSD";
         ArbitrageRings[2][1]="EURGBP";
         ArbitrageRings[2][2]="GBPUSD";
         // 4. EURUSD,AUSUSD, EURAUD
         ArbitrageRings[3][0]="EURUSD";
         ArbitrageRings[3][1]="AUDUSD";
         ArbitrageRings[3][2]="EURAUD";
         
         // 5. GBPCHF,GBPUSD,USDCHF
         ArbitrageRings[4][0]="GBPCHF";
         ArbitrageRings[4][1]="GBPUSD";
         ArbitrageRings[4][2]="USDCHF";
         // 6. GBPUSD,GBPAUD,AUDUSD
         ArbitrageRings[5][0]="GBPUSD";
         ArbitrageRings[5][1]="GBPAUD";
         ArbitrageRings[5][2]="AUDUSD";
         // 7. EURJPY,CADJPY,EURCAD
         ArbitrageRings[6][0]="EURJPY";
         ArbitrageRings[6][1]="CADJPY";
         ArbitrageRings[6][2]="EURCAD";
         // 8.GBPJPY, GBPCHF,CHFJPY
         ArbitrageRings[7][0]="GBPJPY";
         ArbitrageRings[7][1]="GBPCHF";
         ArbitrageRings[7][2]="CHFJPY";
         // 9.EURJPY, EURCHF,CHFJPY
         ArbitrageRings[8][0]="EURJPY";
         ArbitrageRings[8][1]="EURCHF";
         ArbitrageRings[8][2]="CHFJPY";
         // 10.USDJPY, USDCHF,CHFJPY
         ArbitrageRings[9][0]="USDJPY";
         ArbitrageRings[9][1]="USDCHF";
         ArbitrageRings[9][2]="CHFJPY";
         
         
         int j=0;
         while (Symbol()!=ArbitrageRings[j][0])
         {
            j++;
            if(j>12)
            {
               break;
            }
         }
          ArbRing=j;
         
         
         string shortName="CombinedMAs"+IntegerToString(ArbRing)+" : "+ArbitrageRings[ArbRing][0]+" : "+ArbitrageRings[ArbRing][1]+ " : "+ArbitrageRings[ArbRing][2];
         IndicatorShortName(shortName);
         windex=WindowFind(shortName);
         ObjectCreate("ARJ-MAs-"+"IndActiveRing", OBJ_LABEL, 0, 0, 0);
         
         ObjectSet("ARJ-MAs-"+"IndActiveRing", OBJPROP_CORNER, 3);
         ObjectSet("ARJ-MAs-"+"IndActiveRing", OBJPROP_XDISTANCE, 10);
         ObjectSet("ARJ-MAs-"+"IndActiveRing", OBJPROP_YDISTANCE, 10);
          ObjectSetText("ARJ-MAs-"+"IndActiveRing","IARing:"+IntegerToString(ArbRing)+" : "+ArbitrageRings[ArbRing][0]+" : "+ArbitrageRings[ArbRing][1]+ " : "+ArbitrageRings[ArbRing][2], 7, "Courier", Yellow);      
        
            ObjectDelete("ARJ-MAs-ArbVal");
            ObjectCreate(ChartID(),"ARJ-MAs-ArbVal", OBJ_LABEL, windex, 0, 0);
            ObjectDelete("ARJ-MAs-ArbUp");
            ObjectCreate(ChartID(),"ARJ-MAs-ArbUp", OBJ_LABEL, windex, 0, 0);
            ObjectDelete("ARJ-MAs-ArbDn");
            ObjectCreate(ChartID(),"ARJ-MAs-ArbDn", OBJ_LABEL, windex, 0, 0);
            
            /*
            ObjectCreate(ChartID(),"AskLine",OBJ_HLINE,windex,0,0);
            ObjectSet("AskLine",OBJPROP_COLOR,Red);
            
            ObjectCreate(ChartID(),"BidLine",OBJ_HLINE,windex,0,0);
            ObjectSet("BidLine",OBJPROP_COLOR,Blue);
            */
            
        
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int limit=0;
   
   
      if(counted_bars > 0)
      {  
            counted_bars--;
      }
      
      limit=Bars-counted_bars;
   
//----
         double arbhigh=0;
         double arblow=0;
         for(int i=limit; i>=0; i--)
         {
           double divA= iClose(ArbitrageRings[ArbRing][0],Period(),i)-iMA(ArbitrageRings[ArbRing][0],Period(),MAPeriod,0,MODE_SMA,PRICE_CLOSE,i);
           double divB= iClose(ArbitrageRings[ArbRing][1],Period(),i)-iMA(ArbitrageRings[ArbRing][1],Period(),MAPeriod,0,MODE_SMA,PRICE_CLOSE,i);              
           double divc= iClose(ArbitrageRings[ArbRing][2],Period(),i)-iMA(ArbitrageRings[ArbRing][2],Period(),MAPeriod,0,MODE_SMA,PRICE_CLOSE,i);   
           
            Will1Buffer[i]=divA;
            Will2Buffer[i] =divB;
            Will3Buffer[i]=divc;
           // Will3Buffer[i] =iMAOnArray(Will1Buffer,0,7,0,MODE_SMA,i);
            
            
         }
            
           
            
            ObjectSet("ARJ-MAs-ArbVal", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
            ObjectSet("ARJ-MAs-ArbVal", OBJPROP_XDISTANCE, 5);
            ObjectSet("ARJ-MAs-ArbVal", OBJPROP_YDISTANCE, 10);
           // ObjectCreate(ChartID(),"ARJ-MAs-CurrInd",OBJ_TEXT,windowIndex,iTime(ArbitrageRings[ArbRing][2],Period(),0),0);
            ObjectSetText("ARJ-MAs-ArbVal",ArbitrageRings[ArbRing][0]+"MA-Div="+DoubleToString(Will1Buffer[0],4) , 7, "TimesNewRoman",Green);
             
             
             
            
            ObjectSet("ARJ-MAs-ArbUp", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
            ObjectSet("ARJ-MAs-ArbUp", OBJPROP_XDISTANCE, 5);
            ObjectSet("ARJ-MAs-ArbUp", OBJPROP_YDISTANCE, 20); 
            //ObjectCreate(ChartID(),"ARJ-MAs-CurrInd2",OBJ_TEXT,windowIndex,iTime(ArbitrageRings[ArbRing][2],Period(),0),0);
            ObjectSetText("ARJ-MAs-ArbUp",ArbitrageRings[ArbRing][1]+"MA-Div="+DoubleToString(Will2Buffer[0],4) , 7, "TimesNewRoman",Red);
            
            
            ObjectSet("ARJ-MAs-ArbDn", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
            ObjectSet("ARJ-MAs-ArbDn", OBJPROP_XDISTANCE, 5);
            ObjectSet("ARJ-MAs-ArbDn", OBJPROP_YDISTANCE, 30);
            //ObjectCreate(ChartID(),"ARJ-MAs-CurrInd3",OBJ_TEXT,windowIndex,iTime(ArbitrageRings[ArbRing][2],Period(),0),0);
            ObjectSetText("ARJ-MAs-ArbDn",ArbitrageRings[ArbRing][2]+"MA-Div="+DoubleToString(Will3Buffer[0],4) , 7, "TimesNewRoman",Yellow);
         
        
       
//----
   return(0);
  }
  
  
//+------------------------------------------------------------------+