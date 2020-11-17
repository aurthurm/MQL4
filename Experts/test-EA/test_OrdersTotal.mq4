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
int count_cci_1 = 3;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
  time = TimeCurrent();
  stochasticBreak = new StochasticBreak(time);
  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
}

void OnDeinit(const int reason)
{
  if (stochasticBreak != NULL)
  {
    delete stochasticBreak;
    stochasticBreak = NULL;
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class StochasticBreak
{
private:
  datetime time;
public:
  StochasticBreak(datetime time) {
    this.time = time;
  }
  ~StochasticBreak() {}
  
  void MaxMinCalculate()
  {
    int index, count, start = 0;
    string up_down = "DOWN";
    double high = 0;
    double low = 0x7fffffff;

    while (count != 4)
    {
      //start = index;
      index = TailRecursive(start, index, up_down, high, low);
      count += 1;
    }

    Print("Final high : ",high);
    Print("Final low : ",low);
  }

private:
  void BuySend()
  {
  }
  void SellSend()
  {
  }

  int TailRecursive(int &start,int n,string &up_down, double &high, double &low)
  {
    double lips = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, n);
    double teeth = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, n);
    double jaws = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW, n);
    if(up_down == "UP"){
      if (iHigh(NULL, 0, n) < MathMin(MathMin(lips, teeth), jaws)){
        up_down = "DOWN";
        int bar = iLowest(NULL,0,MODE_LOW,fabs(n-start)+1,start);
        double ihigh = High[iHighest(NULL,0,MODE_HIGH,fabs(bar-start),start)];
        Print("bar : ",bar);
        Print("start : ",start);
        Print("bar Price : ", Close[bar]);
        Print("ihigh : ",ihigh);
        high = (ihigh > high) ? ihigh : high;
        start = bar;
        return n;
      }
    }else if(up_down == "DOWN"){
      if (iLow(NULL, 0, n) > MathMax(MathMax(lips, teeth), jaws)){
        up_down = "UP";
        int bar = iHighest(NULL,0,MODE_HIGH,fabs(n-start)+1,start);
        double ilow = Low[iLowest(NULL,0,MODE_LOW,fabs(bar-start),start)];
        Print("bar : ",bar);
        Print("bar Price : ", Close[bar]);
        Print("ilow : ",ilow);
        low = (ilow < low) ? ilow : low;
        start = bar;
        return n;
      }
    }
    return TailRecursive(start, n + 1, up_down,high, low);
  }
};
StochasticBreak *stochasticBreak;
//+------------------------------------------------------------------+
