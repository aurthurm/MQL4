//+------------------------------------------------------------------+
//|                                             test_OrdersTotal.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

extern int MagicNo = 1445029;
extern double Lots = 1.0;
extern double take_profit = 30;
extern double stop_loss = 100;

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
   double price;
   AddPostion(price);
   
//   double ma_200_value = iMA(NULL,0,200,0,MODE_SMA,PRICE_CLOSE,1);
//   Print("200 MA Value : ",ma_200_value);
//   Print("current buy price :",Bid);
//   Print("current Sell price :",Ask);
//   Print("current before bar higt : ",High[1]);
//   Print("Point value : ",Point);
//   Print("Close Price : ",Close[1]);

//   int ticket = OrderSend(Symbol(), OP_BUY, 1.0,Ask,10, Ask-(stop_loss*Point),Ask+(take_profit*Point),"MA",MagicNo,0,Blue);
//   if(ticket<0)
//     {
//      Print("OrderSend failed with error #",GetLastError());
//     }
//   else
//      Print("OrderSend placed successfully");

  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

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
