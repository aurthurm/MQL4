#property copyright "EA_jjangchan"
#property link "https://www.github.com/jjangchan"
#property version "1.00"
#property strict

#include <ChanInclude/MQL4Function.mqh>
#include <generic/queue.mqh>

#define StrategyTest
//#define Live

extern string nameInd1 = "_______________ADX_______________"; // ADX
extern int ADX_period = 14;                                   // ADX period
extern ENUM_APPLIED_PRICE ADX_Price = PRICE_CLOSE;            // ADX Applied Price
extern double ADX_max = 50;
extern double ADX_min = 20;

extern string nameInd2 = "_______________CCI_______________"; // CCI
extern int CCI_period = 14;                                   // CCI period
extern ENUM_APPLIED_PRICE CCI_Price = PRICE_CLOSE;            // CCI Applied Price
extern double CCI_max = 100;                                  // CCI buying signal
extern double CCI_min = -100;                                 // CCI selling signal

extern string nameInd3 = "______________Bands______________"; // Bolinger Bands
extern double BB_deviation = 2;                               // Boligner Bands deviation
extern ENUM_APPLIED_PRICE BB_Price = PRICE_CLOSE;             // Boligner Bands Price

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
int BB_period;

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
  if (_Period >= 1440)
  {
    Comment("Invalid TimeFrame !");
    Print("Invalid TimeFrame");
    return (INIT_FAILED);
  }

  int hour = 60;
  int day_hour = 24;
  BB_period = _Period > 60 ? day_hour / (_Period / hour) : (hour / _Period) * day_hour;

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

  if (Time[0] != time)
  {
    time = Time[0];
  }

  trading.Validation();
  trading.OrdersClose();
}

class Trading
{
private:
  /** 0 : buy , 1 : sell **/
  bool IsBuySell[2];
  /**
   * 배열 정보
   * 0. Sell , [0][0] profit , [0][1] stoploss , [0][2] current spread, [0][3] current adx
   * 1. Buy  , [1][0] profit , [1][1] stoploss , [1][2] current spread, [1][3] current adx
   * **/
  double LimitOrder[2][5];
  datetime buy_time;
  datetime sell_time;

public:
  Trading()
  {
    LimitOrder[0][3] = -1;
    LimitOrder[1][3] = -1;
  }
  ~Trading() {}

  void Validation()
  {
    double s3_value = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 6, 0), _Digits);
    double p3_value = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 5, 0), _Digits);
    if (Close[0] > s3_value && Close[0] < p3_value)
    {
      if (!IsBuySell[0])
      {
        BuySignal();
      }
      if (!IsBuySell[1])
      {
        SellSignal();
      }
    }
  }

  void OrdersClose()
  {
    for (int i = 0; i != NumberOfTry; i++)
    {
      int total = OrdersTotal();
      if (total == 0)
        return;
      for (int j = 0; j < total; j++)
      {
        if (OrderSelect(j, SELECT_BY_POS, MODE_TRADES))
        {
          if (OrderMagicNumber() == MagicNumber)
          {
            if (OrderType() == OP_BUY)
            {
              if (LimitOrder[0][4] == 0)
              {
                BuyClose(0);
              }
              else
              {
                SellClose(0);
              }
            }
            if (OrderType() == OP_SELL)
            {
              if (LimitOrder[1][4] == 0)
              {
                SellClose(1);
              }
              else
              {
                BuyClose(1);
              }
            }
          }
        }
      }
    }
  }

private:
  void BuySignal()
  {
    double bb_value = iBands(NULL, 0, BB_period, BB_deviation, 0, BB_Price, 1, 0);
    if (Close[0] > bb_value)
    {
      double adx_value = iADX(NULL, 0, ADX_period, ADX_Price, 0, 0);
      double stoploss, profit;
      int ticket;
      // if (buy_time == Time[0] || LimitOrder[0][3] == -1 || adx_value > LimitOrder[0][3])
      // {
      //   MakePosition(2, profit, stoploss);
      //   Print("buy");
      //   Print("profit : ", profit);
      //   Print("stoploss : ", stoploss);
      //   Print("Close Price : ",Close[0]);
      //   Print(adx_value,">",LimitOrder[0][3]);
      //   LimitOrder[0][3] = iADX(NULL, 0, ADX_period, ADX_Price, 0, 0);
      //   LimitOrder[0][4] = 0;
      //   ticket = OrderSend(NULL, OP_BUY, Lot, Ask, Slippage, 0, 0, "BUY", MagicNumber, 0, Blue);
      // }
      // else
      // {
      //   MakePosition(1, profit, stoploss);
      //   Print("reverse buy");
      //   Print("profit : ", profit);
      //   Print("stoploss : ", stoploss);
      //   Print("Close Price : ",Close[0]);
      //   Print(LimitOrder[0][3],">",adx_value);
      //   LimitOrder[0][3] = -1;
      //   LimitOrder[0][4] = 1;
      //   ticket = OrderSend(NULL, OP_SELL, Lot, Bid, Slippage, 0, 0, "SELL", MagicNumber, 0, Red);
      // }

      MakePosition(1, profit, stoploss);
      Print("reverse buy");
      Print("profit : ", profit);
      Print("stoploss : ", stoploss);
      Print("Close Price : ",Close[0]);
      ticket = OrderSend(NULL, OP_SELL, Lot, Bid, Slippage, 0, 0, "1", MagicNumber, 0, Red);
      LimitOrder[0][4] = 1;

      buy_time = Time[0];
      IsBuySell[0] = true;
      LimitOrder[0][0] = profit;
      LimitOrder[0][1] = stoploss;
      LimitOrder[0][2] = MarketInfo(NULL, MODE_SPREAD) * _Point;
      LimitOrder[1][3] = -1;
    }
  }

  void SellSignal()
  {
    double bb_value = iBands(NULL, 0, BB_period, BB_deviation, 0, BB_Price, 2, 0);
    if (Close[0] < bb_value)
    {
      double adx_value = iADX(NULL, 0, ADX_period, ADX_Price, 0, 0);
      double stoploss, profit;
      int ticket;
      // if (sell_time == Time[0] || LimitOrder[1][3] == -1 || adx_value > LimitOrder[1][3])
      // {
      //   Print("sell");
      //   MakePosition(1, profit, stoploss);
      //   LimitOrder[1][3] = iADX(NULL, 0, ADX_period, ADX_Price, 0, 0);
      //   LimitOrder[1][4] = 0;
      //   ticket = OrderSend(NULL, OP_SELL, Lot, Bid, Slippage, 0, 0, "SELL", MagicNumber, 0, Red);
      // }
      // else
      // {
      //   Print("reverse sell");
      //   MakePosition(2, profit, stoploss);
      //   LimitOrder[1][3] = -1;
      //   LimitOrder[1][4] = 1;
      //   ticket = OrderSend(NULL, OP_BUY, Lot, Ask, Slippage, 0, 0, "BUY", MagicNumber, 0, Blue);
      // }

      MakePosition(2, profit, stoploss);
      Print("reverse Sell");
      Print("profit : ", profit);
      Print("stoploss : ", stoploss);
      Print("Close Price : ",Close[0]);
      ticket = OrderSend(NULL, OP_BUY, Lot, Ask, Slippage, 0, 0, "BUY", MagicNumber, 0, Blue);
      LimitOrder[1][4] = 1;

      sell_time = Time[0];
      IsBuySell[1] = true;
      LimitOrder[1][0] = profit;
      LimitOrder[1][1] = stoploss;
      LimitOrder[1][2] = MarketInfo(NULL, MODE_SPREAD) * _Point;
      LimitOrder[0][3] = -1;
    }
  }
  // 이익, 청산 포지션 설정
  /** mode
   *  1. sell
   *  2. buy 
  **/
  void MakePosition(const int mode, double &profit, double &stoploss)
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
        profit = NormalizeDouble(high == 0 ? datas[high] - (datas[low] - datas[high]) / 2 : datas[high], _Digits);
        stoploss = NormalizeDouble(low == ArraySize(datas) - 1 ? datas[low] + (datas[low] - datas[high]) / 2 : (datas[low + 1] + datas[low]) / 2, _Digits);
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

  //ADX > DI
  bool UpperADX(const int mode)
  {
    double di_value = iADX(NULL, 0, ADX_period, ADX_Price, mode, 0);
    double adx_value = iADX(NULL, 0, ADX_period, ADX_Price, 0, 0);
    return (adx_value > di_value);
  }

  void BuyClose(const int index)
  {
    if (Close[0] >= LimitOrder[index][0] && OrderOpenPrice() <= Bid)
    {
      Print("buy index : ",index);
      OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, White);
      IsBuySell[index] = false;
    }
    else if (Close[0] <= LimitOrder[index][1])
    {
      Print("buy index : ",index);
      OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, White);
      IsBuySell[index] = false;
    }
  }

  void SellClose(const int index)
  {
    if (Close[0] <= LimitOrder[index][0] && OrderOpenPrice() >= Ask)
    {
      Print("sell index : ",index);
      OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, White);
      IsBuySell[index] = false;
    }
    else if (Close[0] >= LimitOrder[index][1])
    {
      Print("sell index : ",index);
      OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, White);
      IsBuySell[index] = false;
    }
  }
};
Trading *trading;
