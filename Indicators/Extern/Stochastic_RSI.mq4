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
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "Stochastic RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_width2  11
//--- input parameters
input int inpStoPeriod   = 32;          // Stochastic period
input int inpRsiPeriod   = 14;          // RSI period
input int inpRsiShift=0;
input ENUM_APPLIED_PRICE inpPrice=PRICE_CLOSE; // Price
//--- buffers declarations
double val[],valc[],signal[],rsi[];
//--- indicator handles
int _rsiHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,signal,INDICATOR_DATA);
   SetIndexBuffer(3,rsi,INDICATOR_CALCULATIONS);
//---
   _rsiHandle=iRSI(Symbol(),0,inpRsiPeriod,inpPrice,inpRsiShift);
   if(_rsiHandle==INVALID_HANDLE)
     {
      return(INIT_FAILED);
     }
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
   for(int i=0; i<index && !_StopFlag; i++)
   {
      rsi[i] = iRSI(NULL,0,inpRsiPeriod,inpPrice,inpRsiShift);
      
   }
   
   
   return(rates_total);
  }
//+------------------------------------------------------------------+


//int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
//                const double &open[],
//                const double &high[],
//                const double &low[],
//                const double &close[],
//                const long &tick_volume[],
//                const long &volume[],
//                const int &spread[])
//  {
//   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
//   if(BarsCalculated(_rsiHandle)<rates_total)  return(prev_calculated);
//   double _rsiVal[];
//   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
//     {
//      int _rsiCopied=CopyBuffer(_rsiHandle,0,time[i],1,_rsiVal);
//      if(_rsiCopied==1) rsi[i]=_rsiVal[0];
//      int    _start = (int)MathMax(i-inpStoPeriod+1,0);
//      double _lo    = rsi[ArrayMinimum(rsi,_start,inpStoPeriod)];
//      double _hi    = rsi[ArrayMaximum(rsi,_start,inpStoPeriod)];
//      //---------------
//      val[i]    = (_hi!=_lo) ? (rsi[i]-_lo)/(_hi-_lo) : 0;
//      signal[i] = (i>0) ? 0.96*val[i-1]+0.02 : val[i];
//      valc[i]   = (val[i]>signal[i]) ? 1 :(val[i]<signal[i]) ? 2 :(i>0) ? valc[i-1]: 0;
//     }
//   return (i);
//  }