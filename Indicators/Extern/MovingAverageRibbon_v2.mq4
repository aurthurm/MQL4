#property copyright "Momantic [https://cafe.naver.com/appletrees3]"
#property link      "https://cafe.naver.com/appletrees3"
#property version   "1.00"
#property strict

//---- indicator settings
#property indicator_chart_window
#property  indicator_buffers 9;
#property  indicator_color1  C'1,27,173';
#property  indicator_color2  C'50,0,253';
#property  indicator_color3  C'70,0,253';
#property  indicator_color4  C'90,0,253';
#property  indicator_color5  C'110,0,253';
#property  indicator_color6  C'130,0,253';
#property  indicator_color7  C'150,0,253';
#property  indicator_color8  C'170,0,253';
#property  indicator_color9  C'190,0,253';

//Extern Indicator
extern string MovingAveragePeriodInterval = "______________________MV Period Interval______________________";
extern int MovingAverageInterval = 5;


extern string MovingAverageShift = "______________________MV Shift______________________";
extern int MovingAverageShift1 = 2;
extern int MovingAverageShift2 = 2;
extern int MovingAverageShift3 = 2;
extern int MovingAverageShift4 = 2;
extern int MovingAverageShift5 = 2;
extern int MovingAverageShift6 = 2;
extern int MovingAverageShift7 = 2;
extern int MovingAverageShift8 = 2;
extern int MovingAverageShift9 = 2;

extern string MovingAverageMethod = "______________________MV Method______________________";
extern ENUM_MA_METHOD MovingAverageMethod1 = 0;
extern ENUM_MA_METHOD MovingAverageMethod2 = 0;
extern ENUM_MA_METHOD MovingAverageMethod3 = 0;
extern ENUM_MA_METHOD MovingAverageMethod4 = 0;
extern ENUM_MA_METHOD MovingAverageMethod5 = 0;
extern ENUM_MA_METHOD MovingAverageMethod6 = 0;
extern ENUM_MA_METHOD MovingAverageMethod7 = 0;
extern ENUM_MA_METHOD MovingAverageMethod8 = 0;
extern ENUM_MA_METHOD MovingAverageMethod9 = 0;

extern string MovingAveragePrice = "______________________MV Price______________________";
extern ENUM_APPLIED_PRICE MovingAveragePrice1 = 0;
extern ENUM_APPLIED_PRICE MovingAveragePrice2 = 0;
extern ENUM_APPLIED_PRICE MovingAveragePrice3 = 0;
extern ENUM_APPLIED_PRICE MovingAveragePrice4 = 0;
extern ENUM_APPLIED_PRICE MovingAveragePrice5 = 0;
extern ENUM_APPLIED_PRICE MovingAveragePrice6 = 0;
extern ENUM_APPLIED_PRICE MovingAveragePrice7 = 0;
extern ENUM_APPLIED_PRICE MovingAveragePrice8 = 0;
extern ENUM_APPLIED_PRICE MovingAveragePrice9 = 0;


//Indicator Buffers
double     MABuffer1[];
double     MABuffer2[];
double     MABuffer3[];
double     MABuffer4[];
double     MABuffer5[];
double     MABuffer6[];
double     MABuffer7[];
double     MABuffer8[];
double     MABuffer9[];

int ma_period_array[9];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  //---- 2 additional buffers are used for counting.
  IndicatorBuffers(9);
  SetIndexBuffer(0, MABuffer1);
  SetIndexBuffer(1, MABuffer2);
  SetIndexBuffer(2, MABuffer3);
  SetIndexBuffer(3, MABuffer4);
  SetIndexBuffer(4, MABuffer5);
  SetIndexBuffer(5, MABuffer6);
  SetIndexBuffer(6, MABuffer7);
  SetIndexBuffer(7, MABuffer8);
  SetIndexBuffer(8, MABuffer9);

  //---- drawing settings
  SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexLabel(0,"MA1");

  SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexLabel(1,"MA2");

  SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexLabel(2,"MA3");
  
  SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexLabel(3,"MA4");

  SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexLabel(4,"MA5");

  SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexLabel(5,"MA6");

  SetIndexStyle(6, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexLabel(6,"MA7");

  SetIndexStyle(7, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexLabel(7,"MA8");

  SetIndexStyle(8, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexLabel(8,"MA9");

  int count = MovingAverageInterval;
  for (int i = 0; i < ArraySize(ma_period_array); i++)
  {
    ma_period_array[i] = count;
    SetIndexDrawBegin(i,ma_period_array[i]);
    count += MovingAverageInterval;
  }
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
    int index = MathMax(rates_total-prev_calculated,1);
    for(int i=0; i<index; i++){
      MABuffer1[i] = iMA(NULL, 0, ma_period_array[0], MovingAverageShift1, MovingAverageMethod1, MovingAveragePrice1, i);
      MABuffer2[i] = iMA(NULL, 0, ma_period_array[1], MovingAverageShift2, MovingAverageMethod2, MovingAveragePrice2, i);
      MABuffer3[i] = iMA(NULL, 0, ma_period_array[2], MovingAverageShift3, MovingAverageMethod3, MovingAveragePrice3, i);
      MABuffer4[i] = iMA(NULL, 0, ma_period_array[3], MovingAverageShift4, MovingAverageMethod4, MovingAveragePrice4, i);
      MABuffer5[i] = iMA(NULL, 0, ma_period_array[4], MovingAverageShift5, MovingAverageMethod5, MovingAveragePrice5, i);
      MABuffer6[i] = iMA(NULL, 0, ma_period_array[5], MovingAverageShift6, MovingAverageMethod6, MovingAveragePrice6, i);
      MABuffer7[i] = iMA(NULL, 0, ma_period_array[6], MovingAverageShift7, MovingAverageMethod7, MovingAveragePrice7, i);
      MABuffer8[i] = iMA(NULL, 0, ma_period_array[7], MovingAverageShift8, MovingAverageMethod8, MovingAveragePrice8, i);
      MABuffer9[i] = iMA(NULL, 0, ma_period_array[8], MovingAverageShift9, MovingAverageMethod9, MovingAveragePrice9, i);
    }

    //--- return value of prev_calculated for next call
    return (rates_total);
  }
//+------------------------------------------------------------------+
