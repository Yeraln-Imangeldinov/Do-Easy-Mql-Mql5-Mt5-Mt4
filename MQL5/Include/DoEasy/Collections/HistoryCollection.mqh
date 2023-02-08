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
#include <Arrays\ArrayObj.mqh>
#include "..\DELib.mqh"
#include "..\Objects\HistoryOrder.mqh"
#include "..\Objects\HistoryPending.mqh"
#include "..\Objects\HistoryDeal.mqh"
//+------------------------------------------------------------------+
//| Collection of historical orders and deals                        |
//+------------------------------------------------------------------+
class CHistoryCollection
  {
private:
   CArrayObj         m_list_all_orders;      // List of all historical orders and deals
   CArrayObj         m_list_of_events;       // Event queue list
   COrder            m_order_instance;       // Order object for searching by property
   bool              m_is_trade_event;       // Trading event flag
   int               m_index_order;          // Index of the last order added to the collection from the terminal history list (MQL4, MQL5)
   int               m_index_deal;           // Index of the last deal added to the collection from the terminal history list (MQL5)
   int               m_delta_order;          // Difference in the number of orders compared to the previous check
   int               m_delta_deal;           // Difference in the number of deals compared to the previous check
public:
   //--- Return the full collection list 'as is'
   CArrayObj        *GetList(void)                                                                       { return &this.m_list_all_orders;                                       }
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
   this.m_list_all_orders.Sort(SORT_BY_ORDER_TIME_CLOSE);
   this.m_list_of_events.Sort();
  }
//+------------------------------------------------------------------+
//| Update the list of orders                                        |
//+------------------------------------------------------------------+
void CHistoryCollection::Refresh(void)
  {
#ifdef __MQL4__
   int total=::OrdersHistoryTotal(),i=m_index_order;
   for(; i<total; i++)
     {
      if(!::OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      ENUM_ORDER_TYPE order_type=(ENUM_ORDER_TYPE)::OrderType();
      //--- Closed positions and balance/credit operations
      if(order_type<ORDER_TYPE_BUY_LIMIT || order_type>ORDER_TYPE_SELL_STOP)
        {
         CHistoryOrder *order=new CHistoryOrder(::OrderTicket());
         if(order==NULL) continue;
         if(!this.m_list_all_orders.InsertSort(order))
           {
            ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Failed to add order to list"));
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
            ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Failed to add order to list"));
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
      if(type==ORDER_TYPE_BUY || type==ORDER_TYPE_SELL)
        {
         CHistoryOrder *order=new CHistoryOrder(order_ticket);
         if(order==NULL) continue;
         if(!this.m_list_all_orders.InsertSort(order))
           {
            ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Failed to add order to list"));
            delete order;
           }
        }
      else
        {
         CHistoryPending *order=new CHistoryPending(order_ticket);
         if(order==NULL) continue;
         if(!this.m_list_all_orders.InsertSort(order))
           {
            ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Failed to add order to list"));
            delete order;
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
      this.m_list_all_orders.InsertSort(deal);
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
