#property copyright "jjangchan"
#property link "https://www.github.com/jjangchan"
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>

class ModuleMQL4
{
private:
   int binance_start;
   datetime binance_time;
   double binance_total;
   double min_lot;
   double max_lot;
   double division_price;

public:
   ModuleMQL4() {}
   ~ModuleMQL4() {}

   void TradingOnOff()
   {
      string message;
      if (!IsTradeAllowed())
      {
         message = "You must allow trading!";
         Comment(message);
      }
   }

   void PushAlersTrading(string SoundFile, bool PopupAlerts, bool EmailAlerts, bool PushNotificationAlerts, bool SoundAlerts)
   {
      string message;
      if (!IsTradeAllowed())
      {
         message = "You must allow trading!";
         doAlerts(message, SoundFile, PopupAlerts, EmailAlerts, PushNotificationAlerts, SoundAlerts);
         Comment(message);
      }
   }

   void ShowError()
   {
      Print("Error : ", ErrorDescription(GetLastError()));
   }

   void InitAccountHistory(double min_lot, double max_lot, double division_price)
   {
      for (int i = 0; i < OrdersHistoryTotal(); i++)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         {
            if (OrderType() == 6)
            {
               binance_time = OrderOpenTime();
            }
            if (OrderType() > 5)
            {
               binance_total += OrderProfit();
            }
         }
      }
      binance_start = OrdersHistoryTotal();
      if (binance_total >= 25500)
      {
         this.min_lot = 0.17;
         this.max_lot = 3.4;
      }
      else
      {
         int num = binance_total / division_price;
         this.min_lot = num * min_lot;
         this.max_lot = num * max_lot;
      }
      Print("Total Binance : ", binance_total, " , minLot=", this.min_lot, " , MaxLot=", this.max_lot);
      this.division_price = division_price;
   }

   void InfoDespositWithdrawal()
   {
      if (binance_start == OrdersHistoryTotal())
         return;
      datetime curremt_time;
      for (int i = binance_start; i < OrdersHistoryTotal(); i++)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         {
            if (OrderType() == 6)
            {
               curremt_time = OrderOpenTime();
            }
            if (OrderType() > 5)
            {
               binance_total += OrderProfit();
            }
         }
      }
      if (curremt_time != binance_time)
      {
         binance_time = curremt_time;
         if (binance_total >= 25500)
         {
            this.min_lot = 0.17;
            this.max_lot = 3.4;
         }
         else
         {
            int num = binance_total / division_price;
            this.min_lot = num * min_lot;
            this.max_lot = num * max_lot;
         }
         Print("Total Binance : ", binance_total, " , minLot=", this.min_lot, " , MaxLot=", this.max_lot);
      }
      binance_start = OrdersHistoryTotal();
   }

private:
   void doAlerts(string msg, string SoundFile, bool PopupAlerts, bool EmailAlerts, bool PushNotificationAlerts, bool SoundAlerts)
   {
      //msg="MarginLevelAlertIndicator, Alert on "+Symbol()+", period "+TFtoStr(Period())+": "+msg;
      msg = "[" + string(AccountNumber()) + "] " + AccountName() + " , " + msg;
      string emailsubject = "MT4 alert on acc. " + string(AccountNumber()) + ", " + WindowExpertName() + " - Alert on " + Symbol();
      if (PopupAlerts)
         Alert(msg);
      if (EmailAlerts)
         SendMail(emailsubject, msg);
      if (PushNotificationAlerts)
      {
         SendNotification(msg);
      }
      if (SoundAlerts)
         PlaySound(SoundFile);
   }
};