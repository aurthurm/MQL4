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
extern int count_cci = 2;
ModuleMQL4 *module;
datetime time;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//Print("High : ",High[iHighest(NULL,0,MODE_HIGH,10,5)]);
   int index,count = 0;
   double close_price = Close[0];
   double value = iCustom(NULL,0,"Extern/waverider zigzag.ex4",0,cnt);
   while(value == 0x7fffffff && count != 2)
     {
      value = iCustom(NULL,0,"Extern/waverider zigzag.ex4",0,index);
      if(value != 0x7fffffff) break;
      index+=1;
     }
   Print(value);

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
