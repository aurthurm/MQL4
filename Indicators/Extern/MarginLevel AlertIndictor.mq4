#property copyright "MarginLevel Indicator"
#property link      "http://forexBaron.net"

#property indicator_chart_window
extern double AlertAtMarginLevelOf   = -25.0;
extern bool   ShowScreenComment      = true;
extern string ahi="******* ALERT SETTINGS:";
extern int    AlertPeriod            = 30;  // Alert Period(minute)
extern bool   PopupAlerts            = true;
extern bool   EmailAlerts            = false;
extern bool   PushNotificationAlerts = false;
extern bool   SoundAlerts            = false;
extern string SoundFileName          = "alert.wav";
bool AlertDone=false;
string cstring = "MarginLevel AlertIndicator -> http://ForexBaron.net\n ";

int init() {
AlertPeriod *= 60;
return(0);
}

int deinit() {
 if (ShowScreenComment) Comment("");
return(0);
}

int start() {
 int counted_bars=IndicatorCounted();
 Print(counted_bars,"=",Bars);
 if(counted_bars<0) return(-1);
 if(counted_bars>0) counted_bars--;
 int limit = MathMin(Bars-counted_bars,Bars-1);
   for(int i=limit; i>=0; i--) {
    double marginlevel = GetAccountMarginLevel();
    
    if (!AlertDone && ShowScreenComment) Comment(cstring+"current MarginLevel: "+DoubleToStr(marginlevel,2)+"%, alert will be given at level <= "+DoubleToStr(AlertAtMarginLevelOf,2)+"%");
    
    if (!AlertDone && AlertAtMarginLevelOf!=0.0 && marginlevel<=AlertAtMarginLevelOf) {
     AlertDone=true;
     doAlerts("Margin Level of "+DoubleToStr(AlertAtMarginLevelOf,2)+"% reached (current level: "+DoubleToStr(marginlevel,2)+"%)",SoundFileName);
     if (ShowScreenComment) Comment(cstring+"Marginlevel Alert done at "+TimeToStr(TimeLocal())+", restart the Indicator to set a new level");
    }
   }
 return(0);
}
  
double GetAccountMarginLevel() {
 double level=0.0;
 if (AccountMargin() > 0) level = AccountEquity()/AccountMargin()*100; 
return(level);
}

void doAlerts(string msg,string SoundFile) {
        //msg="MarginLevelAlertIndicator, Alert on "+Symbol()+", period "+TFtoStr(Period())+": "+msg;
        msg="MarginLevelAlertIndicator: "+msg;
 string emailsubject="MT4 alert on acc. "+AccountNumber()+", "+WindowExpertName()+" - Alert on "+Symbol()+", period "+TFtoStr(Period());
  if (PopupAlerts) Alert(msg);
  if (EmailAlerts) SendMail(emailsubject,msg);
  if (PushNotificationAlerts) SendNotification(msg);
  if (SoundAlerts) PlaySound(SoundFile);

}//void doAlerts(string msg,string SoundFile) {

string TFtoStr(int period) {
 switch(period) {
  case 1     : return("M1");  break;
  case 5     : return("M5");  break;
  case 15    : return("M15"); break;
  case 30    : return("M30"); break;
  case 60    : return("H1");  break;
  case 240   : return("H4");  break;
  case 1440  : return("D1");  break;
  case 10080 : return("W1");  break;
  case 43200 : return("MN1"); break;
  default    : return(DoubleToStr(period,0));
 }
 return("UNKNOWN");
}//string TFtoStr(int period) {

// class MarginLevel AlertIndictor
// {
// private:
  
// public:
//   MarginLevel AlertIndictor();
//   ~MarginLevel AlertIndictor();

// };
