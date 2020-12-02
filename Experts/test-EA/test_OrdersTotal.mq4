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

//#define Live

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
  Print(Bid," = ",Close[0]);
  stochasticBreak = new StochasticBreak(time);
  double array[7] = {1.2, 1.4, 1.5, 2.0, 5.3, 6.2, 6.9};
  int left = 0; 
  int right = ArraySize(array) - 1;
  double value = 1.3;
  double profit,stoploss;
  stochasticBreak.BinarySearch(array, value, left, right, profit, stoploss);
  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define MACRO
void OnTick()
{
 
  if (time != Time[0])
  { 
    //stochasticBreak.MaxMinCalculate();
    // Print(iStochastic(NULL,0,5,3,3,MODE_SMA,0,0,1));
    time = Time[0];
  }
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
  StochasticBreak(datetime time)
  {
    this.time = time;
  }
  ~StochasticBreak() {}

  void MaxMinCalculate()
  {
    int index, count, start = 0;
    
    string up_down = InitPosition(0);
    Print("up_down : ",up_down);

    double high = 0;
    double low = 0x7fffffff;

    while (count != 3)
    {
      //start = index;
      index = TailRecursive(start, index, up_down, high, low);
      count += 1;
    }

    Print("Final high : ", high);
    Print("Final low : ", low);
  }

  //근사치 구하기(이진 탐색)
  void BinarySearch(const double &datas[], const double value, const int left, const int right, double &value2, double &value3){
    Print(left, " , ", right);
    if(left > right) {
      value2 = datas[left];
      value3 = datas[right];
      return;
    }
    int mid = (left+right)/2;
    if(datas[mid] == value){
      value2 = datas[mid+1];
      value3 = datas[mid-1];
      return;
    }else if(datas[mid] < value){
      BinarySearch(datas , value, mid+1, right, value2, value3);
    }else{
      BinarySearch(datas, value, left, mid-1, value2, value3);
    }
  }

private:
  void BuySend()
  {
  }
  void SellSend()
  {
  }

  string InitPosition(int n)
  {
    double lips = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, n);
    double teeth = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, n);
    double jaws = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW, n);
    if(iHigh(NULL, 0, n) < MathMin(MathMin(lips, teeth), jaws)){
      return "DOWN";
    }else if(iLow(NULL, 0, n) > MathMax(MathMax(lips, teeth), jaws)){
      return "UP";
    }
    return InitPosition(n+1);
  }

  int TailRecursive(int &start, int n, string &up_down, double &high, double &low)
  {
    double lips = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, n);
    double teeth = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, n);
    double jaws = iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW, n);
    if (up_down == "UP")
    {
      if (iHigh(NULL, 0, n) < MathMin(MathMin(lips, teeth), jaws))
      {
        up_down = "DOWN";
        int bar = iLowest(NULL, 0, MODE_LOW, fabs(n - start) + 1, start);
        double ihigh = High[iHighest(NULL, 0, MODE_HIGH, fabs(bar - start), start)];
        Print("ihigh", NormalizeDouble(ihigh, 4));
        high = (ihigh > high) ? ihigh : high;
        start = bar;
        return n;
      }
    }
    else if (up_down == "DOWN")
    {
      if (iLow(NULL, 0, n) > MathMax(MathMax(lips, teeth), jaws))
      {
        up_down = "UP";
        int bar = iHighest(NULL, 0, MODE_HIGH, fabs(n - start) + 1, start);
        double ilow = Low[iLowest(NULL, 0, MODE_LOW, fabs(bar - start), start)];
        Print("ilow", NormalizeDouble(ilow, 4));
        low = (ilow < low) ? ilow : low;
        start = bar;
        return n;
      }
    }
    return TailRecursive(start, n + 1, up_down, high, low);
  }

};
StochasticBreak *stochasticBreak;
//+------------------------------------------------------------------+
