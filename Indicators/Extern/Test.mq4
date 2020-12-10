//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link "https://www.mql5.com"
#property version "1.00"
#property strict
#property indicator_chart_window
#include <Generic\Queue.mqh>
#include <Generic\HashMap.mqh>

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
datetime date1 = D'2010.12.24 00:00:00';
datetime date2 = D'2020.12.31 00:00:00';
int OnInit()
{
  //--- indicator buffers mapping

  //---
  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
  //---
  int index = MathMax(rates_total - prev_calculated, 1);
  double unix;
  int time_differnce = 2;
  int current_hour = -1;
  for (int i = 0; i < index; i++)
  {
    if (date1 <= time[i] && date2 >= time[i])
    {
      unix = (double)time[i];
      int prev_hour = UnixToHour(unix);
      if (prev_hour == time_differnce)
      {
        //Print("continue : ", time[i]);
      }
      else if (current_hour != -1 && HoliDay(current_hour, prev_hour, time_differnce))
      {
        int differnce = (int)time[i - 1] - (int)time[i];
        if (differnce < 1440)
        {
          if(prev_hour >= time_differnce && time_differnce <= current_hour){
          }
            Print("0 : ", time[i]);
        }
        else
        {
          Print("2~ : ", time[i]);
        }
      }
      current_hour = prev_hour;
    }
  }

  //--- return value of prev_calculated for next call
  return (rates_total);
}

double UnixToHour(double &unix)
{
  unix /= (double)(60 * 60 * 24);
  unix -= (int)unix;
  return (int)NormalizeDouble(unix * 24, 5);
}

bool HoliDay(const int current_hour, const int prev_hour, const int time_difference)
{
  int hour_differnce = current_hour - prev_hour;
  //Print(hour_differnce);
  if (hour_differnce != 1)
  {
    if (hour_differnce != -23)
    {
      return true;
    }
  }
  return false;
}

void CalculateUnix(int &day, int &hour, const int unix)
{
  double cal_hour = (double)unix / (double)(60 * 60 * 24);
  double cal_year = (double)cal_hour / (double)365;

  day = (int)cal_hour;

  cal_hour -= day;
  hour = (int)NormalizeDouble(cal_hour * 24, 5);
}

//+------------------------------------------------------------------+
