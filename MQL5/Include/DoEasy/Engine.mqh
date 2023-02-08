//+------------------------------------------------------------------+
//|                                                       Engine.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/en/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/en/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include files                                                    |
//+------------------------------------------------------------------+
#include "Collections\HistoryCollection.mqh"
#include "Collections\MarketCollection.mqh"
#include "Services\TimerCounter.mqh"
//+------------------------------------------------------------------+
//| Library basis class                                              |
//+------------------------------------------------------------------+
class CEngine : public CObject
  {
private:
   CHistoryCollection   m_history;                       // Collection of historical orders and deals
   CMarketCollection    m_market;                        // Collection of market orders and deals
   CArrayObj            m_list_counters;                 // List of timer counters
   bool                 m_first_start;                   // First launch flag
   bool                 m_is_hedge;                      // Hedge account flag
   bool                 m_is_market_trade_event;         // Account trading event flag
   bool                 m_is_history_trade_event;        // Account history trading event flag
   int                  m_trade_event_code;              // Account trading event status code
   ENUM_TRADE_EVENT     m_acc_trade_event;               // Account trading event
//--- Decode the event code and set the trading event on the account
   void                 SetTradeEvent(void);
//--- Return the counter index by id
   int                  CounterIndex(const int id) const;
//--- Return the (1) first launch flag, (2) presence of the flag in the trading event
   bool                 IsFirstStart(void);
   bool                 IsTradeEventFlag(const int event_code)    const { return (this.m_trade_event_code&event_code)==event_code;  }
//--- Working with (1) hedging, (2) netting collections
   void                 WorkWithHedgeCollections(void);
   void                 WorkWithNettoCollections(void);
//--- Return the last (1) market pending order, (2) market order, (3) last position, (4) position by ticket
   COrder*              GetLastMarketPending(void);
   COrder*              GetLastMarketOrder(void);
   COrder*              GetLastPosition(void);
   COrder*              GetPosition(const ulong ticket);
//--- Return the last (1) removed pending order, (2) historical market order, (3) historical market order by its ticket
   COrder*              GetLastHistoryPending(void);
   COrder*              GetLastHistoryOrder(void);
   COrder*              GetHistoryOrder(const ulong ticket);
//--- Return the (1) first and the (2) last historical market orders from the list of all position orders, (3) the last deal
   COrder*              GetFirstOrderPosition(const ulong position_id);
   COrder*              GetLastOrderPosition(const ulong position_id);
   COrder*              GetLastDeal(void);
public:
   //--- Return the list of market (1) positions, (2) pending orders and (3) market orders
   CArrayObj*           GetListMarketPosition(void);
   CArrayObj*           GetListMarketPendings(void);
   CArrayObj*           GetListMarketOrders(void);
   //--- Return the list of historical (1) orders, (2) removed pending orders, (3) deals, (4) all position market orders by its id
   CArrayObj*           GetListHistoryOrders(void);
   CArrayObj*           GetListHistoryPendings(void);
   CArrayObj*           GetListHistoryDeals(void);
   CArrayObj*           GetListAllOrdersByPosID(const ulong position_id);
//--- Reset the last trading event
   void                 ResetLastTradeEvent(void)                       { this.m_acc_trade_event=TRADE_EVENT_NO_EVENT;  }
//--- Return the (1) last trading event, (2) trading event code, (3) hedge account flag
   ENUM_TRADE_EVENT     LastTradeEvent(void)                      const { return this.m_acc_trade_event;                }
   int                  TradeEventCode(void)                      const { return this.m_trade_event_code;               }
   bool                 IsHedge(void)                             const { return this.m_is_hedge;                       }
//--- Create the timer counter
   void                 CreateCounter(const int id,const ulong frequency,const ulong pause);
//--- Timer
   void                 OnTimer(void);
//--- Constructor/destructor
                        CEngine();
                       ~CEngine();
  };
//+------------------------------------------------------------------+
//| CEngine constructor                                              |
//+------------------------------------------------------------------+
CEngine::CEngine() : m_first_start(true),m_trade_event_code(TRADE_EVENT_FLAG_NO_EVENT),m_acc_trade_event(TRADE_EVENT_NO_EVENT)
  {
   ::EventSetMillisecondTimer(TIMER_FREQUENCY);
   this.m_list_counters.Sort();
   this.CreateCounter(COLLECTION_COUNTER_ID,COLLECTION_COUNTER_STEP,COLLECTION_PAUSE);
   this.m_is_hedge=bool(::AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
  }
//+------------------------------------------------------------------+
//| CEngine destructor                                               |
//+------------------------------------------------------------------+
CEngine::~CEngine()
  {
   ::EventKillTimer();
  }
//+------------------------------------------------------------------+
//| CEngine timer                                                    |
//+------------------------------------------------------------------+
void CEngine::OnTimer(void)
  {
//--- Timer of the collections of historical orders and deals, as well as of market orders and positions
   int index=this.CounterIndex(COLLECTION_COUNTER_ID);
   if(index>WRONG_VALUE)
     {
      CTimerCounter* counter=this.m_list_counters.At(index);
      if(counter!=NULL && counter.IsTimeDone())
        {
         if(this.m_is_hedge)
            this.WorkWithHedgeCollections();
        }
     }
   //Comment("\nLast trade event: ",EnumToString(this.LastTradeEvent()));
  }
//+------------------------------------------------------------------+
//| Create the timer counter                                         |
//+------------------------------------------------------------------+
void CEngine::CreateCounter(const int id,const ulong step,const ulong pause)
  {
   if(this.CounterIndex(id)>WRONG_VALUE)
     {
      ::Print(TextByLanguage("Ошибка. Уже создан счётчик с идентификатором ","Error. Already created counter with id "),(string)id);
      return;
     }
   m_list_counters.Sort();
   CTimerCounter* counter=new CTimerCounter(id);
   if(counter==NULL)
      ::Print(TextByLanguage("Не удалось создать счётчик таймера ","Failed to create timer counter "),(string)id);
   counter.SetParams(step,pause);
   if(this.m_list_counters.Search(counter)==WRONG_VALUE)
      this.m_list_counters.Add(counter);
   else
     {
      string t1=TextByLanguage("Ошибка. Счётчик с идентификатором ","Error. Counter with ID ")+(string)id;
      string t2=TextByLanguage(", шагом ",", step ")+(string)step;
      string t3=TextByLanguage(" и паузой "," and pause ")+(string)pause;
      ::Print(t1+t2+t3+TextByLanguage(" уже существует"," already exists"));
      delete counter;
     }
  }
//+------------------------------------------------------------------+
//| Return the counter index by id                                   |
//+------------------------------------------------------------------+
int CEngine::CounterIndex(const int id) const
  {
   int total=this.m_list_counters.Total();
   for(int i=0;i<total;i++)
     {
      CTimerCounter* counter=this.m_list_counters.At(i);
      if(counter==NULL) continue;
      if(counter.Type()==id) 
         return i;
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Return the first launch flag, reset the flag                     |
//+------------------------------------------------------------------+
bool CEngine::IsFirstStart(void)
  {
   if(this.m_first_start)
     {
      this.m_first_start=false;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Return the list of market positions                              |
//+------------------------------------------------------------------+
CArrayObj* CEngine::GetListMarketPosition(void)
  {
   CArrayObj* list=this.m_market.GetList();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_MARKET_POSITION,EQUAL);
   return list;
  }
//+------------------------------------------------------------------+
//| Return the list of market pending orders                         |
//+------------------------------------------------------------------+
CArrayObj* CEngine::GetListMarketPendings(void)
  {
   CArrayObj* list=this.m_market.GetList();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_MARKET_PENDING,EQUAL);
   return list;
  }
//+------------------------------------------------------------------+
//| Return the list of market orders                                 |
//+------------------------------------------------------------------+
CArrayObj* CEngine::GetListMarketOrders(void)
  {
   CArrayObj* list=this.m_market.GetList();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_MARKET_ORDER,EQUAL);
   return list;
  }
//+------------------------------------------------------------------+
//| Return the list of historical orders                             |
//+------------------------------------------------------------------+
CArrayObj* CEngine::GetListHistoryOrders(void)
  {
   CArrayObj* list=this.m_history.GetList();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_HISTORY_ORDER,EQUAL);
   return list;
  }
//+------------------------------------------------------------------+
//| Return the list of removed pending orders                        |
//+------------------------------------------------------------------+
CArrayObj* CEngine::GetListHistoryPendings(void)
  {
   CArrayObj* list=this.m_history.GetList();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_HISTORY_PENDING,EQUAL);
   return list;
  }
//+------------------------------------------------------------------+
//| Return the list of deals                                         |
//+------------------------------------------------------------------+
CArrayObj* CEngine::GetListHistoryDeals(void)
  {
   CArrayObj* list=this.m_history.GetList();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_STATUS,ORDER_STATUS_DEAL,EQUAL);
   return list;
  }
//+------------------------------------------------------------------+
//|  Return the list of all position orders                          |
//+------------------------------------------------------------------+
CArrayObj* CEngine::GetListAllOrdersByPosID(const ulong position_id)
  {
   CArrayObj* list=this.GetListHistoryOrders();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_POSITION_ID,position_id,EQUAL);
   return list;
  }
//+------------------------------------------------------------------+
//| Return the last position                                         |
//+------------------------------------------------------------------+
COrder* CEngine::GetLastPosition(void)
  {
   CArrayObj* list=this.GetListMarketPosition();
   if(list==NULL) return NULL;
   list.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   COrder* order=list.At(list.Total()-1);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Return position by ticket                                        |
//+------------------------------------------------------------------+
COrder* CEngine::GetPosition(const ulong ticket)
  {
   CArrayObj* list=this.GetListMarketPosition();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_TICKET,ticket,EQUAL);
   if(list==NULL) return NULL;
   list.Sort(SORT_BY_ORDER_TICKET);
   COrder* order=list.At(list.Total()-1);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Return the last deal                                             |
//+------------------------------------------------------------------+
COrder* CEngine::GetLastDeal(void)
  {
   CArrayObj* list=this.GetListHistoryDeals();
   if(list==NULL) return NULL;
   list.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   COrder* order=list.At(list.Total()-1);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Return the last market pending order                             |
//+------------------------------------------------------------------+
COrder* CEngine::GetLastMarketPending(void)
  {
   CArrayObj* list=this.GetListMarketPendings();
   if(list==NULL) return NULL;
   list.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   COrder* order=list.At(list.Total()-1);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Return the last historical pending order                         |
//+------------------------------------------------------------------+
COrder* CEngine::GetLastHistoryPending(void)
  {
   CArrayObj* list=this.GetListHistoryPendings();
   if(list==NULL) return NULL;
   list.Sort(#ifdef __MQL5__ SORT_BY_ORDER_TIME_OPEN_MSC #else SORT_BY_ORDER_TIME_CLOSE_MSC #endif);
   COrder* order=list.At(list.Total()-1);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Return the last market order                                     |
//+------------------------------------------------------------------+
COrder* CEngine::GetLastMarketOrder(void)
  {
   CArrayObj* list=this.GetListMarketOrders();
   if(list==NULL) return NULL;
   list.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   COrder* order=list.At(list.Total()-1);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Return the last historical market order                          |
//+------------------------------------------------------------------+
COrder* CEngine::GetLastHistoryOrder(void)
  {
   CArrayObj* list=this.GetListHistoryOrders();
   if(list==NULL) return NULL;
   list.Sort(SORT_BY_ORDER_TIME_OPEN_MSC);
   COrder* order=list.At(list.Total()-1);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Return historical market order by its ticket                     |
//+------------------------------------------------------------------+
COrder* CEngine::GetHistoryOrder(const ulong ticket)
  {
   CArrayObj* list=this.GetListHistoryOrders();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_TICKET,(long)ticket,EQUAL);
   if(list==NULL) return NULL;
   list.Sort(SORT_BY_ORDER_TICKET);
   COrder* order=list.At(list.Total()-1);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Return the first historical market order                         |
//| from the list of all position orders                             |
//+------------------------------------------------------------------+
COrder* CEngine::GetFirstOrderPosition(const ulong position_id)
  {
   CArrayObj* list=this.GetListAllOrdersByPosID(position_id);
   if(list==NULL) return NULL;
   list.Sort(SORT_BY_ORDER_TIME_OPEN);
   COrder* order=list.At(0);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Return the last historical market order                          |
//| from the list of all position orders                             |
//+------------------------------------------------------------------+
COrder* CEngine::GetLastOrderPosition(const ulong position_id)
  {
   CArrayObj* list=this.GetListAllOrdersByPosID(position_id);
   if(list==NULL) return NULL;
   list.Sort(SORT_BY_ORDER_TIME_OPEN);
   COrder* order=list.At(list.Total()-1);
   return(order!=NULL ? order : NULL);
  }
//+------------------------------------------------------------------+
//| Check trading events (hedging)                                   |
//+------------------------------------------------------------------+
void CEngine::WorkWithHedgeCollections(void)
  {
//--- Initialize the trading events code and flag
   this.m_trade_event_code=TRADE_EVENT_FLAG_NO_EVENT;
   this.m_is_market_trade_event=false;
   this.m_is_history_trade_event=false;
//--- Update the lists 
   this.m_market.Refresh();
   this.m_history.Refresh();
//--- First launch actions
   if(this.IsFirstStart())
     {
      this.m_acc_trade_event=TRADE_EVENT_NO_EVENT;
      return;
     }
//--- Check the market state dynamics and account history
   this.m_is_market_trade_event=this.m_market.IsTradeEvent();
   this.m_is_history_trade_event=this.m_history.IsTradeEvent();
//---
#ifdef __MQL4__

#else // MQL5
//--- If an event is only in market orders and positions
   if(this.m_is_market_trade_event && !this.m_is_history_trade_event)
     {
      //--- If the number of pending orders increased
      if(this.m_market.NewPendingOrders()>0)
        {
         //--- Add the flag for installing a pending order
         this.m_trade_event_code+=TRADE_EVENT_FLAG_ORDER_PLASED;
        }
      //--- If the number of market orders increased
      if(this.m_market.NewMarketOrders()>0)
        {
         //--- do not add the event flag
         //--- ...
        }
     }
   
//--- If an event is only in historical orders and deals
   else if(this.m_is_history_trade_event && !this.m_is_market_trade_event)
     {
      //--- If a new deal appeared
      if(this.m_history.NewDeals()>0)
        {
         //--- Add the account balance event flag
         this.m_trade_event_code+=TRADE_EVENT_FLAG_ACCOUNT_BALANCE;
        }
     }
   
//--- If the events are in market and historical orders and positions
   else if(this.m_is_market_trade_event && this.m_is_history_trade_event)
     {
      //--- If the number of pending orders decreased and no new deals appeared
      if(this.m_market.NewPendingOrders()<0 && this.m_history.NewDeals()==0)
        {
         //--- Add the flag for removing a pending order
         this.m_trade_event_code+=TRADE_EVENT_FLAG_ORDER_REMOVED;
        }
      
      //--- If there is a new deal and a new historical order
      if(this.m_history.NewDeals()>0 && this.m_history.NewOrders()>0)
        {
         //--- Take the last deal
         COrder* deal=this.GetLastDeal();
         if(deal!=NULL)
           {
            //--- In case of a market entry deal
            if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_IN)
              {
               //--- Add the position opening flag
               this.m_trade_event_code+=TRADE_EVENT_FLAG_POSITION_OPENED;
               //--- If the number of pending orders decreased
               if(this.m_market.NewPendingOrders()<0)
                 {
                  //--- Add the pending order activation flag
                  this.m_trade_event_code+=TRADE_EVENT_FLAG_ORDER_ACTIVATED;
                 }
               //--- Take the order's ticket from the order
               ulong order_ticket=deal.GetProperty(ORDER_PROP_DEAL_ORDER);
               COrder* order=this.GetHistoryOrder(order_ticket);
               if(order!=NULL)
                 {
                  //--- If the current order volume exceeds zero
                  if(order.VolumeCurrent()>0)
                    {
                     //--- Add the partial execution flag
                     this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
                    }
                 }
              }
            
            //--- In case of a market exit deal
            if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_OUT)
              {
               //--- Add the position closing flag
               this.m_trade_event_code+=TRADE_EVENT_FLAG_POSITION_CLOSED;
               //--- Take the order's ticket from the order
               ulong order_ticket=deal.GetProperty(ORDER_PROP_DEAL_ORDER);
               COrder* order=this.GetHistoryOrder(order_ticket);
               if(order!=NULL)
                 {
                  //--- If the deal's position is still present in the market
                  COrder* pos=this.GetPosition(deal.PositionID());
                  if(pos!=NULL)
                    {
                     //--- Add the partial execution flag
                     this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
                    }
                  //--- Otherwise, if the position is fully closed
                  else
                    {
                     //--- If the order has the flag for closing by StopLoss
                     if(order.IsCloseByStopLoss())
                       {
                        //--- Add the flag for closing by StopLoss
                        this.m_trade_event_code+=TRADE_EVENT_FLAG_SL;
                       }
                     //--- If the order has the flag for closing by TakeProfit
                     if(order.IsCloseByTakeProfit())
                       {
                        //--- Add the the flag for closing by TakeProfit
                        this.m_trade_event_code+=TRADE_EVENT_FLAG_TP;
                       }
                    }
                 }
              }
            
            //--- When closing by an opposite position
            if(deal.GetProperty(ORDER_PROP_DEAL_ENTRY)==DEAL_ENTRY_OUT_BY)
              {
               //--- Add the position closing flag
               this.m_trade_event_code+=TRADE_EVENT_FLAG_POSITION_CLOSED;
               //--- Add the flag for closing by an opposite position
               this.m_trade_event_code+=TRADE_EVENT_FLAG_BY_POS;
               //--- Take the deal order
               ulong ticket_from=deal.GetProperty(ORDER_PROP_DEAL_ORDER);
               COrder* order=this.GetHistoryOrder(ticket_from);
               if(order!=NULL)
                 {
                  //--- If the order position is still present in the market
                  COrder* pos=this.GetPosition(order.PositionID());
                  if(pos!=NULL)
                    {
                     //--- Add the partial execution flag
                     this.m_trade_event_code+=TRADE_EVENT_FLAG_PARTIAL;
                    }
                 }
              }
           //--- end of the last deal processing block
           }
        }
     }
#endif 
   this.SetTradeEvent();
  }
//+------------------------------------------------------------------+
//| Decode the event code and set a trading event                    |
//+------------------------------------------------------------------+
void CEngine::SetTradeEvent(void)
  {
//--- No trading event. Exit
   if(this.m_trade_event_code==TRADE_EVENT_FLAG_NO_EVENT)
      return;
//--- Pending order is set (check if the event code is matched since there can be only one flag here)
   if(this.m_trade_event_code==TRADE_EVENT_FLAG_ORDER_PLASED)
     {
      this.m_acc_trade_event=TRADE_EVENT_PENDING_ORDER_PLASED;
      Print(DFUN,"Code=",this.m_trade_event_code,", m_acc_trade_event=",EnumToString(m_acc_trade_event));
      return;
     }
//--- Pending order is removed (check if the event code is matched since there can be only one flag here)
   if(this.m_trade_event_code==TRADE_EVENT_FLAG_ORDER_REMOVED)
     {
      this.m_acc_trade_event=TRADE_EVENT_PENDING_ORDER_REMOVED;
      Print(DFUN,"Code=",this.m_trade_event_code,", m_acc_trade_event=",EnumToString(m_acc_trade_event));
      return;
     }
//--- Position is opened (Check for multiple flags in the event code)
   if(this.IsTradeEventFlag(TRADE_EVENT_FLAG_POSITION_OPENED))
     {
      //--- If this pending order is activated by the price
      if(this.IsTradeEventFlag(TRADE_EVENT_FLAG_ORDER_ACTIVATED))
        {
         this.m_acc_trade_event=(!this.IsTradeEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_PENDING_ORDER_ACTIVATED : TRADE_EVENT_PENDING_ORDER_ACTIVATED_PARTIAL);
         Print(DFUN,"Code=",this.m_trade_event_code,", m_acc_trade_event=",EnumToString(m_acc_trade_event));
         return;
        }
      this.m_acc_trade_event=(!this.IsTradeEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_OPENED : TRADE_EVENT_POSITION_OPENED_PARTIAL);
      Print(DFUN,"Code=",this.m_trade_event_code,", m_acc_trade_event=",EnumToString(m_acc_trade_event));
      return;
     }
//--- Position is closed (Check for multiple flags in the event code)
   if(this.IsTradeEventFlag(TRADE_EVENT_FLAG_POSITION_CLOSED))
     {
      //--- if the position is closed by StopLoss
      if(this.IsTradeEventFlag(TRADE_EVENT_FLAG_SL))
        {
         //--- check the partial closing flag and set the "Position closed by StopLoss" or "Position closed by StopLoss partially" trading event
         this.m_acc_trade_event=(!this.IsTradeEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED_BY_SL : TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_SL);
         Print(DFUN,"Code=",this.m_trade_event_code,", m_acc_trade_event=",EnumToString(m_acc_trade_event));
         return;
        }
      //--- if the position is closed by TakeProfit
      else if(this.IsTradeEventFlag(TRADE_EVENT_FLAG_TP))
        {
         //--- check the partial closing flag and set the "Position closed by TakeProfit" or "Position closed by TakeProfit partially" trading event
         this.m_acc_trade_event=(!this.IsTradeEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED_BY_TP : TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_TP);
         Print(DFUN,"Code=",this.m_trade_event_code,", m_acc_trade_event=",EnumToString(m_acc_trade_event));
         return;
        }
      //--- if the position is closed by an opposite one
      else if(this.IsTradeEventFlag(TRADE_EVENT_FLAG_BY_POS))
        {
         //--- check the partial closing flag and set the "Position closed by opposite one" or "Position closed by opposite one partially" event
         this.m_acc_trade_event=(!this.IsTradeEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED_BY_POS : TRADE_EVENT_POSITION_CLOSED_PARTIAL_BY_POS);
         Print(DFUN,"Code=",this.m_trade_event_code,", m_acc_trade_event=",EnumToString(m_acc_trade_event));
         return;
        }
      //--- If the position is closed
      else
        {
         //--- check the partial closing flag and set the "Position closed" or "Position closed partially" event
         this.m_acc_trade_event=(!this.IsTradeEventFlag(TRADE_EVENT_FLAG_PARTIAL) ? TRADE_EVENT_POSITION_CLOSED : TRADE_EVENT_POSITION_CLOSED_PARTIAL);
         Print(DFUN,"Code=",this.m_trade_event_code,", m_acc_trade_event=",EnumToString(m_acc_trade_event));
         return;
        }
     }
//--- Balance operation on the account (clarify the event by the deal type)
   if(this.m_trade_event_code==TRADE_EVENT_FLAG_ACCOUNT_BALANCE)
     {
      //--- Initialize the trading event
      this.m_acc_trade_event=TRADE_EVENT_NO_EVENT;
      //--- Take the last deal
      COrder* deal=this.GetLastDeal();
      if(deal!=NULL)
        {
         ENUM_DEAL_TYPE deal_type=(ENUM_DEAL_TYPE)deal.GetProperty(ORDER_PROP_TYPE);
         //--- if the deal is a balance operation
         if(deal_type==DEAL_TYPE_BALANCE)
           {
           //--- check the deal profit and set the event (funds deposit or withdrawal)
            this.m_acc_trade_event=(deal.Profit()>0 ? TRADE_EVENT_ACCOUNT_BALANCE_REFILL : TRADE_EVENT_ACCOUNT_BALANCE_WITHDRAWAL);
           }
         //--- Remaining balance operation types match the ENUM_DEAL_TYPE enumeration starting with DEAL_TYPE_CREDIT
         else if(deal_type>DEAL_TYPE_BALANCE)
           {
           //--- set the event
            this.m_acc_trade_event=(ENUM_TRADE_EVENT)deal_type;
           }
        }
      Print(DFUN,"Code=",this.m_trade_event_code,", m_acc_trade_event=",EnumToString(m_acc_trade_event));
      return;
     }
  }
//+------------------------------------------------------------------+
