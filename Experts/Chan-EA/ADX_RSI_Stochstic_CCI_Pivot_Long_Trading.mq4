#property copyright "EA_jjangchan"
#property link "https://www.github.com/jjangchan"
#property version "1.00"
#property strict

#include <ChanInclude/MQL4Function.mqh>

#define StrategyTest
//#define Live

//------- external parameters ---------------------------------------+
extern string nameInd1 = "___________Stochastic___________"; // Stochastic
extern int K_period = 5;                                     // Stochastic K period
extern int D_period = 3;                                     // Stochastic D period
extern int Slow_period = 3;                                  // Stochastic Slowing
extern ENUM_MA_METHOD Stoch_Method = MODE_SMA;               // Stochastic Methods
extern double stoch_max = 80;                                // Stochastic buying signal
extern double stoch_min = 20;                                // Stochastic selling signal

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
extern double Weight = 1;
extern int AllowLoss = 300;       // allow Loss, 0 - close by Stocho
extern int TrailingStop = 300;    // Trailing Stop, 0 - close by Stocho
extern int StopLoss = 100;        // StopLoss Point Number
extern int TakeProfit = 300;      // TakeProfit Point Number
extern int Slippage = 10;         // Slippage
extern int NumberOfTry = 5;       // number of trade attempts
extern int MagicNumber = 5577555; // Magic Number
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
  if (!module.ValidPeriod(K_period))
  {
    Comment("Invalid Period !");
    Print("Invalid Period !");
    return (INIT_FAILED);
  }
  if (!module.ValidPeriod(D_period))
  {
    Comment("Invalid Period !");
    Print("Invalid Period !");
    return (INIT_FAILED);
  }
  if (!module.ValidPeriod(Slow_period))
  {
    Comment("Invalid Period !");
    Print("Invalid Period !");
    return (INIT_FAILED);
  }
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
#ifdef Live
  //live Trading
  if (day <= TimeCurrent())
  {
    init_day = time[0];
    trading.InitData();
    day += (60 * 60 * 24);
    Print("day : ", day);
    return;
  }
#else
  //Strategy Tester
  //unix time -> current day
  double double_day = ((double)Time[0] / (double)31536000) - ((int)(Time[0] / 31536000));
  int int_day = (int)(NormalizeDouble(double_day * 365, 8));
  if (day != int_day)
  {
    init_day = Time[0];
    trading.InitData();
    day = int_day;
    return;
  }
#endif

  if (init_day != Time[0] && Time[0] != time)
  {
    trading.CalculationDIAverage();
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
   * [0][0] : buy profit , [0][1] : but stoploss 
   * [1][0] : sell profit , [1][1] : sell stoploss
   * **/
  double LimitOrder[2][2]; 
  
  double average_plusdi;
  double average_minusdi;
  bool is_plus_di;
  bool is_minus_di;
  int count_di;

public:
  Trading(/* args */) {}

  ~Trading() {}

  void InitData()
  {
    is_minus_di = false;
    is_plus_di = false;
    count_di = 0;
    average_minusdi = iADX(NULL, 0, ADX_period, ADX_Price, 2, 0);
    average_plusdi = iADX(NULL, 0, ADX_period, ADX_Price, 1, 0);
  }

  void CalculationDIAverage()
  {
    average_minusdi = trading.AverageMinusDI();
    average_plusdi = trading.AveragePlusDI();
  }

  void Validation()
  {
    if (!IsBuySell[0] && average_plusdi > average_minusdi)
    {
      BuySignal();
    }
    else if (!IsBuySell[1] && average_plusdi < average_minusdi)
    {
      SellSignal();
    }
  }

  void OrdersClose(){
    for (int i = 0; i != NumberOfTry; i++)
    {
      int total = OrdersTotal();
      if (total == 0)
        return;
      for (int i = 0; i < total; i++)
      {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
          if (OrderMagicNumber() == MagicNumber)
          {
            if (OrderType() == OP_BUY)
            {
              if (Close[0] >= LimitOrder[0][0])
              {
                OrderClose(OrderTicket(), OrderLots(), Close[0], Slippage, White);
                IsBuySell[0] = false;
              }
              else if (Close[0] <= LimitOrder[0][1])
              {
                OrderClose(OrderTicket(), OrderLots(), Close[0], Slippage, White);
                IsBuySell[0] = false;
              }
            }
            else if (OrderType() == OP_SELL)
            {
              if (Close[0] >= LimitOrder[1][0])
              {
                OrderClose(OrderTicket(), OrderLots(), Close[0], Slippage, White);
                IsBuySell[1] = false;
              }
              else if (Close[0] <= LimitOrder[1][1])
              {
                OrderClose(OrderTicket(), OrderLots(), Close[0], Slippage, White);
                IsBuySell[1] = false;
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
    double pivot_value = iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 0, 6);
    if (UpperADX(average_plusdi) && Close[0] > pivot_value)
    {
      double stoploss,profit;
      MakePosition(2,stoploss,profit);
      int ticket = OrderSend(NULL,OP_BUY,Lot,Ask,Slippage,0,0,"BUY",MagicNumber,0,Blue);
      IsBuySell[0]  = true;
      LimitOrder[0][0] = profit;
      LimitOrder[0][1] = stoploss-(_Point*LossPoint);
    }
  }

  void SellSignal()
  {
    double pivot_value = iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 0, 5);
    if (UpperADX(average_minusdi) && Close[0] < pivot_value)
    {
      double stoploss,profit;
      MakePosition(1,stoploss,profit);
      int ticket = OrderSend(NULL,OP_SELL,Lot,Bid,Slippage,0,0,"SELL",MagicNumber,0,Red);
      IsBuySell[1] = true;
      LimitOrder[1][0] = profit;
      LimitOrder[1][1] = stoploss+(_Point*LossPoint);;
    }
  }

  // High Point Of DI < ADX
  bool UpperADX(const double value)
  {
    double adx_value = iADX(NULL, 0, ADX_period, ADX_Price, 0, 0);
    return adx_value > value;
  }

  // CCI or Stochastic Sell Signal
  bool SellIsCCIStoch()
  {
    double CCI_value = iCCI(NULL, 0, CCI_period, CCI_Price, 0);
    double Stoch_value = iStochastic(NULL, 0, K_period, D_period, Slow_period, Stoch_Method, 0, 0, 0);
    return ((CCI_value > CCI_max) || (Stoch_value > stoch_max)) ? true : false;
  }

  // CCI or Stochastic Buy Signal
  bool BuyIsCCIStoch()
  {
    double CCI_value = iCCI(NULL, 0, CCI_period, CCI_Price, 0);
    double Stoch_value = iStochastic(NULL, 0, K_period, D_period, Slow_period, Stoch_Method, 0, 0, 0);
    return ((CCI_value < CCI_min) || (Stoch_value < stoch_min)) ? true : false;
  }


  // 이익, 청산 포지션 설정
  /** mode
   *  1. sell
   *  2. buy 
  **/
  void MakePosition(int mode, double &stoploss, double &profit)
  {
    double pivot[7];
    pivot[0] = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 6, 0), _Digits);
    pivot[1] = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 2, 0), _Digits);
    pivot[2] = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 1, 0), _Digits);
    pivot[3] = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 0, 0), _Digits);
    pivot[4] = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 3, 0), _Digits);
    pivot[5] = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 4, 0), _Digits);
    pivot[6] = NormalizeDouble(iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 5, 0), _Digits);
    double value = Close[0];
    int low,left = 0;
    int right = ArraySize(pivot)-1;
    if (mode == 1)
    {
      BinarySearch(pivot, value, low, right, profit, stoploss, left);
      stoploss = (stoploss+((left+1 == ArraySize(pivot)-1) ? pivot[left+1] : pivot[left+2] ))/2;
    }
    else
    {
      BinarySearch(pivot, value, low ,right, profit, stoploss, left);
      stoploss -= (_Point*LossPoint);
    }
  }

  //근사치 구하기(이진 탐색)
  void BinarySearch(const double &datas[], const double value, const int low, const int high, double &value2, double &value3, int &left){
    if(low > right) {
      value2 = datas[low];
      value3 = datas[right];
      left = right;
      return;
    }
    int mid = (low+right)/2;
    if(datas[mid] == value){
      value2 = datas[mid+1];
      value3 = datas[mid-1];
      left = mid-1;
      return;
    }else if(datas[mid] < value){
      BinarySearch(datas , value, mid+1, right, value2, value3);
    }else{
      BinarySearch(datas, value, low, mid-1, value2, value3);
    }
  }

  //High Point Average of -DI
  //-DI 의 고점 평균
  double AverageMinusDI()
  {
    double adx_value1 = iADX(NULL, 0, ADX_period, ADX_Price, 2, 1);
    double adx_value2 = iADX(NULL, 0, ADX_period, ADX_Price, 2, 2);
    if (!is_minus_di)
    {
      is_minus_di = (adx_value1 > adx_value2);
      return average_minusdi;
    }
    if (adx_value1 - adx_value2 < 0)
    {
      count_di += 1;
      is_minus_di = false;
      double return_value = NormalizeDouble((count_di != 1) ? ((average_minusdi * (count_di - 1)) + adx_value2) / count_di : adx_value2, _Digits);
      return return_value;
    }
    return average_minusdi;
  }

  //High Point Average of +DI
  //+DI 의 고점 평균
  double AveragePlusDI()
  {
    double adx_value1 = iADX(NULL, 0, ADX_period, ADX_Price, 1, 1);
    double adx_value2 = iADX(NULL, 0, ADX_period, ADX_Price, 1, 2);
    if (!is_plus_di)
    {
      is_plus_di = (adx_value1 > adx_value2);
      return average_plusdi;
    }
    if (adx_value1 - adx_value2 < 0)
    {
      count_di += 1;
      is_plus_di = false;
      double return_value = NormalizeDouble((count_di != 1) ? ((average_plusdi * (count_di - 1)) + adx_value2) / count_di : adx_value2, _Digits);
      return return_value;
    }
    return average_plusdi;
  }
};
Trading *trading;
