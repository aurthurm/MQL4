#property copyright "jjangchan"
#property link "https://www.github.com/jjangchan"
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>

class ModuleMQL4
{
private:
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

   bool ValidPeriod(int period){
      if(period <= 0) return false;
      return true;
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
      bool is_account = false;
      datetime current_time = binance_time;
      for (int i = OrdersHistoryTotal(); i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         {
            if (OrderOpenTime() <= current_time)
               break;
            if (OrderType() == 6 && !is_account)
            {
               is_account = true;
               binance_time = OrderOpenTime();
            }
            if (OrderType() > 5)
            {
               binance_total += OrderProfit();
            }
         }
      }
      if (is_account)
      {
         if (binance_total >= 25500)
         {
            this.min_lot = 0.17;
            this.max_lot = 3.4;
         }
         else
         {
            int num = binance_total / division_price;
            min_lot *= num;
            max_lot *= num;
         }
         Print("Total Binance : ", binance_total, " , minLot=", this.min_lot, " , MaxLot=", this.max_lot);
      }
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