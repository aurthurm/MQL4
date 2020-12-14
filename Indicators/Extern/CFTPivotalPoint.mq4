#property copyright "Momantic [https://cafe.naver.com/appletrees3]"
#property link "https://cafe.naver.com/appletrees3"
#property version "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 DarkBlue
#property indicator_color3 DarkBlue
#property indicator_color4 Maroon
#property indicator_color5 Maroon
#property indicator_color6 Green
#property indicator_color7 Green

#include <Generic/Queue.mqh>

//Indicator Buffers
double PivotPoint[];
double SupportLine1Buffers[];
double SupportLine2Buffers[];
double SupportLine3Buffers[];
double Resistance1Buffers[];
double Resistance2Buffers[];
double Resistance3Buffers[];

class Pivot;
Pivot *pivot;

//============================= Class Function Pointer =============================================
typedef void (*TFunction)(Pivot *, const int, const int, const datetime &time[],
            const double &high[],
            const double &low[]);

void Equlas(Pivot *ptr,
            const int rates_total,
            const int prev_calculated,
            const datetime &time[],
            const double &high[],
            const double &low[])
{
  ptr.EqualsUnix(rates_total, prev_calculated, time, high, low);
}
void Plus(Pivot *ptr,
          const int rates_total,
          const int prev_calculated,
          const datetime &time[],
          const double &high[],
          const double &low[])
{
  ptr.PlusUnix(rates_total, prev_calculated, time, high, low);
}
void Minus(Pivot *ptr,
           const int rates_total,
           const int prev_calculated,
           const datetime &time[],
           const double &high[],
           const double &low[])
{
  ptr.MinusUnix(rates_total, prev_calculated, time, high, low);
}
TFunction func;
//===================================================================================================

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{

  //--- indicator buffers mapping
  SetIndexBuffer(0, PivotPoint);
  SetIndexBuffer(1, SupportLine1Buffers);
  SetIndexBuffer(2, SupportLine2Buffers);
  SetIndexBuffer(3, Resistance1Buffers);
  SetIndexBuffer(4, Resistance2Buffers);
  SetIndexBuffer(5, Resistance3Buffers);
  SetIndexBuffer(6, SupportLine3Buffers);
  //---

  SetIndexStyle(0, DRAW_SECTION, STYLE_SOLID, 2);
  SetIndexLabel(0, "PP");

  SetIndexStyle(1, DRAW_SECTION, STYLE_SOLID, 1);
  SetIndexLabel(1, "S1");

  SetIndexStyle(2, DRAW_SECTION, STYLE_SOLID, 1);
  SetIndexLabel(2, "S2");

  SetIndexStyle(3, DRAW_SECTION, STYLE_SOLID, 1);
  SetIndexLabel(3, "R1");

  SetIndexStyle(4, DRAW_SECTION, STYLE_SOLID, 1);
  SetIndexLabel(4, "R2");

  SetIndexStyle(5, DRAW_SECTION, STYLE_SOLID, 1);
  SetIndexLabel(5, "R3");

  SetIndexStyle(6, DRAW_SECTION, STYLE_SOLID, 1);
  SetIndexLabel(6, "S3");

  if (_Period >= 1440)
  {
    Print("Invalid TimeFrame");
    return (INIT_FAILED);
  }
  pivot = new Pivot();
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
  if (prev_calculated == 0)
  {
    pivot.UnixToClock(rates_total);
    return (rates_total);
  }
  func(pivot, rates_total, prev_calculated, time, high, low);
  return (rates_total);
}

void OnDeinit(const int reason)
{
  if (pivot != NULL)
  {
    delete pivot;
    pivot = NULL;
  }
  return;
}

class Pivot
{
private:
  double ilow;
  double ihigh;
  double iclose;
  int time_difference;
  int main_time;

public:
  Pivot(){}
  ~Pivot(){}

  void UnixToClock(const int rates_total)
  {
    int value = (int)TimeCurrent() - (int)TimeGMT() + 120;
    time_difference = value / 3600;
    time_difference -= 2;

    if (time_difference == 0)
    {
      func = Equlas;
    }
    else if (time_difference > 0)
    {
      func = Plus;
    }
    else
    {
      time_difference = 24 + time_difference;
      func = Minus;
    }
      InitializeData(rates_total);
    
  }

  void EqualsUnix(const int rates_total, 
  const int prev_calculated, 
  const datetime &time[], 
  const double &high[], 
  const double &low[])
  {
    int index = MathMax(rates_total - prev_calculated, 1);
    int dayi = 0;
    double value1 = 60*60*24;
    int value2 = 24;

    for (int i = 0; i < index; i++)
    {
       double unix = (double)time[index];
       if(time[index] >= main_time &&  UnixToTime(unix,value1, value2) >= time_difference){
         dayi = iBarShift(NULL, PERIOD_H1, time[index], false);
         iclose = iClose(NULL, PERIOD_H1, i-1);
         PivotPoint[i] = (ilow + ihigh + iclose) / 3;
         SupportLine1Buffers[i] = (PivotPoint[i] * 2) - ihigh;
         SupportLine2Buffers[i] = PivotPoint[i] - (ihigh - ilow);
         Resistance1Buffers[i] = (PivotPoint[i] * 2) - ilow;
         Resistance2Buffers[i] = PivotPoint[i] + (ihigh - ilow);
         Resistance3Buffers[i] = (2 * PivotPoint[i]) + (ihigh - (2 * ilow));
         SupportLine3Buffers[i] = (2 * PivotPoint[i]) - ((2 * ihigh) - ilow);
         ihigh = high[0];
         ilow = low[0];
         main_time += (60 * 60);
      }
      ihigh = (ihigh > high[index]) ? ihigh : high[index];
      ilow = (ilow < low[index]) ? ilow : low[index];
    }
    // PivotPoint[i] = (ilow + ihigh + iclose) / 3;
    // SupportLine1Buffers[i] = (PivotPoint[i] * 2) - ihigh;
    // SupportLine2Buffers[i] = PivotPoint[i] - (ihigh - ilow);
    // Resistance1Buffers[i] = (PivotPoint[i] * 2) - ilow;
    // Resistance2Buffers[i] = PivotPoint[i] + (ihigh - ilow);
    // Resistance3Buffers[i] = (2 * PivotPoint[i]) + (ihigh - (2 * ilow));
    // SupportLine3Buffers[i] = (2 * PivotPoint[i]) - ((2 * ihigh) - ilow);
  }

  void PlusUnix(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &high[],
                const double &low[])
  {
    int index = MathMax(rates_total - prev_calculated, 1);
    int dayi = 0;
    int h = time_difference / 4;
    int hit_time = (_Period < 240) ? time_difference : h * 4;
  }

  void MinusUnix(const int rates_total,
                 const int prev_calculated,
                 const datetime &time[],
                 const double &high[],
                 const double &low[])
  {
  }

private:
  void CalculateUnix(int &day, int &hour, const int unix)
  {
    double cal_hour = (double)unix / (double)(60 * 60 * 24);
    double cal_year = (double)cal_hour / (double)365;

    day = (int)cal_hour;

    cal_hour -= day;
    hour = (int)NormalizeDouble(cal_hour * 24, 5);
  }

  void InitializeData(int const rates_total)
  {
    CQueue<double> highs;
    CQueue<double> lows;
    CQueue<double> closes;
    CQueue<int> indexs;

    int bars = iBars(NULL, PERIOD_H1);
    Print(bars);
    double unix;
    int current_hour = -1;
    double d_high = iHigh(NULL, PERIOD_H1, 0);
    double d_low = iLow(NULL, PERIOD_H1, 0);
    double d_close = iClose(NULL, PERIOD_H1, 0);
    double value1 = 60*60*24;
    int value2 = 24;
    for (int i = 0; i < bars - 1; i++)
    {
      unix = (double)iTime(NULL, PERIOD_H1, i);
      int prev_hour = UnixToTime(unix,value1, value2);
      if (prev_hour == time_difference)
      {
        d_high = (d_high > iHigh(NULL, PERIOD_H1, i)) ? d_high : iHigh(NULL, PERIOD_H1, i);
        d_low = (d_low < iLow(NULL, PERIOD_H1, i)) ? d_low : iLow(NULL, PERIOD_H1, i);
        highs.Add(d_high);
        lows.Add(d_low);
        closes.Add(d_close);
        indexs.Add(i);
        d_high = iHigh(NULL, PERIOD_H1, i + 1);
        d_low = iLow(NULL, PERIOD_H1, i + 1);
        d_close = iClose(NULL, PERIOD_H1, i + 1);
        current_hour = prev_hour;
        continue;
      }
      else if (current_hour != -1 && NoisyDay(current_hour, prev_hour))
      {
        int differnce = (int)iTime(NULL, PERIOD_H1, i - 1) - (int)iTime(NULL, PERIOD_H1, i);
        if (differnce < 1440)
        {
          if (prev_hour >= time_difference && time_difference <= current_hour)
          {
            highs.Add(d_high);
            lows.Add(d_low);
            closes.Add(d_close);
            indexs.Add(i-1);
            d_high = iHigh(NULL, PERIOD_H1, i);
            d_low = iLow(NULL, PERIOD_H1, i);
            d_close = iClose(NULL, PERIOD_H1, i);
            current_hour = prev_hour;
            continue;
          }
        }
        else
        {
          highs.Add(d_high);
          lows.Add(d_low);
          closes.Add(d_close);
          indexs.Add(i-1);
          d_high = iHigh(NULL, PERIOD_H1, i);
          d_low = iLow(NULL, PERIOD_H1, i);
          d_close = iClose(NULL, PERIOD_H1, i);
          current_hour = prev_hour;
          continue;
        }
      }
      d_high = (d_high > iHigh(NULL, PERIOD_H1, i)) ? d_high : iHigh(NULL, PERIOD_H1, i);
      d_low = (d_low < iLow(NULL, PERIOD_H1, i)) ? d_low : iLow(NULL, PERIOD_H1, i);
      current_hour = prev_hour;
    }
    CalculatePivot(highs, lows, closes, indexs, rates_total);
  }

  bool NoisyDay(const int current_hour, const int prev_hour)
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

  int UnixToTime(double &unix, double value1, int value2)
  {
    unix /= value1;
    unix -= (int)unix;
    return (int)NormalizeDouble(unix * value2, 5);
  }

  void CalculatePivot(CQueue<double> &highs, CQueue<double> &lows, CQueue<double> &closes, CQueue<int> &indexs, int const rates_total)
  {

    iclose = closes.Dequeue();
    ihigh = highs.Dequeue();
    ilow = lows.Dequeue();

    int dayi = 0;
    int h = time_difference / 4;
    int hit_time = (_Period < 240) ? time_difference : h * 4;

    double d_close = closes.Dequeue();
    double d_high = highs.Dequeue();
    double d_low = lows.Dequeue();
    int index = indexs.Dequeue();


    int prev_dayi = iBarShift(NULL, PERIOD_H1, iTime(NULL, 0, 0), false);
    main_time = (int)iTime(NULL,PERIOD_H1, 0)+(60*60);

    for (int i = 0; i < rates_total; i++)
    {
      dayi = iBarShift(NULL, PERIOD_H1, iTime(NULL, 0, i), false);
      if(dayi-prev_dayi == 1 && prev_dayi == index){
         d_close = closes.Dequeue();
         d_high = highs.Dequeue();
         d_low = lows.Dequeue();
         index = indexs.Dequeue();
      }
      PivotPoint[i] = (d_low + d_high + d_close) / 3;
      SupportLine1Buffers[i] = (PivotPoint[i] * 2) - d_high;
      SupportLine2Buffers[i] = PivotPoint[i] - (d_high - d_low);
      Resistance1Buffers[i] = (PivotPoint[i] * 2) - d_low;
      Resistance2Buffers[i] = PivotPoint[i] + (d_high - d_low);
      Resistance3Buffers[i] = (2 * PivotPoint[i]) + (d_high - (2 * d_low));
      SupportLine3Buffers[i] = (2 * PivotPoint[i]) - ((2 * d_high) - d_low);
      prev_dayi = dayi;
      // if (dayi == index)
      // {
      //   double unix = (double)iTime(NULL, 0, i);
      //   int min = UnixToTime(unix, 60*60, 60);
      //   if (min == 0)
      //   {
      //     d_close = closes.Dequeue();
      //     d_high = highs.Dequeue();
      //     d_low = lows.Dequeue();
      //     index = indexs.Dequeue();
      //   }
      // }
      // ilow = iLow(Symbol(), PERIOD_D1, dayi + 1);
      // ihigh = iHigh(Symbol(), PERIOD_D1, dayi + 1);
      // iclose = iClose(Symbol(), PERIOD_D1, dayi + 1);
    }
  }
};