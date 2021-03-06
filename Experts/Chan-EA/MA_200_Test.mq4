//+------------------------------------------------------------------+
//|                                                  MA_200_Test.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int magic_number = 1234;
extern double lots = 1.0;
extern int ma_line = 200;
extern double profit_point = 100;
extern double loss_point = 30;

// current_bar 하나 기준

int current_bar;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   current_bar = Bars;
   return(INIT_SUCCEEDED);
  }

void OnTick(){
      if(current_bar == Bars){
      int i, ticket, total;
   
      // Order type 검사,
      total = OrdersTotal();
      bool is_buy = false;
      bool is_sell = false;
   
      for(i =0; i != total; i++)
      {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
            if(OrderMagicNumber() == magic_number && OrderSymbol() == Symbol()){
               if(OrderType() == OP_BUY){
                  is_buy = true; 
               }else if(OrderType() == OP_SELL){
                  is_sell = true;
               }
            }
         }
      }
      double ma_200_value;
   
      // 전 캔틀 종가 가격
      double close_price = Close[1];
   
      // 전 캔틀 200 MA value
      ma_200_value = iMA(NULL,
      0,
      ma_line,
      0,
      MODE_SMA,
      PRICE_CLOSE,
      1);
      if(!is_buy && close_price > ma_200_value){
         ticket = OrderSend(Symbol(),
         OP_BUY,
         lots,
         close_price,
         10,
         close_price-(loss_point*Point),
         close_price+(profit_point*Point),
         "MA",
         magic_number,
         0,
         Blue);
      }else if(!is_sell && close_price < ma_200_value){
         ticket = OrderSend(Symbol(),
         OP_SELL,
         lots,
         close_price,
         10,
         close_price+(loss_point*Point),
         close_price-(profit_point*Point),
         "MA",
         magic_number,
         0,
         Red);
      }
      current_bar += 1;
   }
}

  
void OnDeinit(const int reason)
  {
//---
  }
