//+------------------------------------------------------------------+
//|                                           EventPositionClose.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "Event.mqh"
//+------------------------------------------------------------------+
//| Position opening event                                           |
//+------------------------------------------------------------------+
class CEventPositionClose : public CEvent
  {
public:
//--- Constructor
                     CEventPositionClose(const int event_code,const ulong ticket=0) : CEvent(EVENT_STATUS_HISTORY_POSITION,event_code,ticket) {}
//--- Supported order properties (1) real, (2) integer
   virtual bool      SupportProperty(ENUM_EVENT_PROP_INTEGER property);
   virtual bool      SupportProperty(ENUM_EVENT_PROP_DOUBLE property);
//--- (1) Display a brief message about the event in the journal, (2) Send the event to the chart
   virtual void      PrintShort(void);
   virtual void      SendEvent(void);
  };
//+------------------------------------------------------------------+
//| Return 'true' if the event supports the passed                   |
//| integer property, otherwise return 'false'                       |
//+------------------------------------------------------------------+
bool CEventPositionClose::SupportProperty(ENUM_EVENT_PROP_INTEGER property)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Return 'true' if the event supports the passed                   |
//| real property, otherwise return 'false'                          |
//+------------------------------------------------------------------+
bool CEventPositionClose::SupportProperty(ENUM_EVENT_PROP_DOUBLE property)
  {
   return true;
  }
//+------------------------------------------------------------------+
//| Display a brief message about the event in the journal           |
//+------------------------------------------------------------------+
void CEventPositionClose::PrintShort(void)
  {
   string head="- "+this.TypeEventDescription()+": "+TimeMSCtoString(this.TimePosition())+" -\n";
   string opposite=(this.IsPresentEventFlag(TRADE_EVENT_FLAG_BY_POS) ? " by "+this.TypeOrderDescription()+" #"+(string)this.PositionByID() : "");
   string vol=::DoubleToString(this.VolumeExecuted(),DigitsLots(this.Symbol()));
   string magic=(this.Magic()!=0 ? TextByLanguage(", магик ",", magic ")+(string)this.Magic() : "");
   string type=this.TypePositionDescription()+" #"+(string)this.PositionID()+opposite;
   string price=TextByLanguage(" по цене "," at price ")+::DoubleToString(this.PriceClose(),(int)::SymbolInfoInteger(this.Symbol(),SYMBOL_DIGITS));
   string profit=TextByLanguage(", профит: ",", profit: ")+::DoubleToString(this.Profit(),this.m_digits_acc)+" "+::AccountInfoString(ACCOUNT_CURRENCY);
   string txt=head+this.Symbol()+" "+vol+" "+type+price+magic+profit;
   ::Print(txt);
  }
//+------------------------------------------------------------------+
//| Send the event to the chart                                      |
//+------------------------------------------------------------------+
void CEventPositionClose::SendEvent(void)
  {
   this.PrintShort();
   ::EventChartCustom(this.m_chart_id,(ushort)this.m_trade_event,this.PositionID(),this.PriceClose(),this.Symbol());
  }
//+------------------------------------------------------------------+
