//+------------------------------------------------------------------+
//|                                            EventPositionOpen.mqh |
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
class CEventPositionOpen : public CEvent
  {
public:
//--- Constructor
                     CEventPositionOpen(const int event_code,const ulong ticket=0) : CEvent(EVENT_STATUS_MARKET_POSITION,event_code,ticket) {}
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
bool CEventPositionOpen::SupportProperty(ENUM_EVENT_PROP_INTEGER property)
  {
   return(property==EVENT_PROP_POSITION_BY_ID ? false : true);
  }
//+------------------------------------------------------------------+
//| Return 'true' if the event supports the passed                   |
//| real property, otherwise return 'false'                          |
//+------------------------------------------------------------------+
bool CEventPositionOpen::SupportProperty(ENUM_EVENT_PROP_DOUBLE property)
  {
   if(property==EVENT_PROP_PRICE_CLOSE ||
      property==EVENT_PROP_PROFIT
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Display a brief message about the event in the journal           |
//+------------------------------------------------------------------+
void CEventPositionOpen::PrintShort(void)
  {
   string head="- "+this.TypeEventDescription()+": "+TimeMSCtoString(this.TimePosition())+" -\n";
   string order=(this.IsPresentEventFlag(TRADE_EVENT_FLAG_ORDER_ACTIVATED) ? " #"+(string)this.TicketOrderPosition() : "");
   string activated=(this.IsPresentEventFlag(TRADE_EVENT_FLAG_ORDER_ACTIVATED) ? TextByLanguage(" активацией ордера "," by ")+this.TypeOrderBasedDescription() : "");
   string sl=(this.PriceStopLoss()>0 ? ", sl "+::DoubleToString(this.PriceStopLoss(),(int)::SymbolInfoInteger(this.Symbol(),SYMBOL_DIGITS)) : "");
   string tp=(this.PriceTakeProfit()>0 ? ", tp "+::DoubleToString(this.PriceTakeProfit(),(int)::SymbolInfoInteger(this.Symbol(),SYMBOL_DIGITS)) : "");
   string vol=::DoubleToString(this.VolumeInitial(),DigitsLots(this.Symbol()));
   string magic=(this.Magic()!=0 ? TextByLanguage(", магик ",", magic ")+(string)this.Magic() : "");
   string type=this.TypePositionDescription()+" #"+(string)this.PositionID();
   string price=TextByLanguage(" по цене "," at price ")+::DoubleToString(this.PriceOpen(),(int)::SymbolInfoInteger(this.Symbol(),SYMBOL_DIGITS));
   string txt=head+this.Symbol()+" "+vol+" "+type+activated+order+price+sl+tp+magic;
   ::Print(txt);
  }
//+------------------------------------------------------------------+
//| Send the event to the chart                                      |
//+------------------------------------------------------------------+
void CEventPositionOpen::SendEvent(void)
  {
   this.PrintShort();
   ::EventChartCustom(this.m_chart_id,(ushort)this.m_trade_event,this.PositionID(),this.PriceOpen(),this.Symbol());
  }
//+------------------------------------------------------------------+
