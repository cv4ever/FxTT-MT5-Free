//+------------------------------------------------------------------+
//|                                           ControlsCheckGroup.mq5 |
//|                         Copyright 2000-2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Control Panels and Dialogs. Demonstration class CCheckGroup"

#include <Controls\Dialog.mqh>
#include <Controls\CheckGroup.mqh>

#define INDENT 11
#define CONTROL_GAP 5
#define BUTTON_SIZE 100, 20
#define EDIT_HEIGHT 20
#define GROUP_SIZE 150, 93

class CControlsDialog : public CAppDialog {
private:
   CCheckGroup m_check_group;

public:
   bool Create(long chart, string name, int subwin, int x1, int y1, int x2, int y2);
   bool OnEvent(int id, const long &lparam, const double &dparam, const string &sparam);

protected:
   bool CreateCheckGroup();
   void OnChangeCheckGroup();
};

EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CHANGE, m_check_group, OnChangeCheckGroup)
EVENT_MAP_END(CAppDialog)

bool CControlsDialog::Create(long chart, string name, int subwin, int x1, int y1, int x2, int y2) {
   if (!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2)) return false;
   return CreateCheckGroup();
}

bool CControlsDialog::CreateCheckGroup() {
   int x = INDENT, y = INDENT + 4 * (EDIT_HEIGHT + CONTROL_GAP) + CONTROL_GAP;
   if (!m_check_group.Create(m_chart_id, name + "CheckGroup", m_subwin, x, y, x + GROUP_SIZE, y + GROUP_SIZE)) return false;
   for (int i = 0; i < 5; i++) m_check_group.AddItem("Item " + IntegerToString(i), 1 << i);
   m_check_group.Check(0, 1 << 0).Check(2, 1 << 2);
   return Add(m_check_group);
}

void CControlsDialog::OnChangeCheckGroup() {
   Comment(__FUNCTION__ + " : Value=" + IntegerToString(m_check_group.Value()));
}

CControlsDialog ExtDialog;

int OnInit() {
   if (!ExtDialog.Create(ChartID(), "Controls", 0, 40, 40, 380, 344)) return INIT_FAILED;
   ExtDialog.Run();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
   Comment("");
   ExtDialog.Destroy(reason);
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   ExtDialog.ChartEvent(id, lparam, dparam, sparam);
}
