//+------------------------------------------------------------------+
//|                                                MA_Cross_Test.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int magic_number = 1234;
extern double lots = 1.0;
extern double profit_point = 100;
extern double loss_point = 30;
extern int short_ma_line = 20;
extern int long_ma_line = 200;

int current_bar;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   current_bar = Bars;
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
      
      // 현재 봉 장기 이동평균선 값
      double current_ma_long_value;
      // 전 봉 장기 이동평균선 값
      double before_ma_long_value;
      // 현재 봉 단기 이동평균선 값
      double current_ma_short_value;
      // 전 봉 단기 이동평균선 값 
      double before_ma_short_value;
   
      current_ma_long_value = iMA(NULL,
      0,
      long_ma_line,
      0,
      MODE_SMA,
      PRICE_CLOSE,
      0);
      before_ma_long_value = iMA(NULL,
      0,
      long_ma_line,
      0,
      MODE_SMA,
      PRICE_CLOSE,
      1);
      current_ma_short_value = iMA(NULL,
      0,
      short_ma_line,
      0,
      MODE_SMA,
      PRICE_CLOSE,
      0);
      before_ma_short_value = iMA(NULL,
      0,
      short_ma_line,
      0,
      MODE_SMA,
      PRICE_CLOSE,
      1);
            
      // golden-cross
      if(!is_buy && current_ma_short_value > current_ma_long_value && before_ma_long_value > before_ma_short_value){
         ticket = OrderSend(Symbol(),
         OP_BUY,
         lots,
         Ask,
         10,
         Ask-(loss_point*Point),
         Ask+(profit_point*Point),
         "MA",
         magic_number,
         0,
         Blue);
         Print(" current_ma_short_value : ",current_ma_short_value," > current_ma_long_value : ",current_ma_long_value);
      // dead-cross
      }else if(!is_sell && current_ma_long_value > current_ma_short_value && before_ma_short_value > before_ma_long_value){
         ticket = OrderSend(Symbol(),
         OP_SELL,
         lots,
         Bid,
         10,
         Bid+(loss_point*Point),
         Bid-(profit_point*Point),
         "MA",
         magic_number,
         0,
         Red);
      }
      current_bar += 1;
   }
  }
//+------------------------------------------------------------------+
