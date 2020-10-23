//+------------------------------------------------------------------+
//|                                               Stochastic RSI.mq4 |
//|                                                tonyc2a@yahoo.com |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "tonyc2a@yahoo.com"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_minimum -5
#property indicator_maximum 105
#property indicator_color1 Red
#property indicator_color2 Yellow

//---- input parameters
extern int RSI_Periods=14;
extern int Percent_K=14;
extern int Percent_D=9;
extern int NumOfBars=0;

//---- buffers
double Buffer1[];
double Buffer2[];
double test1;
double test2;
double alertTag;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,STYLE_DOT,2);
   SetIndexBuffer(0,Buffer1);
   SetIndexLabel(0,"StochRSI");
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT,1);
   SetIndexBuffer(1,Buffer2);
   SetIndexLabel(1,"Signal");

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   double Current_RSI,Lowest_RSI,Highest_RSI,sum_K;
//---- TODO: add your code here
   if(NumOfBars==0)
      NumOfBars=Bars;
   for(int i=NumOfBars-MathMax(RSI_Periods,Percent_K)-1; i>=0; i--)
     {
      Current_RSI=iRSI(NULL,0,RSI_Periods,PRICE_TYPICAL,i);
      Highest_RSI=Current_RSI;
      Lowest_RSI=Current_RSI;
      if(Highest_RSI > 50 && alertTag!=Time[0])
         Alert("StochRSI trend Down on ",Symbol(),Period()," LOWRSI= ",Lowest_RSI," HRSI= ",Highest_RSI," b1 ",Buffer1[i],"b2= ",Buffer2[i]," curr= ",Current_RSI,"i=",i);
      alertTag = Time[0];
      if(Highest_RSI < 50 && alertTag!=Time[0])
         Alert("StochRSI trend Up on ",Symbol(),Period()," LOWRSI= ",Lowest_RSI," HRSI= ",Highest_RSI," b1 ",Buffer1[i],"b2= ",Buffer2[i]," curr= ",Current_RSI,"i=",i);
      alertTag = Time[0];

      for(int x=0; x<=Percent_K; x++)
        {
         Lowest_RSI=MathMin(Lowest_RSI,iRSI(NULL,0,RSI_Periods,PRICE_TYPICAL,i+x));
         Highest_RSI=MathMax(Highest_RSI,iRSI(NULL,0,RSI_Periods,PRICE_TYPICAL,i+x));
        }

      sum_K=0;
      for(x=0; x<=Percent_D; x++)
         sum_K=sum_K+Buffer1[i+x];

      Buffer1[i]=((Current_RSI-Lowest_RSI)/(Highest_RSI-Lowest_RSI))*100;
      Buffer2[i]=sum_K/Percent_D;

     }

//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
