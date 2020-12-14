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
#include <Generic\HashMap.mqh>

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
int bar_count;
int count_cci_1 = 3;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
  return (INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define MACRO
void OnTick()
{
  iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 6, 0);
}

void OnDeinit(const int reason)
{
  if (stochasticBreak != NULL)
  {
    delete stochasticBreak;
    stochasticBreak = NULL;
  }
}

void HoliDay(const int prev_hour, const int current_hour, const int time_difference){
  int hour_differnce = current_hour - prev_hour;
  if(hour_differnce != 1){
    if(hour_differnce != -23){
      
    }
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class StochasticBreak;
StochasticBreak *stochasticBreak;
typedef int (*TFunction)(StochasticBreak*,int);

int TestFunction(StochasticBreak* ptr,int a){return ptr.TestOn(a);}

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


  void FunctionPoint()
  {
    TFunction tfunc = TestFunction;
    tfunc(stochasticBreak,3);
  }

  int TestOn(int a)
  {
    Print("ok");
    return 3;
  }

   double UnixToHour(double &unix){
    unix /= (double)(60*60*24);
    Print(unix);
    unix -= (int)unix;
    return (int)NormalizeDouble(unix*24, 5);
  }

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

  void CalculateUnix(int &day, int &hour, const int unix)
  {
    double cal_hour = (double)unix / (double)(60 * 60 * 24);
    double cal_year = (double)cal_hour / (double)365;
    
    day = (int)cal_hour;
    
    cal_hour -= day;
    hour = (int)NormalizeDouble(cal_hour*24, 5);
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
//+------------------------------------------------------------------+
