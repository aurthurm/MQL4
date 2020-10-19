//+------------------------------------------------------------------+
//|                                           BB_RSI_CostAverage.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Arrays/ArrayDouble.mqh>

extern int magic_number = 1234;
extern double lots = 0.1;
extern int add_distance = 20;
extern int end_loss = 700;
extern int rsi_periods = 14;
extern int bb_periods = 34;
extern int bb_deviation = 2;
extern int bb_width = 20;

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
      buy_signal = bb_down > rsi_array[0] && rsi_array[0] <= 30;
      sell_signal = bb_up < rsi_array[0] && rsi_array[0] >= 70;


      rsi_array.Insert(iRSI(NULL,
                            0,
                            rsi_periods,
                            PRICE_CLOSE,
                            1),0);
      BandCalculation();
      if(OrdersTotal() == 0)
        {
         if(buy_signal && bb_down <= rsi_array[0])
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

           }
         else
            if(sell_signal && bb_up >= rsi_array[0])
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
         double rsi_value = buffer_array[0];
         double bb_value;
         ArrayFree(buffer_array);
         if(OrderType() == OP_BUY)
           {
            bb_value = iBandsOnArray(buffer_array,
                                     0,
                                     bb_periods,
                                     bb_deviation,
                                     0,
                                     MODE_UPPER,
                                     0);
            Print(rsi_value,">=",bb_value);
            if(rsi_value >= bb_value)
              {
               OrderClose(OrderTicket(),lots,Bid,10,Blue);
              }
           }
         if(OrderType() == OP_SELL)
           {
            bb_value = iBandsOnArray(buffer_array,
                                     0,
                                     bb_periods,
                                     bb_deviation,
                                     0,
                                     MODE_LOWER,
                                     0);
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
