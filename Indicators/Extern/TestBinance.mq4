//+------------------------------------------------------------------+
//|                                                  TestBinance.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link "https://www.mql5.com"
#property version "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  datetime last_datetime;
  double total_binance;
  for(int i=0; i<OrdersHistoryTotal(); i++){
    if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){
      if(OrderType() == 6)
      {
        last_datetime = OrderOpenTime();
      }
      if(OrderType() > 5)
      {
        total_binance += OrderProfit();
      }
    }
  }

  Print("OrderOpenTime () : ",last_datetime);
  Print("total_binance : ",total_binance);
  return (INIT_SUCCEEDED);
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
  return (rates_total);
}
//+------------------------------------------------------------------+
