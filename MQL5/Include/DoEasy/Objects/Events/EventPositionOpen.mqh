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
private:
//--- Create and return a short event message
   string            EventsMessage(void);  
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
   ::Print(this.EventsMessage());
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
//| Create and return a short event message                          |
//+------------------------------------------------------------------+
string CEventPositionOpen::EventsMessage(void)
  {
//--- number of decimal places in an event symbol quote
   int digits=(int)::SymbolInfoInteger(this.Symbol(),SYMBOL_DIGITS);
//--- (1) header, (2) executed order volume, (3) executed position volume, (4) event price,
//--- (5) StopLoss price, (6) TakeProfit price, (7) magic number, (6) profit in account currency
   string head="- "+this.TypeEventDescription()+": "+TimeMSCtoString(this.TimePosition())+" -\n";
   string vol_ord=::DoubleToString(this.VolumeOrderExecuted(),DigitsLots(this.Symbol()));
   string vol_pos=::DoubleToString(this.VolumePositionExecuted(),DigitsLots(this.Symbol()));
   string price=TextByLanguage(" по цене "," at price ")+::DoubleToString(this.PriceEvent(),digits);
   string sl=(this.PriceStopLoss()>0 ? ", sl "+ ::DoubleToString(this.PriceStopLoss(),digits) : "");
   string tp=(this.PriceTakeProfit()>0 ? ", tp "+ ::DoubleToString(this.PriceTakeProfit(),digits) : "");
   string magic=(this.Magic()!=0 ? TextByLanguage(", магик ",", magic ")+(string)this.Magic() : "");
   string profit=TextByLanguage(", профит ",", profit ")+::DoubleToString(this.Profit(),this.m_digits_acc)+" "+::AccountInfoString(ACCOUNT_CURRENCY);
   //---
   string text="";
   //--- Position reversal
   if(this.GetProperty(EVENT_PROP_REASON_EVENT)<EVENT_REASON_ACTIVATED_PENDING)
     {
      //--- EURUSD: Buy #xx changed to 0.1 Sell #xx (0.2 SellLimit order #XX) at х.ххххх, sl х.ххххх, tp x.xxxxx, magic, profit xxxx
      text=
        (
         this.Symbol()+" "+
         this.TypePositionPreviousDescription()+" #"+(string)this.TicketPositionPrevious()+
         TextByLanguage(" изменен на "," turned to ")+vol_pos+" "+this.TypePositionCurrentDescription()+" #"+(string)this.TicketPositionCurrent()+
         " ["+vol_ord+" "+this.TypeOrderEventDescription()+" #"+(string)this.TicketOrderEvent()+"]"+price+sl+tp+magic+profit
        );
     }
   else
     {
      //--- Add volume
      if(this.GetProperty(EVENT_PROP_TICKET_ORDER_EVENT)!=this.GetProperty(EVENT_PROP_POSITION_ID))
        {
         //--- EURUSD: Added 0.1 to Buy #xx (BuyLimit order #XX) at х.ххххх, magic
         text=
           (
            this.Symbol()+" "+
            TextByLanguage("Добавлено ","Added ")+vol_ord+TextByLanguage(" к "," to ")+
            this.TypePositionCurrentDescription()+" #"+(string)this.TicketPositionCurrent()+
            " ["+vol_ord+" "+this.TypeOrderEventDescription()+" #"+(string)this.TicketOrderEvent()+"]"+price+magic
           );
        }
      //--- Open a position
      else
        {
         //--- EURUSD: Opened 0.1 Buy #xx (BuyLimit order #XX) at х.ххххх, sl х.ххххх, tp x.xxxxx, magic
         text=
           (
            this.Symbol()+" "+
            TextByLanguage("Открыт ","Open ")+vol_pos+" "+
            this.TypePositionCurrentDescription()+" #"+(string)this.TicketPositionCurrent()+
            " ["+vol_ord+" "+this.TypeOrderEventDescription()+" #"+(string)this.TicketOrderEvent()+"]"+price+sl+tp+magic
           );
        }
     }
   return head+text;
  }
//+------------------------------------------------------------------+
