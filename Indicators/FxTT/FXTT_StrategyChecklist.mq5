//+------------------------------------------------------------------+
//|                                      FXTT_StrategyChecklist.mq5  |
//|                                  Copyright 2016, Carlos Oliveira |
//|                                 https://www.forextradingtools.eu |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Carlos Oliveira"
#property link      "https://www.forextradingtools.eu/"
#property version   "2.0"
#property strict
#property indicator_chart_window

//#property script_show_inputs
#property indicator_plots               0
#property indicator_buffers             0
#property indicator_minimum             0.0
#property indicator_maximum             0.0

#include <Controls\Dialog.mqh>
#include <Controls\CheckGroup.mqh>

#define NUM_CHECKS (20)

input string TAG = "FxTT_SC20_";
input ENUM_BASE_CORNER Location = CORNER_RIGHT_LOWER; //Window Location
input string Check01 = ">------- Example 1 -------<";
input string Check02 = "Example 2";
input string Check03 = "Example 3";
input string Check04 = "";
input string Check05 = "";
input string Check06 = "";
input string Check07 = "";
input string Check08 = "";
input string Check09 = "";
input string Check10 = "";
input string Check11 = "";
input string Check12 = "";
input string Check13 = "";
input string Check14 = "";
input string Check15 = "";
input string Check16 = "";
input string Check17 = "";
input string Check18 = "";
input string Check19 = "";
input string Check20 = "";

// Struct for dimensions and positions
struct Dimension
  {
   int               width, height;
  };

struct Position
  {
   int               x, y;
  };

string  DataFileName="data.bin";             // File name
string  DataDirectoryName="SChecklist";      // Folder name

//+------------------------------------------------------------------+
//| Class CPanelDialog                                               |
//+------------------------------------------------------------------+
class CPanelDialog : public CAppDialog
  {
private:
   CCheckGroup       m_check_group;
public:
   bool ChecksArray[NUM_CHECKS];
   bool              chk01;
   bool              chk02;
   bool              chk03;
   bool              chk04;
   bool              chk05;
   bool              chk06;
   bool              chk07;
   bool              chk08;
   bool              chk09;
   bool              chk10;
   bool              chk11;
   bool              chk12;
   bool              chk13;
   bool              chk14;
   bool              chk15;
   bool              chk16;
   bool              chk17;
   bool              chk18;
   bool              chk19;
   bool              chk20;

                     CPanelDialog(void);
                    ~CPanelDialog(void);
   //--- Create
   virtual bool      Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2);

   //--- Create dependent controls
   bool              InitializeCheckGroupControls(void);

   void              SaveChecklistState(void);
   void              LoadChecklistState(void);
  };
//+------------------------------------------------------------------+
CPanelDialog::CPanelDialog(void) :
   chk01(false), chk02(false), chk03(false), chk04(false),
   chk05(false), chk06(false), chk07(false), chk08(false),
   chk09(false), chk10(false), chk11(false), chk12(false),
   chk13(false), chk14(false), chk15(false), chk16(false),
   chk17(false), chk18(false), chk19(false), chk20(false)
  {
  }
//+------------------------------------------------------------------+
CPanelDialog::~CPanelDialog(void)
  {
   SaveChecklistState();
  }
//+------------------------------------------------------------------+
bool CPanelDialog::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
  {
   if(!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2))
      return(false);

   if(!InitializeCheckGroupControls())
      return(false);

   LoadChecklistState();

   m_check_group.Check(0, chk01);
   m_check_group.Check(1, chk02);
   m_check_group.Check(2, chk03);
   m_check_group.Check(3, chk04);
   m_check_group.Check(4, chk05);
   m_check_group.Check(5, chk06);
   m_check_group.Check(6, chk07);
   m_check_group.Check(7, chk08);
   m_check_group.Check(8, chk09);
   m_check_group.Check(9, chk10);
   m_check_group.Check(10, chk11);
   m_check_group.Check(11, chk12);
   m_check_group.Check(12, chk13);
   m_check_group.Check(13, chk14);
   m_check_group.Check(14, chk15);
   m_check_group.Check(15, chk16);
   m_check_group.Check(16, chk17);
   m_check_group.Check(17, chk18);
   m_check_group.Check(18, chk19);
   m_check_group.Check(19, chk20);

   return(true);
  }
//+------------------------------------------------------------------+
bool CPanelDialog::InitializeCheckGroupControls(void)
  {
   int x1 = 10;
   int y1 = 10;
   int x2 = 320;
   int y2 = CalculateWindowHeight(CountNonEmptyChecklistItems());

   if(!m_check_group.Create(m_chart_id, TAG+m_name + "CheckGroup", m_subwin, x1, y1, x2, y2))
      return(false);

   if(!Add(m_check_group))
      return(false);

   string checks[NUM_CHECKS];
   GetChecklistStrings(checks);

   for(int i = 0; i < NUM_CHECKS; ++i)
     {
      if(StringLen(checks[i]) > 0 && !m_check_group.AddItem(checks[i], 1 << i))
         return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
void CPanelDialog::SaveChecklistState()
  {
   bool arr[20] =
     {
      chk01, chk02, chk03, chk04, chk05,
      chk06, chk07, chk08, chk09, chk10,
      chk11, chk12, chk13, chk14, chk15,
      chk16, chk17, chk18, chk19, chk20
     };

   string path = DataDirectoryName + "//" + Symbol() + DataFileName;
   ResetLastError();

   int handle = FileOpen(path, FILE_READ | FILE_WRITE | FILE_BIN);
   if(handle == INVALID_HANDLE)
      Print("Failed to open the file, error: " + (string) GetLastError());
   else
     {
      if(!FileWriteArray(handle, arr))
         Print("Failed to write to the file, error: " + (string)GetLastError());
      FileClose(handle);
     }
  }
//+------------------------------------------------------------------+
void CPanelDialog::LoadChecklistState()
  {
   bool arr[NUM_CHECKS];
   string path = DataDirectoryName + "//" + Symbol() + DataFileName;

   ResetLastError();

   int file_handle = FileOpen(path, FILE_READ | FILE_BIN);
   if(file_handle == INVALID_HANDLE)
      Print("File open failed, error: " + (string) GetLastError());
   else
     {
      if(!FileReadArray(file_handle, arr))
         Print("Failed to read from the file, error: " + (string) GetLastError());
      else
        {
         chk01 = arr[0];
         chk02 = arr[1];
         chk03 = arr[2];
         chk04 = arr[3];
         chk05 = arr[4];
         chk06 = arr[5];
         chk07 = arr[6];
         chk08 = arr[7];
         chk09 = arr[8];
         chk10 = arr[9];
         chk11 = arr[10];
         chk12 = arr[11];
         chk13 = arr[12];
         chk14 = arr[13];
         chk15 = arr[14];
         chk16 = arr[15];
         chk17 = arr[16];
         chk18 = arr[17];
         chk19 = arr[18];
         chk20 = arr[19];
        }
      FileClose(file_handle);
     }
  }
//+------------------------------------------------------------------+

// Global variable
CPanelDialog ExtDialog;

//+------------------------------------------------------------------+
int OnInit()
  {
   Dimension dialogDim = InitDialogDimensions();
   Dimension chartDim = GetChartDimensions();

   if(!CreateAndRunDialog(dialogDim, chartDim))
      return INIT_FAILED;

   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(ChartID(),TAG);
   ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
Dimension InitDialogDimensions()
  {
   Dimension dim = {340, CalculateWindowHeight(CountNonEmptyChecklistItems()) + 40};
   return dim;
  }
//+------------------------------------------------------------------+
Dimension GetChartDimensions()
  {
   Dimension dim =
     {
      (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0),
      (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0)
     };
   return dim;
  }
//+------------------------------------------------------------------+
bool CreateAndRunDialog(const Dimension& dialogDim, const Dimension& chartDim)
  {
   Position dialogPos = CalculateDialogPosition(dialogDim, chartDim);
   Position dialogEndPos = {dialogPos.x + dialogDim.width, dialogPos.y + dialogDim.height};

   return ExtDialog.Create(0, TAG + "-Strategy Checklist", 0, dialogPos.x, dialogPos.y, dialogEndPos.x, dialogEndPos.y) && ExtDialog.Run();
  }
//+------------------------------------------------------------------+
int CountNonEmptyChecklistItems()
  {
   string checks[NUM_CHECKS];
   GetChecklistStrings(checks);

   int dy = 0;
   for(int i = 0; i < NUM_CHECKS; ++i)
     {
      if(StringLen(checks[i]) > 0)
         dy++;
     }
   return dy;
  }
//+------------------------------------------------------------------+
void GetChecklistStrings(string &arr[])
  {
   string checks[NUM_CHECKS] = {Check01, Check02, Check03, Check04, Check05,
                                Check06, Check07, Check08, Check09, Check10,
                                Check11, Check12, Check13, Check14, Check15,
                                Check16, Check17, Check18, Check19, Check20
                               };
   for(int i = 0; i < NUM_CHECKS; ++i)
     {
      arr[i] = checks[i];
     }
  }
//+------------------------------------------------------------------+
int CalculateWindowHeight(int numberOfCheckboxes)
  {
   int checkboxHeight = 19;
   int padding = 3;
   int topAndBottomMargin = 10;

   int windowHeight = (numberOfCheckboxes * checkboxHeight) + topAndBottomMargin;
   return windowHeight;
  }
//+------------------------------------------------------------------+
Position CalculateDialogPosition(const Dimension& dialogDim, const Dimension& chartDim)
  {
   Position dialogPos = {20, 20}; // Default values
   switch(Location)
     {
      case CORNER_RIGHT_UPPER:
         dialogPos.x = chartDim.width - dialogDim.width - 20;
         break;
      case CORNER_LEFT_LOWER:
         dialogPos.y = chartDim.height - dialogDim.height - 20;
         break;
      case CORNER_RIGHT_LOWER:
         dialogPos.x = chartDim.width - dialogDim.width - 20;
         dialogPos.y = chartDim.height - dialogDim.height - 20;
         break;
         // No default needed as dialogPos is initialized
     }
   return dialogPos;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
