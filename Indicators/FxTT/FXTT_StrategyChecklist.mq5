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

#property script_show_inputs
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
   bool              m_checks_array[NUM_CHECKS];
public:
                     CPanelDialog(void);
                    ~CPanelDialog(void);
   //--- Create
   virtual bool      Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   //--- handlers of the dependent controls events
   void              OnChangeCheckGroup(void);

   //--- Create dependent controls
   bool              InitializeCheckGroupControls(void);
   bool              InitCheckGroupItems(void);

   void              SaveChecklistState(void);
   void              LoadChecklistState(void);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CPanelDialog)
ON_EVENT(ON_CHANGE,m_check_group,OnChangeCheckGroup)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
CPanelDialog::CPanelDialog(void)
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

   return(true);
  }
//+------------------------------------------------------------------+
void CPanelDialog::OnChangeCheckGroup(void)
  {
   for(int i = 0; i < NUM_CHECKS; ++i)
     {
      m_checks_array[i] = m_check_group.Check(i);
     }
  }
//+------------------------------------------------------------------+
bool CPanelDialog::InitializeCheckGroupControls(void)
  {
   // Define the positions and dimensions of the check group control
   const int x1 = 10, y1 = 10;
   const int x2 = 320, y2 = CalculateWindowHeight(CountNonEmptyChecklistItems());

   // Create the check group control
   if(!m_check_group.Create(m_chart_id, TAG + m_name + "CheckGroup", m_subwin, x1, y1, x2, y2))
      return(false);

   // Attach the check group control to the dialog
   if(!Add(m_check_group))
      return(false);

   // Initialize the check group items
   if(!InitCheckGroupItems())
      return(false);

   return(true);
  }
//+------------------------------------------------------------------+
bool CPanelDialog::InitCheckGroupItems(void)
  {
   string checks[NUM_CHECKS];
   GetChecklistStrings(checks);
   for(int i = 0; i < NUM_CHECKS; ++i)
     {
      if(StringLen(checks[i]) > 0)
        {
         int id = 1 << i;
         if(!m_check_group.AddItem(checks[i], id))
            return(false);
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
void CPanelDialog::SaveChecklistState()
  {
   string path = DataDirectoryName + "//" + Symbol() + DataFileName;
   ResetLastError();

   int handle = FileOpen(path, FILE_READ | FILE_WRITE | FILE_BIN);
   if(handle == INVALID_HANDLE)
      Print("Failed to open the file, error: " + (string) GetLastError());
   else
     {
      if(!FileWriteArray(handle, m_checks_array))
         Print("Failed to write to the file, error: " + (string)GetLastError());
      FileClose(handle);
     }
  }
//+------------------------------------------------------------------+
void CPanelDialog::LoadChecklistState()
  {
   string path = DataDirectoryName + "//" + Symbol() + DataFileName;

   ResetLastError();

   int file_handle = FileOpen(path, FILE_READ | FILE_BIN);
   if(file_handle == INVALID_HANDLE)
      Print("File open failed, error: " + (string) GetLastError());
   else
     {
      if(!FileReadArray(file_handle, m_checks_array))
         Print("Failed to read from the file, error: " + (string) GetLastError());
      FileClose(file_handle);

      for(int i=0; i<NUM_CHECKS; i++)
        {
         m_check_group.Check(i, m_checks_array[i]);
        }
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

   int count = 0;
   for(int i = 0; i < NUM_CHECKS; ++i)
     {
      if(StringLen(checks[i]) > 0)
         count++;
     }
   return count;
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
   const int checkboxHeight = 19;
   const int padding = 3;
   const int topAndBottomMargin = 10;

   int windowHeight = (numberOfCheckboxes * checkboxHeight) + topAndBottomMargin;
   return windowHeight;
  }
//+------------------------------------------------------------------+
Position CalculateDialogPosition(const Dimension& dialogDim, const Dimension& chartDim)
  {
   const int margin = 20;
   Position dialogPos = {margin, margin}; // Default values are for CORNER_LEFT_UPPER
   switch(Location)
     {
      case CORNER_RIGHT_UPPER:
         dialogPos.x = chartDim.width - dialogDim.width - margin;
         break;
      case CORNER_LEFT_LOWER:
         dialogPos.y = chartDim.height - dialogDim.height - margin;
         break;
      case CORNER_RIGHT_LOWER:
         dialogPos.x = chartDim.width - dialogDim.width - margin;
         dialogPos.y = chartDim.height - dialogDim.height - margin;
         break;
     }
   return dialogPos;
  }
//+------------------------------------------------------------------+