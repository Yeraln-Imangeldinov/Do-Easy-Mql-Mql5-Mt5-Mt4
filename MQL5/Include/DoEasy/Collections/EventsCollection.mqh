//+------------------------------------------------------------------+
//|                                             EventsCollection.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "ListObj.mqh"
#include "..\Services\Select.mqh"
#include "..\Objects\Orders\Order.mqh"
#include "..\Objects\Events\EventBalanceOperation.mqh"
#include "..\Objects\Events\EventOrderPlaced.mqh"
#include "..\Objects\Events\EventOrderRemoved.mqh"
#include "..\Objects\Events\EventPositionOpen.mqh"
#include "..\Objects\Events\EventPositionClose.mqh"
//+------------------------------------------------------------------+
//| Collection of account events                                     |
//+------------------------------------------------------------------+
class CEventsCollection : public CListObj
  {
private:
   CListObj          m_list_events;                   // List of events
   bool              m_is_hedge;                      // Hedge account flag
   long              m_chart_id;                      // Control program chart ID
   int               m_trade_event_code;              // Trading event code
   ENUM_TRADE_EVENT  m_trade_event;                   // Account trading event
   CEvent            m_event_instance;                // Event object for searching by property
   
//--- Create a trading event depending on the (1) order status and (2) change type
   void              CreateNewEvent(COrder* order,CArrayObj* list_history,CArrayObj* list_market);
   void              CreateNewEvent(COrderControl* order);
//--- Create an event for a (1) hedging account, (2) netting account
   void              NewDealEventHedge(COrder* deal,CArrayObj* list_history,CArrayObj* list_market);
   void              NewDealEventNetto(COrder* deal,CArrayObj* list_history,CArrayObj* list_market);
//--- Select and return the list of market pending orders
   CArrayObj*        GetListMarketPendings(CArrayObj* list);
//--- Select and return the list of historical (1) removed pending orders, (2) deals, (3) all closing orders 
   CArrayObj*        GetListHistoryPendings(CArrayObj* list);
   CArrayObj*        GetListDeals(CArrayObj* list);
   CArrayObj*        GetListCloseByOrders(CArrayObj* list);
//--- Return the list of (1) all position orders by its ID, (2) all deal positions by its ID
//--- (3) all market entry deals by position ID, (4) all market exit deals by position ID,
//--- (5) all position reversal deals by position ID
   CArrayObj*        GetListAllOrdersByPosID(CArrayObj* list,const ulong position_id);
   CArrayObj*        GetListAllDealsByPosID(CArrayObj* list,const ulong position_id);
   CArrayObj*        GetListAllDealsInByPosID(CArrayObj* list,const ulong position_id);
   CArrayObj*        GetListAllDealsOutByPosID(CArrayObj* list,const ulong position_id);
   CArrayObj*        GetListAllDealsInOutByPosID(CArrayObj* list,const ulong position_id);
//--- Return the total volume of all deals (1) IN, (2) OUT of the position by its ID
   double            SummaryVolumeDealsInByPosID(CArrayObj* list,const ulong position_id);
   double            SummaryVolumeDealsOutByPosID(CArrayObj* list,const ulong position_id);
//--- Return the (1) first, (2) last and (3) closing order from the list of all position orders,
//--- (4) an order by ticket, (5) market position by ID,
//--- (6) the last and (7) penultimate InOut deal by position ID
   COrder*           GetFirstOrderFromList(CArrayObj* list,const ulong position_id);
   COrder*           GetLastOrderFromList(CArrayObj* list,const ulong position_id);
   COrder*           GetCloseByOrderFromList(CArrayObj* list,const ulong position_id);
   COrder*           GetHistoryOrderByTicket(CArrayObj* list,const ulong order_ticket);
   COrder*           GetPositionByID(CArrayObj* list,const ulong position_id);
//--- Return the flag of the event object presence in the event list
   bool              IsPresentEventInList(CEvent* compared_event);
//--- The handler of an existing order/position change event
   void              OnChangeEvent(CArrayObj* list_changes,const int index);
public:
//--- Select events from the collection with time within the range from begin_time to end_time
   CArrayObj        *GetListByTime(const datetime begin_time=0,const datetime end_time=0);
//--- Return the full event collection list "as is"
   CArrayObj        *GetList(void)                                                                       { return &this.m_list_events;                                           }
//--- Return the list by selected (1) integer, (2) real and (3) string properties meeting the compared criterion
   CArrayObj        *GetList(ENUM_EVENT_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode=EQUAL)  { return CSelect::ByEventProperty(this.GetList(),property,value,mode);  }
   CArrayObj        *GetList(ENUM_EVENT_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode=EQUAL) { return CSelect::ByEventProperty(this.GetList(),property,value,mode);  }
   CArrayObj        *GetList(ENUM_EVENT_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode=EQUAL) { return CSelect::ByEventProperty(this.GetList(),property,value,mode);  }
//--- Update the list of events
   void              Refresh(CArrayObj* list_history,
                             CArrayObj* list_market,
                             CArrayObj* list_changes,
                             const bool is_history_event,
                             const bool is_market_event,
                             const int  new_history_orders,
                             const int  new_market_pendings,
                             const int  new_market_positions,
                             const int  new_deals);
//--- Set the control program chart ID
   void              SetChartID(const long id)        { this.m_chart_id=id;         }
//--- Return the last trading event on the account
   ENUM_TRADE_EVENT  GetLastTradeEvent(void)    const { return this.m_trade_event;  }
//--- Reset the last trading event
   void              ResetLastTradeEvent(void)        { this.m_trade_event=TRADE_EVENT_NO_EVENT;   }
//--- Constructor
                     CEventsCollection(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CEventsCollection::CEventsCollection(void) : m_trade_event(TRADE_EVENT_NO_EVENT),m_trade_event_code(TRADE_EVENT_FLAG_NO_EVENT)
  {
   this.m_list_events.Clear();
   this.m_list_events.Sort(SORT_BY_EVENT_TIME_EVENT);
   this.m_list_events.Type(COLLECTION_EVENTS_ID);
   this.m_is_hedge=bool(::AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
   this.m_chart_id=::ChartID();
  }
//+------------------------------------------------------------------+
//| Update the event list                                            |
//+------------------------------------------------------------------+
void CEventsCollection::Refresh(CArrayObj* list_history,
                                CArrayObj* list_market,
                                CArrayObj* list_changes,
                                const bool is_history_event,
                                const bool is_market_event,
                                const int  new_history_orders,
                                const int  new_market_pendings,
                                const int  new_market_positions,
                                const int  new_deals)
  {
//--- Exit if the lists are empty
   if(list_history==NULL || list_market==NULL)
      return;
//--- If the event is in the market environment
   if(is_market_event)
     {
      //--- if there was a change in the order properties
      int total_changes=list_changes.Total();
      if(total_changes>0)
        {
         for(int i=total_changes-1;i>=0;i--)
           {
            this.OnChangeEvent(list_changes,i);
           }
        }
      //--- if the number of placed pending orders increased
      if(new_market_pendings>0)
        {
         //--- Receive the list of the newly placed pending orders
         CArrayObj* list=this.GetListMarketPendings(list_market);
         if(list!=NULL)
           {
            //--- Sort the new list by order placement time
            list.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
            //--- Take the number of orders equal to the number of newly placed ones from the end of the list in a loop (the last N events)
            int total=list.Total(), n=new_market_pendings;
            for(int i=total-1; i>=0 && n>0; i--,n--)
              {
               //--- Receive an order from the list, if this is a pending order, set a trading event
               COrder* order=list.At(i);
               if(order!=NULL && order.Status()==ORDER_STATUS_MARKET_PENDING)
                  this.CreateNewEvent(order,list_history,list_market);
              }
           }
        }
     }
//--- If the event is in the account history
   if(is_history_event)
     {
      //--- If the number of historical orders increased
      if(new_history_orders>0)
        {
         //--- Receive the list of removed pending orders only
         CArrayObj* list=this.GetListHistoryPendings(list_history);
         if(list!=NULL)
           {
            //--- Sort the new list by order removal time
            list.Sort(SORT_BY_ORDER_TIME_CLOSE_MSC);
            //--- Take the number of orders equal to the number of newly removed ones from the end of the list in a loop (the last N events)
            int total=list.Total(), n=new_history_orders;
            for(int i=total-1; i>=0 && n>0; i--,n--)
              {
               //--- Receive an order from the list. If this is a removed pending order without a position ID, 
               //--- this is an order removal - set a trading event
               COrder* order=list.At(i);
               if(order!=NULL && order.Status()==ORDER_STATUS_HISTORY_PENDING && order.PositionID()==0)
                  this.CreateNewEvent(order,list_history,list_market);
              }
           }
        }
      //--- If the number of deals increased
      if(new_deals>0)
        {
         //--- Receive the list of deals only
         CArrayObj* list=this.GetListDeals(list_history);
         if(list!=NULL)
           {
            //--- Sort the new list by deal time
            list.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
            //--- Take the number of deals equal to the number of new ones from the end of the list in a loop (the last N events)
            int total=list.Total(), n=new_deals;
            for(int i=total-1; i>=0 && n>0; i--,n--)
              {
               //--- Receive a deal from the list and set a trading event
               COrder* order=list.At(i);
               if(order!=NULL)
                  this.CreateNewEvent(order,list_history,list_market);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| The handler of an existing order/position change event           |
//+------------------------------------------------------------------+
void CEventsCollection::OnChangeEvent(CArrayObj* list_changes,const int index)
  {
   COrderControl* order_changed=list_changes.Detach(index);
   if(order_changed!=NULL)
     {
      if(order_changed.GetChangeType()==CHANGE_TYPE_ORDER_TYPE)
        {
         this.CreateNewEvent(order_changed);
        }
      delete order_changed;
     }
  }
//+------------------------------------------------------------------+
//| Create a trading event depending on the order change type        |
//+------------------------------------------------------------------+
void CEventsCollection::CreateNewEvent(COrderControl* order)
  {
   CEvent* event=NULL;
//--- Pending StopLimit order placed
   if(order.GetChangeType()==CHANGE_TYPE_ORDER_TYPE)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_PLASED;
      event=new CEventOrderPlased(this.m_trade_event_code,order.Ticket());
     }
//--- 
   if(event!=NULL)
     {
      event.SetProperty(EVENT_PROP_TIME_EVENT,order.Time());                        // Event time
      event.SetProperty(EVENT_PROP_REASON_EVENT,EVENT_REASON_STOPLIMIT_TRIGGERED);  // Event reason (from the ENUM_EVENT_REASON enumeration)
      event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,order.TypeOrderPrev());          // Type of the order that triggered an event
      event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());               // Ticket of the order that triggered an event
      event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order.TypeOrder());             // Event order type
      event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());              // Event order ticket
      event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order.TypeOrder());          // Position first order type
      event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());           // Position first order ticket
      event.SetProperty(EVENT_PROP_POSITION_ID,order.PositionID());                 // Position ID
      event.SetProperty(EVENT_PROP_POSITION_BY_ID,0);                               // Opposite position ID
      event.SetProperty(EVENT_PROP_MAGIC_BY_ID,0);                                  // Opposite position magic number
         
      event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrderPrev());      // Position order type before changing direction
      event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());           // Position order ticket before changing direction
      event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());         // Current position order type
      event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());          // Current position order ticket
         
      event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                      // Order magic number
      event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimePrev());           // Position first order time
      event.SetProperty(EVENT_PROP_PRICE_EVENT,order.PricePrev());                  // Event price
      event.SetProperty(EVENT_PROP_PRICE_OPEN,order.Price());                       // Order placement price
      event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.Price());                      // Order closure price
      event.SetProperty(EVENT_PROP_PRICE_SL,order.StopLoss());                      // StopLoss order price
      event.SetProperty(EVENT_PROP_PRICE_TP,order.TakeProfit());                    // TakeProfit order price
      event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());            // Requested order volume
      event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,0);                        // Executed order volume
      event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order.Volume());            // Remaining (unexecuted) order volume
      event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,0);                     // Executed position volume
      event.SetProperty(EVENT_PROP_PROFIT,0);                                       // Profit
      event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                          // Order symbol
      event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                    // Opposite position symbol
      //--- Set the control program chart ID, decode the event code and set the event type
      event.SetChartID(this.m_chart_id);
      event.SetTypeEvent();
      //--- Add the event object if it is not in the list
      if(!this.IsPresentEventInList(event))
        {
         this.m_list_events.InsertSort(event);
         //--- Send a message about the event and set the value of the last trading event
         event.SendEvent();
         this.m_trade_event=event.TradeEvent();
        }
      //--- If the event is already present in the list, remove a new event object and display a debugging message
      else
        {
         ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event already in the list."));
         delete event;
        }
     }
  }
//+------------------------------------------------------------------+
//| Create a trading event depending on the order status             |
//+------------------------------------------------------------------+
void CEventsCollection::CreateNewEvent(COrder* order,CArrayObj* list_history,CArrayObj* list_market)
  {
   this.m_trade_event_code=TRADE_EVENT_FLAG_NO_EVENT;
   ENUM_ORDER_STATUS status=order.Status();
//--- Pending order placed
   if(status==ORDER_STATUS_MARKET_PENDING)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_PLASED;
      CEvent* event=new CEventOrderPlased(this.m_trade_event_code,order.Ticket());
      if(event!=NULL)
        {
         event.SetProperty(EVENT_PROP_TIME_EVENT,order.TimeOpenMSC());                             // Event time
         event.SetProperty(EVENT_PROP_REASON_EVENT,EVENT_REASON_DONE);                             // Event reason (from the ENUM_EVENT_REASON enumeration)
         event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,order.TypeOrder());                          // Event deal type
         event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());                           // Event order ticket
         event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order.TypeOrder());                         // Event order type
         event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order.TypeOrder());                      // Event order type
         event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());                          // Event order ticket
         event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());                       // Order ticket
         event.SetProperty(EVENT_PROP_POSITION_ID,order.PositionID());                             // Position ID
         event.SetProperty(EVENT_PROP_POSITION_BY_ID,order.PositionByID());                        // Opposite position ID
         event.SetProperty(EVENT_PROP_MAGIC_BY_ID,order.Magic());                                  // Opposite position magic number
            
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrder());                      // Position order type before changing direction
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());                       // Position order ticket before changing direction
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());                     // Current position order type
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());                      // Current position order ticket
            
         event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                                  // Order magic number
         event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimeOpenMSC());                    // Order time
         event.SetProperty(EVENT_PROP_PRICE_EVENT,order.PriceOpen());                              // Event price
         event.SetProperty(EVENT_PROP_PRICE_OPEN,order.PriceOpen());                               // Order placement price
         event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.PriceClose());                             // Order closure price
         event.SetProperty(EVENT_PROP_PRICE_SL,order.StopLoss());                                  // StopLoss order price
         event.SetProperty(EVENT_PROP_PRICE_TP,order.TakeProfit());                                // TakeProfit order price
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());                        // Requested order volume
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order.Volume()-order.VolumeCurrent()); // Executed order volume
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order.VolumeCurrent());                 // Remaining (unexecuted) order volume
         event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,0);                                 // Executed position volume
         event.SetProperty(EVENT_PROP_PROFIT,order.Profit());                                      // Profit
         event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                                      // Order symbol
         event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                                // Opposite position symbol
         //--- Set the control program chart ID, decode the event code and set the event type
         event.SetChartID(this.m_chart_id);
         event.SetTypeEvent();
         //--- Add the event object if it is not in the list
         if(!this.IsPresentEventInList(event))
           {
            this.m_list_events.InsertSort(event);
            //--- Send a message about the event and set the value of the last trading event
            event.SendEvent();
            this.m_trade_event=event.TradeEvent();
           }
         //--- If the event is already present in the list, remove a new event object and display a debugging message
         else
           {
            ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event already in the list."));
            delete event;
           }
        }
     }
//--- Pending order removed
   if(status==ORDER_STATUS_HISTORY_PENDING)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_ORDER_REMOVED;
      CEvent* event=new CEventOrderRemoved(this.m_trade_event_code,order.Ticket());
      if(event!=NULL)
        {
         ENUM_EVENT_REASON reason=
           (
            order.State()==ORDER_STATE_CANCELED ? EVENT_REASON_CANCEL :
            order.State()==ORDER_STATE_EXPIRED  ? EVENT_REASON_EXPIRED : EVENT_REASON_DONE
           );
         event.SetProperty(EVENT_PROP_TIME_EVENT,order.TimeCloseMSC());                            // Event time
         event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                                        // Event reason (from the ENUM_EVENT_REASON enumeration)
         event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,order.TypeOrder());                          // Event order type
         event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());                           // Event order ticket
         event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order.TypeOrder());                         // Type of the order that triggered an event deal (the last position order)
         event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order.TypeOrder());                      // Type of the order that triggered a position deal (the first position order)
         event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());                          // Ticket of the order, based on which an event deal is opened (the last position order)
         event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());                       // Ticket of the order, based on which a position deal is opened (the first position order)
         event.SetProperty(EVENT_PROP_POSITION_ID,order.PositionID());                             // Position ID
         event.SetProperty(EVENT_PROP_POSITION_BY_ID,order.PositionByID());                        // Opposite position ID
         event.SetProperty(EVENT_PROP_MAGIC_BY_ID,order.Magic());                                  // Opposite position magic number
            
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrder());                      // Position order type before changing direction
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());                       // Position order ticket before changing direction
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());                     // Current position order type
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());                      // Current position order ticket
            
         event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                                  // Order magic number
         event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimeOpenMSC());                    // Time of the order, based on which a position deal is opened (the first position order)
         event.SetProperty(EVENT_PROP_PRICE_EVENT,order.PriceOpen());                              // Event price
         event.SetProperty(EVENT_PROP_PRICE_OPEN,order.PriceOpen());                               // Order placement price
         event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.PriceClose());                             // Order closure price
         event.SetProperty(EVENT_PROP_PRICE_SL,order.StopLoss());                                  // StopLoss order price
         event.SetProperty(EVENT_PROP_PRICE_TP,order.TakeProfit());                                // TakeProfit order price
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());                        // Requested order volume
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order.Volume()-order.VolumeCurrent()); // Executed order volume
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order.VolumeCurrent());                 // Remaining (unexecuted) order volume
         event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,0);                                 // Executed position volume
         event.SetProperty(EVENT_PROP_PROFIT,order.Profit());                                      // Profit
         event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                                      // Order symbol
         event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                                // Opposite position symbol
         //--- Set the control program chart ID, decode the event code and set the event type
         event.SetChartID(this.m_chart_id);
         event.SetTypeEvent();
         //--- Add the event object if it is not in the list
         if(!this.IsPresentEventInList(event))
           {
            this.m_list_events.InsertSort(event);
            //--- Send a message about the event and set the value of the last trading event
            event.SendEvent();
            this.m_trade_event=event.TradeEvent();
           }
         //--- If the event is already present in the list, remove a new event object and display a debugging message
         else
           {
            ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event already in the list."));
            delete event;
           }
        }
     }
//--- Position opened (__MQL4__)
   if(status==ORDER_STATUS_MARKET_POSITION)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_OPENED;
      CEvent* event=new CEventPositionOpen(this.m_trade_event_code,order.Ticket());
      if(event!=NULL)
        {
         event.SetProperty(EVENT_PROP_TIME_EVENT,order.TimeOpen());                                // Event time
         event.SetProperty(EVENT_PROP_REASON_EVENT,EVENT_REASON_DONE);                             // Event reason (from the ENUM_EVENT_REASON enumeration)
         event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,order.TypeOrder());                          // Event deal type
         event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());                           // Event deal ticket
         event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order.TypeOrder());                         // Type of the order that triggered an event deal (the last position order)
         event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order.TypeOrder());                      // Type of the order that triggered a position deal (the first position order)
         event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());                          // Ticket of the order, based on which an event deal is opened (the last position order)
         event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());                       // Ticket of the order, based on which a position deal is opened (the first position order)
         event.SetProperty(EVENT_PROP_POSITION_ID,order.PositionID());                             // Position ID
         event.SetProperty(EVENT_PROP_POSITION_BY_ID,order.PositionByID());                        // Opposite position ID
         event.SetProperty(EVENT_PROP_MAGIC_BY_ID,order.Magic());                                  // Opposite position magic number
            
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrder());                      // Position order type before changing direction
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());                       // Position order ticket before changing direction
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());                     // Current position order type
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());                      // Current position order ticket
            
         event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                                  // Order/deal/position magic number
         event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimeOpen());                       // Time of an order, based on which a position deal is opened (the first position order)
         event.SetProperty(EVENT_PROP_PRICE_EVENT,order.PriceOpen());                              // Event price
         event.SetProperty(EVENT_PROP_PRICE_OPEN,order.PriceOpen());                               // Order/deal/position open price
         event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.PriceClose());                             // Order/deal/position close price
         event.SetProperty(EVENT_PROP_PRICE_SL,order.StopLoss());                                  // StopLoss position price
         event.SetProperty(EVENT_PROP_PRICE_TP,order.TakeProfit());                                // TakeProfit position price
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());                        // Requested order volume
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order.Volume()-order.VolumeCurrent()); // Executed order volume
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order.VolumeCurrent());                 // Remaining (unexecuted) order volume
         event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,order.Volume());                    // Executed position volume
         event.SetProperty(EVENT_PROP_PROFIT,order.Profit());                                      // Profit
         event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                                      // Order symbol
         event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                                // Opposite position symbol
         //--- Set the control program chart ID, decode the event code and set the event type
         event.SetChartID(this.m_chart_id);
         event.SetTypeEvent();
         //--- Add the event object if it is not in the list
         if(!this.IsPresentEventInList(event))
           {
            this.m_list_events.InsertSort(event);
            //--- Send a message about the event and set the value of the last trading event
            event.SendEvent();
            this.m_trade_event=event.TradeEvent();
           }
         //--- If the event is already present in the list, remove a new event object and display a debugging message
         else
           {
            ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event already in the list."));
            delete event;
           }
        }
     }
//--- New deal (__MQL5__)
   if(status==ORDER_STATUS_DEAL)
     {
      //--- New balance operation
      if((ENUM_DEAL_TYPE)order.TypeOrder()>DEAL_TYPE_SELL)
        {
         this.m_trade_event_code=TRADE_EVENT_FLAG_ACCOUNT_BALANCE;
         CEvent* event=new CEventBalanceOperation(this.m_trade_event_code,order.Ticket());
         if(event!=NULL)
           {
            ENUM_EVENT_REASON reason=
              (
               (ENUM_DEAL_TYPE)order.TypeOrder()==DEAL_TYPE_BALANCE ? (order.Profit()>0 ? EVENT_REASON_BALANCE_REFILL : EVENT_REASON_BALANCE_WITHDRAWAL) :
               (ENUM_EVENT_REASON)(order.TypeOrder()+REASON_EVENT_SHIFT)
              );
            event.SetProperty(EVENT_PROP_TIME_EVENT,order.TimeOpenMSC());                 // Event time
            event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                            // Event reason (from the ENUM_EVENT_REASON enumeration)
            event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,order.TypeOrder());              // Event deal type
            event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,order.Ticket());               // Event deal ticket
            event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order.TypeOrder());             // Type of the order that triggered an event deal (the last position order)
            event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order.TypeOrder());          // Type of an order that triggered a position deal (the first position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order.Ticket());              // Ticket of an order, based on which an event deal is opened (the last position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order.Ticket());           // Ticket of the order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_POSITION_ID,order.PositionID());                 // Position ID
            event.SetProperty(EVENT_PROP_POSITION_BY_ID,order.PositionByID());            // Opposite position ID
            event.SetProperty(EVENT_PROP_MAGIC_BY_ID,order.Magic());                      // Opposite position magic number
            
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order.TypeOrder());          // Position order type before changing direction
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order.Ticket());           // Position order ticket before changing direction
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order.TypeOrder());         // Current position order type
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order.Ticket());          // Current position order ticket
            
            event.SetProperty(EVENT_PROP_MAGIC_ORDER,order.Magic());                      // Order/deal/position magic number
            event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order.TimeOpenMSC());        // Time of the order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_PRICE_EVENT,order.PriceOpen());                  // Event price
            event.SetProperty(EVENT_PROP_PRICE_OPEN,order.PriceOpen());                   // Order/deal/position open price
            event.SetProperty(EVENT_PROP_PRICE_CLOSE,order.PriceOpen());                  // Order/deal/position close price
            event.SetProperty(EVENT_PROP_PRICE_SL,0);                                     // StopLoss deal price
            event.SetProperty(EVENT_PROP_PRICE_TP,0);                                     // TakeProfit deal price
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order.Volume());            // Requested deal volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order.Volume());           // Executed deal volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,0);                         // Remaining (unexecuted) deal volume
            event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,order.Volume());        // Executed position volume
            event.SetProperty(EVENT_PROP_PROFIT,order.Profit());                          // Profit
            event.SetProperty(EVENT_PROP_SYMBOL,order.Symbol());                          // Order symbol
            event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order.Symbol());                    // Opposite position symbol
            //--- Set the control program chart ID, decode the event code and set the event type
            event.SetChartID(this.m_chart_id);
            event.SetTypeEvent();
            //--- Add the event object if it is not in the list
            if(!this.IsPresentEventInList(event))
              {
               //--- Send a message about the event and set the value of the last trading event
               this.m_list_events.InsertSort(event);
               event.SendEvent();
               this.m_trade_event=event.TradeEvent();
              }
            //--- If the event is already present in the list, remove a new event object and display a debugging message
            else
              {
               ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event already in the list."));
               delete event;
              }
           }
        }
      //--- If this is not a balance operation
      else
        {
         if(this.m_is_hedge)
            this.NewDealEventHedge(order,list_history,list_market);
         else
            this.NewDealEventNetto(order,list_history,list_market);
        }
     }
  }
//+------------------------------------------------------------------+
//| Create a hedging account event                                   |
//+------------------------------------------------------------------+
void CEventsCollection::NewDealEventHedge(COrder* deal,CArrayObj* list_history,CArrayObj* list_market)
  {
   //--- Market entry
   if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_IN)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_OPENED;
      int reason=EVENT_REASON_DONE;
      //--- Look for all position deals in the direction of its opening and count its total volume
      double volume_in=this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID());
      //--- Take the deal order and the last position order from the list of all position orders
      ulong order_ticket=deal.GetProperty(ORDER_PROP_DEAL_ORDER_TICKET);
      COrder* order_first=this.GetHistoryOrderByTicket(list_history,order_ticket);
      COrder* order_last=this.GetLastOrderFromList(list_history,deal.PositionID());
      //--- Get an open position by ticket
      COrder* position=this.GetPositionByID(list_market,deal.PositionID());
      double vol_position=(position!=NULL ? position.Volume() : 0);
      //--- If there is no last order, the first and last position orders coincide
      if(order_last==NULL)
         order_last=order_first;
      if(order_first!=NULL)
        {
         //--- If the order volume is opened partially, this is a partial execution
         if(this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID())<order_first.Volume())
           {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
            reason=EVENT_REASON_DONE_PARTIALLY;
           }
         //--- If an opening order is a pending one, the pending order is activated
         if(order_first.TypeOrder()>ORDER_TYPE_SELL && order_first.TypeOrder()<ORDER_TYPE_CLOSE_BY)
           {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_ORDER_ACTIVATED;
            //--- If an order is executed partially, set the partial order execution as an event reason
            reason=
              (this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID())<order_first.Volume() ? 
               EVENT_REASON_ACTIVATED_PENDING_PARTIALLY : 
               EVENT_REASON_ACTIVATED_PENDING
              );
           }
         CEvent* event=new CEventPositionOpen(this.m_trade_event_code,deal.PositionID());
         if(event!=NULL)
           {
            event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpenMSC());                        // Event time (position open time)
            event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                                  // Event reason (from the ENUM_EVENT_REASON enumeration)
            event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                     // Event deal type
            event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                      // Event deal ticket
            event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order_first.TypeOrder());          // Type of the order that triggered a position deal (the first position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order_first.Ticket());           // Ticket of the order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order_last.TypeOrder());              // Type of the order that triggered an event deal (the last position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order_last.Ticket());               // Ticket of the order, based on which an event deal is opened (the last position order)
            event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                        // Position ID
            event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last.PositionByID());             // Opposite position ID
            //---
            event.SetProperty(EVENT_PROP_MAGIC_BY_ID,deal.Magic());                             // Opposite position magic number
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order_first.TypeOrder());          // Position order type before changing direction
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order_first.Ticket());           // Position order ticket before changing direction
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order_first.TypeOrder());         // Current position order type
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order_first.Ticket());          // Current position order ticket
            event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,deal.Symbol());                           // Opposite position symbol
            //---
            event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                             // Order/deal/position magic number
            event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first.TimeOpenMSC());        // Time of the order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                         // Event price (position open price)
            event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first.PriceOpen());                   // Order open price (position opening order price)
            event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last.PriceClose());                  // Order close price (the last position order close price)
            event.SetProperty(EVENT_PROP_PRICE_SL,order_first.StopLoss());                      // StopLoss price (Position order StopLoss price)
            event.SetProperty(EVENT_PROP_PRICE_TP,order_first.TakeProfit());                    // TakeProfit price (Position order TakeProfit price)
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_first.Volume());                                 // Requested order volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,(order_first.Volume()-order_first.VolumeCurrent()));  // Executed order volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order_first.VolumeCurrent());                          // Remaining (unexecuted) order volume
            event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);                                     // Executed position volume
            event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                             // Profit
            event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                                 // Order symbol
            //--- Set the control program chart ID, decode the event code and set the event type
            event.SetChartID(this.m_chart_id);
            event.SetTypeEvent();
            //--- Add the event object if it is not in the list
            if(!this.IsPresentEventInList(event))
              {
               this.m_list_events.InsertSort(event);
               //--- Send a message about the event and set the value of the last trading event
               event.SendEvent();
               this.m_trade_event=event.TradeEvent();
              }
            //--- If the event is already present in the list, remove a new event object and display a debugging message
            else
              {
               ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event already in the list."));
               delete event;
              }
           }
        }
     }
   //--- Market exit
   else if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_OUT)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_CLOSED;
      int reason=EVENT_REASON_DONE;
      //--- Take the first and last position orders from the list of all position orders
      COrder* order_first=this.GetFirstOrderFromList(list_history,deal.PositionID());
      COrder* order_last=this.GetLastOrderFromList(list_history,deal.PositionID());
      //--- Get an open position by ticket
      COrder* position=this.GetPositionByID(list_market,deal.PositionID());
      double vol_position=(position!=NULL ? position.Volume() : 0);
      if(order_first!=NULL && order_last!=NULL)
        {
         //--- Look for all position deals in the directions of its opening and closing, and count their total volume
         double volume_in=this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID());
         double volume_out=this.SummaryVolumeDealsOutByPosID(list_history,deal.PositionID());
         //--- Calculate the current volume of the closed position
         int dgl=(int)DigitsLots(deal.Symbol());
         double volume_current=::NormalizeDouble(volume_in-volume_out,dgl);
         //--- If the order volume is closed partially, this is a partial execution
         if(volume_current>0)
           {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
           }
         //--- If the closing order is executed partially, set the closing order partial execution as an event reason
         if(order_last.VolumeCurrent()>0)
           {
            reason=EVENT_REASON_DONE_PARTIALLY;
           }
         //--- If the closing flag is set to StopLoss for a position's closing order, then closing is performed by StopLoss
         //--- If a StopLoss order is executed partially, set partial StopLoss order execution as the event reason
         if(order_last.IsCloseByStopLoss())
           {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_SL;
            reason=(order_last.VolumeCurrent()>0 ? EVENT_REASON_DONE_SL_PARTIALLY : EVENT_REASON_DONE_SL);
           }
         //--- If the closing flag is set to TakeProfit for a position's closing order, then closing is performed by TakeProfit
         //--- If a TakeProfit order is executed partially, set partial TakeProfit order execution as the event reason
         else if(order_last.IsCloseByTakeProfit())
           {
            this.m_trade_event_code+=TRADE_EVENT_FLAG_TP;
            reason=(order_last.VolumeCurrent()>0 ? EVENT_REASON_DONE_TP_PARTIALLY : EVENT_REASON_DONE_TP);
           }
         //---
         CEvent* event=new CEventPositionClose(this.m_trade_event_code,deal.PositionID());
         if(event!=NULL)
           {
            event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpenMSC());                        // Event time (position close time)
            event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                                  // Event reason (from the ENUM_EVENT_REASON enumeration)
            event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                     // Event deal type
            event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                      // Event deal ticket
            event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order_first.TypeOrder());          // Type of the order that triggered a position deal (the first position order)
            event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order_last.TypeOrder());              // Type of the order that triggered an event deal (the last position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order_first.Ticket());           // Ticket of the order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order_last.Ticket());               // Ticket of the order, based on which an event deal is opened (the last position order)
            event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                        // Position ID
            event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last.PositionByID());             // Opposite position ID
            //---
            event.SetProperty(EVENT_PROP_MAGIC_BY_ID,order_last.Magic());                       // Opposite position magic number
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order_first.TypeOrder());          // Position order type before changing direction
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order_first.Ticket());           // Position order ticket before changing direction
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order_first.TypeOrder());         // Current position order type
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order_first.Ticket());          // Current position order ticket
            event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order_last.Symbol());                     // Opposite position symbol
            //---
            event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                             // Order/deal/position magic number
            event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first.TimeOpenMSC());        // Time of the order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                         // Event price (position close price)
            event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first.PriceOpen());                   // Order open price (position opening order price)
            event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last.PriceClose());                  // Order close price (the last position order close price)
            event.SetProperty(EVENT_PROP_PRICE_SL,order_first.StopLoss());                      // StopLoss price (Position order StopLoss price)
            event.SetProperty(EVENT_PROP_PRICE_TP,order_first.TakeProfit());                    // TakeProfit price (Position order TakeProfit price)
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_last.Volume());                               // Requested order volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,order_last.Volume()-order_last.VolumeCurrent());   // Executed order volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,order_last.VolumeCurrent());                        // Remaining (current) order volume
            event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);                                  // Remaining (current) position volume
            //---
            event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                             // Profit
            event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                                 // Order symbol
            //--- Set the control program chart ID, decode the event code and set the event type
            event.SetChartID(this.m_chart_id);
            event.SetTypeEvent();
            //--- Add the event object if it is not in the list
            if(!this.IsPresentEventInList(event))
              {
               this.m_list_events.InsertSort(event);
               //--- Send a message about the event and set the value of the last trading event
               event.SendEvent();
               this.m_trade_event=event.TradeEvent();
              }
            //--- If the event is already present in the list, remove a new event object and display a debugging message
            else
              {
               ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event already in the list."));
               delete event;
              }
           }
        }
     }
   //--- Opposite position
   else if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_OUT_BY)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_CLOSED;
      int reason=EVENT_REASON_DONE_BY_POS;
      //--- Take the first and closing position orders from the list of all position orders
      COrder* order_first=this.GetFirstOrderFromList(list_history,deal.PositionID());
      COrder* order_close=this.GetCloseByOrderFromList(list_history,deal.PositionID());
      //--- Get the open position by ID
      COrder* position=this.GetPositionByID(list_market,order_first.PositionID());
      double vol_position=(position!=NULL ? position.Volume() : 0);
      if(order_first!=NULL && order_close!=NULL)
        {
         //--- Add the flag of closing by an opposite position
         this.m_trade_event_code+=TRADE_EVENT_FLAG_BY_POS;
         //--- Take the first order of the closing position
         CArrayObj* list_close_by=this.GetListAllOrdersByPosID(list_history,order_close.PositionByID());
         COrder* order_close_by=list_close_by.At(0);
         if(order_close_by==NULL)
            return;
         //--- Look for all closed position deals in the direction of its opening and closing and count their total volume
         double volume_in=this.SummaryVolumeDealsInByPosID(list_history,deal.PositionID());
         double volume_out=this.SummaryVolumeDealsOutByPosID(list_history,deal.PositionID());//+order_close.Volume();
         //--- Calculate the current volume of the closed position
         int dgl=(int)DigitsLots(deal.Symbol());
         double volume_current=::NormalizeDouble(volume_in-volume_out,dgl);
         //--- Look for all opposite position deals in the directions of its opening and closing and calculate their total volume
         double volume_opp_in=this.SummaryVolumeDealsInByPosID(list_history,order_close.PositionByID());
         double volume_opp_out=this.SummaryVolumeDealsOutByPosID(list_history,order_close.PositionByID());
         //--- Calculate the current volume of the opposite position
         double volume_opp_current=::NormalizeDouble(volume_opp_in-volume_opp_out,dgl);
         //--- If the closed position volume is closed partially, this is a partial closing
         if(volume_current>0 || order_close.VolumeCurrent()>0)
           {
            //--- Add the partial closing flag
            this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
            //--- If the opposite position is closed partially, there is a partial closing by the part of the opposite position volume
            reason=(volume_opp_current>0 ? EVENT_REASON_DONE_PARTIALLY_BY_POS_PARTIALLY : EVENT_REASON_DONE_PARTIALLY_BY_POS);
           }
         //--- If the position volume is closed in full and there is a partial execution by the opposite one, there is a closing by the part of the opposite position volume
         else
           {
            if(volume_opp_current>0)
              {
               reason=EVENT_REASON_DONE_BY_POS_PARTIALLY;
              }
           }
         CEvent* event=new CEventPositionClose(this.m_trade_event_code,deal.PositionID());
         if(event!=NULL)
           {
            event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpenMSC());                        // Event time
            event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                                  // Event reason (from the ENUM_EVENT_REASON enumeration)
            event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());                     // Event deal type
            event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                      // Event deal ticket
            event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,order_close.TypeOrder());             // Type of the order that triggered an event deal (the last position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,order_close.Ticket());              // Ticket of the order, based on which an event deal is opened (the last position order)
            event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first.TimeOpenMSC());        // Time of the order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,order_first.TypeOrder());          // Type of the order that triggered a position deal (the first position order)
            event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,order_first.Ticket());           // Ticket of the order, based on which a position deal is opened (the first position order)
            event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                        // Position ID
            event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_close.PositionByID());            // Opposite position ID
            //---
            event.SetProperty(EVENT_PROP_MAGIC_BY_ID,order_close_by.Magic());                   // Opposite position magic number
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,order_first.TypeOrder());          // Position order type before changing direction
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,order_first.Ticket());           // Position order ticket before changing direction
            event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,order_first.TypeOrder());         // Current position order type
            event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,order_first.Ticket());          // Current position order ticket
            event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,order_close_by.Symbol());                 // Opposite position symbol
            //---
            event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                             // Order/deal/position magic number
            event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                         // Event price
            event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first.PriceOpen());                   // Order/deal/position open price
            event.SetProperty(EVENT_PROP_PRICE_CLOSE,deal.PriceClose());                        // Order/deal/position close price
            event.SetProperty(EVENT_PROP_PRICE_SL,order_first.StopLoss());                      // StopLoss price (Position order StopLoss price)
            event.SetProperty(EVENT_PROP_PRICE_TP,order_first.TakeProfit());                    // TakeProfit price (Position order TakeProfit price)
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,::NormalizeDouble(volume_in,dgl));// Initial volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,deal.Volume());                  // Closed volume
            event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,volume_current);                  // Remaining (current) volume
            event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);                // Remaining (current) volume
            event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                             // Profit
            event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                                 // Order symbol
            //--- Set the control program chart ID, decode the event code and set the event type
            event.SetChartID(this.m_chart_id);
            event.SetTypeEvent();
            //--- Add the event object if it is not in the list
            if(!this.IsPresentEventInList(event))
              {
               this.m_list_events.InsertSort(event);
               //--- Send a message about the event and set the value of the last trading event
               event.SendEvent();
               this.m_trade_event=event.TradeEvent();
              }
            //--- If the event is already present in the list, remove a new event object and display a debugging message
            else
              {
               ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event already in the list."));
               delete event;
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Create an event for a netting account                            |
//+------------------------------------------------------------------+
void CEventsCollection::NewDealEventNetto(COrder *deal,CArrayObj *list_history,CArrayObj *list_market)
  {
//--- Prepare position history data
//--- Lists of all deals and position direction changes
   CArrayObj* list_deals=this.GetListAllDealsByPosID(list_history,deal.PositionID());
   CArrayObj* list_changes=this.GetListAllDealsInOutByPosID(list_history,deal.PositionID());
   if(list_deals==NULL || list_changes==NULL)
      return;
   list_deals.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   list_changes.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   if(!list_changes.InsertSort(list_deals.At(0)))
      return;
   
//--- Orders of the first and last position deals
   CArrayObj* list_tmp=this.GetListAllOrdersByPosID(list_history,deal.PositionID());
   COrder* order_first_deal=list_tmp.At(0);
   list_tmp=CSelect::ByOrderProperty(list_tmp,ORDER_PROP_TICKET,deal.GetProperty(ORDER_PROP_DEAL_ORDER_TICKET),EQUAL);
   COrder* order_last_deal=list_tmp.At(list_tmp.Total()-1);
   if(order_first_deal==NULL || order_last_deal==NULL)
      return;
//--- Type and tickets of the first and last position deals' orders
   ENUM_ORDER_TYPE type_order_first_deal=(ENUM_ORDER_TYPE)order_first_deal.TypeOrder();
   ENUM_ORDER_TYPE type_order_last_deal=(ENUM_ORDER_TYPE)order_last_deal.TypeOrder();
   ulong ticket_order_first_deal=order_first_deal.Ticket();
   ulong ticket_order_last_deal=order_last_deal.Ticket();
   
//--- Current and previous positions
   COrder* position_current=list_changes.At(list_changes.Total()-1);
   COrder* position_previous=(list_changes.Total()>1 ? list_changes.At(list_changes.Total()-2) : position_current);
   if(position_current==NULL || position_previous==NULL)
      return;
   ENUM_ORDER_TYPE type_position_current=(ENUM_ORDER_TYPE)position_current.TypeOrder();
   ulong ticket_position_current=position_current.GetProperty(ORDER_PROP_DEAL_ORDER_TICKET);
   ENUM_ORDER_TYPE type_position_previous=(ENUM_ORDER_TYPE)position_previous.TypeOrder();
   ulong ticket_position_previous=position_previous.GetProperty(ORDER_PROP_DEAL_ORDER_TICKET);

//--- Get an open position by the ticket and write its volume
   COrder* position=this.GetPositionByID(list_market,deal.PositionID());
   double vol_position=(position!=NULL ? position.Volume() : 0);
//--- Executed order volume
   double vol_order_done=order_last_deal.Volume()-order_last_deal.VolumeCurrent();
//--- Remaining (unexecuted) order volume
   double vol_order_current=order_last_deal.VolumeCurrent();

//--- Market entry
   if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_IN)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_OPENED;
      int num_deals=list_deals.Total();
      int reason=(num_deals>1 ? EVENT_REASON_VOLUME_ADD : EVENT_REASON_DONE);
      //--- If this is not the first deal in the position, add the position change flag
      if(num_deals>1)
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_POSITION_CHANGED;
        }
      //--- If the order volume is opened partially, this is a partial execution
      if(order_last_deal.VolumeCurrent()>0)
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
         //--- If this is not the first position deal, the volume is added by partial execution, otherwise - partial opening
         reason=(num_deals>1 ? EVENT_REASON_VOLUME_ADD_PARTIALLY : EVENT_REASON_DONE_PARTIALLY);
        }
      //--- If an opening order is a pending one, the pending order is activated
      if(order_last_deal.TypeOrder()>ORDER_TYPE_SELL && order_last_deal.TypeOrder()<ORDER_TYPE_CLOSE_BY)
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_ORDER_ACTIVATED;
         //--- If this is not the first position deal
         if(num_deals>1)
           {
            //--- If the order is executed partially, set adding the volume to the position by pending order partial execution as an event reason,
            //--- otherwise, the volume is added to the position by executing a pending order
            reason=
              (order_last_deal.VolumeCurrent()>0 ? 
               EVENT_REASON_VOLUME_ADD_BY_PENDING_PARTIALLY  : 
               EVENT_REASON_VOLUME_ADD_BY_PENDING
              );
           }
         //--- If this is a new position
         else
           {
            //--- If the order is executed partially, set pending order partial execution as an event reason,
            //--- otherwise, the position is opened by activating a pending order
            reason=
              (order_last_deal.VolumeCurrent()>0 ? 
               EVENT_REASON_ACTIVATED_PENDING_PARTIALLY  : 
               EVENT_REASON_ACTIVATED_PENDING
              );
           }
        }
      CEvent* event=new CEventPositionOpen(this.m_trade_event_code,deal.PositionID());
      if(event!=NULL)
        {
         //--- Event deal parameters
         event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpenMSC());                  // Event time (position open time)
         event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                            // Event reason (from the ENUM_EVENT_REASON enumeration)
         event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());               // Event deal type
         event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                // Event deal ticket
         event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                       // Order/deal/position magic number
         event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                   // Event price (position open price)
         event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                       // Profit
         event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                           // Order symbol
         event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,deal.Symbol());                     // Opposite position symbol
         event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                  // Position ID
         
         //--- Event order parameters
         event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,type_order_last_deal);          // Type of the order that triggered an event deal (the last position order)
         event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,ticket_order_last_deal);      // Ticket of the order, based on which an event deal is opened (the last position order)
         event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last_deal.PositionByID());  // Opposite position ID
         event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last_deal.PriceClose());       // Order close price (the last position order close price)
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_last_deal.Volume());  // Requested order volume
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,vol_order_done);           // Executed order volume
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,vol_order_current);         // Remaining (unexecuted) order volume
         event.SetProperty(EVENT_PROP_MAGIC_BY_ID,deal.Magic());                       // Opposite position magic number
            
         //--- Position parameters
         event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,type_order_first_deal);      // Type of the order that triggered the first position deal
         event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,ticket_order_first_deal);  // Ticket of the order, based on which a position deal is opened (the first position order)
         event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first_deal.TimeOpenMSC());  // Time of the order, based on which a position deal is opened (the first position order)
         event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first_deal.PriceOpen());        // Position first order open price
         event.SetProperty(EVENT_PROP_PRICE_SL,order_first_deal.StopLoss());           // StopLoss price (Position order StopLoss price)
         event.SetProperty(EVENT_PROP_PRICE_TP,order_first_deal.TakeProfit());         // TakeProfit price (Position order TakeProfit price)
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,type_position_previous);     // Position type before changing the direction
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,ticket_position_previous); // Position order ticket before changing direction
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,type_position_current);     // Current position order type
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,ticket_position_current); // Current position order ticket
         event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);          // Executed position volume
         
         //--- Set the control program chart ID, decode the event code and set the event type
         event.SetChartID(this.m_chart_id);
         event.SetTypeEvent();
         //--- Add the event object if it is not in the list
         if(!this.IsPresentEventInList(event))
           {
            this.m_list_events.InsertSort(event);
            //--- Send a message about the event and set the value of the last trading event
            event.SendEvent();
            this.m_trade_event=event.TradeEvent();
           }
         //--- If the event is already present in the list, remove a new event object and display a debugging message
         else
           {
            ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event already in the list."));
            delete event;
           }
        }
     }
//--- Position reversal
   else if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_INOUT)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_OPENED+TRADE_EVENT_FLAG_POSITION_CHANGED+TRADE_EVENT_FLAG_POSITION_REVERSE;
      int reason=EVENT_REASON_REVERSE;
      //--- If the order volume is opened partially, this is a partial execution
      if(order_last_deal.VolumeCurrent()>0)
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
         reason=EVENT_REASON_REVERSE_PARTIALLY;
        }
      //--- If an opening order is a pending one, the pending order is activated
      if(order_last_deal.TypeOrder()>ORDER_TYPE_SELL && order_last_deal.TypeOrder()<ORDER_TYPE_CLOSE_BY)
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_ORDER_ACTIVATED;
         //--- If the order is executed partially, set the position reversal by a pending order partial execution as the event reason
         reason=
           (order_last_deal.VolumeCurrent()>0 ? 
            EVENT_REASON_REVERSE_BY_PENDING_PARTIALLY  : 
            EVENT_REASON_REVERSE_BY_PENDING
           );
        }
      CEvent* event=new CEventPositionOpen(this.m_trade_event_code,deal.PositionID());
      if(event!=NULL)
        {
         //--- Event deal parameters
         event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpenMSC());                  // Event time (position open time)
         event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                            // Event reason (from the ENUM_EVENT_REASON enumeration)
         event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());               // Event deal type
         event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                // Event deal ticket
         event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                       // Order/deal/position magic number
         event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                   // Event price (position open price)
         event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                       // Profit
         event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                           // Order symbol
         event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,deal.Symbol());                     // Opposite position symbol
         event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                  // Position ID
            
         //--- Event order parameters
         event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,type_order_last_deal);          // Type of the order that triggered an event deal (the last position order)
         event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,ticket_order_last_deal);      // Ticket of the order, based on which an event deal is opened (the last position order)
         event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last_deal.PositionByID());  // Opposite position ID
         event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last_deal.PriceClose());       // Order close price (the last position order close price)
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_last_deal.Volume());  // Requested order volume
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,vol_order_done);           // Executed order volume
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,vol_order_current);         // Remaining (unexecuted) order volume
         event.SetProperty(EVENT_PROP_MAGIC_BY_ID,deal.Magic());                       // Opposite position magic number
            
         //--- Position parameters
         event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,type_order_first_deal);      // Type of the order that triggered the first position deal
         event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,ticket_order_first_deal);  // Ticket of the order, based on which a position deal is opened (the first position order)
         event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first_deal.TimeOpenMSC());  // Time of the order, based on which a position deal is opened (the first position order)
         event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first_deal.PriceOpen());        // Position first order open price
         event.SetProperty(EVENT_PROP_PRICE_SL,order_first_deal.StopLoss());           // StopLoss price (Position order StopLoss price)
         event.SetProperty(EVENT_PROP_PRICE_TP,order_first_deal.TakeProfit());         // TakeProfit price (Position order TakeProfit price)
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,type_position_previous);     // Position order type before changing the direction
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,ticket_position_previous); // Position order ticket before changing direction
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,type_position_current);     // Current position order type
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,ticket_position_current); // Current position order ticket
         event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);          // Executed position volume
         
         //--- Set the control program chart ID, decode the event code and set the event type
         event.SetChartID(this.m_chart_id);
         event.SetTypeEvent();
         //--- Add the event object if it is not in the list
         if(!this.IsPresentEventInList(event))
           {
            this.m_list_events.InsertSort(event);
            //--- Send a message about the event and set the value of the last trading event
            event.SendEvent();
            this.m_trade_event=event.TradeEvent();
           }
         //--- If the event is already present in the list, remove a new event object and display a debugging message
         else
           {
            ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event already in the list."));
            delete event;
           }
        }
     }
//--- Market exit
   else if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_OUT)
     {
      this.m_trade_event_code=TRADE_EVENT_FLAG_POSITION_CLOSED;
      int reason=EVENT_REASON_DONE;
      //--- If the position with the ID is still in the market, this means partial execution
      if(this.GetPositionByID(list_market,deal.PositionID())!=NULL)
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
        }
      //--- If the closing order is executed partially, set the closing order partial execution as an event reason
      if(order_last_deal.VolumeCurrent()>0)
        {
         reason=EVENT_REASON_DONE_PARTIALLY;
        }
      //--- If the closing flag is set to StopLoss for a position's closing order, then closing is performed by StopLoss
      //--- If a StopLoss order is executed partially, set partial StopLoss order execution as the event reason
      if(order_last_deal.IsCloseByStopLoss())
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_SL;
         reason=(order_last_deal.VolumeCurrent()>0 ? EVENT_REASON_DONE_SL_PARTIALLY : EVENT_REASON_DONE_SL);
        }
      //--- If the closing flag is set to TakeProfit for a position's closing order, then closing is performed by TakeProfit
      //--- If a TakeProfit order is executed partially, set partial TakeProfit order execution as the event reason
      else if(order_last_deal.IsCloseByTakeProfit())
        {
         this.m_trade_event_code+=TRADE_EVENT_FLAG_TP;
         reason=(order_last_deal.VolumeCurrent()>0 ? EVENT_REASON_DONE_TP_PARTIALLY : EVENT_REASON_DONE_TP);
        }
      //---
      CEvent* event=new CEventPositionClose(this.m_trade_event_code,deal.PositionID());
      if(event!=NULL)
        {
         //--- Event deal parameters
         event.SetProperty(EVENT_PROP_TIME_EVENT,deal.TimeOpenMSC());                  // Event time (position open time)
         event.SetProperty(EVENT_PROP_REASON_EVENT,reason);                            // Event reason (from the ENUM_EVENT_REASON enumeration)
         event.SetProperty(EVENT_PROP_TYPE_DEAL_EVENT,deal.TypeOrder());               // Event deal type
         event.SetProperty(EVENT_PROP_TICKET_DEAL_EVENT,deal.Ticket());                // Event deal ticket
         event.SetProperty(EVENT_PROP_MAGIC_ORDER,deal.Magic());                       // Order/deal/position magic number
         event.SetProperty(EVENT_PROP_PRICE_EVENT,deal.PriceOpen());                   // Event price (position open price)
         event.SetProperty(EVENT_PROP_PROFIT,deal.ProfitFull());                       // Profit
         event.SetProperty(EVENT_PROP_SYMBOL,deal.Symbol());                           // Order symbol
         event.SetProperty(EVENT_PROP_SYMBOL_BY_ID,deal.Symbol());                     // Opposite position symbol
         event.SetProperty(EVENT_PROP_POSITION_ID,deal.PositionID());                  // Position ID
         
         //--- Event order parameters
         event.SetProperty(EVENT_PROP_TYPE_ORDER_EVENT,type_order_last_deal);          // Type of the order that triggered an event deal (the last position order)
         event.SetProperty(EVENT_PROP_TICKET_ORDER_EVENT,ticket_order_last_deal);      // Ticket of the order, based on which an event deal is opened (the last position order)
         event.SetProperty(EVENT_PROP_POSITION_BY_ID,order_last_deal.PositionByID());  // Opposite position ID
         event.SetProperty(EVENT_PROP_PRICE_CLOSE,order_last_deal.PriceClose());       // Order close price (the last position order close price)
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_INITIAL,order_last_deal.Volume());  // Requested order volume
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_EXECUTED,vol_order_done);           // Executed order volume
         event.SetProperty(EVENT_PROP_VOLUME_ORDER_CURRENT,vol_order_current);         // Remaining (unexecuted) order volume
         event.SetProperty(EVENT_PROP_MAGIC_BY_ID,order_last_deal.Magic());            // Opposite position magic number
            
         //--- Position parameters
         event.SetProperty(EVENT_PROP_TYPE_ORDER_POSITION,type_order_first_deal);      // Type of the order that triggered the first position deal
         event.SetProperty(EVENT_PROP_TICKET_ORDER_POSITION,ticket_order_first_deal);  // Ticket of the order, based on which a position deal is opened (the first position order)
         event.SetProperty(EVENT_PROP_TIME_ORDER_POSITION,order_first_deal.TimeOpenMSC());  // Time of the order, based on which a position deal is opened (the first position order)
         event.SetProperty(EVENT_PROP_PRICE_OPEN,order_first_deal.PriceOpen());        // Position first order open price
         event.SetProperty(EVENT_PROP_PRICE_SL,order_first_deal.StopLoss());           // StopLoss price (Position order StopLoss price)
         event.SetProperty(EVENT_PROP_PRICE_TP,order_first_deal.TakeProfit());         // TakeProfit price (Position order TakeProfit price)
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_BEFORE,type_position_previous);     // Position order type before changing the direction
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_BEFORE,ticket_position_previous); // Position order ticket before changing direction
         event.SetProperty(EVENT_PROP_TYPE_ORD_POS_CURRENT,type_position_current);     // Current position order type
         event.SetProperty(EVENT_PROP_TICKET_ORD_POS_CURRENT,ticket_position_current); // Current position order ticket
         event.SetProperty(EVENT_PROP_VOLUME_POSITION_EXECUTED,vol_position);          // Executed position volume
         
         //--- Set the control program chart ID, decode the event code and set the event type
         event.SetChartID(this.m_chart_id);
         event.SetTypeEvent();
         //--- Add the event object if it is not in the list
         if(!this.IsPresentEventInList(event))
           {
            this.m_list_events.InsertSort(event);
            //--- Send a message about the event and set the value of the last trading event
            event.SendEvent();
            this.m_trade_event=event.TradeEvent();
           }
         //--- If the event is already present in the list, remove a new event object and display a debugging message
         else
           {
            ::Print(DFUN_ERR_LINE,TextByLanguage("Такое событие уже есть в списке","This event already in the list."));
            delete event;
           }
        }
     }
  }  
//+------------------------------------------------------------------+
//| Select events from the collection with time                      |
//| from begin_time to end_time                                      |
//+------------------------------------------------------------------+
CArrayObj *CEventsCollection::GetListByTime(const datetime begin_time=0,const datetime end_time=0)
  {
   CArrayObj *list=new CArrayObj();
   if(list==NULL)
     {
      ::Print(DFUN+TextByLanguage("Ошибка создания временного списка","Error creating temporary list"));
      return NULL;
     }
   datetime begin=begin_time,end=(end_time==0 ? END_TIME : end_time);
   if(begin_time>end_time) begin=0;
   list.FreeMode(false);
   ListStorage.Add(list);
   //---
   this.m_event_instance.SetProperty(EVENT_PROP_TIME_EVENT,begin);
   int index_begin=this.m_list_events.SearchGreatOrEqual(&m_event_instance);
   if(index_begin==WRONG_VALUE)
      return list;
   this.m_event_instance.SetProperty(EVENT_PROP_TIME_EVENT,end);
   int index_end=this.m_list_events.SearchLessOrEqual(&m_event_instance);
   if(index_end==WRONG_VALUE)
      return list;
   for(int i=index_begin; i<=index_end; i++)
      list.Add(this.m_list_events.At(i));
   return list;
  }
//+------------------------------------------------------------------+
//| Select only market pending orders from the list                  |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListMarketPendings(CArrayObj* list)
  {
   if(list.Type()!=COLLECTION_MARKET_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком рыночной коллекции","Error. The list is not a list of market collection"));
      return NULL;
     }
   CArrayObj* list_orders=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_MARKET_PENDING,EQUAL);
   return list_orders;
  }
//+------------------------------------------------------------------+
//| Select only removed pending orders from the list                 |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListHistoryPendings(CArrayObj* list)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of history collection"));
      return NULL;
     }
   CArrayObj* list_orders=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_HISTORY_PENDING,EQUAL);
   return list_orders;
  }
//+------------------------------------------------------------------+
//| Select only deals from the list                                  |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListDeals(CArrayObj* list)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of history collection"));
      return NULL;
     }
   CArrayObj* list_deals=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_DEAL,EQUAL);
   return list_deals;
  }
//+------------------------------------------------------------------+
//|  Return the list of all closing CloseBy orders from the list     |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListCloseByOrders(CArrayObj *list)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of history collection"));
      return NULL;
     }
   CArrayObj* list_orders=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,ORDER_TYPE_CLOSE_BY,EQUAL);
   return list_orders;
  }
//+------------------------------------------------------------------+
//|  Return the list of all position orders by its ID                |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListAllOrdersByPosID(CArrayObj* list,const ulong position_id)
  {
   CArrayObj* list_orders=CSelect::ByOrderProperty(list,ORDER_PROP_POSITION_ID,position_id,EQUAL);
   list_orders=CSelect::ByOrderProperty(list_orders,ORDER_PROP_STATUS,ORDER_STATUS_DEAL,NO_EQUAL);
   return list_orders;
  }
//+------------------------------------------------------------------+
//| Return the list of all position deals by its ID                  |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListAllDealsByPosID(CArrayObj *list,const ulong position_id)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of history collection"));
      return NULL;
     }
   CArrayObj* list_deals=CSelect::ByOrderProperty(list,ORDER_PROP_POSITION_ID,position_id,EQUAL);
   list_deals=CSelect::ByOrderProperty(list_deals,ORDER_PROP_STATUS,ORDER_STATUS_DEAL,EQUAL);
   return list_deals;
  }
//+------------------------------------------------------------------+
//| Return the list of all market entry deals (IN)                   |
//| by position ID                                                   |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListAllDealsInByPosID(CArrayObj *list,const ulong position_id)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of history collection"));
      return NULL;
     }
   CArrayObj* list_deals=this.GetListAllDealsByPosID(list,position_id);
   list_deals=CSelect::ByOrderProperty(list_deals,ORDER_PROP_DEAL_ENTRY,DEAL_ENTRY_IN,EQUAL);
   return list_deals;
  }
//+------------------------------------------------------------------+
//| Return the list of all market exit deals (OUT)                   |
//| by position ID                                                   |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListAllDealsOutByPosID(CArrayObj *list,const ulong position_id)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of history collection"));
      return NULL;
     }
   CArrayObj* list_deals=this.GetListAllDealsByPosID(list,position_id);
   list_deals=CSelect::ByOrderProperty(list_deals,ORDER_PROP_DEAL_ENTRY,DEAL_ENTRY_OUT,EQUAL);
   return list_deals;
  }
//+------------------------------------------------------------------+
//| Return the list of all reversal deals (IN_OUT)                   |
//| by position ID                                                   |
//+------------------------------------------------------------------+
CArrayObj* CEventsCollection::GetListAllDealsInOutByPosID(CArrayObj *list,const ulong position_id)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of history collection"));
      return NULL;
     }
   CArrayObj* list_deals=this.GetListAllDealsByPosID(list,position_id);
   list_deals=CSelect::ByOrderProperty(list_deals,ORDER_PROP_DEAL_ENTRY,DEAL_ENTRY_INOUT,EQUAL);
   return list_deals;
  }
//+------------------------------------------------------------------+
//| Return the total volume of all deals of IN position              |
//| by its ID                                                        |
//+------------------------------------------------------------------+
double CEventsCollection::SummaryVolumeDealsInByPosID(CArrayObj *list,const ulong position_id)
  {
   double vol=0.0;
   CArrayObj* list_in=this.GetListAllDealsInByPosID(list,position_id);
   if(list_in==NULL)
      return 0;
   for(int i=0;i<list_in.Total();i++)
     {
      COrder* deal=list_in.At(i);
      if(deal==NULL)
         continue;
      vol+=deal.Volume();
     }
   return vol;
  }
//+--------------------------------------------------------------------+
//| Return the total volume of all deals of OUT position by its        |
//| ID (participation in closing by an opposite position is considered)|
//+--------------------------------------------------------------------+
double CEventsCollection::SummaryVolumeDealsOutByPosID(CArrayObj *list,const ulong position_id)
  {
   double vol=0.0;
   CArrayObj* list_out=this.GetListAllDealsOutByPosID(list,position_id);
   if(list_out!=NULL)
     {
      for(int i=0;i<list_out.Total();i++)
        {
         COrder* deal=list_out.At(i);
         if(deal==NULL)
            continue;
         vol+=deal.Volume();
        }
     }
   CArrayObj* list_by=this.GetListCloseByOrders(list);
   if(list_by!=NULL)
     {
      for(int i=0;i<list_by.Total();i++)
        {
         COrder* order=list_by.At(i);
         if(order==NULL)
            continue;
         if(order.PositionID()==position_id || order.PositionByID()==position_id)
           {
            vol+=order.Volume();
           }
        }
     }
   return vol;
  }
//+------------------------------------------------------------------+
//| Return the first order from the list of all position orders      |
//+------------------------------------------------------------------+
COrder* CEventsCollection::GetFirstOrderFromList(CArrayObj* list,const ulong position_id)
  {
   CArrayObj* list_orders=this.GetListAllOrdersByPosID(list,position_id);
   if(list_orders==NULL || list_orders.Total()==0) return NULL;
   list_orders.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   COrder* order=list_orders.At(0);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Return the last order from the list of all position orders       |
//+------------------------------------------------------------------+
COrder* CEventsCollection::GetLastOrderFromList(CArrayObj* list,const ulong position_id)
  {
   CArrayObj* list_orders=this.GetListAllOrdersByPosID(list,position_id);
   if(list_orders==NULL || list_orders.Total()==0) return NULL;
   list_orders.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   COrder* order=list_orders.At(list_orders.Total()-1);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Return the last closing order                                    |
//| from the list of all position orders                             |
//+------------------------------------------------------------------+
COrder* CEventsCollection::GetCloseByOrderFromList(CArrayObj *list,const ulong position_id)
  {
   CArrayObj* list_orders=this.GetListAllOrdersByPosID(list,position_id);
   list_orders=CSelect::ByOrderProperty(list_orders,ORDER_PROP_TYPE,ORDER_TYPE_CLOSE_BY,EQUAL);
   if(list_orders==NULL || list_orders.Total()==0) return NULL;
   list_orders.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   COrder* order=list_orders.At(list_orders.Total()-1);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Return the order by ticket                                       |
//+------------------------------------------------------------------+
COrder* CEventsCollection::GetHistoryOrderByTicket(CArrayObj *list,const ulong order_ticket)
  {
   if(list.Type()!=COLLECTION_HISTORY_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком исторической коллекции","Error. The list is not a list of history collection"));
      return NULL;
     }
   CArrayObj* list_orders=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_DEAL,NO_EQUAL);
   list_orders=CSelect::ByOrderProperty(list_orders,ORDER_PROP_TICKET,order_ticket,EQUAL);
   if(list_orders==NULL || list_orders.Total()==0) return NULL;
   COrder* order=list_orders.At(0);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Return a position by ID                                          |
//+------------------------------------------------------------------+
COrder* CEventsCollection::GetPositionByID(CArrayObj *list,const ulong position_id)
  {
   if(list.Type()!=COLLECTION_MARKET_ID)
     {
      Print(DFUN,TextByLanguage("Ошибка. Список не является списком рыночной коллекции","Error. The list is not a list of market collection"));
      return NULL;
     }
   CArrayObj* list_orders=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_MARKET_POSITION,EQUAL);
   list_orders=CSelect::ByOrderProperty(list_orders,ORDER_PROP_POSITION_ID,position_id,EQUAL);
   if(list_orders==NULL || list_orders.Total()==0) return NULL;
   COrder* order=list_orders.At(0);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Return the flag of the event object presence in the event list   |
//+------------------------------------------------------------------+
bool CEventsCollection::IsPresentEventInList(CEvent *compared_event)
  {
   int total=this.m_list_events.Total();
   if(total==0)
      return false;
   for(int i=total-1;i>=0;i--)
     {
      CEvent* event=this.m_list_events.At(i);
      if(event==NULL)
         continue;
      if(event.IsEqual(compared_event))
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
