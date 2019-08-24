//+------------------------------------------------------------------+
//| Digits_Comment.mq4 
//| Ramdass - Conversion only
//+------------------------------------------------------------------+
#property copyright "Copyright 2002, Finware.ru Ltd."
#property link "http://www.finware.ru/"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 SteelBlue
#property indicator_color3 DarkViolet
#property indicator_color4 Red

extern int CountBars=300;
//---- buffers
double FATLBuffer[];
double SATLBuffer[];
double RSTLBuffer[];
double RFTLBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,FATLBuffer);
   SetIndexLabel(0,"FATL");
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,SATLBuffer);
   SetIndexLabel(1,"SATL");
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,RSTLBuffer);
   SetIndexLabel(2,"RSTL");
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,RFTLBuffer);
   SetIndexLabel(3,"RFTL");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom                                                           |
//+------------------------------------------------------------------+
int start()
  {
   SetIndexDrawBegin(0,Bars-CountBars+38);
   SetIndexDrawBegin(1,Bars-CountBars+64);
   SetIndexDrawBegin(2,Bars-CountBars+98);
   SetIndexDrawBegin(3,Bars-CountBars+44);
   int i,counted_bars=IndicatorCounted();
//----
   if(Bars<=38) return(0);
//---- initial zero
   if(counted_bars<38)
      for(i=1;i<=0;i++) FATLBuffer[CountBars-i]=0.0;
//----
   i=CountBars-38-1;
//   if(counted_bars>=38) i=Bars-counted_bars-1;
   while(i>=0)
     {
      FATLBuffer[i]=
0.4360409450*Close[i+0]
+0.3658689069*Close[i+1]
+0.2460452079*Close[i+2]
+0.1104506886*Close[i+3]
-0.0054034585*Close[i+4]
-0.0760367731*Close[i+5]
-0.0933058722*Close[i+6]
-0.0670110374*Close[i+7]
-0.0190795053*Close[i+8]
+0.0259609206*Close[i+9]
+0.0502044896*Close[i+10]
+0.0477818607*Close[i+11]
+0.0249252327*Close[i+12]
-0.0047706151*Close[i+13]
-0.0272432537*Close[i+14]
-0.0338917071*Close[i+15]
-0.0244141482*Close[i+16]
-0.0055774838*Close[i+17]
+0.0128149838*Close[i+18]
+0.0226522218*Close[i+19]
+0.0208778257*Close[i+20]
+0.0100299086*Close[i+21]
-0.0036771622*Close[i+22]
-0.0136744850*Close[i+23]
-0.0160483392*Close[i+24]
-0.0108597376*Close[i+25]
-0.0016060704*Close[i+26]
+0.0069480557*Close[i+27]
+0.0110573605*Close[i+28]
+0.0095711419*Close[i+29]
+0.0040444064*Close[i+30]
-0.0023824623*Close[i+31]
-0.0067093714*Close[i+32]
-0.0072003400*Close[i+33]
-0.0047717710*Close[i+34]
+0.0005541115*Close[i+35]
+0.0007860160*Close[i+36]
+0.0130129076*Close[i+37]
+0.0040364019*Close[i+38];



SATLBuffer[i]=
0.0982862174*Close[i+0]
+0.0975682269*Close[i+1]
+0.0961401078*Close[i+2]
+0.0940230544*Close[i+3]
+0.0912437090*Close[i+4]
+0.0878391006*Close[i+5]
+0.0838544303*Close[i+6]
+0.0793406350*Close[i+7]
+0.0743569346*Close[i+8]
+0.0689666682*Close[i+9]
+0.0632381578*Close[i+10]
+0.0572428925*Close[i+11]
+0.0510534242*Close[i+12]
+0.0447468229*Close[i+13]
+0.0383959950*Close[i+14]
+0.0320735368*Close[i+15]
+0.0258537721*Close[i+16]
+0.0198005183*Close[i+17]
+0.0139807863*Close[i+18]
+0.0084512448*Close[i+19]
+0.0032639979*Close[i+20]
-0.0015350359*Close[i+21]
-0.0059060082*Close[i+22]
-0.0098190256*Close[i+23]
-0.0132507215*Close[i+24]
-0.0161875265*Close[i+25]
-0.0186164872*Close[i+26]
-0.0205446727*Close[i+27]
-0.0219739146*Close[i+28]
-0.0229204861*Close[i+29]
-0.0234080863*Close[i+30]
-0.0234566315*Close[i+31]
-0.0231017777*Close[i+32]
-0.0223796900*Close[i+33]
-0.0213300463*Close[i+34]
-0.0199924534*Close[i+35]
-0.0184126992*Close[i+36]
-0.0166377699*Close[i+37]
-0.0147139428*Close[i+38]
-0.0126796776*Close[i+39]
-0.0105938331*Close[i+40]
-0.0084736770*Close[i+41]
-0.0063841850*Close[i+42]
-0.0043466731*Close[i+43]
-0.0023956944*Close[i+44]
-0.0005535180*Close[i+45]
+0.0011421469*Close[i+46]
+0.0026845693*Close[i+47]
+0.0040471369*Close[i+48]
+0.0052380201*Close[i+49]
+0.0062194591*Close[i+50]
+0.0070340085*Close[i+51]
+0.0076266453*Close[i+52]
+0.0080376628*Close[i+53]
+0.0083037666*Close[i+54]
+0.0083694798*Close[i+55]
+0.0082901022*Close[i+56]
+0.0080741359*Close[i+57]
+0.0077543820*Close[i+58]
+0.0073260526*Close[i+59]
+0.0068163569*Close[i+60]
+0.0062325477*Close[i+61]
+0.0056078229*Close[i+62]
+0.0049516078*Close[i+63]
+0.0161380976*Close[i+64];



RSTLBuffer[i]=
-0.00514293*Close[i+0]
-0.00398417*Close[i+1]
-0.00262594*Close[i+2]
-0.00107121*Close[i+3]
+0.00066887*Close[i+4]
+0.00258172*Close[i+5]
+0.00465269*Close[i+6]
+0.00686394*Close[i+7]
+0.00919334*Close[i+8]
+0.01161720*Close[i+9]
+0.01411056*Close[i+10]
+0.01664635*Close[i+11]
+0.01919533*Close[i+12]
+0.02172747*Close[i+13]
+0.02421320*Close[i+14]
+0.02662203*Close[i+15]
+0.02892446*Close[i+16]
+0.03109071*Close[i+17]
+0.03309496*Close[i+18]
+0.03490921*Close[i+19]
+0.03651145*Close[i+20]
+0.03788045*Close[i+21]
+0.03899804*Close[i+22]
+0.03984915*Close[i+23]
+0.04042329*Close[i+24]
+0.04071263*Close[i+25]
+0.04071263*Close[i+26]
+0.04042329*Close[i+27]
+0.03984915*Close[i+28]
+0.03899804*Close[i+29]
+0.03788045*Close[i+30]
+0.03651145*Close[i+31]
+0.03490921*Close[i+32]
+0.03309496*Close[i+33]
+0.03109071*Close[i+34]
+0.02892446*Close[i+35]
+0.02662203*Close[i+36]
+0.02421320*Close[i+37]
+0.02172747*Close[i+38]
+0.01919533*Close[i+39]
+0.01664635*Close[i+40]
+0.01411056*Close[i+41]
+0.01161720*Close[i+42]
+0.00919334*Close[i+43]
+0.00686394*Close[i+44]
+0.00465269*Close[i+45]
+0.00258172*Close[i+46]
+0.00066887*Close[i+47]
-0.00107121*Close[i+48]
-0.00262594*Close[i+49]
-0.00398417*Close[i+50]
-0.00514293*Close[i+51]
-0.00609634*Close[i+52]
-0.00684602*Close[i+53]
-0.00739452*Close[i+54]
-0.00774847*Close[i+55]
-0.00791630*Close[i+56]
-0.00790940*Close[i+57]
-0.00774085*Close[i+58]
-0.00742482*Close[i+59]
-0.00697718*Close[i+60]
-0.00641613*Close[i+61]
-0.00576108*Close[i+62]
-0.00502957*Close[i+63]
-0.00423873*Close[i+64]
-0.00340812*Close[i+65]
-0.00255923*Close[i+66]
-0.00170217*Close[i+67]
-0.00085902*Close[i+68]
-0.00004113*Close[i+69]
+0.00073700*Close[i+70]
+0.00146422*Close[i+71]
+0.00213007*Close[i+72]
+0.00272649*Close[i+73]
+0.00324752*Close[i+74]
+0.00368922*Close[i+75]
+0.00405000*Close[i+76]
+0.00433024*Close[i+77]
+0.00453068*Close[i+78]
+0.00465046*Close[i+79]
+0.00469058*Close[i+80]
+0.00466041*Close[i+81]
+0.00457855*Close[i+82]
+0.00442491*Close[i+83]
+0.00423019*Close[i+84]
+0.00399201*Close[i+85]
+0.00372169*Close[i+86]
+0.00342736*Close[i+87]
+0.00311822*Close[i+88]
+0.00280309*Close[i+89]
+0.00249088*Close[i+90]
+0.00219089*Close[i+91]
+0.00191283*Close[i+92]
+0.00166683*Close[i+93]
+0.00146419*Close[i+94]
+0.00131867*Close[i+95]
+0.00124645*Close[i+96]
+0.00126836*Close[i+97]
-0.00401854*Close[i+98];
      


      RFTLBuffer[i]=
-0.02232324*Close[i+0]
+0.02268676*Close[i+1]
+0.08389067*Close[i+2]
+0.14630380*Close[i+3]
+0.19282649*Close[i+4]
+0.21002638*Close[i+5]
+0.19282649*Close[i+6]
+0.14630380*Close[i+7]
+0.08389067*Close[i+8]
+0.02268676*Close[i+9]
-0.02232324*Close[i+10]
-0.04296564*Close[i+11]
-0.03980614*Close[i+12]
-0.02082171*Close[i+13]
+0.00243636*Close[i+14]
+0.01950580*Close[i+15]
+0.02460929*Close[i+16]
+0.01799295*Close[i+17]
+0.00470540*Close[i+18]
-0.00831985*Close[i+19]
-0.01544722*Close[i+20]
-0.01456262*Close[i+21]
-0.00733980*Close[i+22]
+0.00201852*Close[i+23]
+0.00902504*Close[i+24]
+0.01093067*Close[i+25]
+0.00766099*Close[i+26]
+0.00145478*Close[i+27]
-0.00447175*Close[i+28]
-0.00750446*Close[i+29]
-0.00671646*Close[i+30]
-0.00304016*Close[i+31]
+0.00143433*Close[i+32]
+0.00457475*Close[i+33]
+0.00517589*Close[i+34]
+0.00336708*Close[i+35]
+0.00034406*Close[i+36]
-0.00233637*Close[i+37]
-0.00352280*Close[i+38]
-0.00293522*Close[i+39]
-0.00114249*Close[i+40]
+0.00083536*Close[i+41]
+0.00215524*Close[i+42]
+0.00604133*Close[i+43]
-0.00013046*Close[i+44];

Comment("FATL=",FATLBuffer[i],"\n","SATL=",SATLBuffer[i],"\n","RSTL=",RSTLBuffer[i],"\n","RFTL=",RFTLBuffer[i] );
   


      i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+