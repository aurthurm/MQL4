
#property copyright "EA_jjangchan"
#property link "https://www.github.com/jjangchan"
#property version "1.00"
#property strict

#include <ChanInclude/MQL4Function.mqh>

#define StrategyTest
//#define Live

extern string nameInd2 = "_______________ADX_______________"; // ADX
extern int ADX_period = 14;                                   // ADX period
extern ENUM_APPLIED_PRICE ADX_Price = PRICE_CLOSE;            // ADX Applied Price

extern string nameInd3 = "_______________CCI_______________"; // CCI
extern int CCI_period = 14;                                   // CCI period
extern ENUM_APPLIED_PRICE CCI_Price = PRICE_CLOSE;            // CCI Applied Price
extern double CCI_max = 100;                                  // CCI buying signal
extern double CCI_min = -100;                                 // CCI selling signal

extern string EA_properties = "___________Expert___________"; // Expert properties
extern double Lot = 0.01;                                     // Lot
extern int AllowLoss = 300;                                   // allow Loss, 0 - close by Stocho
extern int TrailingStop = 300;                                // Trailing Stop, 0 - close by Stocho
extern int StopLoss = 100;                                    // StopLoss Point Number
extern int TakeProfit = 300;                                  // TakeProfit Point Number
extern int Slippage = 10;                                     // Slippage
extern int NumberOfTry = 5;                                   // number of trade attempts
extern int MagicNumber = 5577555;                             // Magic Number
extern int LossPoint = 5;

#ifdef Live
datetime day = __DATE__;
#else
int day;
#endif

ModuleMQL4 *module;
datetime time;
datetime init_day;

int OnInit()
{
  module = new ModuleMQL4();
  trading = new Trading();
 
  if (!module.ValidPeriod(ADX_period))
  {
    Comment("Invalid Period !");
    Print("Invalid Period !");
    return (INIT_FAILED);
  }
  if (!module.ValidPeriod(CCI_period))
  {
    Comment("Invalid Period !");
    Print("Invalid Period !");
    return (INIT_FAILED);
  }
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   Comment("");
  if (module != NULL)
  {
    delete module;
    module = NULL;
  }

  if (trading != NULL)
  {
    delete trading;
    trading = NULL;
  }
}

void OnTick()
{
}

class Trading
{
private:
  /* data */
public:
  Trading(){

  }
  ~Trading(){}


private:
 // 이익, 청산 포지션 설정
  /** mode
   *  1. sell
   *  2. buy 
  **/
  void MakePosition(int mode, double &profit, double &stoploss)
  {
    double pivot[7];
    pivot[0] = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 6, 0), _Digits);
    pivot[1] = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 2, 0), _Digits);
    pivot[2] = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 1, 0), _Digits);
    pivot[3] = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 0, 0), _Digits);
    pivot[4] = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 3, 0), _Digits);
    pivot[5] = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 4, 0), _Digits);
    pivot[6] = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 5, 0), _Digits);

    // Print("s3 : ", pivot[0]);
    // Print("s2 : ", pivot[1]);
    // Print("s1 : ", pivot[2]);
    // Print("pp : ", pivot[3]);
    // Print("p1 : ", pivot[4]);
    // Print("p2 : ", pivot[5]);
    // Print("p3 : ", pivot[6]);
    // Print("close : ", Close[0]);

    double value = Close[0];
    int low = 0;
    int high = ArraySize(pivot) - 1;
    BinarySearch(pivot, value, low, high, profit, stoploss, mode);
  }

  //근사치 구하기(이진 탐색)
  void BinarySearch(const double &datas[], const double value, const int low, const int high, double &profit, double &stoploss, const int mode)
  {
    if (low > high)
    {
      if (mode == 1)
      {
        Print(low, " , ", high);
        profit = NormalizeDouble(high == 0 ? datas[high] - (datas[low] - datas[high]) / 2 : datas[high], _Digits);
        stoploss = NormalizeDouble(low == ArraySize(datas) - 1 ? datas[low] + (datas[low] - datas[high]) / 2 : (datas[low + 1] + datas[low]) / 2, _Digits);
        Print("BF stoploss : ", stoploss);
      }
      else
      {
        profit = NormalizeDouble(low == ArraySize(datas) - 1 ? datas[low] + (datas[low] - datas[high]) / 2 : datas[low], _Digits);
        stoploss = NormalizeDouble(high == 0 ? datas[high] - (datas[low] - datas[high]) / 2 : (datas[high - 1] + datas[high]) / 2, _Digits);
      }
      return;
    }
    int mid = (low + high) / 2;
    if (datas[mid] == value)
    {
      if (mode == 1)
      {
        profit = NormalizeDouble(mid - 1 == 0 ? datas[mid - 1] - (datas[mid + 1] - datas[mid - 1]) / 2 : datas[mid - 1], _Digits);
        stoploss = NormalizeDouble(mid + 1 == ArraySize(datas) - 1 ? datas[mid + 1] + (datas[mid + 1] - datas[mid - 1]) / 2 : (datas[mid + 2] + datas[mid + 1]) / 2, _Digits);
      }
      else
      {
        profit = NormalizeDouble(mid + 1 == ArraySize(datas) - 1 ? datas[mid + 1] + (datas[mid + 1] - datas[mid - 1]) / 2 : datas[mid + 1], _Digits);
        stoploss = NormalizeDouble(mid - 1 == 0 ? datas[mid - 1] - (datas[mid + 1] - datas[mid - 1]) / 2 : (datas[mid - 1] + datas[mid - 2]) / 2, _Digits);
      }
      return;
    }
    else if (datas[mid] < value)
    {
      BinarySearch(datas, value, mid + 1, high, profit, stoploss, mode);
    }
    else
    {
      BinarySearch(datas, value, low, mid - 1, profit, stoploss, mode);
    }
  }
};
Trading *trading;



