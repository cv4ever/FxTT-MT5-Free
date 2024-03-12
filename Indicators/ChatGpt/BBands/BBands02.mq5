//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2021, CompanyName |
//|                                       http://www.companywebsite.com |
//+------------------------------------------------------------------+
#property copyright "2021 CompanyName"
#property link      "http://www.companywebsite.com/"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

input int       InpBandsPeriod    = 20;     // Period
input double    InpBandsDeviation = 2.0;   // Deviation
input int       InpBandsShift     = 0;     // Shift
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE; // Applied price

double         UpperBandBuffer[];
double         MiddleBandBuffer[];
double         LowerBandBuffer[];

int            BandsHandle;
//+------------------------------------------------------------------+
int OnInit()
{
    BandsHandle = iBands(_Symbol, PERIOD_M5, InpBandsPeriod, InpBandsShift, InpBandsDeviation, InpAppliedPrice);
    if(BandsHandle == INVALID_HANDLE)
    {
        Print("Failed to create handle for the iBands indicator");
        return(INIT_FAILED);
    }

    SetIndexBuffer(0, UpperBandBuffer);
    SetIndexBuffer(1, MiddleBandBuffer);
    SetIndexBuffer(2, LowerBandBuffer);

    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);

    PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_SOLID);
    PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
    PlotIndexSetString(0, PLOT_LABEL, "Upper Band");

    // Removed PlotIndexGetInteger usage as it was incorrect

    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    if(rates_total < InpBandsPeriod)
        return 0;

    int begin = rates_total - InpBandsPeriod;
    if(prev_calculated > begin)
        begin = prev_calculated - 1;

    for(int i = begin; i >= 0; i--)
    {
        double upperBand[1], middleBand[1], lowerBand[1];

        if(CopyBuffer(BandsHandle, 0, i, 1, upperBand) <= 0 ||
           CopyBuffer(BandsHandle, 1, i, 1, middleBand) <= 0 ||
           CopyBuffer(BandsHandle, 2, i, 1, lowerBand) <= 0)
        {
            Print("Error copying data from iBands indicator.");
            continue;
        }

        UpperBandBuffer[i] = upperBand[0];
        MiddleBandBuffer[i] = middleBand[0];
        LowerBandBuffer[i] = lowerBand[0];
    }
    return(rates_total);
}
//+------------------------------------------------------------------+
