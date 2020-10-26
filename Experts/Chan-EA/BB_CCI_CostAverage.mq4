//+------------------------------------------------------------------+
//|                                        BB_RSI_CostAverage_v2.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#include <Arrays/ArrayDouble.mqh>
//------- external parameters ---------------------------------------+
extern string             nameInd1           = "___________BB__________";  // BB
extern int                BB_period          = 3;                          // BB period
extern ENUM_APPLIED_PRICE BB_applied_price   = PRICE_CLOSE;                // BB applied price
extern double BB_deviation                   = 2.0;                        // BB deviation
extern string             nameInd2           = "___________CCI_________";  // CCI
extern int                CCI_period         = 20;                         // CCI period
extern int                CCI_up_level        = 200;                       // level up - CCI
extern int                CCI_dn_level        = -200;                      // level down - CCI
extern ENUM_APPLIED_PRICE CCI_applied_price  = PRICE_CLOSE;                // CCI applied price
extern string             EA_properties      = "_________Expert_________"; // Expert properties
extern double             Lot                = 0.1;                        // Lot
extern int                AllowLoss          = 300;                        // allow Loss, 0 - close by Stocho
extern int                TrailingStop       = 300;                        // Trailing Stop, 0 - close by Stocho
extern int                Slippage           = 10;                         // Slippage
extern int                NumberOfTry        = 5;                          // number of trade attempts
extern int                MagicNumber        = 5577555;                    // Magic Number
extern int                TradingPosition    = 100;

//global variable
int current_bar;
bool is_buy,is_sell;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   current_bar = Bars;
   Comment("Waiting a new tick!");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(!IsTradeAllowed())
     {
      string _txt_new="You must allow trading!";
      Print(_txt_new);
      Comment(_txt_new);
      return;
     }
   if(current_bar == Bars)
     {
      double cci_value = iCCI(NULL,0,CCI_period,CCI_applied_price,1);
      if(cci_value >= CCI_up_level)
        {
         is_sell = true;
        }
      else
         if(cci_value <= CCI_dn_level)
           {
            is_buy = true;
           }
      current_bar += 1;
     }
   BuySellCancel();
   BuySellTranding();
   BuySellClose();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuySellTranding()
  {
   if(is_buy)
     {
      double BB_value = Close[0] - iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,MODE_UPPER,0);
      BB_value = NormalizeDouble(BB_value,Digits);
      if(BB_value*-1 >= Digits*TradingPosition)
        {
         OrderSend(NULL,
                   OP_BUY,
                   Lot,
                   Bid,
                   Slippage,
                   0,
                   0,
                   "MA",
                   MagicNumber,
                   0,
                   Red);
         is_buy = false;
        }
     }
   else
      if(is_sell)
        {
         double BB_value = Close[0]-iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,MODE_LOWER,0);
         BB_value = NormalizeDouble(BB_value,Digits);
         if(BB_value >= Digits*TradingPosition)
           {
            OrderSend(NULL,
                      OP_SELL,
                      Lot,
                      Ask,
                      Slippage,
                      0,
                      0,
                      "MA",
                      MagicNumber,
                      0,
                      Blue);
            is_sell = false;
           }
        }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuySellCancel()
  {
   if(is_sell)
     {
      double cci_value = iCCI(NULL,0,CCI_period,CCI_applied_price,1);
      if(cci_value <=CCI_up_level)
        {
         is_sell = false;
        }
     }
   else
      if(is_buy)
        {
         double cci_value = iCCI(NULL,0,CCI_period,CCI_applied_price,1);
         if(cci_value >= CCI_dn_level)
           {
            is_buy = false;
           }
        }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuySellClose()
  {
   if(is_buy){
      double ma_value = iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,MODE_MAIN,0);
      if(ma_value <= Bid){
      
      }
   }else if(is_sell){
      double ma_value = iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,MODE_MAIN,0);
      if(ma_value >= Ask){
      }
   }
  }
//+------------------------------------------------------------------+
