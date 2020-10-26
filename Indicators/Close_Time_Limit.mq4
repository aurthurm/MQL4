//+------------------------------------------------------------------+
//|                                             Close_Time_Limit.mq4 |
//|                                                         타짜라면 |
//|                                  http://cafe.daum.net/hanfutures |
//+------------------------------------------------------------------+
#property copyright "타짜라면"
#property link      "http://cafe.daum.net/hanfutures"

//#property indicator_chart_window
extern string sTimerMenu = "타이머(기본값은 2시간 30분)";
extern string sTimer = "02:30";

extern string sCondition1Menu = "현재가가 기준가 보다 크면, 청산";
extern bool   bCondition1 = false;
extern string sCondition2Menu = "현재가가 기준가 보다 작으면, 청산";
extern bool   bCondition2 = false;
extern string sCondition3Menu = "현재가가 기준가를 상향 돌파하면, 청산";
extern bool   bCondition3 = false;
extern string sCondition4Menu = "현재가가 기준가를 하향 돌파하면, 청산";
extern bool   bCondition4 = false;

extern string  sSlippageMenu = "청산 슬리피지";
extern int     nSlippage = 10;

extern string  sLineMenu = "기준선 스타일";
extern color  crLineColor = Red; 
extern int     nLineStyle = STYLE_SOLID;

extern string sCloseAlertWavMenu = "청산 싸운드";
extern string sCloseAlertWav="ok.wav";


datetime dtOpenTime=0;
double dbLinePrice = 0;
string sLineName="청산기준선";
int nTimer=0;
int NumberOfTries        = 10; //Number of try if the order rejected by the system.
bool bContinue = true;  //초기화 성공여부, 청산절차 진행여부

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
  // 청산 기준값을 현재가로 초기화 한다. 
  dbLinePrice =  Close[0];

  //타이머 값이 0이면 메시지 박스를 띄운다.   
  if(sTimer =="0" || sTimer =="00" || sTimer =="0000" || sTimer =="0:0" || sTimer =="0:00" || sTimer =="00:0"|| sTimer =="00:00")
    {
      bContinue = false;      
      Alert("타이머를 0으로 설정 할 수 없습니다");        
    } 

  if(!bCondition1 && !bCondition2 && !bCondition3 && !bCondition4)
    {
      bContinue = false;      
      Alert("청산 조건이 없습니다. 조건이 모두 false 입니다.");          
    } 

  if(OpenTotal()==0)
    {
      bContinue = false;      
      Alert("진입상태인 포지션이 없습니다.");        
    } 
  
  // 초기화 실패
  if(!bContinue)
  {
    //회색 라인 표시 
    ObjectCreate(sLineName, OBJ_HLINE, 0, 0, dbLinePrice);
    ObjectSet(sLineName, OBJPROP_STYLE, nLineStyle);
    ObjectSet(sLineName, OBJPROP_COLOR, DimGray);
    ObjectSet(sLineName, OBJPROP_WIDTH, 2); 
    return(0);
  }
    
    // 초기화 성공
    // crLineColor 색상 라인 표시 
    ObjectCreate(sLineName, OBJ_HLINE, 0, 0, dbLinePrice);
    ObjectSet(sLineName, OBJPROP_STYLE, nLineStyle);
    ObjectSet(sLineName, OBJPROP_COLOR, crLineColor);
    ObjectSet(sLineName, OBJPROP_WIDTH, 2);

    //타이머 값을 초로 환산한다. 
    datetime dbTimer = StrToTime(sTimer);
    nTimer = TimeHour(dbTimer)*60*60 + TimeMinute(dbTimer)*60;
    dtOpenTime = OpenTime();

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll(); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  bool bResult = false;
  double dbBuyValue = 0;
  static bool bfirst = true; //감시 시작을 알리기 위해  
  
  
//----   
  // 초기화 실패
  // 진입상태인 포지션 없음
  if(!bContinue)
  {
    //회색 라인 표시 
    ObjectCreate(sLineName, OBJ_HLINE, 0, 0, dbLinePrice);
    ObjectSet(sLineName, OBJPROP_STYLE, nLineStyle);
    ObjectSet(sLineName, OBJPROP_COLOR, DimGray);
    ObjectSet(sLineName, OBJPROP_WIDTH, 2); 
  
   return(0);
  }

  if( TimeCurrent() - dtOpenTime <  nTimer  )return(0); 
  
  if(bfirst)
  {
    bfirst = false;
    Alert("청산을 위한 감시를 시작합니다.");            
  }


  dbLinePrice =  ObjectGet( sLineName, OBJPROP_PRICE1); 
///////////////////////////////////////////////////////
//청산 조건문 

  //"현재가가 기준가 보다 크면, 청산";
  if(bCondition1 && Close[0] > dbLinePrice)
  {
    bResult = true;
    CloseOrderAll();

  }
  
  //"현재가가 기준가 보다 작으면, 청산";
  if(bCondition2 && Close[0] < dbLinePrice)
  {
    bResult = true;
    CloseOrderAll();    

  }
  
  //"현재가가 기준가를 상향 돌파하면, 청산";
  if(bCondition3 && Close[0] >= dbLinePrice && Close[1] < dbLinePrice )
  {
    bResult = true;
    CloseOrderAll();    

  }
  
  //"현재가가 기준가를 하향 돌파하면, 청산";
  if(bCondition4 && Close[0] <= dbLinePrice && Close[1] > dbLinePrice)
  {
    bResult = true;
    CloseOrderAll();    

  }   
 
//청산 조건문  
/////////////////////////////////////////////////////////

   
//----
   return(0);
  }
//+------------------------------------------------------------------+

void CloseOrderAll()
{
   int
         cnt, 
         total       = 0,
         ticket      = 0,
         err         = 0,
         c           = 0;

   total = OrdersTotal();
   for(cnt=total-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if(OrderSymbol()==Symbol())
      {
         switch(OrderType())
         {
            case OP_BUY      :
               for(c=0;c<NumberOfTries;c++)
               {
                  ticket=OrderClose(OrderTicket(),OrderLots(),Bid,nSlippage,Violet);
                  err=GetLastError();
                  if(err==0)
                  {                      
                     if(ticket>0)
                     {
                       PlaySound(sCloseAlertWav);
                       break;                     
                     } 
                  }
                  else
                  {
                     if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
                     {
                        Sleep(5000);
                        continue;
                     }
                     else //normal error
                     {
                        if(ticket>0) break;
                     }  
                  }
               }   
               break;
               
            case OP_SELL     :
               for(c=0;c<NumberOfTries;c++)
               {
                  ticket=OrderClose(OrderTicket(),OrderLots(),Ask,nSlippage,Violet);
                  err=GetLastError();
                  if(err==0)
                  { 
                     if(ticket>0)
                     {
                       PlaySound(sCloseAlertWav);
                       break;                     
                     } 
                  }
                  else
                  {
                     if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
                     {
                        Sleep(5000);
                        continue;
                     }
                     else //normal error
                     {
                        if(ticket>0) break;
                     }  
                  }
               }   
               break;

         }
      }
   }
   
   // 진입상태인 포지션이 더이상 없다면 감시 종료 
   if(OpenTotal()==0)bContinue=false;     
}

// 진입한 포지션 카운터 
int OpenTotal()
{
   int
         cnt, 
         total       = 0,
         nOpenTotal  = 0;
         
   total = OrdersTotal();
   for(cnt=total-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if(OrderSymbol()==Symbol())
      {
         switch(OrderType())
         {
            case OP_BUY      :
               nOpenTotal++;
               break;
               
            case OP_SELL     :
               nOpenTotal++; 
               break;

         }
      }
   }

  return(nOpenTotal);         
}

// 제일 마지막에 진입한 시간을 리턴한다.
datetime OpenTime()
{
   int
         cnt, 
         total       = 0;
   datetime dtMaxTime = 0;         
         
   total = OrdersTotal();

   for(cnt=total-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if(OrderSymbol()==Symbol())
      {
         switch(OrderType())
         {
            case OP_BUY      :
               if(OrderOpenTime() >= dtMaxTime)dtMaxTime = OrderOpenTime();
               break;
               
            case OP_SELL     :
               if(OrderOpenTime() >= dtMaxTime)dtMaxTime = OrderOpenTime();
               break;

         }
      }
   }

  return(dtMaxTime);         
}



