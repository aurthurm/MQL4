//+------------------------------------------------------------------+
//|                                             Close_Time_Limit.mq4 |
//|                                                         Ÿ¥��� |
//|                                  http://cafe.daum.net/hanfutures |
//+------------------------------------------------------------------+
#property copyright "Ÿ¥���"
#property link      "http://cafe.daum.net/hanfutures"

//#property indicator_chart_window
extern string sTimerMenu = "Ÿ�̸�(�⺻���� 2�ð� 30��)";
extern string sTimer = "02:30";

extern string sCondition1Menu = "���簡�� ���ذ� ���� ũ��, û��";
extern bool   bCondition1 = false;
extern string sCondition2Menu = "���簡�� ���ذ� ���� ������, û��";
extern bool   bCondition2 = false;
extern string sCondition3Menu = "���簡�� ���ذ��� ���� �����ϸ�, û��";
extern bool   bCondition3 = false;
extern string sCondition4Menu = "���簡�� ���ذ��� ���� �����ϸ�, û��";
extern bool   bCondition4 = false;

extern string  sSlippageMenu = "û�� ��������";
extern int     nSlippage = 10;

extern string  sLineMenu = "���ؼ� ��Ÿ��";
extern color  crLineColor = Red; 
extern int     nLineStyle = STYLE_SOLID;

extern string sCloseAlertWavMenu = "û�� �ο��";
extern string sCloseAlertWav="ok.wav";


datetime dtOpenTime=0;
double dbLinePrice = 0;
string sLineName="û����ؼ�";
int nTimer=0;
int NumberOfTries        = 10; //Number of try if the order rejected by the system.
bool bContinue = true;  //�ʱ�ȭ ��������, û������ ���࿩��

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
  // û�� ���ذ��� ���簡�� �ʱ�ȭ �Ѵ�. 
  dbLinePrice =  Close[0];

  //Ÿ�̸� ���� 0�̸� �޽��� �ڽ��� ����.   
  if(sTimer =="0" || sTimer =="00" || sTimer =="0000" || sTimer =="0:0" || sTimer =="0:00" || sTimer =="00:0"|| sTimer =="00:00")
    {
      bContinue = false;      
      Alert("Ÿ�̸Ӹ� 0���� ���� �� �� �����ϴ�");        
    } 

  if(!bCondition1 && !bCondition2 && !bCondition3 && !bCondition4)
    {
      bContinue = false;      
      Alert("û�� ������ �����ϴ�. ������ ��� false �Դϴ�.");          
    } 

  if(OpenTotal()==0)
    {
      bContinue = false;      
      Alert("���Ի����� �������� �����ϴ�.");        
    } 
  
  // �ʱ�ȭ ����
  if(!bContinue)
  {
    //ȸ�� ���� ǥ�� 
    ObjectCreate(sLineName, OBJ_HLINE, 0, 0, dbLinePrice);
    ObjectSet(sLineName, OBJPROP_STYLE, nLineStyle);
    ObjectSet(sLineName, OBJPROP_COLOR, DimGray);
    ObjectSet(sLineName, OBJPROP_WIDTH, 2); 
    return(0);
  }
    
    // �ʱ�ȭ ����
    // crLineColor ���� ���� ǥ�� 
    ObjectCreate(sLineName, OBJ_HLINE, 0, 0, dbLinePrice);
    ObjectSet(sLineName, OBJPROP_STYLE, nLineStyle);
    ObjectSet(sLineName, OBJPROP_COLOR, crLineColor);
    ObjectSet(sLineName, OBJPROP_WIDTH, 2);

    //Ÿ�̸� ���� �ʷ� ȯ���Ѵ�. 
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
  static bool bfirst = true; //���� ������ �˸��� ����  
  
  
//----   
  // �ʱ�ȭ ����
  // ���Ի����� ������ ����
  if(!bContinue)
  {
    //ȸ�� ���� ǥ�� 
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
    Alert("û���� ���� ���ø� �����մϴ�.");            
  }


  dbLinePrice =  ObjectGet( sLineName, OBJPROP_PRICE1); 
///////////////////////////////////////////////////////
//û�� ���ǹ� 

  //"���簡�� ���ذ� ���� ũ��, û��";
  if(bCondition1 && Close[0] > dbLinePrice)
  {
    bResult = true;
    CloseOrderAll();

  }
  
  //"���簡�� ���ذ� ���� ������, û��";
  if(bCondition2 && Close[0] < dbLinePrice)
  {
    bResult = true;
    CloseOrderAll();    

  }
  
  //"���簡�� ���ذ��� ���� �����ϸ�, û��";
  if(bCondition3 && Close[0] >= dbLinePrice && Close[1] < dbLinePrice )
  {
    bResult = true;
    CloseOrderAll();    

  }
  
  //"���簡�� ���ذ��� ���� �����ϸ�, û��";
  if(bCondition4 && Close[0] <= dbLinePrice && Close[1] > dbLinePrice)
  {
    bResult = true;
    CloseOrderAll();    

  }   
 
//û�� ���ǹ�  
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
   
   // ���Ի����� �������� ���̻� ���ٸ� ���� ���� 
   if(OpenTotal()==0)bContinue=false;     
}

// ������ ������ ī���� 
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

// ���� �������� ������ �ð��� �����Ѵ�.
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



