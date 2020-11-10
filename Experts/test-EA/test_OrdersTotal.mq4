//+------------------------------------------------------------------+
//|                                             test_OrdersTotal.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link "https://www.mql5.com"
#property version "1.00"
#property strict
#include <ChanInclude/MQL4Function.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

extern int MagicNo = 1445029;
extern double Lots = 1.0;
extern double take_profit = 30;
extern double stop_loss = 100;
extern int count_cci = 2;
ModuleMQL4 *module;
datetime time;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
  stochasticBreak = new StochasticBreak();
  module = new ModuleMQL4();
  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
  ulong start_time, elapsed_time;
  start_time = GetMicrosecondCount();
  module.CurrentTime(time);
  stochasticBreak.MaxMinCalculate();
  elapsed_time = GetMicrosecondCount() - start_time;
  Print("new Instance : ", elapsed_time);

  start_time = GetMicrosecondCount();
  Test1F();
  Test2F();
  elapsed_time = GetMicrosecondCount() - start_time;
  Print("Function : ", elapsed_time);


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TestFunction(int &aaa)
{
  Print(aaa);
  aaa = 3;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  //---
  if (module != NULL)
  {
    delete module;
    module = NULL;
  }
  // if (stochasticBreak != NULL)
  // {
  //   delete stochasticBreak;
  //   stochasticBreak = NULL;
  // }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddPostion(double &profit)
{
  int total = OrdersTotal();
  for (int i = 0; i != total; i++)
  {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
      profit += OrderOpenPrice();
    }
  }
  double unit_price = NormalizeDouble(profit / total, 5);
  Print("profit = ", total * Lots * 100000 * (Bid - unit_price));
}
//+------------------------------------------------------------------+

void Test1F()
{
  int index, count = 0;
  double value, high;
  double low = 0x7fffffff;
  while (count != 2)
  {
    value = iCustom(NULL, 0, "Extern/waverider zigzag.ex4", 0, index);
    if (value != 0x7fffffff)
    {
      high = (value > high) ? value : high;
      low = (value < low) ? value : low;
      count += 1;
    }
    index += 1;
  }
}

void Test2F()
{
  if (Time[0] != time)
  {
    time = Time[0];
    Print("Not Matching Time");
  }
}

class StochasticBreak
{
private:
public:
  StochasticBreak() {}
  ~StochasticBreak() {}
  void MaxMinCalculate()
  {
    int index, count = 0;
    double value, high;
    double low = 0x7fffffff;
    while (count != 2)
    {
      value = iCustom(NULL, 0, "Extern/waverider zigzag.ex4", 0, index);
      if (value != 0x7fffffff)
      {
        high = (value > high) ? value : high;
        low = (value < low) ? value : low;
        count += 1;
      }
      index += 1;
    }
  }

private:
  void BuySend()
  {
  }
  void SellSend()
  {
  }
};
StochasticBreak *stochasticBreak;