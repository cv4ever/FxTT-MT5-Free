//+------------------------------------------------------------------+
//|                                     FXTT_MTF_BollingerBands.mq5  |
//|                                  Copyright 2024, Carlos Oliveira |
//|                                 https://www.forextradingtools.eu |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Carlos Oliveira"
#property link "https://www.forextradingtools.eu/"
#property version "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 27
#property indicator_plots 27

#include <Controls\CheckGroup.mqh>
#include <Controls\Dialog.mqh>

int bars_calculated = 0;

input int BBPeriod     = 20;   // Bollinger Bands Period
input int BBDeviations = 2;    // Bollinger Bands Deviations
input int BBShift      = 0;    // Bollinger Bands Shift

input ENUM_LINE_STYLE UpperStyle     = STYLE_DOT;   // Upper Band line style
input int             UpperLineWidth = 1;           // Upper Band line width
input color           UpperLineColor = clrPurple;   // Upper Band line color

input ENUM_LINE_STYLE MainStyle     = STYLE_DOT;   // Main Band line style
input int             MainLineWidth = 1;           // Main Band line style
input color           MainLineColor = clrRed;      // Main Band line style

input ENUM_LINE_STYLE LowerStyle     = STYLE_DOT;   // Lower Band line style
input int             LowerLineWidth = 1;           // Lower Band line style
input color           LowerLineColor = clrPurple;   // Lower Band line style

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT    (11)   // indent from left (with allowance for border width)
#define INDENT_TOP     (11)   // indent from top (with allowance for border width)
#define INDENT_RIGHT   (11)   // indent from right (with allowance for border width)
#define INDENT_BOTTOM  (11)   // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X (5)    // gap by X coordinate
#define CONTROLS_GAP_Y (5)    // gap by Y coordinate
//--- for group controls
#define GROUP_WIDTH  (230)   // size by X coordinate
#define GROUP_HEIGHT (57)    // size by Y coordinate

string       DataFileName      = "data.bin";    // File name
string       DataDirectoryName = "MTFBBands";   // Folder name
const string prefix            = "MTF BBands";
//+------------------------------------------------------------------+
//| Class CPanelDialog                                               |
//| Usage: main dialog of the SimplePanel application                |
//+------------------------------------------------------------------+
class CPanelDialog : public CAppDialog
  {
private:
   CCheckGroup       m_check_group;   // the check box group object
public:
   bool              mM1;
   bool              mM5;
   bool              mM15;
   bool              mM30;
   bool              mH1;
   bool              mH4;
   bool              mD1;
   bool              mW1;
   bool              mMN1;

                     CPanelDialog(void);
                    ~CPanelDialog(void);
   virtual bool      Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2);
   virtual bool      OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
   void              WriteIndicatorsData(void);
   void              ReadIndicatorsData(void);
   void              DrawIndicatorsData(void);

protected:
   bool              CreateCheckGroup(void);
   virtual bool      OnResize(void);
   void              OnChangeCheckGroup(void);
   void              DrawLabels();
   bool              OnDefault(const int id, const long &lparam, const double &dparam, const string &sparam);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CPanelDialog)
ON_EVENT(ON_CHANGE, m_check_group, OnChangeCheckGroup)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPanelDialog::CPanelDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPanelDialog::~CPanelDialog(void)
  {
   WriteIndicatorsData();
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CPanelDialog::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
  {
   if(!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2))
      return (false);
//--- create dependent controls
   if(!CreateCheckGroup())
      return (false);

   mM1  = false;
   mM5  = false;
   mM15 = false;
   mM30 = false;
   mH1  = false;
   mH4  = false;
   mD1  = false;
   mW1  = false;
   mMN1 = false;

   ReadIndicatorsData();

   m_check_group.Check(0, mM1);
   m_check_group.Check(1, mM5);
   m_check_group.Check(2, mM15);
   m_check_group.Check(3, mM30);
   m_check_group.Check(4, mH1);
   m_check_group.Check(5, mH4);
   m_check_group.Check(6, mD1);
   m_check_group.Check(7, mW1);
   m_check_group.Check(8, mMN1);

//--- succeed
   return (true);
  }
//+------------------------------------------------------------------+
//| Create the "CheckGroup" element                                  |
//+------------------------------------------------------------------+
bool CPanelDialog::CreateCheckGroup(void)
  {
   /*
      //--- coordinates
      int x1=INDENT_LEFT;
      int y1=INDENT_TOP;
      int x2=x1+GROUP_WIDTH;
      int y2=y1+GROUP_HEIGHT;

   //--- create
      if(!m_check_group.Create(m_chart_id,m_name+"CheckGroup",m_subwin,x1,y1,x2,y2))
         return(false);
      if(!Add(m_check_group))
         return(false);

   //--- fill out with strings
      if(!m_check_group.AddItem("Mail if Trade event",1<<0))
   */

   if(!m_check_group.Create(m_chart_id, m_name + "CheckGroup", m_subwin, 0, 0, 112, 170))
      return (false);
   if(!Add(m_check_group))
      return (false);

   if(!m_check_group.AddItem("M1", 1 << 0))
      return (false);
   if(!m_check_group.AddItem("M5", 1 << 1))
      return (false);
   if(!m_check_group.AddItem("M15", 1 << 2))
      return (false);
   if(!m_check_group.AddItem("M30", 1 << 3))
      return (false);
   if(!m_check_group.AddItem("H1", 1 << 4))
      return (false);
   if(!m_check_group.AddItem("H4", 1 << 5))
      return (false);
   if(!m_check_group.AddItem("D1", 1 << 6))
      return (false);
   if(!m_check_group.AddItem("W1", 1 << 7))
      return (false);
   if(!m_check_group.AddItem("MN1", 1 << 8))
      return (false);

   return (true);
  }
//+------------------------------------------------------------------+
bool CPanelDialog::OnResize(void)
  {
   if(!CAppDialog::OnResize())
      return (false);

   return (true);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CPanelDialog::OnChangeCheckGroup(void)
  {
   mM1  = m_check_group.Check(0);
   mM5  = m_check_group.Check(1);
   mM15 = m_check_group.Check(2);
   mM30 = m_check_group.Check(3);
   mH1  = m_check_group.Check(4);
   mH4  = m_check_group.Check(5);
   mD1  = m_check_group.Check(6);
   mW1  = m_check_group.Check(7);
   mMN1 = m_check_group.Check(8);

   DrawIndicatorsData();
  }
//+------------------------------------------------------------------+
void DrawIndicator(bool tfEnabled, int idx1, int idx2, int idx3, string objPrefix)
  {
   if(tfEnabled)
     {
      PlotIndexSetInteger(idx1, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(idx2, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(idx3, PLOT_DRAW_TYPE, DRAW_LINE);
     }
   else
     {
      PlotIndexSetInteger(idx1, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(idx2, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(idx3, PLOT_DRAW_TYPE, DRAW_NONE);
      ObjectsDeleteAll(ChartID(), objPrefix);
     }
  }
//+------------------------------------------------------------------+
void CPanelDialog::DrawIndicatorsData()
  {
   DrawIndicator(mMN1, 0, 1, 2, "BBMN");
   DrawIndicator(mW1, 3, 4, 5, "BBW1");
   DrawIndicator(mD1, 6, 7, 8, "BBD1");
   DrawIndicator(mH4, 9, 10, 11, "BBH4");
   DrawIndicator(mH1, 12, 13, 14, "BBH1");
   DrawIndicator(mM30, 15, 16, 17, "BBM30");
   DrawIndicator(mM15, 18, 19, 20, "BBM15");
   DrawIndicator(mM5, 21, 22, 23, "BBM5");
   DrawIndicator(mM1, 24, 25, 26, "BBM1");

   DrawLabels();
  }
//+------------------------------------------------------------------+
void CPanelDialog::DrawLabels()
  {
   ObjectsDeleteAll(0, prefix);

   int sizeM1 = ArraySize(bufferM1BBh) - 1;
   DrawPriceLabel(mM1, lblM1h, bufferM1BBh[sizeM1], "M1 BB Upper", UpperLineColor);
   DrawPriceLabel(mM1, lblM1m, bufferM1BBm[sizeM1], "M1 BB Main", MainLineColor);
   DrawPriceLabel(mM1, lblM1l, bufferM1BBl[sizeM1], "M1 BB Lower", LowerLineColor);

   int sizeM5 = ArraySize(bufferM5BBh) - 1;
   DrawPriceLabel(mM5, lblM5h, bufferM5BBh[sizeM5], "M5 BB Upper", UpperLineColor);
   DrawPriceLabel(mM5, lblM5m, bufferM5BBm[sizeM5], "M5 BB Main", MainLineColor);
   DrawPriceLabel(mM5, lblM5l, bufferM5BBl[sizeM5], "M5 BB Lower", LowerLineColor);

   int sizeM15 = ArraySize(bufferM15BBh) - 1;
   DrawPriceLabel(mM15, lblM15h, bufferM15BBh[sizeM15], "M15 BB Upper", UpperLineColor);
   DrawPriceLabel(mM15, lblM15m, bufferM15BBm[sizeM15], "M15 BB Main", MainLineColor);
   DrawPriceLabel(mM15, lblM15l, bufferM15BBl[sizeM15], "M15 BB Lower", LowerLineColor);

   int sizeM30 = ArraySize(bufferM30BBh) - 1;
   DrawPriceLabel(mM30, lblM30h, bufferM30BBh[sizeM30], "M30 BB Upper", UpperLineColor);
   DrawPriceLabel(mM30, lblM30m, bufferM30BBm[sizeM30], "M30 BB Main", MainLineColor);
   DrawPriceLabel(mM30, lblM30l, bufferM30BBl[sizeM30], "M30 BB Lower", LowerLineColor);

   int sizeH1 = ArraySize(bufferH1BBh) - 1;
   DrawPriceLabel(mH1, lblH1h, bufferH1BBh[sizeH1], "H1 BB Upper", UpperLineColor);
   DrawPriceLabel(mH1, lblH1m, bufferH1BBm[sizeH1], "H1 BB Main", MainLineColor);
   DrawPriceLabel(mH1, lblH1l, bufferH1BBl[sizeH1], "H1 BB Lower", LowerLineColor);

   int sizeH4 = ArraySize(bufferH4BBh) - 1;
   DrawPriceLabel(mH4, lblH4h, bufferH4BBh[sizeH4], "H4 BB Upper", UpperLineColor);
   DrawPriceLabel(mH4, lblH4m, bufferH4BBm[sizeH4], "H4 BB Main", MainLineColor);
   DrawPriceLabel(mH4, lblH4l, bufferH4BBl[sizeH4], "H4 BB Lower", LowerLineColor);

   int sizeD1 = ArraySize(bufferD1BBh) - 1;
   DrawPriceLabel(mD1, lblD1h, bufferD1BBh[sizeD1], "D1 Upper", UpperLineColor);
   DrawPriceLabel(mD1, lblD1m, bufferD1BBm[sizeD1], "D1 Main", MainLineColor);
   DrawPriceLabel(mD1, lblD1l, bufferD1BBl[sizeD1], "D1 Lower", LowerLineColor);

   int sizeW1 = ArraySize(bufferW1BBh) - 1;
   DrawPriceLabel(mW1, lblW1h, bufferW1BBh[sizeW1], "W1 BB Upper", UpperLineColor);
   DrawPriceLabel(mW1, lblW1m, bufferW1BBm[sizeW1], "W1 BB Main", MainLineColor);
   DrawPriceLabel(mW1, lblW1l, bufferW1BBl[sizeW1], "W1 BB Lower", LowerLineColor);

   int sizeMN1 = ArraySize(bufferMN1BBh) - 1;
   DrawPriceLabel(mMN1, lblMN1h, bufferMN1BBh[sizeMN1], "MN1 BB Upper", UpperLineColor);
   DrawPriceLabel(mMN1, lblMN1m, bufferMN1BBm[sizeMN1], "MN1 BB Main", MainLineColor);
   DrawPriceLabel(mMN1, lblMN1l, bufferMN1BBl[sizeMN1], "MN1 BB Lower", LowerLineColor);
  }

//+------------------------------------------------------------------+
//| Rest events handler                                                    |
//+------------------------------------------------------------------+
bool CPanelDialog::OnDefault(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
//--- restore buttons' states after mouse move'n'click
// if(id==CHARTEVENT_CLICK)
// m_radio_group.RedrawButtonStates();
//--- let's handle event by parent
   return (false);
  }
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CPanelDialog ExtDialog;


double bufferMN1BBh[];
double bufferMN1BBm[];
double bufferMN1BBl[];

double bufferW1BBh[];
double bufferW1BBm[];
double bufferW1BBl[];

double bufferD1BBh[];
double bufferD1BBm[];
double bufferD1BBl[];

double bufferH4BBh[];
double bufferH4BBm[];
double bufferH4BBl[];

double bufferH1BBh[];
double bufferH1BBm[];
double bufferH1BBl[];

double bufferM30BBh[];
double bufferM30BBm[];
double bufferM30BBl[];

double bufferM15BBh[];
double bufferM15BBm[];
double bufferM15BBl[];

double bufferM5BBh[];
double bufferM5BBm[];
double bufferM5BBl[];

double bufferM1BBh[];
double bufferM1BBm[];
double bufferM1BBl[];

int lblM1h, lblM1m, lblM1l;
int lblM5h, lblM5m, lblM5l;
int lblM15h, lblM15m, lblM15l;
int lblM30h, lblM30m, lblM30l;
int lblH1h, lblH1m, lblH1l;
int lblH4h, lblH4m, lblH4l;
int lblD1h, lblD1m, lblD1l;
int lblW1h, lblW1m, lblW1l;
int lblMN1h, lblMN1m, lblMN1l;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll(ChartID(), "MTF BBands");

   InitBuffers();

//--- create application dialog
   if(!ExtDialog.Create(0, "MTF BBands", 0, 10, 10, 130, 208))
      // if(!ExtDialog.Create(0,"MTF BBands",0,10,10,230,308))
      return (INIT_FAILED);
//--- run application
   if(!ExtDialog.Run())
      return (INIT_FAILED);
//--- ok

   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(ChartID(), "MTF BBands");

   ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
  {
   if(rates_total < BBPeriod)
      return 0;

   int start = BBPeriod - 1;
   if(prev_calculated > start)
      start = prev_calculated - 1;

   for(int i = start; i < rates_total; i++)
     {
      UpdateBuffers(i, PERIOD_MN1,  time[i], bufferMN1BBm, bufferMN1BBh, bufferMN1BBl);
      UpdateBuffers(i, PERIOD_W1,   time[i], bufferW1BBm, bufferW1BBh, bufferW1BBl);
      UpdateBuffers(i, PERIOD_D1,   time[i], bufferD1BBm, bufferD1BBh, bufferD1BBl);
      UpdateBuffers(i, PERIOD_H4,   time[i], bufferH4BBm, bufferH4BBh, bufferH4BBl);
      UpdateBuffers(i, PERIOD_H1,   time[i], bufferH1BBm, bufferH1BBh, bufferH1BBl);
      UpdateBuffers(i, PERIOD_M30,  time[i], bufferM30BBm, bufferM30BBh, bufferM30BBl);
      UpdateBuffers(i, PERIOD_M15,  time[i], bufferM15BBm, bufferM15BBh, bufferM15BBl);
      UpdateBuffers(i, PERIOD_M5,   time[i], bufferM5BBm, bufferM5BBh, bufferM5BBl);
      UpdateBuffers(i, PERIOD_M1,   time[i], bufferM1BBm, bufferM1BBh, bufferM1BBl);
     }

   ExtDialog.DrawIndicatorsData();

   return (rates_total);
  }
//+------------------------------------------------------------------+
void UpdateBuffers(const int idx, const ENUM_TIMEFRAMES timeframe, const datetime currentCandleTime, double &middleBuffer[], double &upperBuffer[], double &lowerBuffer[])
  {
   int barShift = iBarShift(NULL,timeframe,currentCandleTime,false);
   middleBuffer[idx] = CalculateSimpleMA(barShift,timeframe, BBPeriod);
   double stdDeviation = CalculateStdDeviation(barShift, BBPeriod, timeframe, middleBuffer[idx]);
   upperBuffer[idx] = middleBuffer[idx] + BBDeviations * stdDeviation;
   lowerBuffer[idx] = middleBuffer[idx] - BBDeviations * stdDeviation;
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int     id,
                  const long   &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   ExtDialog.ChartEvent(id, lparam, dparam, sparam);
  }
//+------------------------------------------------------------------+
void InitBuffers()
  {
   AddBuffer(0, bufferMN1BBh, DRAW_NONE, UpperStyle, UpperLineWidth, UpperLineColor, "MN1 BB Upper");
   AddBuffer(1, bufferMN1BBm, DRAW_NONE, MainStyle, MainLineWidth, MainLineColor, "MN1 BB Main");
   AddBuffer(2, bufferMN1BBl, DRAW_NONE, LowerStyle, LowerLineWidth, LowerLineColor, "MN1 BB Lower");

   AddBuffer(3, bufferW1BBh, DRAW_NONE, UpperStyle, UpperLineWidth, UpperLineColor, "W1 BB Upper");
   AddBuffer(4, bufferW1BBm, DRAW_NONE, MainStyle, MainLineWidth, MainLineColor, "W1 BB Main");
   AddBuffer(5, bufferW1BBl, DRAW_NONE, LowerStyle, LowerLineWidth, LowerLineColor, "W1 BB Lower");

   AddBuffer(6, bufferD1BBh, DRAW_NONE, UpperStyle, UpperLineWidth, UpperLineColor, "D1 BB Upper");
   AddBuffer(7, bufferD1BBm, DRAW_NONE, MainStyle, MainLineWidth, MainLineColor, "D1 BB Main");
   AddBuffer(8, bufferD1BBl, DRAW_NONE, LowerStyle, LowerLineWidth, LowerLineColor, "D1 BB Lower");

   AddBuffer(9, bufferH4BBh, DRAW_NONE, UpperStyle, UpperLineWidth, UpperLineColor, "H4 BB Upper");
   AddBuffer(10, bufferH4BBm, DRAW_NONE, MainStyle, MainLineWidth, MainLineColor, "H4 BB Main");
   AddBuffer(11, bufferH4BBl, DRAW_NONE, LowerStyle, LowerLineWidth, LowerLineColor, "H4 BB Lower");

   AddBuffer(12, bufferH1BBh, DRAW_NONE, UpperStyle, UpperLineWidth, UpperLineColor, "H1 BB Upper");
   AddBuffer(13, bufferH1BBm, DRAW_NONE, MainStyle, MainLineWidth, MainLineColor, "H1 BB Main");
   AddBuffer(14, bufferH1BBl, DRAW_NONE, LowerStyle, LowerLineWidth, LowerLineColor, "H1 BB Lower");

   AddBuffer(15, bufferM30BBh, DRAW_NONE, UpperStyle, UpperLineWidth, UpperLineColor, "M30 BB Upper");
   AddBuffer(16, bufferM30BBm, DRAW_NONE, MainStyle, MainLineWidth, MainLineColor, "M30 BB Main");
   AddBuffer(17, bufferM30BBl, DRAW_NONE, LowerStyle, LowerLineWidth, LowerLineColor, "M30 BB Lower");

   AddBuffer(18, bufferM15BBh, DRAW_NONE, UpperStyle, UpperLineWidth, UpperLineColor, "M15 BB Upper");
   AddBuffer(19, bufferM15BBm, DRAW_NONE, MainStyle, MainLineWidth, MainLineColor, "M15 BB Main");
   AddBuffer(20, bufferM15BBl, DRAW_NONE, LowerStyle, LowerLineWidth, LowerLineColor, "M15 BB Lower");

   AddBuffer(21, bufferM5BBh, DRAW_NONE, UpperStyle, UpperLineWidth, UpperLineColor, "M5 BB Upper");
   AddBuffer(22, bufferM5BBm, DRAW_NONE, MainStyle, MainLineWidth, MainLineColor, "M5 BB Main");
   AddBuffer(23, bufferM5BBl, DRAW_NONE, LowerStyle, LowerLineWidth, LowerLineColor, "M5 BB Lower");

   AddBuffer(24, bufferM1BBh, DRAW_NONE, UpperStyle, UpperLineWidth, UpperLineColor, "M1 BB Upper");
   AddBuffer(25, bufferM1BBm, DRAW_NONE, MainStyle, MainLineWidth, MainLineColor, "M1 BB Main");
   AddBuffer(26, bufferM1BBl, DRAW_NONE, LowerStyle, LowerLineWidth, LowerLineColor, "M1 BB Lower");
  }
//+------------------------------------------------------------------+
void AddBuffer(int idx, double &buffer[], int type, int style = STYLE_SOLID, int width = 1, color clr = clrNONE, string text = "")
  {
   SetIndexBuffer(idx, buffer, INDICATOR_DATA);
   PlotIndexSetInteger(idx, PLOT_DRAW_TYPE, DRAW_LINE);   
   PlotIndexSetInteger(idx, PLOT_LINE_COLOR, clr);   
   PlotIndexSetInteger(idx, PLOT_LINE_STYLE, style);
   PlotIndexSetInteger(idx, PLOT_LINE_WIDTH, width);
   PlotIndexSetString(idx, PLOT_LABEL, text);
  }
//+------------------------------------------------------------------+
void DrawPriceLabel(bool show, int lblHwnd, double price, string text, color foreground, color background = clrLightGray)
  {
   string lblName   = prefix + text;
   string hLineName = prefix + "hLine" + text;

   if(show)
     {
      int      x, y;
      datetime fwdTime;
      int      window = 0;

      ChartTimePriceToXY(0, 0, TimeCurrent(), price, x, y);
      x = x + 30;
      y = y - 8;
      ChartXYToTimePrice(0, x, y, window, fwdTime, price);

      ObjectCreate(0, lblName, OBJ_TEXT, 0, fwdTime, price);
      ObjectSetString(0, lblName, OBJPROP_TEXT, text + ":" + PriceToStr(price));
      ObjectSetString(0, lblName, OBJPROP_FONT, "Verdana");
      ObjectSetInteger(0, lblName, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, lblName, OBJPROP_COLOR, foreground);

      ObjectSetInteger(0, lblName, OBJPROP_CORNER, 0);
      ObjectSetInteger(0, lblName, OBJPROP_XDISTANCE, 250);
      ObjectSetInteger(0, lblName, OBJPROP_YDISTANCE, 20);

      if(StringFind(text, "Upper") > 0)
         HLineCreate(0, hLineName, 0, price, UpperLineColor, UpperStyle, UpperLineWidth);
      if(StringFind(text, "Main") > 0)
         HLineCreate(0, hLineName, 0, price, MainLineColor, MainStyle, MainLineWidth);
      if(StringFind(text, "Lower") > 0)
         HLineCreate(0, hLineName, 0, price, LowerLineColor, LowerStyle, LowerLineWidth);
     }
  }
//+------------------------------------------------------------------+
void CPanelDialog::WriteIndicatorsData()
  {
   bool   arr[9];
   string path = DataDirectoryName + "//" + Symbol() + DataFileName;

   arr[0] = mM1;
   arr[1] = mM5;
   arr[2] = mM15;
   arr[3] = mM30;
   arr[4] = mH1;
   arr[5] = mH4;
   arr[6] = mD1;
   arr[7] = mW1;
   arr[8] = mMN1;

//--- open the file
   ResetLastError();
   int handle = FileOpen(path, FILE_READ | FILE_WRITE | FILE_BIN);
   if(handle != INVALID_HANDLE)
     {
      //--- write array data
      FileWriteArray(handle, arr);
      //--- close the file
      FileClose(handle);
     }
   else
     {
      Print("Failed to open the file, error: " + (string)GetLastError());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPanelDialog::ReadIndicatorsData()
  {
   bool   arr[];
   string path = DataDirectoryName + "//" + Symbol() + DataFileName;

//--- open the file
   ResetLastError();
   int file_handle = FileOpen(path, FILE_READ | FILE_BIN);
   if(file_handle != INVALID_HANDLE)
     {
      //--- read all data from the file to the array
      FileReadArray(file_handle, arr);
      int size = ArraySize(arr);

      mM1  = arr[0];
      mM5  = arr[1];
      mM15 = arr[2];
      mM30 = arr[3];
      mH1  = arr[4];
      mH4  = arr[5];
      mD1  = arr[6];
      mW1  = arr[7];
      mMN1 = arr[8];

      //--- close the file
      FileClose(file_handle);
     }
   else
     {
      Print("File open failed, error: " + (string)GetLastError());
     }
  }
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID   = 0,             // chart's ID
                 const string          name       = "HLine",       // line name
                 const int             sub_window = 0,             // subwindow index
                 double                price      = 0,             // line price
                 const color           clr        = clrRed,        // line color
                 const ENUM_LINE_STYLE style      = STYLE_SOLID,   // line style
                 const int             width      = 1,             // line width
                 const bool            back       = false,         // in the background
                 const bool            selection  = false,         // highlight to move
                 const bool            hidden     = true,          // hidden in the object list
                 const long            z_order    = 0)                           // priority for mouse click
  {
   if(!price)
      price = SymbolInfoDouble(Symbol(), SYMBOL_BID);

   ResetLastError();
   if(!ObjectCreate(chart_ID, name, OBJ_HLINE, sub_window, 0, price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ", GetLastError());
      return (false);
     }
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
   ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);

   return (true);
  }
//+------------------------------------------------------------------+
string PriceToStr(double price)
  {
   int    digits         = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   string formattedPrice = DoubleToString(price, digits);
   return formattedPrice;
  }
//+------------------------------------------------------------------+
double CalculateSimpleMA(const int barShift, const ENUM_TIMEFRAMES movingAverageTimeframe, const int movingAveragePeriod)
  {
   if(Period() > movingAverageTimeframe)
      return EMPTY_VALUE;

   double sum = 0.0;
   for(int j = 0; j < movingAveragePeriod; j++)
      sum += iClose(NULL, movingAverageTimeframe, barShift + j);
   return sum / movingAveragePeriod;
  }
//+------------------------------------------------------------------+
double CalculateStdDeviation(const int barShift, const int period, const ENUM_TIMEFRAMES timeframe, const double mean)
  {
   double std_dev=0.0;
   for(int i=0; i<period; i++)
      std_dev += MathPow(iClose(NULL,timeframe, barShift + i)-mean,2.0);
   std_dev = MathSqrt(std_dev/period);
   return(std_dev);
  }
//+------------------------------------------------------------------+
