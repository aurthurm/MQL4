//+------------------------------------------------------------------+
//|                                                          VTS.mq4 |
//|                                                                  |
//+------------------------------------------------------------------+
#define MAXBARSCOUNT 15000

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//extern int Sb = 300;
extern int    PeriodAtr = 10;
extern double kATR      = 2.0;

double VTS[MAXBARSCOUNT];
double VTS1[MAXBARSCOUNT];
double VTS2[MAXBARSCOUNT];
double VTS3[MAXBARSCOUNT];
double VTS4[MAXBARSCOUNT];
double VTS5[MAXBARSCOUNT];
double VTS6[MAXBARSCOUNT];
double VTS7[MAXBARSCOUNT];

double VTS8[MAXBARSCOUNT];
double VTS9[MAXBARSCOUNT];
double VTS10[MAXBARSCOUNT];
double VTS11[MAXBARSCOUNT];
double VTS12[MAXBARSCOUNT];
double VTS13[MAXBARSCOUNT];
double VTS14[MAXBARSCOUNT];
double VTS15[MAXBARSCOUNT];

double VTS16[MAXBARSCOUNT];
double VTS17[MAXBARSCOUNT];
double VTS18[MAXBARSCOUNT];
double VTS19[MAXBARSCOUNT];
double VTS20[MAXBARSCOUNT];
double VTS21[MAXBARSCOUNT];
double VTS22[MAXBARSCOUNT];
double VTS23[MAXBARSCOUNT];


double VTS24[MAXBARSCOUNT];
double VTS25[MAXBARSCOUNT];
double VTS26[MAXBARSCOUNT];
double VTS27[MAXBARSCOUNT];
double VTS28[MAXBARSCOUNT];
double VTS29[MAXBARSCOUNT];
double VTS_TS[MAXBARSCOUNT];
double VTS_TS1[MAXBARSCOUNT];

int init()
  {
//---- indicators
   IndicatorBuffers(2);
   SetIndexBuffer(0, VTS_TS);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(1, VTS_TS1);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);
//----
   return(0);
  }
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
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()  {
   int    counted_bars=IndicatorCounted();
//---- 
   
int    StartBars = Bars - counted_bars+2;
   //if (StartBars<Sb) StartBars = Sb;
   for(int i = StartBars; i>=0; i--){
       VTS[i] = (Close[i]-kATR*iATR(NULL,0,PeriodAtr,i));
       VTS1[i]= (Close[i]+kATR*iATR(NULL,0,PeriodAtr,i));
       }
   for(i = StartBars-1; i>0; i--){
       VTS2[i]= MathMax(VTS[i],VTS[i+1]);
       VTS3[i]= MathMin(VTS1[i],VTS1[i+1]);
       VTS4[i]= MathMax(VTS2[i],VTS2[i+1]);//VTS2[i+1];
       VTS5[i]= MathMin(VTS3[i],VTS3[i+1]);//VTS3[i+1];
       VTS6[i]= MathMax(VTS4[i],VTS4[i+1]);//VTS4[i+1];
       VTS7[i]= MathMin(VTS5[i],VTS5[i+1]);//VTS5[i+1];
       VTS8[i]= MathMax(VTS6[i],VTS6[i+1]);//VTS6[i+1];
       VTS9[i]= MathMin(VTS7[i],VTS7[i+1]);//VTS7[i+1];
       VTS10[i]= MathMax(VTS8[i],VTS8[i+1]);//VTS8[i+1];
       VTS11[i]= MathMin(VTS9[i],VTS9[i+1]);//VTS9[i+1];
       VTS12[i]= MathMax(VTS10[i],VTS10[i+1]);//VTS10[i+1];
       VTS13[i]= MathMin(VTS11[i],VTS11[i+1]);//VTS11[i+1]; 
       VTS14[i]= MathMax(VTS12[i],VTS12[i+1]);//VTS10[i+1];
       VTS15[i]= MathMin(VTS13[i],VTS13[i+1]);//VTS11[i+1]; 
       VTS16[i]= MathMax(VTS14[i],VTS14[i+1]);//VTS6[i+1];
       VTS17[i]= MathMin(VTS15[i],VTS15[i+1]);//VTS7[i+1];
       VTS18[i]= MathMax(VTS16[i],VTS16[i+1]);//VTS6[i+1];
       VTS19[i]= MathMin(VTS17[i],VTS17[i+1]);//VTS7[i+1];
       VTS20[i]= MathMax(VTS18[i],VTS18[i+1]);//VTS6[i+1];
       VTS21[i]= MathMin(VTS19[i],VTS19[i+1]);//VTS7[i+1];
       VTS22[i]= MathMax(VTS20[i],VTS20[i+1]);//VTS6[i+1];
       VTS23[i]= MathMin(VTS21[i],VTS21[i+1]);//VTS7[i+1];
       VTS24[i]= MathMax(VTS22[i],VTS22[i+1]);//VTS6[i+1];
       VTS25[i]= MathMin(VTS23[i],VTS23[i+1]);//VTS7[i+1];
       VTS26[i]= MathMax(VTS24[i],VTS24[i+1]);//VTS6[i+1];
       VTS27[i]= MathMin(VTS25[i],VTS25[i+1]);//VTS7[i+1];
       VTS28[i]= MathMax(VTS26[i],VTS26[i+1]);//VTS6[i+1];
       VTS29[i]= MathMin(VTS27[i],VTS27[i+1]);//VTS7[i+1];
       VTS_TS[i]  = VTS_TS[i+1];
       VTS_TS1[i] = VTS_TS1[i+1];
       if (Close[i]>VTS29[i]) {
           VTS_TS[i] = VTS28[i];
           VTS_TS1[i] = 0;//VTS_TS[i+1];
           }
       if (Close[i]<VTS28[i]) {
           VTS_TS1[i]= VTS29[i];
           VTS_TS[i] = 0;//VTS_TS1[i+1];
           }
       }//for(i = StartBars; i>0; i--){
   
//----
   return(0);
  }
//+------------------------------------------------------------------+