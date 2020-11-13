//+------------------------------------------------------------------+
//| ACC+BAL+MARG v2  copyright Mar 2011 @ File45
//|
//| http://www.forexfactory.com/showthread.php?t=280525              
//| http://codebase.mql4.com/en/author/file45                        
//+------------------------------------------------------------------+
#property indicator_chart_window
#property copyright "unknown"
#property link "http://ForexBaron.net/"

// ++++++++++++++++++++++++++++++++ START OF DEFAULT OPTIONS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

extern string ACCOUNT_OPTIONS;
extern string Acc_Currency_Symbol = "$";// Account: Balance - Equity - Margin - FreeMargin - Profit
extern string POSITION;
extern int    Corner_Position        = 0;
extern int    Left_Right_Balance     = 10;
extern int    Left_Right_Equity      = 280;
extern int    Left_Right_Margin      = 550;
extern int    Left_Right_Free_Margin = 930;
extern int    Left_Right_Profit      = 1200;
extern int    Up_Down                = 3;
extern string SIZE_and_BOLD;
extern int    Font_Size          = 9;
extern bool   Font_Bold          = false;
extern string COLORS;
extern color  Color_Balance      = Green;//Black;
extern color  Color_Equity       = Yellow;//Black;
extern color  Color_Margin       = Tomato;//Black;
color ColorMargin;//fxdaytrader
extern double MarginPercentLvl1 = 1000.0;//fxdaytrader
extern double MarginPercentLvl2 = 500.0;//fxdaytrader
extern color  Color_Margin_Below_Lvl1 = DodgerBlue;//fxdaytrader
extern color  Color_Margin_Below_Lvl2 = Red;//fxdaytrader

extern color  Color_Free_Margin  = Aqua;
extern color  Color_Profit       = Lime;
extern color  Color_Loss         = Red;
extern color  Color_PnL_Closed   = Gray;
extern string SHOW_HIDE;
extern bool   Show_All           = true;
extern bool   Show_Balance       = true;
extern bool   Show_Equity        = true;
extern bool   Show_Margin        = true;
extern bool   Show_Free_Margin   = true;
extern bool   Show_Profit        = true;
extern int    Display_in_Window_0123  = 0;//3;
// ++++++++++++++++++++++++++++++++ END OF DEFAULT OPTIONS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// Balance - Profit alternative color
color PnL_Color;
string Acc_F, TM;
int PC;

int init()
{
   switch(Period())
   {    
      case 1:     TM = "M1";  break;
      case 5:     TM = "M5";  break;
      case 15:    TM = "H15"; break;
      case 30:    TM = "M30"; break;
      case 60:    TM = "H1";  break;
      case 240:   TM = "H4";  break;
      case 1440:  TM = "D1";  break;
      case 10080: TM = "W1";  break;
      case 43200: TM = "M4";  break;
   }     
    
   switch(Font_Bold)
   {
      case 1: Acc_F = "Arial black"; break;
      case 0: Acc_F = "Arial black";      break;
   }
   
   switch(Corner_Position)
   {    
      case 0: PC = 0; break;
      case 1: PC = 1; break;
      case 2: PC = 2; break;
      case 3: PC = 3; break;
      default: Alert(Symbol()+ " - " + TM + " : " + "Please enter 0 (TL), 1 (TR), 2 (BL) or 3 (BR)"); PC = 3;
   }    
    
    return(0);
}

int deinit()
{
    // Balance - deletes
    ObjectDelete("Acc_Balance_Label");
    ObjectDelete("Acc_Equity_Label");
    ObjectDelete("Acc_Margin_Label");
    ObjectDelete("Acc_Free_Margin_Label");
    ObjectDelete("Acc_Profit_Label");
    ObjectDelete("Stop_Loss");
    ObjectDelete("Take_Profit");

    return(0);
}

int start()
{
    // Balance:  Account Balance, Equity, Margin, Free Margin and Profit.
    if (Show_All == true)
    {
        if (Show_Balance == true)
        {
            string Acc_Balance = formatDouble(AccountBalance(), 2);
            ObjectCreate("Acc_Balance_Label", OBJ_LABEL, Display_in_Window_0123, 0, 0);
            ObjectSetText("Acc_Balance_Label", " BALANCE  " + Acc_Currency_Symbol + " " + Acc_Balance, Font_Size, Acc_F, Color_Balance);
            ObjectSet("Acc_Balance_Label", OBJPROP_CORNER, PC);
            ObjectSet("Acc_Balance_Label", OBJPROP_XDISTANCE, Left_Right_Balance);
            ObjectSet("Acc_Balance_Label", OBJPROP_YDISTANCE, Up_Down);
        }

        if (Show_Equity == true)
        {
            string Acc_Equity = formatDouble(AccountEquity(), 2);
            ObjectCreate("Acc_Equity_Label", OBJ_LABEL, Display_in_Window_0123, 0, 0);
            ObjectSetText("Acc_Equity_Label", " EQUITY  " + Acc_Currency_Symbol + " " + Acc_Equity, Font_Size, Acc_F, Color_Equity);
            ObjectSet("Acc_Equity_Label", OBJPROP_CORNER, PC);
            ObjectSet("Acc_Equity_Label", OBJPROP_XDISTANCE, Left_Right_Equity);
            ObjectSet("Acc_Equity_Label", OBJPROP_YDISTANCE, Up_Down);
        }

        double AM   = AccountEquity();
        double AFM  = AccountMargin();
        double AMPC = ((AM / AFM) * 100);
        string AMP  = formatDouble(AMPC,2);

        if (Show_Margin == true)
        {
         ColorMargin = Color_Margin;
         if (AMPC <= MarginPercentLvl1) ColorMargin = Color_Margin_Below_Lvl1;
         if (AMPC <= MarginPercentLvl2) ColorMargin = Color_Margin_Below_Lvl2;
            string Acc_Margin = formatDouble(AccountMargin(), 2);
            ObjectCreate("Acc_Margin_Label", OBJ_LABEL, Display_in_Window_0123, 0, 0);
            //ObjectSetText("Acc_Margin_Label", " MARGIN REQ " + Acc_Currency_Symbol + " " + Acc_Margin + "          " + AMP + "%"+"", Font_Size, Acc_F, Color_Margin);
            ObjectSetText("Acc_Margin_Label", " MARGIN REQ " + Acc_Currency_Symbol + " " + Acc_Margin + "          " + AMP + "%"+"", Font_Size, Acc_F, ColorMargin);
            ObjectSet("Acc_Margin_Label", OBJPROP_CORNER, PC);
            ObjectSet("Acc_Margin_Label", OBJPROP_XDISTANCE, Left_Right_Margin);
            ObjectSet("Acc_Margin_Label", OBJPROP_YDISTANCE, Up_Down);
        }

        if (Show_Free_Margin == true)
        {
            string Acc_Free_Margin = formatDouble(AccountFreeMargin(), 2);
            ObjectCreate("Acc_Free_Margin_Label", OBJ_LABEL, Display_in_Window_0123, 0, 0);
            ObjectSetText("Acc_Free_Margin_Label", "MARGIN LIQ " + Acc_Currency_Symbol + " " + Acc_Free_Margin, Font_Size, Acc_F, Color_Free_Margin);
            ObjectSet("Acc_Free_Margin_Label", OBJPROP_CORNER, PC);
            ObjectSet("Acc_Free_Margin_Label", OBJPROP_XDISTANCE, Left_Right_Free_Margin);
            ObjectSet("Acc_Free_Margin_Label", OBJPROP_YDISTANCE, Up_Down);
        }

        if (Show_Profit == true)
        {
            string Acc_Profit = formatDouble(AccountProfit(), 2);
            ObjectCreate("Acc_Profit_Label", OBJ_LABEL, Display_in_Window_0123, 0, 0);

            if (AccountProfit() >= 0.01)
            {
                PnL_Color = Color_Profit;
            }
            else if (AccountProfit() <= -0.01)
            {
                PnL_Color = Color_Loss;
            }
            else
            {
                PnL_Color = Color_PnL_Closed;
            }

            ObjectSetText("Acc_Profit_Label", " NET " + Acc_Currency_Symbol + " " + AccountCurrency() + "  " + Acc_Profit, Font_Size, Acc_F, PnL_Color);
            ObjectSet("Acc_Profit_Label", OBJPROP_CORNER, PC);
            ObjectSet("Acc_Profit_Label", OBJPROP_XDISTANCE, Left_Right_Profit);
            ObjectSet("Acc_Profit_Label", OBJPROP_YDISTANCE, Up_Down);
        }
    }

    return(0);
}

string formatDouble(double number, int precision, string pcomma = "", string ppoint = ".")
{
    string snum     = DoubleToStr(number, precision);
    int    decp     = StringFind(snum, ".", 0);
    string sright   = StringSubstr(snum, decp + 1, precision);
    string sleft    = StringSubstr(snum, 0, decp);
    string formated = "";
    string comma    = "";

    while (StringLen(sleft) > 3)
    {
        int    length = StringLen(sleft);
        string part   = StringSubstr(sleft, length - 3, 0);
        formated = part + comma + formated;
        comma    = pcomma;
        sleft    = StringSubstr(sleft, 0, length - 3);
    }
    if (sleft == "-")
        comma = "";              // this line missing previously
    if (sleft != "")
        formated = sleft + comma + formated;
    if (precision > 0)
        formated = formated + ppoint + sright;
    return(formated);
}






