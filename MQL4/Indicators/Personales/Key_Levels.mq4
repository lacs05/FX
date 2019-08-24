
#property indicator_chart_window

extern string H                     = " --- Mode_Settings ---";
extern bool   Show_00_50_Levels     = true;
extern bool   Show_20_80_Levels     = true;
extern color  Level_00_Color        = Lime;
extern color  Level_50_Color        = Gray;
extern color  Level_20_Color        = Red;
extern color  Level_80_Color        = Green;

double dXPoint = 1;
double Div = 0;
double i = 0;
double HighPrice = 0;
double LowPrice = 0;
int iDigits;
  
int start() 
{
   HighPrice = MathRound((High[iHighest(NULL, 0, MODE_HIGH, Bars + 300, 2)]+1) * Div);
   LowPrice = MathRound((Low[iLowest(NULL, 0, MODE_LOW, Bars + 300, 2)]-1) * Div);
  
  if(Show_00_50_Levels)
  {
   for (i = LowPrice; i <= HighPrice; i++) 
   {
      if (MathMod(i, 5) == 0.0) {
         if (ObjectFind("RoundPrice " + DoubleToStr(i, 0)) != 0) {
            ObjectCreate("RoundPrice " + DoubleToStr(i, 0), OBJ_HLINE, 0, Time[1], i / Div);
            ObjectSet("RoundPrice " + DoubleToStr(i, 0), OBJPROP_STYLE, STYLE_DOT);
            if(MathMod(i, 10) == 0.0)
            {
            ObjectSet("RoundPrice " + DoubleToStr(i, 0), OBJPROP_COLOR, Level_00_Color);
            }
            else
            {
            ObjectSet("RoundPrice " + DoubleToStr(i, 0), OBJPROP_COLOR, Level_50_Color);
            }
         }
      }
   }
   
  }
  
  if(Show_20_80_Levels)
  {
  
   for (i = LowPrice; i <= HighPrice; i++) 
   {
         
        if (StringSubstr(DoubleToStr(i/Div,iDigits), StringLen(DoubleToStr(i/Div,iDigits))-2, 2)=="20") {
         if (ObjectFind("RoundPrice " + DoubleToStr(i, 0)) != 0) {
            ObjectCreate("RoundPrice " + DoubleToStr(i, 0), OBJ_HLINE, 0, Time[1], i / Div);
            ObjectSet("RoundPrice " + DoubleToStr(i, 0), OBJPROP_STYLE, STYLE_DOT); 
            ObjectSet("RoundPrice " + DoubleToStr(i, 0), OBJPROP_COLOR, Level_20_Color);
            
            }
         }
        
         
         if (StringSubstr(DoubleToStr(i/Div,iDigits), StringLen(DoubleToStr(i/Div,iDigits))-2, 2)=="80") {
         if (ObjectFind("RoundPrice " + DoubleToStr(i, 0)) != 0) {
            ObjectCreate("RoundPrice " + DoubleToStr(i, 0), OBJ_HLINE, 0, Time[1], i / Div);
            ObjectSet("RoundPrice " + DoubleToStr(i, 0), OBJPROP_STYLE, STYLE_DOT);
           
            ObjectSet("RoundPrice " + DoubleToStr(i, 0), OBJPROP_COLOR, Level_80_Color);
            }
         }
         
   }
   
  }
  
   return (0);
}

int init() 
{
   iDigits = Digits;
   if(Digits==5 || Digits==3)dXPoint=10;
   if(Digits==3)  iDigits=2;
   if(Digits==5)  iDigits=4;
   
   Div = 0.1 / (Point*dXPoint);
   return (0);
}

int deinit()
{
   HighPrice = MathRound((High[iHighest(NULL, 0, MODE_HIGH, Bars + 300, 2)]+1) * Div);
   LowPrice = MathRound((Low[iLowest(NULL, 0, MODE_LOW, Bars + 300, 2)]-1) * Div);
   for (i = LowPrice; i <= HighPrice; i++) ObjectDelete("RoundPrice " + DoubleToStr(i, 0));
   return (0);
}