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

//=============================Class Function Pointer=============================================
typedef void (*TFunction)(Pivot *, const int, const int, const datetime &time[]);

void Equlas(Pivot *ptr, const int rates_total, const int prev_calculated, const datetime &time[])
{
  ptr.EqualsUnix(rates_total, prev_calculated, time);
}
void Plus(Pivot *ptr, const int rates_total, const int prev_calculated, const datetime &time[])
{
  ptr.PlusUnix(rates_total, prev_calculated, time);
}
void Minus(Pivot *ptr, const int rates_total, const int prev_calculated, const datetime &time[])
{
  ptr.MinusUnix(rates_total, prev_calculated, time);
}
TFunction func;
//=================================================================================================

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  pivot = new Pivot();
  //pivot.UnixToClock();

  double gmt = (int)TimeGMT();
  int server_time = (int)TimeCurrent();
  Print(server_time-gmt);

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
  func(pivot,rates_total,prev_calculated,time);
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
  double low;
  double high;
  double close;
  int time_difference;

public:
  Pivot()
  {
    low = -1;
    high = 0x7fffffff;
  }
  ~Pivot()
  {
  }

  void UnixToClock()
  {
    int server_day, server_hour, gmt_day, gmt_hour, difference;
    int server_time = (int)TimeCurrent();
    int gmt_time = (int)TimeGMT();

    CalculateUnix(server_day, server_hour, server_time);
    CalculateUnix(gmt_day, gmt_hour, gmt_time);

    if (server_day == gmt_day)
    {
      difference = server_hour - gmt_hour;
      func = Equlas;
    }
    else if (server_day > gmt_day)
    {
      difference = (server_hour + 24) - gmt_hour;
      func = Plus;
    }
    else
    {
      difference = (gmt_hour + 24) - server_hour;
      func = Minus;
    }
    time_difference =  difference;
  }

  double UnixToHour(double &unix)
  {
    unix /= (double)(60 * 60 * 24);
    unix -= (int)unix;
    return (int)NormalizeDouble(unix * 24, 5);
  }

  void EqualsUnix(const int rates_total, const int prev_calculated, const datetime &time[])
  {
    int index = MathMax(rates_total - prev_calculated, 1);
    int dayi = 0;
    double ilow, ihigh, iclose;
    for (int i = 0; i < index; i++)
    {
      dayi = iBarShift(NULL, PERIOD_D1, time[i], false);
      ilow = iLow(Symbol(), PERIOD_D1, dayi + 1);
      ihigh = iHigh(Symbol(), PERIOD_D1, dayi + 1);
      iclose = iClose(Symbol(), PERIOD_D1, dayi + 1);
      PivotPoint[i] = (ilow + ihigh + iclose) / 3;
      SupportLine1Buffers[i] = (PivotPoint[i] * 2) - ihigh;
      SupportLine2Buffers[i] = PivotPoint[i] - (ihigh - ilow);
      Resistance1Buffers[i] = (PivotPoint[i] * 2) - ilow;
      Resistance2Buffers[i] = PivotPoint[i] + (ihigh - ilow);
      Resistance3Buffers[i] = (2 * PivotPoint[i]) + (ihigh - (2 * ilow));
      SupportLine3Buffers[i] = (2 * PivotPoint[i]) - ((2 * ihigh) - ilow);
    }
  }

  void PlusUnix(const int rates_total, const int prev_calculated, const datetime &time[])
  {
    int index = MathMax(rates_total - prev_calculated, 1);
    int dayi = 0;
    int h = time_difference/4;
    int hit_time =  (_Period < 240) ? time_difference : h*4;
    double ilow, ihigh, iclose;
    for (int i = 0; i < index; i++)
    {
      double unix = (int)time[i];
      if(UnixToHour(unix) == hit_time){

      }
      dayi = iBarShift(NULL, PERIOD_H1, time[i], false);
    }
  }

  void MinusUnix(const int rates_total, const int prev_calculated, const datetime &time[])
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
};