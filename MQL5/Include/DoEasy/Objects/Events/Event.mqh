//+------------------------------------------------------------------+
//|                                                        Event.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
#property strict    // Necessary for mql4
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include "\..\..\Services\DELib.mqh"
#include "..\..\Collections\HistoryCollection.mqh"
#include "..\..\Collections\MarketCollection.mqh"
//+------------------------------------------------------------------+
//| Abstract event class                                             |
//+------------------------------------------------------------------+
class CEvent : public CObject
  {
private:
   int               m_event_code;                                   // Event code
//--- Return the index of the array the event's (1) double and (2) string properties are located at
   int               IndexProp(ENUM_EVENT_PROP_DOUBLE property)const { return(int)property-EVENT_PROP_INTEGER_TOTAL;                         }
   int               IndexProp(ENUM_EVENT_PROP_STRING property)const { return(int)property-EVENT_PROP_INTEGER_TOTAL-EVENT_PROP_DOUBLE_TOTAL; }
protected:
   ENUM_TRADE_EVENT  m_trade_event;                                  // Trading event
   long              m_chart_id;                                     // Control program chart ID
   int               m_digits_acc;                                   // Number of decimal places for the account currency
   long              m_long_prop[EVENT_PROP_INTEGER_TOTAL];          // Event integer properties
   double            m_double_prop[EVENT_PROP_DOUBLE_TOTAL];         // Event real properties
   string            m_string_prop[EVENT_PROP_STRING_TOTAL];         // Event string properties
//--- return the flag presence in the trading event
   bool              IsPresentEventFlag(const int event_code)  const { return (this.m_event_code & event_code)==event_code;            }

   //--- Protected parametric constructor
                     CEvent(const ENUM_EVENT_STATUS event_status,const int event_code,const ulong ticket);
public:
//--- Default constructor
                     CEvent(void){;}
 
//--- Set event's (1) integer, (2) real and (3) string properties
   void              SetProperty(ENUM_EVENT_PROP_INTEGER property,long value) { this.m_long_prop[property]=value;                      }
   void              SetProperty(ENUM_EVENT_PROP_DOUBLE property,double value){ this.m_double_prop[this.IndexProp(property)]=value;    }
   void              SetProperty(ENUM_EVENT_PROP_STRING property,string value){ this.m_string_prop[this.IndexProp(property)]=value;    }
//--- Return the event's (1) integer, (2) real and (3) string properties from the property array
   long              GetProperty(ENUM_EVENT_PROP_INTEGER property)      const { return this.m_long_prop[property];                     }
   double            GetProperty(ENUM_EVENT_PROP_DOUBLE property)       const { return this.m_double_prop[this.IndexProp(property)];   }
   string            GetProperty(ENUM_EVENT_PROP_STRING property)       const { return this.m_string_prop[this.IndexProp(property)];   }

//--- Return the flag of the event supporting the property
   virtual bool      SupportProperty(ENUM_EVENT_PROP_INTEGER property)        { return true; }
   virtual bool      SupportProperty(ENUM_EVENT_PROP_DOUBLE property)         { return true; }
   virtual bool      SupportProperty(ENUM_EVENT_PROP_STRING property)         { return true; }

//--- Set the control program chart ID
   void              SetChartID(const long id)                                { this.m_chart_id=id;                                    }
//--- Decode the event code and set the trading event, (2) return the trading event
   void              SetTypeEvent(void);
   ENUM_TRADE_EVENT  TradeEvent(void)                                   const { return this.m_trade_event;                             }
//--- Send the event to the chart (implementation in descendant classes)
   virtual void      SendEvent(void) {;}

//--- Compare CEvent objects by a specified property (to sort the lists by a specified event object property)
   virtual int       Compare(const CObject *node,const int mode=0) const;
//--- Compare CEvent objects by all properties (to search for equal event objects)
   bool              IsEqual(CEvent* compared_event);
//+------------------------------------------------------------------+
//| Methods of simplified access to event object properties          |
//+------------------------------------------------------------------+
//--- Return (1) event type, (2) event time in milliseconds, (3) event status, (4) event reason, (5) deal type, (6) deal ticket, 
//--- (7) order type, based on which a deal was executed, (8) position opening order type, (9) position last order ticket, 
//--- (10) position first order ticket, (11) position ID, (12) opposite position ID, (13) magic number, (14) position open time

   ENUM_TRADE_EVENT  TypeEvent(void)                                    const { return (ENUM_TRADE_EVENT)this.GetProperty(EVENT_PROP_TYPE_EVENT);     }
   long              TimeEvent(void)                                    const { return this.GetProperty(EVENT_PROP_TIME_EVENT);                       }
   ENUM_EVENT_STATUS Status(void)                                       const { return (ENUM_EVENT_STATUS)this.GetProperty(EVENT_PROP_STATUS_EVENT);  }
   ENUM_EVENT_REASON Reason(void)                                       const { return (ENUM_EVENT_REASON)this.GetProperty(EVENT_PROP_REASON_EVENT);  }
   long              TypeDeal(void)                                     const { return this.GetProperty(EVENT_PROP_TYPE_DEAL_EVENT);                  }
   long              TicketDeal(void)                                   const { return this.GetProperty(EVENT_PROP_TICKET_DEAL_EVENT);                }
   long              TypeOrderEvent(void)                               const { return this.GetProperty(EVENT_PROP_TYPE_ORDER_EVENT);                 }
   long              TypeOrderPosition(void)                            const { return this.GetProperty(EVENT_PROP_TYPE_ORDER_POSITION);              }
   long              TicketOrderEvent(void)                             const { return this.GetProperty(EVENT_PROP_TICKET_ORDER_EVENT);               }
   long              TicketOrderPosition(void)                          const { return this.GetProperty(EVENT_PROP_TICKET_ORDER_POSITION);            }
   long              PositionID(void)                                   const { return this.GetProperty(EVENT_PROP_POSITION_ID);                      }
   long              PositionByID(void)                                 const { return this.GetProperty(EVENT_PROP_POSITION_BY_ID);                   }
   long              Magic(void)                                        const { return this.GetProperty(EVENT_PROP_MAGIC_ORDER);                      }
   long              TimePosition(void)                                 const { return this.GetProperty(EVENT_PROP_TIME_ORDER_POSITION);              }
   
//--- Return (1) the price the event occurred at, (2) open price, (3) close price,
//--- (4) StopLoss price, (5) TakeProfit price, (6) profit, (7) requested volume, (8), executed volume, (9) remaining volume
   double            PriceEvent(void)                                   const { return this.GetProperty(EVENT_PROP_PRICE_EVENT);                      }
   double            PriceOpen(void)                                    const { return this.GetProperty(EVENT_PROP_PRICE_OPEN);                       }
   double            PriceClose(void)                                   const { return this.GetProperty(EVENT_PROP_PRICE_CLOSE);                      }
   double            PriceStopLoss(void)                                const { return this.GetProperty(EVENT_PROP_PRICE_SL);                         }
   double            PriceTakeProfit(void)                              const { return this.GetProperty(EVENT_PROP_PRICE_TP);                         }
   double            Profit(void)                                       const { return this.GetProperty(EVENT_PROP_PROFIT);                           }
   double            VolumeInitial(void)                                const { return this.GetProperty(EVENT_PROP_VOLUME_INITIAL);                   }
   double            VolumeExecuted(void)                               const { return this.GetProperty(EVENT_PROP_VOLUME_EXECUTED);                  }
   double            VolumeCurrent(void)                                const { return this.GetProperty(EVENT_PROP_VOLUME_CURRENT);                   }
   
//--- Return a symbol
   string            Symbol(void)                                       const { return this.GetProperty(EVENT_PROP_SYMBOL);                           }
   
//+------------------------------------------------------------------+
//| Descriptions of the order object properties                      |
//+------------------------------------------------------------------+
//--- Get description of an order's (1) integer, (2) real and (3) string property
   string            GetPropertyDescription(ENUM_EVENT_PROP_INTEGER property);
   string            GetPropertyDescription(ENUM_EVENT_PROP_DOUBLE property);
   string            GetPropertyDescription(ENUM_EVENT_PROP_STRING property);
//--- Return the event's (1) status and (2) type
   string            StatusDescription(void)          const;
   string            TypeEventDescription(void)       const;
//--- Return the name of an (1) order/position/deal, (2) parent order, (3) position
   string            TypeOrderDescription(void)       const;
   string            TypeOrderBasedDescription(void)  const;
   string            TypePositionDescription(void)    const;
//--- Return the name of the deal/order/position reason
   string            ReasonDescription(void)          const;

//--- Display (1) description of order properties (full_prop=true - all properties, false - only supported ones),
//--- (2) short event message (implementation in the class descendants) in the journal
   void              Print(const bool full_prop=false);
   virtual void      PrintShort(void) {;}
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CEvent::CEvent(const ENUM_EVENT_STATUS event_status,const int event_code,const ulong ticket) : m_event_code(event_code)
  {
   this.m_long_prop[EVENT_PROP_STATUS_EVENT]       =  event_status;
   this.m_long_prop[EVENT_PROP_TICKET_ORDER_EVENT] =  (long)ticket;
   this.m_digits_acc=(int)::AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);
   this.m_chart_id=::ChartID();
  }
//+------------------------------------------------------------------+
//| Compare CEvent objects by a specified property                   |
//+------------------------------------------------------------------+
int CEvent::Compare(const CObject *node,const int mode=0) const
  {
   const CEvent *event_compared=node;
//--- compare integer properties of two events
   if(mode<EVENT_PROP_INTEGER_TOTAL)
     {
      long value_compared=event_compared.GetProperty((ENUM_EVENT_PROP_INTEGER)mode);
      long value_current=this.GetProperty((ENUM_EVENT_PROP_INTEGER)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
//--- compare integer properties of two objects
   if(mode<EVENT_PROP_DOUBLE_TOTAL+EVENT_PROP_INTEGER_TOTAL)
     {
      double value_compared=event_compared.GetProperty((ENUM_EVENT_PROP_DOUBLE)mode);
      double value_current=this.GetProperty((ENUM_EVENT_PROP_DOUBLE)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
//--- compare string properties of two objects
   else if(mode<EVENT_PROP_DOUBLE_TOTAL+EVENT_PROP_INTEGER_TOTAL+EVENT_PROP_STRING_TOTAL)
     {
      string value_compared=event_compared.GetProperty((ENUM_EVENT_PROP_STRING)mode);
      string value_current=this.GetProperty((ENUM_EVENT_PROP_STRING)mode);
      return(value_current>value_compared ? 1 : value_current<value_compared ? -1 : 0);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//| Compare CEvent events by all properties                          |
//+------------------------------------------------------------------+
bool CEvent::IsEqual(CEvent *compared_event)
  {
   int beg=0, end=EVENT_PROP_INTEGER_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_EVENT_PROP_INTEGER prop=(ENUM_EVENT_PROP_INTEGER)i;
      if(this.GetProperty(prop)!=compared_event.GetProperty(prop)) return false; 
     }
   beg=end; end+=EVENT_PROP_DOUBLE_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_EVENT_PROP_DOUBLE prop=(ENUM_EVENT_PROP_DOUBLE)i;
      if(this.GetProperty(prop)!=compared_event.GetProperty(prop)) return false; 
     }
   beg=end; end+=EVENT_PROP_STRING_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_EVENT_PROP_STRING prop=(ENUM_EVENT_PROP_STRING)i;
      if(this.GetProperty(prop)!=compared_event.GetProperty(prop)) return false; 
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Decode the event code and set a trading event                    |
//+------------------------------------------------------------------+
void CEvent::SetTypeEvent(void)
  {
//--- Pending order is set (check if the event code is matched since there can be only one flag here)
   if(this.m_event_code==TRADE_EVENT_FLAG_ORDER_PLASED)
     {
      this.m_trade_event=TRADE_EVENT_PENDING_ORDER_PLASED;
      this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
      return;
     }
//--- Pending order is removed (check if the event code is matched since there can be only one flag here)
   if(this.m_event_code==TRADE_EVENT_FLAG_ORDER_REMOVED)
     {
      this.m_trade_event=TRADE_EVENT_PENDING_ORDER_REMOVED;
      this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
      return;
     }
//--- Position is opened (Check for multiple flags in the event code)
   if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_POSITION_OPENED))
     {
      //--- If this pending order is activated by the price
      if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_ORDER_ACTIVATED))
        {
         //--- check the partial closure flag and set the "pending order activated" or "pending order partially activated" trading event
         this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_PENDING_ORDER_ACTIVATED : TRADE_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL);
         this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
         return;
        }
      //--- check the partial opening flag and set the "Position opened" or "Position partially opened" trading event
      this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_OPENED : TRADE_EVENT_POSITION_OPENED_PARTIAL);
      this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
      return;
     }
//--- Position is closed (Check for multiple flags in the event code)
   if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_POSITION_CLOSED))
     {
      //--- if the position is closed by StopLoss
      if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_SL))
        {
         //--- check the partial closing flag and set the "Position closed by StopLoss" or "Position closed by StopLoss partially" trading event
         this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED_BY_SL : TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL);
         this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
         return;
        }
      //--- if the position is closed by TakeProfit
      else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_TP))
        {
         //--- check the partial closing flag and set the "Position closed by TakeProfit" or "Position closed by TakeProfit partially" trading event
         this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED_BY_TP : TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP);
         this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
         return;
        }
      //--- if the position is closed by an opposite one
      else if(this.IsPresentEventFlag(TRADE_EVENT_FLAG_BY_POS))
        {
         //--- check the partial closing flag and set the "Position closed by opposite one" or "Position closed by opposite one partially" event
         this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED_BY_POS : TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS);
         this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
         return;
        }
      //--- If the position is closed
      else
        {
         //--- check the partial closing flag and set the "Position closed" or "Position closed partially" event
         this.m_trade_event=(!this.IsPresentEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED : TRADE_EVENT_POSITION_CLOSED_PARTIAL);
         this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
         return;
        }
     }
//--- Balance operation on the account (clarify the event by the deal type)
   if(this.m_event_code==TRADE_EVENT_FLAG_ACCOUNT_BALANCE)
     {
      //--- Initialize the trading event
      this.m_trade_event=TRADE_EVENT_NO_EVENT;
      //--- Take a deal type
      ENUM_DEAL_TYPE deal_type=(ENUM_DEAL_TYPE)this.GetProperty(EVENT_PROP_TYPE_DEAL_EVENT);
      //--- if the deal is a balance operation
      if(deal_type==DEAL_TYPE_BALANCE)
        {
        //--- check the deal profit and set the event (funds deposit or withdrawal)
         this.m_trade_event=(this.GetProperty(EVENT_PROP_PROFIT)>0 ? TRADE_EVENT_ACCOUNT_BALANCE_REFILL : TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL);
        }
      //--- Remaining balance operation types match the ENUM_DEAL_TYPE enumeration starting with DEAL_TYPE_CREDIT
      else if(deal_type>DEAL_TYPE_BALANCE)
        {
        //--- set the event
         this.m_trade_event=(ENUM_TRADE_EVENT)deal_type;
        }
      this.SetProperty(EVENT_PROP_TYPE_EVENT,this.m_trade_event);
      return;
     }
  }
//+------------------------------------------------------------------+
//| Return the description of the event's integer property           |
//+------------------------------------------------------------------+
string CEvent::GetPropertyDescription(ENUM_EVENT_PROP_INTEGER property)
  {
   return
     (
      property==EVENT_PROP_TYPE_EVENT              ?  TextByLanguage("Тип события","Event's type")+": "+this.TypeEventDescription()                                                       :
      property==EVENT_PROP_TIME_EVENT              ?  TextByLanguage("Время события","Time of event")+": "+TimeMSCtoString(this.GetProperty(property))                                    :
      property==EVENT_PROP_STATUS_EVENT            ?  TextByLanguage("Статус события","Status of event")+": \""+this.StatusDescription()+"\""                                             :
      property==EVENT_PROP_REASON_EVENT            ?  TextByLanguage("Причина события","Reason of event")+": "+this.ReasonDescription()                                                   :
      property==EVENT_PROP_TYPE_DEAL_EVENT         ?  TextByLanguage("Тип сделки","Deal's type")+": "+DealTypeDescription((ENUM_DEAL_TYPE)this.GetProperty(property))                     :
      property==EVENT_PROP_TICKET_DEAL_EVENT       ?  TextByLanguage("Тикет сделки","Deal's ticket")+" #"+(string)this.GetProperty(property)                                              :
      property==EVENT_PROP_TYPE_ORDER_EVENT        ?  TextByLanguage("Тип ордера события","Event's order type")+": "+OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(property))    :
      property==EVENT_PROP_TYPE_ORDER_POSITION     ?  TextByLanguage("Тип ордера позиции","Position's order type")+": "+OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(property)) :
      property==EVENT_PROP_TICKET_ORDER_POSITION   ?  TextByLanguage("Тикет первого ордера позиции","Position's first order ticket")+" #"+(string)this.GetProperty(property)              :
      property==EVENT_PROP_TICKET_ORDER_EVENT      ?  TextByLanguage("Тикет ордера события","Event's order ticket")+" #"+(string)this.GetProperty(property)                               :
      property==EVENT_PROP_POSITION_ID             ?  TextByLanguage("Идентификатор позиции","Position ID")+" #"+(string)this.GetProperty(property)                                       :
      property==EVENT_PROP_POSITION_BY_ID          ?  TextByLanguage("Идентификатор встречной позиции","Opposite position's ID")+" #"+(string)this.GetProperty(property)                  :
      property==EVENT_PROP_MAGIC_ORDER             ?  TextByLanguage("Магический номер","Magic number")+": "+(string)this.GetProperty(property)                                           :
      property==EVENT_PROP_TIME_ORDER_POSITION     ?  TextByLanguage("Время открытия позиции","Position's opened time")+": "+TimeMSCtoString(this.GetProperty(property))                  :
      ""
     );
  }
//+------------------------------------------------------------------+
//| Return the description of the event's real property              |
//+------------------------------------------------------------------+
string CEvent::GetPropertyDescription(ENUM_EVENT_PROP_DOUBLE property)
  {
   int dg=(int)::SymbolInfoInteger(this.GetProperty(EVENT_PROP_SYMBOL),SYMBOL_DIGITS);
   int dgl=(int)DigitsLots(this.GetProperty(EVENT_PROP_SYMBOL));
   return
     (
      property==EVENT_PROP_PRICE_EVENT       ?  TextByLanguage("Цена события","Price at the time of event")+": "+::DoubleToString(this.GetProperty(property),dg) :
      property==EVENT_PROP_PRICE_OPEN        ?  TextByLanguage("Цена открытия","Open price")+": "+::DoubleToString(this.GetProperty(property),dg)                    :
      property==EVENT_PROP_PRICE_CLOSE       ?  TextByLanguage("Цена закрытия","Close price")+": "+::DoubleToString(this.GetProperty(property),dg)                   :
      property==EVENT_PROP_PRICE_SL          ?  TextByLanguage("Цена StopLoss","StopLoss price")+": "+::DoubleToString(this.GetProperty(property),dg)                :
      property==EVENT_PROP_PRICE_TP          ?  TextByLanguage("Цена TakeProfit","TakeProfit price")+": "+::DoubleToString(this.GetProperty(property),dg)            :
      property==EVENT_PROP_VOLUME_INITIAL    ?  TextByLanguage("Начальный объём","Initial volume")+": "+::DoubleToString(this.GetProperty(property),dgl)             :
      property==EVENT_PROP_VOLUME_EXECUTED   ?  TextByLanguage("Исполненный объём","Executed volume")+": "+::DoubleToString(this.GetProperty(property),dgl)          :
      property==EVENT_PROP_VOLUME_CURRENT    ?  TextByLanguage("Оставшийся объём","Remaining volume")+": "+::DoubleToString(this.GetProperty(property),dgl)          :
      property==EVENT_PROP_PROFIT            ?  TextByLanguage("Профит","Profit")+": "+::DoubleToString(this.GetProperty(property),this.m_digits_acc)                :
      ""
     );
  }
//+------------------------------------------------------------------+
//| Return the description of the event's string property            |
//+------------------------------------------------------------------+
string CEvent::GetPropertyDescription(ENUM_EVENT_PROP_STRING property)
  {
   return TextByLanguage("Символ","Symbol")+": \""+this.GetProperty(property)+"\"";
  }
//+------------------------------------------------------------------+
//| Return the event status name                                     |
//+------------------------------------------------------------------+
string CEvent::StatusDescription(void) const
  {
   ENUM_EVENT_STATUS status=(ENUM_EVENT_STATUS)this.GetProperty(EVENT_PROP_STATUS_EVENT);
   return
     (
      status==EVENT_STATUS_MARKET_PENDING    ?  TextByLanguage("Установлен отложенный ордер","Pending order placed") :
      status==EVENT_STATUS_MARKET_POSITION   ?  TextByLanguage("Открыта позиция","Position opened")                 :
      status==EVENT_STATUS_HISTORY_PENDING   ?  TextByLanguage("Удален отложенный ордер","Pending order removed")    :
      status==EVENT_STATUS_HISTORY_POSITION  ?  TextByLanguage("Закрыта позиция","Position closed")                  :
      status==EVENT_STATUS_BALANCE           ?  TextByLanguage("Балансная операция","Balance operation")             :
      ""
     );
  }
//+------------------------------------------------------------------+
//| Return the trading event name                                    |
//+------------------------------------------------------------------+
string CEvent::TypeEventDescription(void) const
  {
   ENUM_TRADE_EVENT event=this.TypeEvent();
   return
     (
      event==TRADE_EVENT_PENDING_ORDER_PLASED            ?  TextByLanguage("Отложенный ордер установлен","Pending order placed")                                  :
      event==TRADE_EVENT_PENDING_ORDER_REMOVED           ?  TextByLanguage("Отложенный ордер удалён","Pending order removed")                                     :
      event==TRADE_EVENT_ACCOUNT_CREDIT                  ?  TextByLanguage("Начисление кредита","Credit")                                                         :
      event==TRADE_EVENT_ACCOUNT_CHARGE                  ?  TextByLanguage("Дополнительные сборы","Additional charge")                                            :
      event==TRADE_EVENT_ACCOUNT_CORRECTION              ?  TextByLanguage("Корректирующая запись","Correction")                                                  :
      event==TRADE_EVENT_ACCOUNT_BONUS                   ?  TextByLanguage("Перечисление бонусов","Bonus")                                                        :
      event==TRADE_EVENT_ACCOUNT_COMISSION               ?  TextByLanguage("Дополнительные комиссии","Additional commission")                                     :
      event==TRADE_EVENT_ACCOUNT_COMISSION_DAILY         ?  TextByLanguage("Комиссия, начисляемая в конце торгового дня","Daily commission")                      :
      event==TRADE_EVENT_ACCOUNT_COMISSION_MONTHLY       ?  TextByLanguage("Комиссия, начисляемая в конце месяца","Monthly commission")                           :
      event==TRADE_EVENT_ACCOUNT_COMISSION_AGENT_DAILY   ?  TextByLanguage("Агентская комиссия, начисляемая в конце торгового дня","Daily agent commission")      :
      event==TRADE_EVENT_ACCOUNT_COMISSION_AGENT_MONTHLY ?  TextByLanguage("Агентская комиссия, начисляемая в конце месяца","Monthly agent commission")           :
      event==TRADE_EVENT_ACCOUNT_INTEREST                ?  TextByLanguage("Начисления процентов на свободные средства","Interest rate")                          :
      event==TRADE_EVENT_BUY_CANCELLED                   ?  TextByLanguage("Отмененная сделка покупки","Canceled buy deal")                                       :
      event==TRADE_EVENT_SELL_CANCELLED                  ?  TextByLanguage("Отмененная сделка продажи","Canceled sell deal")                                      :
      event==TRADE_EVENT_DIVIDENT                        ?  TextByLanguage("Начисление дивиденда","Dividend operations")                                          :
      event==TRADE_EVENT_DIVIDENT_FRANKED                ?  TextByLanguage("Начисление франкированного дивиденда","Franked (non-taxable) dividend operations")    :
      event==TRADE_EVENT_TAX                             ?  TextByLanguage("Начисление налога","Tax charges")                                                     :
      event==TRADE_EVENT_ACCOUNT_BALANCE_REFILL          ?  TextByLanguage("Пополнение средств на балансе","Balance refill")                                      :
      event==TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL      ?  TextByLanguage("Снятие средств с баланса","Withdrawals")                                              :
      event==TRADE_EVENT_PENDING_ORDER_ACTIVATED         ?  TextByLanguage("Отложенный ордер активирован ценой","Pending order activated")                        :
      event==TRADE_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL ?  TextByLanguage("Отложенный ордер активирован ценой частично","Pending order activated partially")     :
      event==TRADE_EVENT_POSITION_OPENED                 ?  TextByLanguage("Позиция открыта","Position opened")                                                  :
      event==TRADE_EVENT_POSITION_OPENED_PARTIAL         ?  TextByLanguage("Позиция открыта частично","Position opened partially")                               :
      event==TRADE_EVENT_POSITION_CLOSED                 ?  TextByLanguage("Позиция закрыта","Position closed")                                                   :
      event==TRADE_EVENT_POSITION_CLOSED_PARTIAL         ?  TextByLanguage("Позиция закрыта частично","Position closed partially")                                :
      event==TRADE_EVENT_POSITION_CLOSED_BY_POS          ?  TextByLanguage("Позиция закрыта встречной","Position closed by opposite position")                    :
      event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS  ?  TextByLanguage("Позиция закрыта встречной частично","Position closed partially by opposite position") :
      event==TRADE_EVENT_POSITION_CLOSED_BY_SL           ?  TextByLanguage("Позиция закрыта по StopLoss","Position closed by StopLoss")                           :
      event==TRADE_EVENT_POSITION_CLOSED_BY_TP           ?  TextByLanguage("Позиция закрыта по TakeProfit","Position closed by TakeProfit")                       :
      event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL   ?  TextByLanguage("Позиция закрыта частично по StopLoss","Position closed partially by StopLoss")        :
      event==TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP   ?  TextByLanguage("Позиция закрыта частично по TakeProfit","Position closed partially by TakeProfit")    :
      event==TRADE_EVENT_POSITION_REVERSED               ?  TextByLanguage("Разворот позиции","Position reversal")                                                :
      event==TRADE_EVENT_POSITION_VOLUME_ADD             ?  TextByLanguage("Добавлен объём к позиции","Added volume to position")                                 :
      TextByLanguage("Нет торгового события","No trade event")
     );   
  }
//+------------------------------------------------------------------+
//| Return the name of the order/position/deal                       |
//+------------------------------------------------------------------+
string CEvent::TypeOrderDescription(void) const
  {
   ENUM_EVENT_STATUS status=this.Status();
   return
     (
      status==EVENT_STATUS_MARKET_PENDING  || status==EVENT_STATUS_HISTORY_PENDING  ?  OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORDER_EVENT))      :
      status==EVENT_STATUS_MARKET_POSITION || status==EVENT_STATUS_HISTORY_POSITION ?  PositionTypeDescription((ENUM_POSITION_TYPE)this.GetProperty(EVENT_PROP_TYPE_DEAL_EVENT)) :
      status==EVENT_STATUS_BALANCE  ?  DealTypeDescription((ENUM_DEAL_TYPE)this.GetProperty(EVENT_PROP_TYPE_DEAL_EVENT))  :  "Unknown"
     );
  }
//+------------------------------------------------------------------+
//| Return the name of the parent order                              |
//+------------------------------------------------------------------+
string CEvent::TypeOrderBasedDescription(void) const
  {
   return OrderTypeDescription((ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORDER_POSITION));
  }
//+------------------------------------------------------------------+
//| Return the position name                                         |
//+------------------------------------------------------------------+
string CEvent::TypePositionDescription(void) const
  {
   ENUM_POSITION_TYPE type=PositionTypeByOrderType((ENUM_ORDER_TYPE)this.GetProperty(EVENT_PROP_TYPE_ORDER_POSITION));
   return PositionTypeDescription(type);
  }
//+------------------------------------------------------------------+
//| Return the name of the deal/order/position reason                |
//+------------------------------------------------------------------+
string CEvent::ReasonDescription(void) const
  {
   ENUM_EVENT_REASON reason=this.Reason();
   return 
     (
      reason==EVENT_REASON_ACTIVATED_PENDING                ?  TextByLanguage("Активирован отложенный ордер","Pending order activated")                           :
      reason==EVENT_REASON_ACTIVATED_PENDING_PARTIALLY      ?  TextByLanguage("Частичное срабатывание отложенного ордера","Pending order partially triggered")    :
      reason==EVENT_REASON_CANCEL                           ?  TextByLanguage("Отмена","Canceled")                                                                :
      reason==EVENT_REASON_EXPIRED                          ?  TextByLanguage("Истёк срок действия","Expired")                                                    :
      reason==EVENT_REASON_DONE                             ?  TextByLanguage("Запрос выполнен полностью","Request fully executed")                            :
      reason==EVENT_REASON_DONE_PARTIALLY                   ?  TextByLanguage("Запрос выполнен частично","Request partially executed")                         :
      reason==EVENT_REASON_DONE_SL                          ?  TextByLanguage("закрытие по StopLoss","Close by StopLoss triggered")                               :
      reason==EVENT_REASON_DONE_SL_PARTIALLY                ?  TextByLanguage("Частичное закрытие по StopLoss","Partial close by StopLoss triggered")             :
      reason==EVENT_REASON_DONE_TP                          ?  TextByLanguage("закрытие по TakeProfit","Close by TakeProfit triggered")                           :
      reason==EVENT_REASON_DONE_TP_PARTIALLY                ?  TextByLanguage("Частичное закрытие по TakeProfit","Partial close by TakeProfit triggered")         :
      reason==EVENT_REASON_DONE_BY_POS                      ?  TextByLanguage("Закрытие встречной позицией","Closed by opposite position")                        :
      reason==EVENT_REASON_DONE_PARTIALLY_BY_POS            ?  TextByLanguage("Частичное закрытие встречной позицией","Closed partially by opposite position")    :
      reason==EVENT_REASON_DONE_BY_POS_PARTIALLY            ?  TextByLanguage("Закрытие частью объёма встречной позиции","Closed by incomplete volume of opposite position") :
      reason==EVENT_REASON_DONE_PARTIALLY_BY_POS_PARTIALLY  ?  TextByLanguage("Частичное закрытие частью объёма встречной позиции","Closed partially by incomplete volume of opposite position")  :
      reason==EVENT_REASON_BALANCE_REFILL                   ?  TextByLanguage("Пополнение баланса","Balance refill")                                              :
      reason==EVENT_REASON_BALANCE_WITHDRAWAL               ?  TextByLanguage("Снятие средств с баланса","Withdrawals from the balance")                          :
      reason==EVENT_REASON_ACCOUNT_CREDIT                   ?  TextByLanguage("Начисление кредита","Credit")                                                      :
      reason==EVENT_REASON_ACCOUNT_CHARGE                   ?  TextByLanguage("Дополнительные сборы","Additional charge")                                         :
      reason==EVENT_REASON_ACCOUNT_CORRECTION               ?  TextByLanguage("Корректирующая запись","Correction")                                               :
      reason==EVENT_REASON_ACCOUNT_BONUS                    ?  TextByLanguage("Перечисление бонусов","Bonus")                                                     :
      reason==EVENT_REASON_ACCOUNT_COMISSION                ?  TextByLanguage("Дополнительные комиссии","Additional commission")                                  :
      reason==EVENT_REASON_ACCOUNT_COMISSION_DAILY          ?  TextByLanguage("Комиссия, начисляемая в конце торгового дня","Daily commission")                   :
      reason==EVENT_REASON_ACCOUNT_COMISSION_MONTHLY        ?  TextByLanguage("Комиссия, начисляемая в конце месяца","Monthly commission")                        :
      reason==EVENT_REASON_ACCOUNT_COMISSION_AGENT_DAILY    ?  TextByLanguage("Агентская комиссия, начисляемая в конце торгового дня","Daily agent commission")   :
      reason==EVENT_REASON_ACCOUNT_COMISSION_AGENT_MONTHLY  ?  TextByLanguage("Агентская комиссия, начисляемая в конце месяца","Monthly agent commission")        :
      reason==EVENT_REASON_ACCOUNT_INTEREST                 ?  TextByLanguage("Начисления процентов на свободные средства","Interest rate")                       :
      reason==EVENT_REASON_BUY_CANCELLED                    ?  TextByLanguage("Отмененная сделка покупки","Canceled buy deal")                                    :
      reason==EVENT_REASON_SELL_CANCELLED                   ?  TextByLanguage("Отмененная сделка продажи","Canceled sell deal")                                   :
      reason==EVENT_REASON_DIVIDENT                         ?  TextByLanguage("Начисление дивиденда","Dividend operations")                                       :
      reason==EVENT_REASON_DIVIDENT_FRANKED                 ?  TextByLanguage("Начисление франкированного дивиденда","Franked (non-taxable) dividend operations") :
      reason==EVENT_REASON_TAX                              ?  TextByLanguage("Начисление налога","Tax charges")                                                  :
      EnumToString(reason)
     );
  }
//+------------------------------------------------------------------+
//| Display the event properties in the journal                      |
//+------------------------------------------------------------------+
void CEvent::Print(const bool full_prop=false)
  {
   ::Print("============= ",TextByLanguage("Начало списка параметров события: \"","Beginning of event parameter list: \""),this.StatusDescription(),"\" =============");
   int beg=0, end=EVENT_PROP_INTEGER_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_EVENT_PROP_INTEGER prop=(ENUM_EVENT_PROP_INTEGER)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   beg=end; end+=EVENT_PROP_DOUBLE_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_EVENT_PROP_DOUBLE prop=(ENUM_EVENT_PROP_DOUBLE)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("------");
   beg=end; end+=EVENT_PROP_STRING_TOTAL;
   for(int i=beg; i<end; i++)
     {
      ENUM_EVENT_PROP_STRING prop=(ENUM_EVENT_PROP_STRING)i;
      if(!full_prop && !this.SupportProperty(prop)) continue;
      ::Print(this.GetPropertyDescription(prop));
     }
   ::Print("================== ",TextByLanguage("Конец списка параметров: \"","End of parameter list: \""),this.StatusDescription(),"\" ==================\n");
  }
//+------------------------------------------------------------------+
