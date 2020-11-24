#property copyright "Momantic [https://cafe.naver.com/appletrees3]"
#property link "https://cafe.naver.com/appletrees3"
#property version "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 DarkBlue
#property indicator_color3 DarkBlue
#property indicator_color4 Maroon
#property indicator_color5 Maroon
//Indicator Buffers
double PivotPoint[];
double SupportLine1Buffers[];
double SupportLine2Buffers[];
double Resistance1Buffers[];
double Resistance2Buffers[];

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
  int h1_bars = iBars(NULL, PERIOD_D1);
  int index = MathMax(rates_total - prev_calculated, 1);
  int dayi = 0;
  double ilow,ihigh,iclose;
  for (int i = 0; i < index; i++)
  {
    dayi = iBarShift(NULL, PERIOD_D1, time[i], false);
    ilow = iLow(Symbol(), PERIOD_D1, dayi + 1);
    ihigh = iHigh(Symbol(), PERIOD_D1, dayi + 1);
    iclose =  iClose(Symbol(), PERIOD_D1, dayi + 1);
    PivotPoint[i] = (ilow+ihigh+iclose) / 3;
    SupportLine1Buffers[i] = (PivotPoint[i]*2)-ihigh;
    SupportLine2Buffers[i] = PivotPoint[i]-(ihigh-ilow);
    Resistance1Buffers[i] = (PivotPoint[i]*2)-ilow;
    Resistance2Buffers[i] = PivotPoint[i]+(ihigh-ilow);
  }
  return (rates_total);
}
