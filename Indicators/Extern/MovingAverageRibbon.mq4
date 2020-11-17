//+------------------------------------------------------------------+
//|                                          MovingAverageRibbon.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

//Extern Indicator
extern int MovingAverage1 = 4;
extern int MovingAverage2 = 6;
extern int MovingAverage3 = 8;
extern int MovingAverage4 = 10;
extern int MovingAverage5 = 12;
extern int MovingAverage6 = 14;
extern int MovingAverage7 = 16;
extern int MovingAverage8 = 18;
extern int MovingAverage9 = 20;
extern int MovingAverage10 = 22;
extern int MovingAverage11 = 24;
extern int MovingAverage12 = 26;
extern int MovingAverage13 = 28;
extern int MovingAverage14 = 30;

//Indicator Buffers
double     MABuffer1[];
double     MABuffer2[];
double     MABuffer3[];
double     MABuffer4[];
double     MABuffer5[];
double     MABuffer6[];
double     MABuffer7[];
double     MABuffer8[];
double     MABuffer9[];
double     MABuffer10[];
double     MABuffer11[];
double     MABuffer12[];
double     MABuffer13[];
double     MABuffer14[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
