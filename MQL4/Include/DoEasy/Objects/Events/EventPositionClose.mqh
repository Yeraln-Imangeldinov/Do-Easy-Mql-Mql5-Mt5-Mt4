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
private:
//--- Create and return a short event message
   string            EventsMessage(void);  
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
   ::Print(this.EventsMessage());
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
//| Create and return a short event message                          |
//+------------------------------------------------------------------+
string CEventPositionClose::EventsMessage(void)
  {
//--- (1) header, (2) executed order volume, (3) executed position volume, (4) event price,
//--- (5) StopLoss price, (6) TakeProfit price, (7) magic number, (6) profit in account currency, (7,8) closure message variants
   string head="- "+this.TypeEventDescription()+": "+TimeMSCtoString(this.TimePosition())+" -\n";
   string vol_ord=::DoubleToString(this.VolumeOrderExecuted(),DigitsLots(this.Symbol()));
   string vol_pos=::DoubleToString(this.VolumePositionExecuted(),DigitsLots(this.Symbol()));
   string price=TextByLanguage(" по цене "," at price ")+::DoubleToString(this.PriceEvent(),this.m_digits);
   string sl=(this.PriceStopLoss()>0 ? ", sl "+ ::DoubleToString(this.PriceStopLoss(),this.m_digits) : "");
   string tp=(this.PriceTakeProfit()>0 ? ", tp "+ ::DoubleToString(this.PriceTakeProfit(),this.m_digits) : "");
   string magic=(this.Magic()!=0 ? TextByLanguage(", магик ",", magic ")+(string)this.Magic() : "");
   string profit=TextByLanguage(", профит ",", profit ")+::DoubleToString(this.Profit(),this.m_digits_acc)+" "+::AccountInfoString(ACCOUNT_CURRENCY);
   string close=TextByLanguage("Закрыт ","Close ");
   string in_pos="";
   //---
   if(this.GetProperty(EVENT_PROP_TYPE_EVENT)>TRADE_EVENT_POSITION_VOLUME_ADD_BY_PENDING_PARTIAL)
     {
      close=TextByLanguage("Закрыт объём ","Closed volume ")+vol_ord;
      in_pos=TextByLanguage(" в "," in ");
     }
   string opposite=
     (
      this.IsPresentEventFlag(TRADE_EVENT_FLAG_BY_POS)   ? 
      TextByLanguage(" встречным "," by opposite ")+this.SymbolCloseBy()+" "+
      this.TypeOrderDealDescription()+" #"+(string)this.PositionByID()+(this.MagicCloseBy()> 0 ? "("+(string)this.MagicCloseBy()+"]" : "")
                                                         : ""
     );
   //--- EURUSD: Closed 0.1 Sell #xx [0.2 SellLimit order #XX] at х.ххххх, sl х.ххххх, tp x.xxxxx, magic, profit xxxx
   string text=
     (
      this.Symbol()+" "+close+in_pos+this.TypePositionCurrentDescription()+" #"+(string)this.TicketPositionCurrent()+
      opposite+" ["+vol_ord+" "+this.TypeOrderEventDescription()+" #"+(string)this.TicketOrderEvent()+"]"+price+sl+tp+magic+profit
     );
   return head+text;
  }
//+------------------------------------------------------------------+
