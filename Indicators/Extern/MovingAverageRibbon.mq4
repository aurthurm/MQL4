#property copyright "Momantic [https://cafe.naver.com/appletrees3]"
#property link      "https://cafe.naver.com/appletrees3"
#property version   "1.00"
#property strict

//---- indicator settings
#property indicator_chart_window
#property  indicator_buffers 14;
#property  indicator_color1  C'115,3,0';
#property  indicator_color2  C'157,4,0';
#property  indicator_color3  C'253,0,0';
#property  indicator_color4  C'253,20,0';
#property  indicator_color5  C'253,40,0';
#property  indicator_color6  C'253,60,0';
#property  indicator_color7  C'253,80,0';
#property  indicator_color8  C'253,100,0';
#property  indicator_color9  C'253,120,0';
#property  indicator_color10  C'253,140,0';
#property  indicator_color11  C'253,160,0';
#property  indicator_color12  C'253,180,0';
#property  indicator_color13  C'253,200,0';
#property  indicator_color14  C'253,220,0';

//Extern Indicator
extern string MovingAveragePeriod = "______________________MV Period______________________";
extern int MovingAveragePeriod1 = 5;
extern int MovingAveragePeriod2 = 10;
extern int MovingAveragePeriod3 = 20;
extern int MovingAveragePeriod4 = 30;
extern int MovingAveragePeriod5 = 40;
extern int MovingAveragePeriod6 = 50;
extern int MovingAveragePeriod7 = 60;
extern int MovingAveragePeriod8 = 80;
extern int MovingAveragePeriod9 = 100;
extern int MovingAveragePeriod10 = 120;
extern int MovingAveragePeriod11 = 160;
extern int MovingAveragePeriod12 = 200;
extern int MovingAveragePeriod13 = 240;
extern int MovingAveragePeriod14 = 300;

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
extern int MovingAverageShift10 = 2;
extern int MovingAverageShift11 = 2;
extern int MovingAverageShift12 = 2;
extern int MovingAverageShift13 = 2;
extern int MovingAverageShift14 = 2;

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
extern ENUM_MA_METHOD MovingAverageMethod10 = 0;
extern ENUM_MA_METHOD MovingAverageMethod11 = 0;
extern ENUM_MA_METHOD MovingAverageMethod12 = 0;
extern ENUM_MA_METHOD MovingAverageMethod13 = 0;
extern ENUM_MA_METHOD MovingAverageMethod14 = 0;

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
extern ENUM_APPLIED_PRICE MovingAveragePrice10 = 0;
extern ENUM_APPLIED_PRICE MovingAveragePrice11 = 0;
extern ENUM_APPLIED_PRICE MovingAveragePrice12 = 0;
extern ENUM_APPLIED_PRICE MovingAveragePrice13 = 0;
extern ENUM_APPLIED_PRICE MovingAveragePrice14 = 0;


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
double     MABuffer10[];
double     MABuffer11[];
double     MABuffer12[];
double     MABuffer13[];
double     MABuffer14[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  Print("color : ",DodgerBlue);
  //---- 2 additional buffers are used for counting.
  IndicatorBuffers(14);
  SetIndexBuffer(0, MABuffer1);
  SetIndexBuffer(1, MABuffer2);
  SetIndexBuffer(2, MABuffer3);
  SetIndexBuffer(3, MABuffer4);
  SetIndexBuffer(4, MABuffer5);
  SetIndexBuffer(5, MABuffer6);
  SetIndexBuffer(6, MABuffer7);
  SetIndexBuffer(7, MABuffer8);
  SetIndexBuffer(8, MABuffer9);
  SetIndexBuffer(9, MABuffer10);
  SetIndexBuffer(10, MABuffer11);
  SetIndexBuffer(11, MABuffer12);
  SetIndexBuffer(12, MABuffer13);
  SetIndexBuffer(13, MABuffer14);

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

  SetIndexStyle(9, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexLabel(9,"MA10");

  SetIndexStyle(10, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexLabel(10,"MA11");

  SetIndexStyle(11, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexLabel(11,"MA12");

  SetIndexStyle(12, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexLabel(12,"MA13");

  SetIndexStyle(13, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexLabel(13,"MA14");

  SetIndexDrawBegin(0,MovingAveragePeriod1);
  SetIndexDrawBegin(1,MovingAveragePeriod2);
  SetIndexDrawBegin(2,MovingAveragePeriod3);
  SetIndexDrawBegin(3,MovingAveragePeriod4);
  SetIndexDrawBegin(4,MovingAveragePeriod5);
  SetIndexDrawBegin(5,MovingAveragePeriod6);
  SetIndexDrawBegin(6,MovingAveragePeriod7);
  SetIndexDrawBegin(7,MovingAveragePeriod8);
  SetIndexDrawBegin(8,MovingAveragePeriod9);
  SetIndexDrawBegin(9,MovingAveragePeriod10);
  SetIndexDrawBegin(10,MovingAveragePeriod11);
  SetIndexDrawBegin(11,MovingAveragePeriod12);
  SetIndexDrawBegin(12,MovingAveragePeriod13);
  SetIndexDrawBegin(13,MovingAveragePeriod14);
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
      MABuffer1[i] = iMA(NULL, 0, MovingAveragePeriod1, MovingAverageShift1, MovingAverageMethod1, MovingAveragePrice1, i);
      MABuffer2[i] = iMA(NULL, 0, MovingAveragePeriod2, MovingAverageShift2, MovingAverageMethod2, MovingAveragePrice2, i);
      MABuffer3[i] = iMA(NULL, 0, MovingAveragePeriod3, MovingAverageShift3, MovingAverageMethod3, MovingAveragePrice3, i);
      MABuffer4[i] = iMA(NULL, 0, MovingAveragePeriod4, MovingAverageShift4, MovingAverageMethod4, MovingAveragePrice4, i);
      MABuffer5[i] = iMA(NULL, 0, MovingAveragePeriod5, MovingAverageShift5, MovingAverageMethod5, MovingAveragePrice5, i);
      MABuffer6[i] = iMA(NULL, 0, MovingAveragePeriod6, MovingAverageShift6, MovingAverageMethod6, MovingAveragePrice6, i);
      MABuffer7[i] = iMA(NULL, 0, MovingAveragePeriod7, MovingAverageShift7, MovingAverageMethod7, MovingAveragePrice7, i);
      MABuffer8[i] = iMA(NULL, 0, MovingAveragePeriod8, MovingAverageShift8, MovingAverageMethod8, MovingAveragePrice8, i);
      MABuffer9[i] = iMA(NULL, 0, MovingAveragePeriod9, MovingAverageShift9, MovingAverageMethod9, MovingAveragePrice9, i);
      MABuffer10[i] = iMA(NULL, 0, MovingAveragePeriod10, MovingAverageShift10, MovingAverageMethod10, MovingAveragePrice10, i);
      MABuffer11[i] = iMA(NULL, 0, MovingAveragePeriod11, MovingAverageShift11, MovingAverageMethod11, MovingAveragePrice11, i);
      MABuffer12[i] = iMA(NULL, 0, MovingAveragePeriod12, MovingAverageShift12, MovingAverageMethod12, MovingAveragePrice12, i);
      MABuffer13[i] = iMA(NULL, 0, MovingAveragePeriod13, MovingAverageShift13, MovingAverageMethod13, MovingAveragePrice13, i);
      MABuffer14[i] = iMA(NULL, 0, MovingAveragePeriod14, MovingAverageShift14, MovingAverageMethod14, MovingAveragePrice14, i);
    }

    //--- return value of prev_calculated for next call
    return (rates_total);
  }
//+------------------------------------------------------------------+
