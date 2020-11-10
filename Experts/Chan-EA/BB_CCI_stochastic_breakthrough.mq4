//+------------------------------------------------------------------+
//|                               BB_CCI_stochastic_breakthrough.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link "https://www.mql5.com"
#property version "1.00"
#property strict

#include <ChanInclude/MQL4Function.mqh>

//------- external parameters ---------------------------------------+
extern string nameInd1 = "___________Stochastic___________";      // Stochastic
extern int Stochastic_period = 45;                                // Stochastic period
extern ENUM_APPLIED_PRICE Stochastic_applied_price = PRICE_CLOSE; // Stochastic applied price
extern string nameInd2 = "___________MACD___________";            // MACD
extern int MACD_short_period = 12;                                // MACD Short Period
extern int MACD_long_period = 26;                                 // MACD Long Period
extern int MACD_signal_period = 9;                                // MACD Signal Period
extern string EA_properties = "___________Expert___________";     // Expert properties
extern double Lot = 0.01;                                         // Lot
extern int AllowLoss = 300;                                       // allow Loss, 0 - close by Stocho
extern int TrailingStop = 300;                                    // Trailing Stop, 0 - close by Stocho
extern int Slippage = 10;                                         // Slippage
extern int NumberOfTry = 5;                                       // number of trade attempts
extern int MagicNumber = 5577555;                                 // Magic Number
extern int average_number = 2;                                    // breakthrough Number

datetime current_time;
bool is_buy, is_sell;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{


  stochasticBreak = new StochasticBreak();
  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  if(stochasticBreak != NULL){
    delete stochasticBreak;
    stochasticBreak = NULL;
  }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  if (Time[0] != current_time)
  {
    current_time = Time[0];
  }
  stochasticBreak.MaxMinCalculate();
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
