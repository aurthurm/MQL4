#property copyright "MarginLevel Indicator"
#property link "http://forexBaron.net"

#property indicator_chart_window
extern double AlertAtMarginLevelOf = 150.0;
extern string ahi = "******* ALERT SETTINGS:";
extern int AlertPeriod = 30; // Alert Period(minute)
extern bool PopupAlerts = true;
extern bool EmailAlerts = false;
extern bool PushNotificationAlerts = false;
extern bool SoundAlerts = false;
extern string SoundFileName = "alert.wav";
bool AlertDone = false;
datetime time;

int init()
{
  marginLevel = new MarginLevel();
  time = TimeCurrent();
  AlertPeriod *= 60;
  return (0);
}

int deinit()
{
  if (marginLevel != NULL){
    delete marginLevel;
    marginLevel = NULL;
  }
  return (0);
}

int start()
{
  if(TimeCurrent() >= time){
    marginLevel.Alert();
  }
  return (0);
}


string TFtoStr(int period)
{
  switch (period)
  {
  case 1:
    return ("M1");
    break;
  case 5:
    return ("M5");
    break;
  case 15:
    return ("M15");
    break;
  case 30:
    return ("M30");
    break;
  case 60:
    return ("H1");
    break;
  case 240:
    return ("H4");
    break;
  case 1440:
    return ("D1");
    break;
  case 10080:
    return ("W1");
    break;
  case 43200:
    return ("MN1");
    break;
  default:
    return (DoubleToStr(period, 0));
  }
  return ("UNKNOWN");
} //string TFtoStr(int period) {

class MarginLevel
{
private:


public:
  MarginLevel(){}
  ~MarginLevel() {}
  // 현재 증거금비율이 설정한 값 이하로 떨어지는지 유효성 검사하는 함수
  void Alert()
  {
    double marginlevel = GetAccountMarginLevel();
    if (AccountMargin() != 0 && OrdersTotal() != 0 && marginlevel <= AlertAtMarginLevelOf)
    {
      time = TimeCurrent()+AlertPeriod;
      doAlerts("Margin Level of " + DoubleToStr(AlertAtMarginLevelOf, 2) + "% reached (current level: " + DoubleToStr(marginlevel, 2) + "%)", SoundFileName);
    }
  }

private:
  // 증거금 비율 값 함수
  double GetAccountMarginLevel()
  {
    double level = 0.0;
    if (AccountMargin() > 0)
      level = AccountEquity() / AccountMargin() * 100;
    return (level);
  }
  //알람 보내는 함수
  void doAlerts(string msg, string SoundFile)
  {
    //msg="MarginLevelAlertIndicator, Alert on "+Symbol()+", period "+TFtoStr(Period())+": "+msg;
    msg = "["+AccountNumber()+"] "+AccountName()+" , " + msg;
    string emailsubject = "MT4 alert on acc. " + AccountNumber() + ", " + WindowExpertName() + " - Alert on " + Symbol() + ", period " + TFtoStr(Period());
    if (PopupAlerts)
      Alert(msg);
    if (EmailAlerts)
      SendMail(emailsubject, msg);
    if (PushNotificationAlerts){
      bool is_send = SendNotification(msg);
      if(!is_send) Print("SendNotification. Error: ",GetLastError());
    }
    if (SoundAlerts)
      PlaySound(SoundFile);
  }
};
MarginLevel *marginLevel;
