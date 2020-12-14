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
datetime date1 = D'2019.12.24 01:00:00';
datetime date2 = D'2019.12.26 06:00:00';
bool is_file;
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

  CQueue<double> highs;
  CQueue<double> lows;
  CQueue<double> closes;
  CQueue<int> indexs;

  double d_high = 0;
  double d_low = 0x7fffffff;
  double d_close = close[0];

  string texts;
  Print(date1+(60*60));

  for (int i = 0; i < index-1; i++)
  {
    if (date1 <= time[i] && date2 >= time[i])
    {
      texts += time[i] + " : " + DoubleToStr(high[i], _Digits) +" , "+ DoubleToStr(low[i], _Digits) + " , " + DoubleToStr(close[i], _Digits) + "\n";
      unix = (double)time[i];
      int prev_hour = UnixToHour(unix);
      if (prev_hour == time_differnce)
      {
        d_high = (d_high > high[i]) ? d_high : high[i];
        d_low = (d_low < low[i]) ? d_low : low[i]; 
        highs.Add(d_high);
        lows.Add(d_low);
        closes.Add(d_close);
        indexs.Add(i+1);
        d_high = high[i+1];
        d_low = low[i+1];
        d_close = close[i+1];
        current_hour = prev_hour;
        continue;
      }
      else if (current_hour != -1 && HoliDay(current_hour, prev_hour, time_differnce))
      {
        int differnce = (int)time[i - 1] - (int)time[i];
        if (differnce < 1440)
        {
          if (prev_hour >= time_differnce && time_differnce <= current_hour)
          {
            highs.Add(d_high);
            lows.Add(d_low);
            closes.Add(d_close);
            d_high = high[i];
            d_low = low[i];
            d_close = close[i];
            current_hour = prev_hour;
            continue;
          }
        }
        else
        {
          highs.Add(d_high);
          lows.Add(d_low);
          closes.Add(d_close);
          d_high = high[i];
          d_low = low[i];
          d_close = close[i];
          current_hour = prev_hour;
          continue;
        }
      }
      d_high = (d_high > high[i]) ? d_high : high[i];
      d_low = (d_low < low[i]) ? d_low : low[i]; 
      current_hour = prev_hour;
    }
  }
  texts += "==============================================================\n";
  double high1,low1,close1;
  while (closes.Count())
  {
    high1 = highs.Dequeue();
    low1 = lows.Dequeue();
    close1 = closes.Dequeue();
    texts += high1+" , "+low1+ " , "+close1+ "\n";
    double pp = (high1+low1+close1)/3;
    texts += NormalizeDouble(pp, _Digits)+ "\n";
  }

  if (!is_file)
  {
    int filehandle = FileOpen("test.txt", FILE_WRITE | FILE_TXT);
    if (filehandle == INVALID_HANDLE)
    {
      Alert("failed to open file. error=", GetLastError());
    }
    FileWriteString(filehandle, texts + "\r\n");
    FileClose(filehandle);
  }
  is_file = true;
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
