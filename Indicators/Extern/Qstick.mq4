//+------------------------------------------------------------------+
//|                                                       Qstick.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#property indicator_color1 clrDarkGray
#property indicator_color2 clrDeepSkyBlue
#property indicator_buffers 2

input int Qstick_period = 8;
double Qstick_array[],ma_Qstick_array[],close_open_array[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(3);
//--- indicator buffers mapping
   IndicatorShortName("Qstick("+string(Qstick_period));

//Qstick Config
   SetIndexBuffer(0,Qstick_array);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexLabel(0,"Qstick");

//Qstick MA Config
   SetIndexBuffer(1,ma_Qstick_array);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   SetIndexLabel(1,"Qstick MA");

   SetIndexBuffer(2,close_open_array);

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
   int index = MathMax(rates_total-prev_calculated,1);
   for(int i=0; i<index; i++)
     {
      close_open_array[i] = close[i]-open[i];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalulateOstick(int index)
  {
   double sum;
   for(int i=0; i<Qstick_period;i++){
      sum += close_open_array[i];
   }
   Qstick_array[0] = sum/Qstick_period;
   if(index<=1)
      return;
   
   double weight = close_open_array[0];
   int count=1;
   for(int i=Qstick_period; i<index; i++){
      sum += close_open_array[i]-weight;
      Qstick_array[count] = sum/Qstick_period;
      weight += close_open_array[count];
      count +=1;
   
   }
      
   
//   for(int i=0; i<index; i++)
//     {
//      sum += colse_open_array[i];
//      if(i%Qstick_period == 0)
//        {
//         sum -= weight;
//         
//         weight += colse_open_array[i];
//          Qstick_array
//        }
//     }
  }
//+------------------------------------------------------------------+
