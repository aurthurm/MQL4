//+------------------------------------------------------------------+
//|                                             test_OrdersTotal.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <ChanInclude/MQL4Function.mqh>


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

extern int MagicNo = 1445029;
extern double Lots = 1.0;
extern double take_profit = 30;
extern double stop_loss = 100;
ModuleMQL4 *module;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   module = new ModuleMQL4();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   double BB_value = Close[1] - iBands(NULL,0,14,2,0,PRICE_CLOSE,MODE_LOWER,1);
   BB_value = NormalizeDouble(BB_value,Digits);
   Print(BB_value," , ",Point*100);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TestFunction(int &aaa)
  {
   Print(aaa);
   aaa = 3;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(module != NULL)
     {
      delete module;
      module = NULL;
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddPostion(double &profit)
  {
   int total = OrdersTotal();
   for(int i=0; i != total; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         profit += OrderOpenPrice();
        }
     }
   double unit_price = NormalizeDouble(profit/total,5);
   Print("profit = ",total*Lots*100000*(Bid-unit_price));

  }
//+------------------------------------------------------------------+
