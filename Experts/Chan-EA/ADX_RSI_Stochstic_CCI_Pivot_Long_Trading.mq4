#property copyright "EA_jjangchan"
#property link "https://www.github.com/jjangchan"
#property version "1.00"
#property strict

#include <ChanInclude/MQL4Function.mqh>

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

bool IsBuySell[4];
ModuleMQL4 *module;

int OnInit()
{
  module = new ModuleMQL4();
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
}

void OnTick()
{
}

class Trading
{
private:
  /* data */
public:
  Trading(/* args */) {}

  ~Trading() {}

  int BuySignal()
  {
    double lot = Lot;
    if(BuyPivotAutoLot(lot) && BuyIsCCIStoch() ){
      int ticket = OrderSend(NULL, OP_BUY, lot, Ask, Slippage, 0, 0, "Pivot", MagicNumber, 0, Blue);
    }
  }

  int SellSignal()
  {
    double lot = Lot;
     if(SellPivotAutoLot(lot) && SellIsCCIStoch()){
       int ticket = OrderSend(NULL, OP_BUY, lot, Ask, Slippage, 0, 0, "Pivot", MagicNumber, 0, Red);
    } 
  }

private:

  bool DICross(double value1, double value2)
  {
    double adx_value = iADX(NULL, 0, ADX_period, ADX_Price, 0, 0);
    return ((adx_value > value2) && (value1 > value2)) ? true : false;
  }

  bool BuyIsCCIStoch()
  {
    double CCI_value = iCCI(NULL, 0, CCI_period, CCI_Price, 0);
    double Stoch_value = iStochastic(NULL, 0, K_period, D_period, Slow_period, Stoch_Method, 0, 0, 0);
    return ((CCI_value > CCI_max) || (Stoch_value > stoch_max)) ? true : false;
  }

  bool SellIsCCIStoch()
  {
    double CCI_value = iCCI(NULL, 0, CCI_period, CCI_Price, 0);
    double Stoch_value = iStochastic(NULL, 0, K_period, D_period, Slow_period, Stoch_Method, 0, 0, 0);
    return ((CCI_value < CCI_min) || (Stoch_value < stoch_min)) ? true : false;
  }

  bool BuyPivotAutoLot(double &lot)
  {
    double pivot_s1 = iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 1, 0);
    double pivot_s2 = iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 2, 0);
    double pivot_pp = iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 0, 0);

    double plus_value = iADX(NULL, 0, ADX_period, ADX_Price, 1, 0);
    double minus_value = iADX(NULL, 0, ADX_period, ADX_Price, 2, 0);

    if (!IsBuySell[0] && Close[0] >= pivot_s2 && DICross(plus_value, minus_value))
    {
      lot *= Weight;
      IsBuySell[0] = true;
      return true;
    }

    return (!IsBuySell[1] && Close[0] >= pivot_s1 && DICross(plus_value, minus_value))
    {
      IsBuySell[1] = true;
      return true;
    }
    return false;
  }

  bool SellPivotAutoLot(double &lot)
  {
    double pivot_r1 = iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 3, 0);
    double pivot_r2 = iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 4, 0);
    double pivot_pp = iCustom(NULL, 0, "Extern/CFTPivotalPoint.ex4", 0, 0);

    double plus_value = iADX(NULL, 0, ADX_period, ADX_Price, 1, 0);
    double minus_value = iADX(NULL, 0, ADX_period, ADX_Price, 2, 0);

    if (!IsBuySell[3] && Close[0] <= pivot_r2 && DICross(minus_value, plus_value))
    {
      lot *= Weight;
      IsBuySell[3] = true;
      return true;
    }

    if (!IsBuySell[4] && Close[0] <= pivot_r1 && DICross(minus_value, plus_value))
    {
      IsBuySell[4] = true
      return true;
    }
    return false;
  }
};
