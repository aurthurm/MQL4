//+------------------------------------------------------------------+
//|                                        BB_RSI_CostAverage.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//------- external parameters ---------------------------------------+
extern string             nameInd1           = "___________BB__________";  // BB
extern int                BB_period          = 14;                          // BB period
extern ENUM_APPLIED_PRICE BB_applied_price   = PRICE_CLOSE;                // BB applied price
extern double BB_deviation                   = 2.0;                        // BB deviation
extern string             nameInd2           = "___________CCI_________";  // CCI
extern int                CCI_period         = 20;                         // CCI period
extern int                CCI_up_level        = 100;                       // level up - CCI
extern int                CCI_dn_level        = -100;                      // level down - CCI
extern ENUM_APPLIED_PRICE CCI_applied_price  = PRICE_CLOSE;                // CCI applied price
extern string             EA_properties      = "_________Expert_________"; // Expert properties
extern double             Lot                = 0.01;                        // Lot
extern int                AllowLoss          = 300;                        // allow Loss, 0 - close by Stocho
extern int                TrailingStop       = 300;                        // Trailing Stop, 0 - close by Stocho
extern int                Slippage           = 10;                         // Slippage
extern int                NumberOfTry        = 5;                          // number of trade attempts
extern int                MagicNumber        = 5577555;                    // Magic Number
extern int                TradingPosition    = 100;
extern int                CCIGradient        = 50;                        // CCI Gradient


//global variable
int current_bar;
bool is_buy,is_sell;
int sell_count,buy_count;

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
   BuySellSend();
   BuySellClose();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuySellSend()
  {
   int mode_index = is_buy ? 2: is_sell ? 1:0;
   if(mode_index == 0)
      return;
   double BB_value = iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,mode_index,0);
   BB_value = is_buy ? BB_value-Close[0] : Close[0]-BB_value;
   BB_value = NormalizeDouble(BB_value,Digits);
   if(BB_value >= Point*TradingPosition)
     {
      double CCI_value = MathAbs(iCCI(NULL,0,CCI_period,CCI_applied_price,0)-iCCI(NULL,0,CCI_period,CCI_applied_price,1));
      if(is_buy)
        {
         if(CCI_value >= CCIGradient || sell_count > buy_count)
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
            sell_count += 1;
           }
         else
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
                      Blue);
            buy_count += 1;
           }
         is_buy = false;
        }
      else
        {
         if(CCI_value >= CCIGradient || buy_count > sell_count)
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
                      Blue);
            buy_count +=1;
           }
         else
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
                      Red);
            sell_count += 1;
           }
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
   for(int i=0; i != NumberOfTry; i++)
     {
      int total = OrdersTotal();
      if(total == 0)
         return;
      RefreshRates();
      double ma_value = iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,MODE_MAIN,0);
      ma_value = NormalizeDouble(ma_value,Digits);
      for(int j=0; j<total; j++)
        {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderType() == OP_BUY)
              {
               if(ma_value == Close[0])
                 {
                  OrderClose(OrderTicket(),OrderLots(),Close[0], Slippage, White);
                  buy_count -= 1;
                 }
              }
            else
               if(OrderType() == OP_SELL)
                 {
                  if(ma_value == Close[0])
                    {
                     OrderClose(OrderTicket(),OrderLots(),Close[0], Slippage, White);
                     sell_count -= 1;
                    }
                 }
           }
        }

     }
  }
//+------------------------------------------------------------------+
