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

int IsGMT;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  int server_unix = (int)TimeCurrent();
  int gmt_unix = (int)TimeGMT();

  int server_time = pivot.CalculateTime(server_unix);
  int gmt_time = pivot.CalculateTime(gmt_unix);

  IsGMT = server_time-gmt_time;

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

  if(_Period >= 1440){
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
  if(IsGMT > 0){

  }else if(IsGMT == 0){
    pivot.EqualsUnix(rates_total,prev_calculated,time);
  }else{

  }
  return (rates_total);
}

class Pivot
{
private:
  double low;
  double high;
  double close;

public:
  Pivot()
  {
    low = -1;
    high = 0x7fffffff;
  }
  ~Pivot()
  {
  }

  int CalculateTime(int &unix)
  {
    unix /= (60 * 60);
    double d_hour = (double)unix / (double)24;
    d_hour -= (int)d_hour;
    return (int)NormalizeDouble(d_hour * 24,5);
  } 

  void EqualsUnix(const int rates_total, const int prev_calculated, const datetime &time[]){
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

  void PlusUnix(const int rates_total, const int prev_calculated, const datetime &time[]){
    int index = MathMax(rates_total - prev_calculated, 1);
    int dayi = 0;
    int hit_time = 24-IsGMT;
    double ilow, ihigh, iclose;
    for (int i = 0; i < index; i++)
    {
      dayi = iBarShift(NULL, PERIOD_H1, time[i], false);
      
    }
  }

  void MinusUnix(){

  }
  
};
Pivot pivot;
