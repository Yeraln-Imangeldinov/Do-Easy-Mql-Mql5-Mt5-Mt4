//+------------------------------------------------------------------+
//|                                            HistoryCollection.mqh |
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
#include "..\Objects\Orders\HistoryOrder.mqh"
#include "..\Objects\Orders\HistoryPending.mqh"
#include "..\Objects\Orders\HistoryDeal.mqh"
#ifdef __MQL4__
#include "..\Objects\Orders\HistoryBalance.mqh"
#endif 
//+------------------------------------------------------------------+
//| Collection of historical orders and deals                        |
//+------------------------------------------------------------------+
class CHistoryCollection : public CListObj
  {
private:
   CListObj          m_list_all_orders;      // List of all historical orders and deals
   COrder            m_order_instance;       // Order object for searching by property
   bool              m_is_trade_event;       // Trading event flag
   int               m_index_order;          // Index of the last order added to the collection from the terminal history list (MQL4, MQL5)
   int               m_index_deal;           // Index of the last deal added to the collection from the terminal history list (MQL5)
   int               m_delta_order;          // Difference in the number of orders compared to the previous check
   int               m_delta_deal;           // Difference in the number of deals compared to the previous check
//--- Return the flag of the order object by its type and ticket in the list of historical orders and deals
   bool              IsPresentOrderInList(const ulong order_ticket,const ENUM_ORDER_TYPE type);
//--- Return the "lost" order type and ticket
   ulong             OrderSearch(const int start,ENUM_ORDER_TYPE &order_type);
//--- Create the order object and place it to the list
   bool              CreateNewOrder(const ulong order_ticket,const ENUM_ORDER_TYPE order_type);
public:
   //--- Select orders from the collection with time from begin_time to end_time
   CArrayObj        *GetListByTime(const datetime begin_time=0,const datetime end_time=0,
                                   const ENUM_SELECT_BY_TIME select_time_mode=SELECT_BY_TIME_CLOSE);
   //--- Return the full collection list 'as is'
   CArrayObj        *GetList(void)                                                                       { return &this.m_list_all_orders;                                       }
   //--- Return the list by selected (1) integer, (2) real and (3) string properties meeting the compared criterion
   CArrayObj        *GetList(ENUM_ORDER_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode=EQUAL)  { return CSelect::ByOrderProperty(this.GetList(),property,value,mode);  }
   CArrayObj        *GetList(ENUM_ORDER_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode=EQUAL) { return CSelect::ByOrderProperty(this.GetList(),property,value,mode);  }
   CArrayObj        *GetList(ENUM_ORDER_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode=EQUAL) { return CSelect::ByOrderProperty(this.GetList(),property,value,mode);  }
   //--- Return the number of (1) new orders, (2) new deals, (3) occurred trading event flag
   int               NewOrders(void)    const                                                            { return this.m_delta_order;     }
   int               NewDeals(void)     const                                                            { return this.m_delta_deal;      }
   bool              IsTradeEvent(void) const                                                            { return this.m_is_trade_event;  }
   //--- Constructor
                     CHistoryCollection();
   //--- Update the list of orders, fill in data on the number of new ones and set the trading event flag
   void              Refresh(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CHistoryCollection::CHistoryCollection(void) : m_index_deal(0),m_delta_deal(0),m_index_order(0),m_delta_order(0),m_is_trade_event(false)
  {
   this.m_list_all_orders.Sort(#ifdef __MQL5__ SORT_BY_ORDER_TIME_OPEN #else SORT_BY_ORDER_TIME_CLOSE #endif );
   this.m_list_all_orders.Clear();
   this.m_list_all_orders.Type(COLLECTION_HISTORY_ID);
  }
//+------------------------------------------------------------------+
//| Update the list of orders and deals                              |
//+------------------------------------------------------------------+
void CHistoryCollection::Refresh(void)
  {
#ifdef __MQL4__
   int total=::OrdersHistoryTotal(),i=m_index_order;
   for(; i<total; i++)
     {
      if(!::OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      ENUM_ORDER_TYPE order_type=(ENUM_ORDER_TYPE)::OrderType();
      //--- Закрытые позиции
      if(order_type<ORDER_TYPE_BUY_LIMIT)
        {
         CHistoryOrder *order=new CHistoryOrder(::OrderTicket());
         if(order==NULL) continue;
         if(!this.m_list_all_orders.InsertSort(order))
           {
            ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Could not add order to list"));
            delete order;
           }
        }
      //--- Balance/credit operations
      else if(order_type>ORDER_TYPE_SELL_STOP)
        {
         CHistoryBalance *order=new CHistoryBalance(::OrderTicket());
         if(order==NULL) continue;
         if(!this.m_list_all_orders.InsertSort(order))
           {
            ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Could not add order to list"));
            delete order;
           }
        }
      else
        {
         //--- Removed pending orders
         CHistoryPending *order=new CHistoryPending(::OrderTicket());
         if(order==NULL) continue;
         if(!this.m_list_all_orders.InsertSort(order))
           {
            ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Could not add order to list"));
            delete order;
           }
        }
     }
//---
   int delta_order=i-m_index_order;
   this.m_index_order=i;
   this.m_delta_order=delta_order;
   this.m_is_trade_event=(this.m_delta_order!=0 ? true : false);
//--- __MQL5__
#else 
   if(!::HistorySelect(0,END_TIME)) return;
//--- Orders
   int total_orders=::HistoryOrdersTotal(),i=m_index_order;
   for(; i<total_orders; i++)
     {
      ulong order_ticket=::HistoryOrderGetTicket(i);
      if(order_ticket==0) continue;
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::HistoryOrderGetInteger(order_ticket,ORDER_TYPE);
      if(type==ORDER_TYPE_BUY || type==ORDER_TYPE_SELL || type==ORDER_TYPE_CLOSE_BY)
        {
         //--- If there is no order of this type and with this ticket in the list, create an order object and add it to the list
         if(!this.IsPresentOrderInList(order_ticket,type))
           {
            if(!this.CreateNewOrder(order_ticket,type))
               ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Could not add order to list"));
           }
         //--- Such an order is already present in the list, which means the necessary order is not the last one in the history list. Let's find it
         else
           {
            ENUM_ORDER_TYPE type_lost=WRONG_VALUE;
            ulong ticket_lost=this.OrderSearch(i,type_lost);
            if(ticket_lost>0 && !this.CreateNewOrder(ticket_lost,type_lost))
               ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Could not add order to list"));
           }
        }
      else
        {
         //--- If there is no pending order of this type and with this ticket in the list, create an order object and add it to the list
         if(!this.IsPresentOrderInList(order_ticket,type))
           {
            if(!this.CreateNewOrder(order_ticket,type))
               ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Could not add order to list"));
           }
         //--- Such an order is already present in the list, which means the necessary order is not the last one in the history list. Let's find it
         else
           {
            ENUM_ORDER_TYPE type_lost=WRONG_VALUE;
            ulong ticket_lost=this.OrderSearch(i,type_lost);
            if(ticket_lost>0 && !this.CreateNewOrder(ticket_lost,type_lost))
               ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Could not add order to list"));
           }
        }
     }
//--- save the index of the last added order and the difference with the last check
   int delta_order=i-this.m_index_order;
   this.m_index_order=i;
   this.m_delta_order=delta_order;

//--- Deals
   int total_deals=::HistoryDealsTotal(),j=m_index_deal;
   for(; j<total_deals; j++)
     {
      ulong deal_ticket=::HistoryDealGetTicket(j);
      if(deal_ticket==0) continue;
      CHistoryDeal *deal=new CHistoryDeal(deal_ticket);
      if(deal==NULL) continue;
      if(!this.m_list_all_orders.InsertSort(deal))
        {
         ::Print(DFUN,TextByLanguage("Не удалось добавить сделку в список","Could not add deal to list"));
         delete deal;
        }
     }
//--- save the index of the last added deal and the difference with the last check
   int delta_deal=j-this.m_index_deal;
   this.m_index_deal=j;
   this.m_delta_deal=delta_deal;
//--- Set the new event flag in history
   this.m_is_trade_event=(this.m_delta_order+this.m_delta_deal);
#endif 
  }
//+------------------------------------------------------------------+
//| Select orders from the collection with time                      |
//| from begin_time to end_time                                      |
//+------------------------------------------------------------------+
CArrayObj *CHistoryCollection::GetListByTime(const datetime begin_time=0,const datetime end_time=0,
                                             const ENUM_SELECT_BY_TIME select_time_mode=SELECT_BY_TIME_CLOSE)
  {
   ENUM_ORDER_PROP_INTEGER property=
     (
      select_time_mode==SELECT_BY_TIME_CLOSE       ?  ORDER_PROP_TIME_CLOSE      : 
      select_time_mode==SELECT_BY_TIME_OPEN        ?  ORDER_PROP_TIME_OPEN       :
      select_time_mode==SELECT_BY_TIME_CLOSE_MSC   ?  ORDER_PROP_TIME_CLOSE_MSC  : 
      ORDER_PROP_TIME_OPEN_MSC
     );

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
   this.m_order_instance.SetProperty(property,begin);
   int index_begin=this.m_list_all_orders.SearchGreatOrEqual(&m_order_instance);
   if(index_begin==WRONG_VALUE)
      return list;
   this.m_order_instance.SetProperty(property,end);
   int index_end=this.m_list_all_orders.SearchLessOrEqual(&m_order_instance);
   if(index_end==WRONG_VALUE)
      return list;
   for(int i=index_begin; i<=index_end; i++)
      list.Add(this.m_list_all_orders.At(i));
   return list;
  }
//+-----------------------------------------------------------------------------+
//| Return the flag of the order object presence in the list by type and ticket |
//+-----------------------------------------------------------------------------+
bool CHistoryCollection::IsPresentOrderInList(const ulong order_ticket,const ENUM_ORDER_TYPE type)
  {
   CArrayObj* list=dynamic_cast<CListObj*>(&this.m_list_all_orders);
   list=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,type,EQUAL);
   list=CSelect::ByOrderProperty(list,ORDER_PROP_TICKET,order_ticket,EQUAL);
   return(list.Total()>0);
  }
//+------------------------------------------------------------------+
//| Return the "lost" order type and ticket                          |
//+------------------------------------------------------------------+
ulong CHistoryCollection::OrderSearch(const int start,ENUM_ORDER_TYPE &order_type)
  {
   ulong order_ticket=0;
#ifdef __MQL5__
   for(int i=start-1;i>=0;i--)
     {
      ulong ticket=::HistoryOrderGetTicket(i);
      if(ticket==0)
         continue;
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::HistoryOrderGetInteger(ticket,ORDER_TYPE);
      if(this.IsPresentOrderInList(ticket,type))
         continue;
      order_ticket=ticket;
      order_type=type;
     }
#else 
   for(int i=start-1;i>=0;i--)
     {
      if(!::OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         continue;
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::OrderType();
      ulong ticket=::OrderTicket();
      if(ticket==0 || type<ORDER_TYPE_BUY_LIMIT || type>ORDER_TYPE_SELL_STOP)
         continue;
      if(this.IsPresentOrderInList(ticket,type))
         continue;
      order_ticket=ticket;
      order_type=type;
     }
#endif    
   return order_ticket;
  }
//+------------------------------------------------------------------+
//| Create the order object and place it to the list                 |
//+------------------------------------------------------------------+
bool CHistoryCollection::CreateNewOrder(const ulong order_ticket,const ENUM_ORDER_TYPE order_type)
  {
   COrder* order=NULL;
   if(order_type==ORDER_TYPE_BUY)
     {
      order=new CHistoryOrder(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_BUY_LIMIT)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_BUY_STOP)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_SELL)
     {
      order=new CHistoryOrder(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_SELL_LIMIT)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_SELL_STOP)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
#ifdef __MQL5__
   else if(order_type==ORDER_TYPE_BUY_STOP_LIMIT)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_SELL_STOP_LIMIT)
     {
      order=new CHistoryPending(order_ticket);
      if(order==NULL)
         return false;
     }
   else if(order_type==ORDER_TYPE_CLOSE_BY)
     {
      order=new CHistoryOrder(order_ticket);
      if(order==NULL)
         return false;
     }
#endif 
   if(this.m_list_all_orders.InsertSort(order))
      return true;
   else
     {
      delete order;
      return false;
     }
   return false;
  }
//+------------------------------------------------------------------+
