//+------------------------------------------------------------------+
//|                                               Stochastic_RSI.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "Stochastic RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_width1  2
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDeepSkyBlue
#property indicator_width2  2

#property indicator_level1     20
#property indicator_level2     50
#property indicator_level3     80

#property indicator_minimum -2
#property indicator_maximum 102

//--- input parameters
input int inpStoPeriod   = 32;          // Stochastic period
input int inpRsiPeriod   = 14;          // RSI period

input ENUM_APPLIED_PRICE inpPrice=PRICE_CLOSE; // Price
//--- buffers declarations
double val[],signal[],rsi[];
//--- indicator handles
int _rsiHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,signal,INDICATOR_DATA);
   SetIndexBuffer(2,rsi,INDICATOR_CALCULATIONS);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexLabel(2,"RSI");
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic RSI ("+(string)inpStoPeriod+","+(string)inpRsiPeriod+")");
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
   int index = MathMax(rates_total-prev_calculated,1);
   //initialize RSI
   for(int i=0; i<index && !_StopFlag; i++)
     {
      rsi[i] = iRSI(NULL,0,inpRsiPeriod,inpPrice,i);
     }
   for(int i=0; i<index && !_StopFlag; i++)
     {
      //기간 별 RSI 최고가
      double rsi_high =rsi[ArrayMaximum(rsi,inpStoPeriod,i)];
      //기간 별 RSI 최저가
      double rsi_low = rsi[ArrayMinimum(rsi,inpStoPeriod,i)];
      //StochRSI 계산
      val[i] = (rsi_high != rsi_low && i+inpStoPeriod < rates_total) ? ((rsi[i]-rsi_low)/(rsi_high-rsi_low))*100: 0;
      //signal = (0.96*StochRSI)+0.02
      signal[i] = (i>0) ? (0.96 *val[i-1])+0.02 : val[i];
     }
   return(rates_total);
   
  }
