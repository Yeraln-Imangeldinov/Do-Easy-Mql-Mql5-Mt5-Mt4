//+------------------------------------------------------------------+
//|                                                  EventModify.mqh |
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
class CEventModify : public CEvent
  {
private:
   double            m_price;                               // Price sent to an event
//--- Create and return a short event message
   string            EventsMessage(void);
public:
//--- Constructor
                     CEventModify(const int event_code,const ulong ticket=0) : CEvent(EVENT_STATUS_MODIFY,event_code,ticket),m_price(0) {}
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
bool CEventModify::SupportProperty(ENUM_EVENT_PROP_INTEGER property)
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
bool CEventModify::SupportProperty(ENUM_EVENT_PROP_DOUBLE property)
  {
   if(property==EVENT_PROP_PRICE_CLOSE             ||
      property==EVENT_PROP_PROFIT
     ) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Display a brief message about the event in the journal           |
//+------------------------------------------------------------------+
void CEventModify::PrintShort(void)
  {
   ::Print(this.EventsMessage());
  }
//+------------------------------------------------------------------+
//| Send the event to the chart                                      |
//+------------------------------------------------------------------+
void CEventModify::SendEvent(void)
  {
   this.PrintShort();
   ::EventChartCustom(this.m_chart_id,(ushort)this.m_trade_event,this.TicketOrderEvent(),this.m_price,this.Symbol());
  }
//+------------------------------------------------------------------+
//| Create and return a short event message                          |
//+------------------------------------------------------------------+
string CEventModify::EventsMessage(void)
  {
//--- (1) header, (2) magic number
   string head="- "+this.TypeEventDescription()+": "+TimeMSCtoString(this.TimePosition())+" -\n";
   string magic=(this.Magic()!=0 ? TextByLanguage(", магик ",", magic ")+(string)this.Magic() : "");
   string text="";

//--- Pending order price is modified
   if(this.TypeEvent()==TRADE_EVENT_MODIFY_ORDER_PRICE)
     {
      string order=OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderPosCurrent();
      string price="["+::DoubleToString(this.PriceOpenBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceOpen(),this.m_digits)+"]";
      text=order+TextByLanguage(": модифицирована цена: ",": modified price: ")+price+magic;
      this.m_price=this.PriceOpen();
     }
//--- Pending order price and StopLoss are modified
   else if(this.TypeEvent()==TRADE_EVENT_MODIFY_ORDER_PRICE_STOP_LOSS)
     {
      string order=OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderPosCurrent();
      string price="["+::DoubleToString(this.PriceOpenBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceOpen(),this.m_digits)+"]";
      string sl="["+::DoubleToString(this.PriceStopLossBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceStopLoss(),this.m_digits)+"]";
      text=order+TextByLanguage(": модифицирована цена: ",": modified price: ")+price+TextByLanguage(" и"," and")+" StopLoss: "+sl+magic;
      this.m_price=this.PriceOpen();
     }
//--- Pending order price and TakeProfit are modified
   else if(this.TypeEvent()==TRADE_EVENT_MODIFY_ORDER_PRICE_TAKE_PROFIT)
     {
      string order=OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderPosCurrent();
      string price="["+::DoubleToString(this.PriceOpenBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceOpen(),this.m_digits)+"]";
      string tp="["+::DoubleToString(this.PriceTakeProfitBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceTakeProfit(),this.m_digits)+"]";
      text=order+TextByLanguage(": модифицирована цена: ",": modified price: ")+price+TextByLanguage(" и"," and")+" TakeProfit: "+tp+magic;
      this.m_price=this.PriceOpen();
     }
//--- Pending order price, as well as its StopLoss and TakeProfit are modified
   else if(this.TypeEvent()==TRADE_EVENT_MODIFY_ORDER_PRICE_STOP_LOSS_TAKE_PROFIT)
     {
      string order=OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderPosCurrent();
      string price="["+::DoubleToString(this.PriceOpenBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceOpen(),this.m_digits)+"]";
      string sl="["+::DoubleToString(this.PriceStopLossBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceStopLoss(),this.m_digits)+"]";
      string tp="["+::DoubleToString(this.PriceTakeProfitBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceTakeProfit(),this.m_digits)+"]";
      text=order+TextByLanguage(": модифицирована цена: ",": modified price: ")+price+", StopLoss: "+sl+TextByLanguage(" и"," and")+" TakeProfit: "+tp+magic;
      this.m_price=this.PriceOpen();
     }
//--- Pending order StopLoss is modified
   else if(this.TypeEvent()==TRADE_EVENT_MODIFY_ORDER_STOP_LOSS)
     {
      string order=OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderPosCurrent();
      string sl="["+::DoubleToString(this.PriceStopLossBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceStopLoss(),this.m_digits)+"]";
      text=order+TextByLanguage(": модифицирован StopLoss: ",": modified StopLoss: ")+sl+magic;
      this.m_price=this.PriceStopLoss();
     }
//--- Pending order TakeProfit is modified
   else if(this.TypeEvent()==TRADE_EVENT_MODIFY_ORDER_TAKE_PROFIT)
     {
      string order=OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderPosCurrent();
      string tp="["+::DoubleToString(this.PriceTakeProfitBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceTakeProfit(),this.m_digits)+"]";
      text=order+TextByLanguage(": модифицирован TakeProfit: ",": modified TakeProfit: ")+tp+magic;
      this.m_price=this.PriceTakeProfit();
     }
//--- Pending order StopLoss and TakeProfit are modified
   else if(this.TypeEvent()==TRADE_EVENT_MODIFY_ORDER_STOP_LOSS_TAKE_PROFIT)
     {
      string order=OrderTypeDescription(this.TypeOrderPosCurrent())+" #"+(string)this.TicketOrderPosCurrent();
      string sl="["+::DoubleToString(this.PriceStopLossBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceStopLoss(),this.m_digits)+"]";
      string tp="["+::DoubleToString(this.PriceTakeProfitBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceTakeProfit(),this.m_digits)+"]";
      text=order+TextByLanguage(": модифицирован StopLoss: ",": modified StopLoss: ")+sl+TextByLanguage(" и"," and")+" TakeProfit: "+tp+magic;
      this.m_price=this.PriceOpen();
     }
//--- Position StopLoss is modified
   else if(this.TypeEvent()==TRADE_EVENT_MODIFY_POSITION_STOP_LOSS)
     {
      string order=PositionTypeDescription(this.TypePositionCurrent())+" #"+(string)this.TicketPositionCurrent();
      string sl="["+::DoubleToString(this.PriceStopLossBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceStopLoss(),this.m_digits)+"]";
      text=order+TextByLanguage(": модифицирован StopLoss: ",": modified StopLoss: ")+sl+magic;
      this.m_price=this.PriceStopLoss();
     }
//--- Position TakeProfit is modified
   else if(this.TypeEvent()==TRADE_EVENT_MODIFY_POSITION_TAKE_PROFIT)
     {
      string order=PositionTypeDescription(this.TypePositionCurrent())+" #"+(string)this.TicketPositionCurrent();
      string tp="["+::DoubleToString(this.PriceTakeProfitBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceTakeProfit(),this.m_digits)+"]";
      text=order+TextByLanguage(": модифицирован TakeProfit: ",": modified TakeProfit: ")+tp+magic;
      this.m_price=this.PriceTakeProfit();
     }
//--- Position StopLoss and TakeProfit are modified
   else if(this.TypeEvent()==TRADE_EVENT_MODIFY_POSITION_STOP_LOSS_TAKE_PROFIT)
     {
      string order=PositionTypeDescription(this.TypePositionCurrent())+" #"+(string)this.TicketPositionCurrent();
      string sl="["+::DoubleToString(this.PriceStopLossBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceStopLoss(),this.m_digits)+"]";
      string tp="["+::DoubleToString(this.PriceTakeProfitBefore(),this.m_digits)+" --> "+::DoubleToString(this.PriceTakeProfit(),this.m_digits)+"]";
      text=order+TextByLanguage(": модифицирован StopLoss: ",": modified StopLoss: ")+sl+TextByLanguage(" и"," and")+" TakeProfit: "+tp+magic;
      this.m_price=this.PriceOpen();
     }
   return head+this.Symbol()+" "+text;
  }
//+------------------------------------------------------------------+
