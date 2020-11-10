//+------------------------------------------------------------------+
//|                                                 MQL4Function.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>

class ModuleMQL4{
   public:
      void tradingOnOff(){
         string message;
         if(!IsTradeAllowed()){
            message = "You must allow trading!";
            Comment(message);
         }
      }
      void ShowError(){
         Print("Error : ", ErrorDescription(GetLastError()));
      }
      void CurrentTime(datetime &time){
         if(Time[0] != time){
            time = Time[0];
            Print("Not Matching Time");
         }
      }
   private:
};