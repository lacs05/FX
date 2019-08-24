

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 RoyalBlue
#property indicator_color3 Red
#property indicator_color4 CLR_NONE

extern bool Alert_Coral_Crossing = true;
bool gi_80 = TRUE;
extern int gi_84 = 34;
double gd_88 = 0.4;
double g_ibuf_96[];
double g_ibuf_100[];
double g_ibuf_104[];
double g_ibuf_108[];
double gda_112[];
double gda_116[];
double gda_120[];
double gda_124[];
double gda_128[];
double gda_132[];
double gd_136;
double gd_144;
double gd_152;
double gd_160;
double gd_168;
double gd_176;
double gd_184;
double gd_192;
double gd_200;
bool gi_208 = FALSE;
bool gi_212 = FALSE;

int init() {
   IndicatorBuffers(4);
   SetIndexBuffer(0, g_ibuf_96);
   SetIndexBuffer(1, g_ibuf_100);
   SetIndexBuffer(2, g_ibuf_104);
   SetIndexBuffer(3, g_ibuf_108);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   IndicatorShortName("THV Coral (" + gi_84 + ") ");
   gd_192 = gd_88 * gd_88;
   gd_200 = 0;
   gd_200 = gd_192 * gd_88;
   gd_136 = -gd_200;
   gd_144 = 3.0 * (gd_192 + gd_200);
   gd_152 = -3.0 * (2.0 * gd_192 + gd_88 + gd_200);
   gd_160 = 3.0 * gd_88 + 1.0 + gd_200 + 3.0 * gd_192;
   gd_168 = gi_84;
   if (gd_168 < 1.0) gd_168 = 1;
   gd_168 = (gd_168 - 1.0) / 2.0 + 1.0;
   gd_176 = 2 / (gd_168 + 1.0);
   gd_184 = 1 - gd_176;
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double ld_0;
   double ld_8;
   string ls_28;
   if (gi_80 == FALSE) return (0);
   int li_20 = IndicatorCounted();
   if (li_20 < 0) return (-1);
   if (li_20 > 0) li_20--;
   int li_16 = Bars - li_20 - 1;
   ArrayResize(gda_112, Bars + 1);
   ArrayResize(gda_116, Bars + 1);
   ArrayResize(gda_120, Bars + 1);
   ArrayResize(gda_124, Bars + 1);
   ArrayResize(gda_128, Bars + 1);
   ArrayResize(gda_132, Bars + 1);
   for (int li_24 = li_16; li_24 >= 0; li_24--) {
      gda_112[Bars - li_24] = gd_176 * Close[li_24] + gd_184 * (gda_112[Bars - li_24 - 1]);
      gda_116[Bars - li_24] = gd_176 * (gda_112[Bars - li_24]) + gd_184 * (gda_116[Bars - li_24 - 1]);
      gda_120[Bars - li_24] = gd_176 * (gda_116[Bars - li_24]) + gd_184 * (gda_120[Bars - li_24 - 1]);
      gda_124[Bars - li_24] = gd_176 * (gda_120[Bars - li_24]) + gd_184 * (gda_124[Bars - li_24 - 1]);
      gda_128[Bars - li_24] = gd_176 * (gda_124[Bars - li_24]) + gd_184 * (gda_128[Bars - li_24 - 1]);
      gda_132[Bars - li_24] = gd_176 * (gda_128[Bars - li_24]) + gd_184 * (gda_132[Bars - li_24 - 1]);
      g_ibuf_108[li_24] = gd_136 * (gda_132[Bars - li_24]) + gd_144 * (gda_128[Bars - li_24]) + gd_152 * (gda_124[Bars - li_24]) + gd_160 * (gda_120[Bars - li_24]);
      ld_0 = g_ibuf_108[li_24];
      ld_8 = g_ibuf_108[li_24 + 1];
      g_ibuf_96[li_24] = ld_0;
      g_ibuf_100[li_24] = ld_0;
      g_ibuf_104[li_24] = ld_0;
      if (ld_8 > ld_0) g_ibuf_100[li_24] = EMPTY_VALUE;
      else {
         if (ld_8 < ld_0) g_ibuf_104[li_24] = EMPTY_VALUE;
         else g_ibuf_96[li_24] = EMPTY_VALUE;
      }
      if (Alert_Coral_Crossing) {
         if (!gi_208 && Close[1] > Close[2] && Close[1] > g_ibuf_108[li_24 + 1] && Close[2] < g_ibuf_108[li_24 + 1]) {
            ls_28 = Symbol() + ": PA crossing Coral from below !";
            Alert(ls_28);
            gi_208 = TRUE;
            gi_212 = FALSE;
         }
         if (!gi_212 && Close[1] < Close[2] && Close[1] < g_ibuf_108[li_24 + 1] && Close[2] > g_ibuf_108[li_24 + 1]) {
            ls_28 = Symbol() + ": PA crossing Coral from above !";
            Alert(ls_28);
            gi_208 = FALSE;
            gi_212 = TRUE;
         }
      }
   }
   return (0);
}