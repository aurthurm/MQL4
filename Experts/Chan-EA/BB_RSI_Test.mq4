//+------------------------------------------------------------------+
//|                                                  BB_RSI_Test.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Arrays/ArrayDouble.mqh>

extern int magic_number = 1234;
extern double lots = 1.0;
extern int rsi_periods = 14;
extern int bb_periods = 34;
extern double bb_deviation = 2;
extern double bb_width = 30;

CArrayDouble *rsi_array;

double bb_up,bb_down,bb_main,down_value,up_value;
bool buy_signal,sell_signal;

int current_bar;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   current_bar = Bars;
   InitData();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(rsi_array != NULL)
      delete rsi_array;

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(current_bar == Bars)
     {
      int ticket;
      rsi_array.Insert(iRSI(NULL,
                            0,
                            rsi_periods,
                            PRICE_CLOSE,
                            1),0);
      // Order type 검사,
      bool is_buy = false;
      bool is_sell = false;
      ValidityCheck(is_buy, is_sell);

      if(!is_buy)
        {
         BandCalculation();
         if(buy_signal && bb_down <= rsi_array[0]&& bb_main-bb_down <= bb_width)
           {
            ticket = OrderSend(Symbol(),
                               OP_BUY,
                               lots,
                               Close[1],
                               10,
                               0,
                               0,
                               "MA",
                               magic_number,
                               0,
                               Blue);
            buy_signal = false;
           }
         else
            if(!buy_signal)
              {
               buy_signal = bb_down > rsi_array[0];
              }
        }
      if(!is_sell)
        {
         BandCalculation();
         if(sell_signal && bb_up >= rsi_array[0] && bb_up-bb_main <= bb_width)
           {
            ticket = OrderSend(Symbol(),
                               OP_SELL,
                               lots,
                               Close[1],
                               10,
                               0,
                               0,
                               "MA",
                               magic_number,
                               0,
                               Red);

            sell_signal = false;
           }
         else
            if(!sell_signal)
              {
               sell_signal = bb_up < rsi_array[0];
              }
        }

      current_bar += 1;
     }
   BuySellClose();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitData()
  {
   rsi_array = new CArrayDouble;
   rsi_array.Resize(bb_periods);
   for(int i=0; i != bb_periods; i++)
     {
      rsi_array.Add(iRSI(NULL,
                         0,
                         rsi_periods,
                         PRICE_CLOSE,
                         i+1));
     }
   current_bar += 1;
   BandCalculation();
   buy_signal = bb_down > rsi_array[0];
   sell_signal = bb_up < rsi_array[0];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BandCalculation()
  {

   double buffer_array[];
   ArrayResize(buffer_array, bb_periods);

   for(int i=0; i<bb_periods; i++)
     {
      buffer_array[i] = rsi_array.At(i);
     }

   bb_up = iBandsOnArray(buffer_array,
                         0,
                         bb_periods,
                         bb_deviation,
                         0,
                         MODE_UPPER,
                         0);
   bb_down = iBandsOnArray(buffer_array,
                           0,
                           bb_periods,
                           bb_deviation,
                           0,
                           MODE_LOWER,
                           0);
   bb_main = iBandsOnArray(buffer_array,
                           0,
                           bb_periods,
                           bb_deviation,
                           0,
                           MODE_MAIN,
                           0);

   ArrayFree(buffer_array);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ValidityCheck(bool &is_buy, bool &is_sell)
  {
   for(int i =0; i != OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
           {
            if(OrderType() == OP_BUY)
              {
               is_buy = true;
              }
            else
               if(OrderType() == OP_SELL)
                 {
                  is_sell = true;
                 }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuySellClose()
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         double buffer_array[];
         ArrayResize(buffer_array, bb_periods);
         for(int j=0; j<bb_periods; j++)
           {
            buffer_array[j] = iRSI(NULL,0,rsi_periods,PRICE_CLOSE,j);
           }
         double bb_value = iBandsOnArray(buffer_array,
                                         0,
                                         bb_periods,
                                         bb_deviation,
                                         0,
                                         MODE_MAIN,
                                         0);
         double rsi_value = buffer_array[0];                                
         ArrayFree(buffer_array);
         if(OrderType() == OP_BUY)
           {
            Print(rsi_value,">=",bb_value);
            if(rsi_value >= bb_value)
              {
               OrderClose(OrderTicket(),lots,Bid,10,Blue);
              }
           }
         if(OrderType() == OP_SELL)
           {
            Print(rsi_value,"<=",bb_value);
            if(rsi_value <= bb_value)
              {
               OrderClose(OrderTicket(),lots,Ask,10,Red);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
