//+------------------------------------------------------------------+
//|                                        EventBalanceOperation.mqh |
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
class CEventBalanceOperation : public CEvent
  {
public:
//--- Constructor
                     CEventBalanceOperation(const int event_code,const ulong ticket=0) : CEvent(EVENT_STATUS_BALANCE,event_code,ticket) {}
//--- Supported order properties (1) real, (2) integer
   virtual bool      SupportProperty(ENUM_EVENT_PROP_INTEGER property);
   virtual bool      SupportProperty(ENUM_EVENT_PROP_DOUBLE property);
   virtual bool      SupportProperty(ENUM_EVENT_PROP_STRING property);
//--- (1) Display a brief message about the event in the journal, (2) Send the event to the chart
   virtual void      PrintShort(void);
   virtual void      SendEvent(void);
  };
//+------------------------------------------------------------------+
//| Return 'true' if the event supports the passed                   |
//| integer property, otherwise return 'false'                       |
//+------------------------------------------------------------------+
bool CEventBalanceOperation::SupportProperty(ENUM_EVENT_PROP_INTEGER property)
  {
   if(property==EVENT_PROP_TYPE_ORDER_EVENT        ||
      property==EVENT_PROP_TYPE_ORDER_POSITION     ||
      property==EVENT_PROP_TICKET_ORDER_EVENT      ||
      property==EVENT_PROP_TICKET_ORDER_POSITION   ||
      property==EVENT_PROP_POSITION_ID             ||
      property==EVENT_PROP_POSITION_BY_ID          ||
      property==EVENT_PROP_POSITION_ID             ||
      property==EVENT_PROP_MAGIC_ORDER             ||
      property==EVENT_PROP_TIME_ORDER_POSITION
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Return 'true' if the event supports the passed                   |
//| real property, otherwise return 'false'                          |
//+------------------------------------------------------------------+
bool CEventBalanceOperation::SupportProperty(ENUM_EVENT_PROP_DOUBLE property)
  {
   return(property==EVENT_PROP_PROFIT ? true : false);
  }
//+------------------------------------------------------------------+
//| Return 'true' if the event supports the passed                   |
//| string property, otherwise return 'false'                        |
//+------------------------------------------------------------------+
bool CEventBalanceOperation::SupportProperty(ENUM_EVENT_PROP_STRING property)
  {
   return false;
  }
//+------------------------------------------------------------------+
//| Display a brief message about the event in the journal           |
//+------------------------------------------------------------------+
void CEventBalanceOperation::PrintShort(void)
  {
   string head="- "+this.StatusDescription()+": "+TimeMSCtoString(this.TimePosition())+" -\n";
   ::Print(head+this.TypeEventDescription()+": "+::DoubleToString(this.Profit(),this.m_digits_acc)+" "+::AccountInfoString(ACCOUNT_CURRENCY));
  }
//+------------------------------------------------------------------+
//| Send the event to the chart                                      |
//+------------------------------------------------------------------+
void CEventBalanceOperation::SendEvent(void)
  {
   this.PrintShort();
   ::EventChartCustom(this.m_chart_id,(ushort)this.m_trade_event,this.TypeEvent(),this.Profit(),::AccountInfoString(ACCOUNT_CURRENCY));
  }
//+------------------------------------------------------------------+
