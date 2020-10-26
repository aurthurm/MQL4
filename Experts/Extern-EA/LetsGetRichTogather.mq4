//+------------------------------------------------------------------+
//|                                            Strategy: LetsGetRichTogather.mq4 |
//|                                       Created with Gharti |
//|                                             http://Gharti.com |
//+------------------------------------------------------------------+
#property copyright "gharti.com"
#property link      "http://gharti.com"
#property version   "1.00"
#property description ""

#include <stdlib.mqh>
#include <stderror.mqh>

int LotDigits; //initialized in OnInit
int MagicNumber = 1268539;
int NextOpenTradeAfterBars = 0; //next open trade after time
datetime LastTradeTime = 0;
int NextOpenTradeAfterTOD_Hour = 00; //next open trade after time of the day
int NextOpenTradeAfterTOD_Min = 00; //next open trade after time of the day
datetime NextTradeTime = 0;
int TOD_From_Hour = 10; //time of the day
int TOD_From_Min = 45; //time of the day
int TOD_To_Hour = 18; //time of the day
int TOD_To_Min = 15; //time of the day
int MaxTradeDurationBars = 0; //maximum trade duration
int MinTradeDurationBars = 0; //minimum trade duration
extern double TradeSize = 0.1;
double MaxSpread = 0;
extern int MaxSlippage = 3; //adjusted in OnInit
extern bool TradeMonday = true;
extern bool TradeTuesday = true;
extern bool TradeWednesday = true;
extern bool TradeThursday = true;
extern bool TradeFriday = true;
extern bool TradeSaturday = false;
extern bool TradeSunday = false;
double MaxSL = 9;
double MinSL = 9;
double MaxTP = 9;
double MinTP = 9;
bool crossed[2]; //initialized to true, used in function Cross
extern bool Send_Email = true;
extern bool Audible_Alerts = true;
int MaxOpenTrades = 1;
int MaxLongTrades = 1000;
int MaxShortTrades = 1000;
int MaxPendingOrders = 1000;
extern bool Hedging = true;
int OrderRetry = 5; //# of retries if sending order returns error
int OrderWait = 5; //# of seconds to wait if sending order returns error
double myPoint; //initialized in OnInit

bool inTimeInterval(datetime t, int TOD_From_Hour, int TOD_From_Min, int TOD_To_Hour, int TOD_To_Min)
  {
   string TOD = TimeToString(t, TIME_MINUTES);
   string TOD_From = StringFormat("%02d", TOD_From_Hour)+":"+StringFormat("%02d", TOD_From_Min);
   string TOD_To = StringFormat("%02d", TOD_To_Hour)+":"+StringFormat("%02d", TOD_To_Min);
   return((StringCompare(TOD, TOD_From) >= 0 && StringCompare(TOD, TOD_To) <= 0)
     || (StringCompare(TOD_From, TOD_To) > 0
       && ((StringCompare(TOD, TOD_From) >= 0 && StringCompare(TOD, "23:59") <= 0)
         || (StringCompare(TOD, "00:00") >= 0 && StringCompare(TOD, TOD_To) <= 0))));
  }

void CloseByDuration(int sec) //close trades opened longer than sec seconds
  {
   if(!IsTradeAllowed()) return;
   bool success = false;
   int err;
   int total = OrdersTotal();
   for(int i = total-1; i >= 0; i--)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderType() > 1 || OrderOpenTime() + sec > TimeCurrent()) continue;
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
      double price = Bid;
      if(OrderType() == OP_SELL)
         price = Ask;
      success = OrderClose(OrderTicket(), NormalizeDouble(OrderLots(), LotDigits), NormalizeDouble(price, Digits()), MaxSlippage, clrWhite);
      if(!success)
        {
         err = GetLastError();
         myAlert("error", "OrderClose failed; error #"+err+" "+ErrorDescription(err));
        }
     }
   if(success) myAlert("order", "Orders closed by duration: "+Symbol()+" Magic #"+MagicNumber);
  }

bool TradeDayOfWeek()
  {
   int day = DayOfWeek();
   return((TradeMonday && day == 1)
   || (TradeTuesday && day == 2)
   || (TradeWednesday && day == 3)
   || (TradeThursday && day == 4)
   || (TradeFriday && day == 5)
   || (TradeSaturday && day == 6)
   || (TradeSunday && day == 0));
  }

bool Cross(int i, bool condition) //returns true if "condition" is true and was false in the previous call
  {
   bool ret = condition && !crossed[i];
   crossed[i] = condition;
   return(ret);
  }

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | Best BB @ "+Symbol()+","+Period()+" | "+message);
      if(Audible_Alerts) Alert(type+" | Best BB @ "+Symbol()+","+Period()+" | "+message);
      if(Send_Email) SendMail("Best BB", type+" | Best BB @ "+Symbol()+","+Period()+" | "+message);
     }
   else if(type == "order")
     {
      Print(type+" | Best BB @ "+Symbol()+","+Period()+" | "+message);
      if(Audible_Alerts) Alert(type+" | Best BB @ "+Symbol()+","+Period()+" | "+message);
      if(Send_Email) SendMail("Best BB", type+" | Best BB @ "+Symbol()+","+Period()+" | "+message);
     }
   else if(type == "modify")
     {
      Print(type+" | Best BB @ "+Symbol()+","+Period()+" | "+message);
      if(Audible_Alerts) Alert(type+" | Best BB @ "+Symbol()+","+Period()+" | "+message);
      if(Send_Email) SendMail("Best BB", type+" | Best BB @ "+Symbol()+","+Period()+" | "+message);
     }
  }

int TradesCount(int type) //returns # of open trades for order type, current symbol and magic number
  {
   int result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) continue;
      if(OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderType() != type) continue;
      result++;
     }
   return(result);
  }

int myOrderSend(int type, double price, double volume, string ordername) //send order, return ticket ("price" is irrelevant for market orders)
  {
   if(!IsTradeAllowed()) return(-1);
   int ticket = -1;
   int retries = 0;
   int err;
   int long_trades = TradesCount(OP_BUY);
   int short_trades = TradesCount(OP_SELL);
   int long_pending = TradesCount(OP_BUYLIMIT) + TradesCount(OP_BUYSTOP);
   int short_pending = TradesCount(OP_SELLLIMIT) + TradesCount(OP_SELLSTOP);
   string ordername_ = ordername;
   if(ordername != "")
      ordername_ = "("+ordername+")";
   //test Hedging
   if(!Hedging && ((type % 2 == 0 && short_trades + short_pending > 0) || (type % 2 == 1 && long_trades + long_pending > 0)))
     {
      myAlert("print", "Order"+ordername_+" not sent, hedging not allowed");
      return(-1);
     }
   //test maximum trades
   if((type % 2 == 0 && long_trades >= MaxLongTrades)
   || (type % 2 == 1 && short_trades >= MaxShortTrades)
   || (long_trades + short_trades >= MaxOpenTrades)
   || (type > 1 && long_pending + short_pending >= MaxPendingOrders))
     {
      myAlert("print", "Order"+ordername_+" not sent, maximum reached");
      return(-1);
     }
   //prepare to send order
   while(IsTradeContextBusy()) Sleep(100);
   RefreshRates();
   if(type == OP_BUY)
      price = Ask;
   else if(type == OP_SELL)
      price = Bid;
   else if(price < 0) //invalid price for pending order
     {
      myAlert("order", "Order"+ordername_+" not sent, invalid price for pending order");
	  return(-1);
     }
   int clr = (type % 2 == 1) ? clrRed : clrBlue;
   if(MaxSpread > 0 && Ask - Bid > MaxSpread * myPoint)
     {
      myAlert("order", "Order"+ordername_+" not sent, maximum spread "+DoubleToStr(MaxSpread * myPoint, Digits())+" exceeded");
      return(-1);
     }
   while(ticket < 0 && retries < OrderRetry+1)
     {
      ticket = OrderSend(Symbol(), type, NormalizeDouble(volume, LotDigits), NormalizeDouble(price, Digits()), MaxSlippage, 0, 0, ordername, MagicNumber, 0, clr);
      if(ticket < 0)
        {
         err = GetLastError();
         myAlert("print", "OrderSend"+ordername_+" error #"+err+" "+ErrorDescription(err));
         Sleep(OrderWait*1000);
        }
      retries++;
     }
   if(ticket < 0)
     {
      myAlert("error", "OrderSend"+ordername_+" failed "+(OrderRetry+1)+" times; error #"+err+" "+ErrorDescription(err));
      return(-1);
     }
   string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
   myAlert("order", "Order sent"+ordername_+": "+typestr[type]+" "+Symbol()+" Magic #"+MagicNumber);
   return(ticket);
  }

int myOrderModifyRel(int ticket, double SL, double TP) //modify SL and TP (relative to open price), zero targets do not modify
  {
   if(!IsTradeAllowed()) return(-1);
   bool success = false;
   int retries = 0;
   int err;
   SL = NormalizeDouble(SL, Digits());
   TP = NormalizeDouble(TP, Digits());
   if(SL < 0) SL = 0;
   if(TP < 0) TP = 0;
   //prepare to select order
   while(IsTradeContextBusy()) Sleep(100);
   if(!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
     {
      err = GetLastError();
      myAlert("error", "OrderSelect failed; error #"+err+" "+ErrorDescription(err));
      return(-1);
     }
   //prepare to modify order
   while(IsTradeContextBusy()) Sleep(100);
   RefreshRates();
   //convert relative to absolute
   if(OrderType() % 2 == 0) //buy
     {
      if(NormalizeDouble(SL, Digits()) != 0)
         SL = OrderOpenPrice() - SL;
      if(NormalizeDouble(TP, Digits()) != 0)
         TP = OrderOpenPrice() + TP;
     }
   else //sell
     {
      if(NormalizeDouble(SL, Digits()) != 0)
         SL = OrderOpenPrice() + SL;
      if(NormalizeDouble(TP, Digits()) != 0)
         TP = OrderOpenPrice() - TP;
     }
   if(CompareDoubles(SL, 0)) SL = OrderStopLoss(); //not to modify
   if(CompareDoubles(TP, 0)) TP = OrderTakeProfit(); //not to modify
   if(CompareDoubles(SL, OrderStopLoss()) && CompareDoubles(TP, OrderTakeProfit())) return(0); //nothing to do
   while(!success && retries < OrderRetry+1)
     {
      success = OrderModify(ticket, NormalizeDouble(OrderOpenPrice(), Digits()), NormalizeDouble(SL, Digits()), NormalizeDouble(TP, Digits()), OrderExpiration(), CLR_NONE);
      if(!success)
        {
         err = GetLastError();
         myAlert("print", "OrderModify error #"+err+" "+ErrorDescription(err));
         Sleep(OrderWait*1000);
        }
      retries++;
     }
   if(!success)
     {
      myAlert("error", "OrderModify failed "+(OrderRetry+1)+" times; error #"+err+" "+ErrorDescription(err));
      return(-1);
     }
   string alertstr = "Order modified: ticket="+ticket;
   if(!CompareDoubles(SL, 0)) alertstr = alertstr+" SL="+SL;
   if(!CompareDoubles(TP, 0)) alertstr = alertstr+" TP="+TP;
   myAlert("modify", alertstr);
   return(0);
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {   
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
      MaxSlippage *= 10;
     }
   //initialize LotDigits
   double LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   if(LotStep >= 1) LotDigits = 0;
   else if(LotStep >= 0.1) LotDigits = 1;
   else if(LotStep >= 0.01) LotDigits = 2;
   else LotDigits = 3;
   LastTradeTime = 0;
   NextTradeTime = 0;
   MaxSL = MaxSL * myPoint;
   MinSL = MinSL * myPoint;
   MaxTP = MaxTP * myPoint;
   MinTP = MinTP * myPoint;
   int i;
   //initialize crossed
   for (i = 0; i < ArraySize(crossed); i++)
      crossed[i] = true;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int ticket = -1;
   double price;   
   double SL;
   double TP;
   
   CloseByDuration(MaxTradeDurationBars * PeriodSeconds());
   
   //Open Buy Order, instant signal is tested first
   RefreshRates();
   if(Cross(0, Bid > iBands(NULL, PERIOD_CURRENT, 50, 3, 0, PRICE_CLOSE, MODE_LOWER, 0)) //Price crosses above Bollinger Bands
   )
     {
      RefreshRates();
      price = Ask;
      SL = 5 * myPoint; //Stop Loss = value in points (relative to price)
      if(SL > MaxSL) SL = MaxSL;
      if(SL < MinSL) SL = MinSL;
      TP = 10 * myPoint; //Take Profit = value in points (relative to price)
      if(TP > MaxTP) TP = MaxTP;
      if(TP < MinTP) TP = MinTP;
      if(TimeCurrent() - LastTradeTime < NextOpenTradeAfterBars * PeriodSeconds()) return; //next open trade after time
      if(TimeCurrent() <= NextTradeTime) return; //next open trade after time of the day
      if(!inTimeInterval(TimeCurrent(), TOD_From_Hour, TOD_From_Min, TOD_To_Hour, TOD_To_Min)) return; //open trades only at specific times of the day
      if(!TradeDayOfWeek()) return; //open trades only on specific days of the week   
      if(IsTradeAllowed())
        {
         ticket = myOrderSend(OP_BUY, price, TradeSize, "");
         if(ticket <= 0) return;
        }
      else //not autotrading => only send alert
         myAlert("order", "");
      LastTradeTime = TimeCurrent();
      NextTradeTime = StringToTime(IntegerToString(NextOpenTradeAfterTOD_Hour)+":"+IntegerToString(NextOpenTradeAfterTOD_Min));
      while(NextTradeTime <= TimeCurrent()) NextTradeTime += 86400;
      myOrderModifyRel(ticket, 0, TP);
      myOrderModifyRel(ticket, SL, 0);
     }
   
   //Open Sell Order, instant signal is tested first
   RefreshRates();
   if(Cross(1, Bid < iBands(NULL, PERIOD_CURRENT, 50, 3, 0, PRICE_CLOSE, MODE_UPPER, 0)) //Price crosses below Bollinger Bands
   )
     {
      RefreshRates();
      price = Bid;
      SL = 5 * myPoint; //Stop Loss = value in points (relative to price)
      if(SL > MaxSL) SL = MaxSL;
      if(SL < MinSL) SL = MinSL;
      TP = 10 * myPoint; //Take Profit = value in points (relative to price)
      if(TP > MaxTP) TP = MaxTP;
      if(TP < MinTP) TP = MinTP;
      if(TimeCurrent() - LastTradeTime < NextOpenTradeAfterBars * PeriodSeconds()) return; //next open trade after time
      if(TimeCurrent() <= NextTradeTime) return; //next open trade after time of the day
      if(!inTimeInterval(TimeCurrent(), TOD_From_Hour, TOD_From_Min, TOD_To_Hour, TOD_To_Min)) return; //open trades only at specific times of the day
      if(!TradeDayOfWeek()) return; //open trades only on specific days of the week   
      if(IsTradeAllowed())
        {
         ticket = myOrderSend(OP_SELL, price, TradeSize, "");
         if(ticket <= 0) return;
        }
      else //not autotrading => only send alert
         myAlert("order", "");
      LastTradeTime = TimeCurrent();
      NextTradeTime = StringToTime(IntegerToString(NextOpenTradeAfterTOD_Hour)+":"+IntegerToString(NextOpenTradeAfterTOD_Min));
      while(NextTradeTime <= TimeCurrent()) NextTradeTime += 86400;
      myOrderModifyRel(ticket, 0, TP);
      myOrderModifyRel(ticket, SL, 0);
     }
  }
//+------------------------------------------------------------------+