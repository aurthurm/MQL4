//+------------------------------------------------------------------+
//|                                                  BB_CCI_Zero.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//------- external parameters ---------------------------------------+
extern string             nameInd1           = "___________BB__________";  // BB
extern int                BB_period          = 14;                         // BB period
extern ENUM_APPLIED_PRICE BB_applied_price   = PRICE_CLOSE;                // BB applied price
extern double BB_deviation                   = 2.0;                        // BB deviation
extern string             nameInd2           = "___________CCI_________";  // CCI
extern int                CCI_period         = 20;                         // CCI period
extern ENUM_APPLIED_PRICE CCI_applied_price  = PRICE_CLOSE;                // CCI applied price
extern string             EA_properties      = "_________Expert_________"; // Expert properties
extern double             Lot                = 0.01;                       // Lot
extern int                AllowLoss          = 300;                        // allow Loss, 0 - close by Stocho
extern int                Profit             = 30;
extern int                StopLoss           = 40;
extern int                Slippage           = 10;                         // Slippage
extern int                NumberOfTry        = 5;                          // number of trade attempts
extern int                MagicNumber        = 5577555;                    // Magic Number


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
      string text = "You must allow trading!";
      Print(text);
      Comment(text);
      return;
     }
   if(Bars == current_bar)
     {
      current_bar += 1;
     }
   //BuySend();
   SellSend();
   SellClose();
   //BuyClose();
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SellSend()
  {
   double prev_bands_value = iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,MODE_UPPER,1);
   prev_bands_value = NormalizeDouble(prev_bands_value,Digits);
   double prev_cci_value = iCCI(NULL,0,CCI_period,CCI_applied_price,1);
   // 이전 볼린져 밴드 up < 이전 종가 가격 and cci >= 100
   if(prev_bands_value < Close[1] && prev_cci_value >= 100)
     {
      double currnet_bands_value = iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,MODE_UPPER,0);
      double current_cci_value = iCCI(NULL,0,CCI_period,CCI_applied_price,0);
      // 현재 볼린져 밴드 up < 현재 종가 and 스토캐스틱 %D < 스토캐스틱 Slow%D
      if(currnet_bands_value<Close[0] && (iStochastic(NULL,0,5,3,3,MODE_SMA,0,1,0)>iStochastic(NULL,0,5,3,3,MODE_SMA,0,0,0)))
        {
         int ticket = OrderSend(NULL,
                                OP_SELL,
                                Lot,
                                Bid,
                                Slippage,
                                0,
                                0,
                                "SELL",
                                MagicNumber,
                                0,
                                Red);
         //ModifyOrder();
         OrderModify(ticket,Bid,0,Bid-(Profit*Point),0,Red);
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuyClose()
  {
   for(int i=0; i != NumberOfTry; i++)
     {
      int total = OrdersTotal();
      if(total == 0)
         return;
      RefreshRates();
      for(int j=0; j<total; j++)
        {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderType() == OP_BUY)
              {
               double bb_value = iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,MODE_UPPER,0);
               if(Close[0] >= bb_value)
                 {
                  OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,White);
                 }
              }
           }
        }

     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SellClose()
  {
   for(int i=0; i != NumberOfTry; i++)
     {
      int total = OrdersTotal();
      if(total == 0)
         return;
      RefreshRates();
      for(int j=0; j<total; j++)
        {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderType() == OP_SELL)
              {
               double bb_value = iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,MODE_LOWER,0);
               if(Close[0] <= bb_value-(Point*50))
                 {
                  OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,White);
                 }
              }
           }
        }

     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuySend()
  {
   double prev_bands_value = iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,MODE_LOWER,1);
   prev_bands_value = NormalizeDouble(prev_bands_value,Digits);
   double prev_cci_value = iCCI(NULL,0,CCI_period,CCI_applied_price,1);
   // 이전 볼린져 밴드 down > 이전 종가 가격 and cci <= -100
   if(prev_bands_value > Close[1] && prev_cci_value <= -100)
     {
      double currnet_bands_value = iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,MODE_LOWER,0);
      double current_cci_value = iCCI(NULL,0,CCI_period,CCI_applied_price,0);
      // 현재 볼린져 밴드 down > 현재 종가 and 스토캐스틱 %D > 스토캐스틱 Slow%D
      if(currnet_bands_value>Close[0] && (iStochastic(NULL,0,5,3,3,MODE_SMA,0,1,0)<iStochastic(NULL,0,5,3,3,MODE_SMA,0,0,0)))
        {
         int ticket = OrderSend(NULL,
                                OP_BUY,
                                Lot,
                                Ask,
                                Slippage,
                                0,
                                0,
                                "Buy",
                                MagicNumber,
                                0,
                                Blue);
         //ModifyOrder();
         OrderModify(ticket,Ask,0,Ask+(Profit*Point),0,Blue);
        }
     }
  }
//+------------------------------------------------------------------+
