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
extern double stoch_max = 80;                                // Stochastic buying signal
extern double stoch_min = 20;                                // Stochastic selling signal

extern string nameInd2 = "_______________ADX_______________"; // ADX
extern int ADX_period = 14;                                   // ADX period
extern ENUM_APPLIED_PRICE ADX_Price = PRICE_CLOSE;            // ADX Applied Price

extern string nameInd3 = "_______________CCI_______________"; // CCI
extern int CCI_period = 14;                                   // CCI period
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

bool is_buy;
bool is_sell;
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
  if (module != NULL)
  {
    delete module;
    module = NULL;
  }
}

void OnTick()
{
}
