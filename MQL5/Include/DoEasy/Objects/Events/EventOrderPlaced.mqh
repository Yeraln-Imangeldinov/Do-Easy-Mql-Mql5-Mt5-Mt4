//+------------------------------------------------------------------+
//|                                             EventOrderPlased.mqh |
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
//| Placing a pending order event                                    |
//+------------------------------------------------------------------+
class CEventOrderPlased : public CEvent
  {
public:
//--- Constructor
                     CEventOrderPlased(const int event_code,const ulong ticket=0) : CEvent(EVENT_STATUS_MARKET_PENDING,event_code,ticket) {}
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
bool CEventOrderPlased::SupportProperty(ENUM_EVENT_PROP_INTEGER property)
  {
   if(property==EVENT_PROP_TYPE_DEAL_EVENT         ||
      property==EVENT_PROP_TICKET_DEAL_EVENT       ||
      property==EVENT_PROP_TYPE_ORDER_POSITION     ||
      property==EVENT_PROP_TICKET_ORDER_POSITION   ||
      property==EVENT_PROP_POSITION_ID             ||
      property==EVENT_PROP_POSITION_BY_ID          ||
      property==EVENT_PROP_TIME_ORDER_POSITION
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Return 'true' if the event supports the passed                   |
//| real property, otherwise return 'false'                          |
//+------------------------------------------------------------------+
bool CEventOrderPlased::SupportProperty(ENUM_EVENT_PROP_DOUBLE property)
  {
   if(property==EVENT_PROP_PRICE_CLOSE             ||
      property==EVENT_PROP_PROFIT
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Display a brief message about the event in the journal           |
//+------------------------------------------------------------------+
void CEventOrderPlased::PrintShort(void)
  {
   int    digits=(int)::SymbolInfoInteger(this.Symbol(),SYMBOL_DIGITS);
   string head="- "+this.TypeEventDescription()+": "+TimeMSCtoString(this.TimePosition())+" -\n";
   string sl=(this.PriceStopLoss()>0 ? ", sl "+::DoubleToString(this.PriceStopLoss(),digits) : "");
   string tp=(this.PriceTakeProfit()>0 ? ", tp "+::DoubleToString(this.PriceTakeProfit(),digits) : "");
   string vol=::DoubleToString(this.VolumeOrderInitial(),DigitsLots(this.Symbol()));
   string magic=(this.Magic()!=0 ? TextByLanguage(", магик ",", magic ")+(string)this.Magic() : "");
   string type=this.TypeOrderFirstDescription()+" #"+(string)this.TicketOrderEvent();
   string event=TextByLanguage(" Установлен "," Placed ");
   string price=TextByLanguage(" по цене "," at price ")+::DoubleToString(this.PriceOpen(),digits);
   string txt=head+this.Symbol()+event+vol+" "+type+price+sl+tp+magic;
   //--- If StopLimit order is activated
   if(this.Reason()==EVENT_REASON_STOPLIMIT_TRIGGERED)
     {
      head="- "+this.TypeEventDescription()+": "+TimeMSCtoString(this.TimeEvent())+" -\n";
      event=TextByLanguage(" Сработал "," Triggered ");
      type=
        (
         OrderTypeDescription(this.TypeOrderPosPrevious())+" #"+(string)this.TicketOrderEvent()+
         TextByLanguage(" по цене "," at price ")+DoubleToString(this.PriceEvent(),digits)+" -->\n"+
         vol+" "+OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderEvent()+
         TextByLanguage(" на цену "," on price ")+DoubleToString(this.PriceOpen(),digits)
        );
      txt=head+this.Symbol()+event+"("+TimeMSCtoString(this.TimePosition())+") "+vol+" "+type+sl+tp+magic;
     }
   ::Print(txt);
  }
//+------------------------------------------------------------------+
//| Send the event to the chart                                      |
//+------------------------------------------------------------------+
void CEventOrderPlased::SendEvent(void)
  {
   this.PrintShort();
   ::EventChartCustom(this.m_chart_id,(ushort)this.m_trade_event,this.TicketOrderEvent(),this.PriceOpen(),this.Symbol());
  }
//+------------------------------------------------------------------+
