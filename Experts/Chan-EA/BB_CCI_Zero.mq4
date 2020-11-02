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
extern int                Profit             = 10;
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
   BuySellSend();
   //BuySellClose();
   
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuySellSend()
  {
   double bands_value = iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,MODE_MAIN,0);
   bands_value = NormalizeDouble(bands_value,Digits);
   if(bands_value == Close[0])
     {
      bands_value = iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,MODE_MAIN,1);
      // 이전 Band(MA-middle) Up or Down
      //if(bands_value > Close[1])
      //  {
      //   OrderSend(NULL,
      //             OP_BUY,
      //             Lot,
      //             Close[0],
      //             Slippage,
      //             0,
      //             Close[0]+(Profit*Point),
      //             "BUY",
      //             MagicNumber,
      //             0,
      //             Bid);
      //  }
      //else
         if(bands_value < Close[1] && (iStochastic(NULL,0,5,3,3,MODE_SMA,0,1,1)>iStochastic(NULL,0,5,3,3,MODE_SMA,0,0,1)))
           {
            OrderSend(NULL,
                      OP_SELL,
                      Lot,
                      Close[0],
                      Slippage,
                      0,
                      Close[0]-(Profit*Point),
                      "BUY",
                      MagicNumber,
                      0,
                      Blue);
           }
     }
  }
//+------------------------------------------------------------------+

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
      for(int j=0; j<total; j++)
        {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
           {
            int mode =  (OrderType() == OP_BUY) ? MODE_LOWER : MODE_UPPER;
            double ma_value = iBands(NULL,0,BB_period,BB_deviation,0,BB_applied_price,mode,0);
            ma_value = NormalizeDouble(ma_value,Digits);
            if(Close[0] == ma_value){
               OrderClose(OrderTicket(),OrderLots(),Close[0],Slippage,White);
            }
           }
        }

     }
  }
//+------------------------------------------------------------------+
