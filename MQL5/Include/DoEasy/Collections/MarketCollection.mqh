//+------------------------------------------------------------------+
//|                                             MarketCollection.mqh |
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
#include "..\Objects\Orders\MarketOrder.mqh"
#include "..\Objects\Orders\MarketPending.mqh"
#include "..\Objects\Orders\MarketPosition.mqh"
//+------------------------------------------------------------------+
//| Collection of market orders and positions                        |
//+------------------------------------------------------------------+
class CMarketCollection : public CListObj
  {
private:
   struct MqlDataCollection
     {
      long           hash_sum_acc;           // Hash sum of all orders and positions on the account
      int            total_market;           // Number of market orders on the account
      int            total_pending;          // Number of pending orders on the account
      int            total_positions;        // Number of positions on the account
      double         total_volumes;          // Total volume of orders and positions on the account
     };
   MqlDataCollection m_struct_curr_market;   // Current data on market orders and positions on the account
   MqlDataCollection m_struct_prev_market;   // Previous data on market orders and positions on the account
   CListObj          m_list_all_orders;      // List of pending orders and positions on the account
   COrder            m_order_instance;       // Order object for searching by property
   bool              m_is_trade_event;       // Trading event flag
   bool              m_is_change_volume;     // Total volume change flag
   double            m_change_volume_value;  // Total volume change value
   int               m_new_market_orders;    // Number of new market orders
   int               m_new_positions;        // Number of new positions
   int               m_new_pendings;         // Number of new pending orders
   //--- Save the current values of the account data status as previous ones
   void              SavePrevValues(void)                                                                { this.m_struct_prev_market=this.m_struct_curr_market;                  }
public:
   //--- Return the list of all pending orders and open positions
   CArrayObj*        GetList(void)                                                                       { return &m_list_all_orders;                                            }
   //--- Return the list of orders and positions with an open time from begin_time to end_time
   CArrayObj*        GetListByTime(const datetime begin_time=0,const datetime end_time=0);
   //--- Return the list of orders and positions by selected (1) double, (2) integer and (3) string property fitting a compared condition
   CArrayObj*        GetList(ENUM_ORDER_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode=EQUAL) { return CSelect::ByOrderProperty(this.GetList(),property,value,mode);  }
   CArrayObj*        GetList(ENUM_ORDER_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode=EQUAL)  { return CSelect::ByOrderProperty(this.GetList(),property,value,mode);  }
   CArrayObj*        GetList(ENUM_ORDER_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode=EQUAL) { return CSelect::ByOrderProperty(this.GetList(),property,value,mode);  }
   //--- Return the number of (1) new market orders, (2) new pending orders, (3) new positions, (4) occurred trading event flag and (5) changed volume
   int               NewMarketOrders(void)                                                         const { return this.m_new_market_orders;                                      }
   int               NewPendingOrders(void)                                                        const { return this.m_new_pendings;                                           }
   int               NewPositions(void)                                                            const { return this.m_new_positions;                                          }
   bool              IsTradeEvent(void)                                                            const { return this.m_is_trade_event;                                         }
   double            ChangedVolumeValue(void)                                                      const { return this.m_change_volume_value;                                    }
   //--- Constructor
                     CMarketCollection(void);
   //--- Update the list of pending orders and positions
   void              Refresh(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMarketCollection::CMarketCollection(void) : m_is_trade_event(false),m_is_change_volume(false),m_change_volume_value(0)
  {
   this.m_list_all_orders.Sort(SORT_BY_ORDER_TIME_OPEN);
   this.m_list_all_orders.Clear();
   ::ZeroMemory(this.m_struct_prev_market);
   this.m_struct_prev_market.hash_sum_acc=WRONG_VALUE;
   this.m_list_all_orders.Type(COLLECTION_MARKET_ID);
  }
//+------------------------------------------------------------------+
//| Update the list of orders                                        |
//+------------------------------------------------------------------+
void CMarketCollection::Refresh(void)
  {
   ::ZeroMemory(this.m_struct_curr_market);
   this.m_is_trade_event=false;
   this.m_is_change_volume=false;
   this.m_new_pendings=0;
   this.m_new_positions=0;
   this.m_change_volume_value=0;
   m_list_all_orders.Clear();
#ifdef __MQL4__
   int total=::OrdersTotal();
   for(int i=0; i<total; i++)
     {
      if(!::OrderSelect(i,SELECT_BY_POS)) continue;
      long ticket=::OrderTicket();
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::OrderType();
      if(type==ORDER_TYPE_BUY || type==ORDER_TYPE_SELL)
        {
         CMarketPosition *position=new CMarketPosition(ticket);
         if(position==NULL) continue;
         if(this.m_list_all_orders.InsertSort(position))
           {
            this.m_struct_market.hash_sum_acc+=ticket;
            this.m_struct_market.total_volumes+=::OrderLots();
            this.m_struct_market.total_positions++;
           }
         else
           {
            ::Print(DFUN,TextByLanguage("Не удалось добавить позицию в список","Failed to add position to list"));
            delete position;
           }
        }
      else
        {
         CMarketPending *order=new CMarketPending(ticket);
         if(order==NULL) continue;
         if(this.m_list_all_orders.InsertSort(order))
           {
            this.m_struct_market.hash_sum_acc+=ticket;
            this.m_struct_market.total_volumes+=::OrderLots();
            this.m_struct_market.total_pending++;
           }
         else
           {
            ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Failed to add order to list"));
            delete order;
           }
        }
     }
//--- MQ5
#else 
//--- Positions
   int total_positions=::PositionsTotal();
   for(int i=0; i<total_positions; i++)
     {
      ulong ticket=::PositionGetTicket(i);
      if(ticket==0) continue;
      CMarketPosition *position=new CMarketPosition(ticket);
      if(position==NULL) continue;
      if(this.m_list_all_orders.InsertSort(position))
        {
         this.m_struct_curr_market.hash_sum_acc+=(long)::PositionGetInteger(POSITION_TIME_UPDATE_MSC);
         this.m_struct_curr_market.total_volumes+=::PositionGetDouble(POSITION_VOLUME);
         this.m_struct_curr_market.total_positions++;
        }
      else
        {
         ::Print(DFUN,TextByLanguage("Не удалось добавить позицию в список","Failed to add position to list"));
         delete position;
        }
     }
//--- Orders
   int total_orders=::OrdersTotal();
   for(int i=0; i<total_orders; i++)
     {
      ulong ticket=::OrderGetTicket(i);
      if(ticket==0) continue;
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::OrderGetInteger(ORDER_TYPE);
      if(type==ORDER_TYPE_BUY || type==ORDER_TYPE_SELL)
        {
         CMarketOrder *order=new CMarketOrder(ticket);
         if(order==NULL) continue;
         if(this.m_list_all_orders.InsertSort(order))
           {
            this.m_struct_curr_market.hash_sum_acc+=(long)ticket;
            this.m_struct_curr_market.total_market++;
           }
         else
           {
            ::Print(DFUN,TextByLanguage("Не удалось добавить маркет-ордер в список","Failed to add market order to the list"));
            delete order;
           }
        }
      else
        {
         CMarketPending *order=new CMarketPending(ticket);
         if(order==NULL) continue;
         if(this.m_list_all_orders.InsertSort(order))
           {
            this.m_struct_curr_market.hash_sum_acc+=(long)ticket;
            this.m_struct_curr_market.total_volumes+=::OrderGetDouble(ORDER_VOLUME_INITIAL);
            this.m_struct_curr_market.total_pending++;
           }
         else
           {
            ::Print(DFUN,TextByLanguage("Не удалось добавить отложенный ордер в список","Failed to add pending order to list"));
            delete order;
           }
        }
     }
#endif 
//--- First launch
   if(this.m_struct_prev_market.hash_sum_acc==WRONG_VALUE)
     {
      this.SavePrevValues();
     }
//--- If the hash sum of all orders and positions changed
   if(this.m_struct_curr_market.hash_sum_acc!=this.m_struct_prev_market.hash_sum_acc)
     {
      this.m_new_market_orders=this.m_struct_curr_market.total_market-this.m_struct_prev_market.total_market;
      this.m_new_pendings=this.m_struct_curr_market.total_pending-this.m_struct_prev_market.total_pending;
      this.m_new_positions=this.m_struct_curr_market.total_positions-this.m_struct_prev_market.total_positions;
      this.m_change_volume_value=::NormalizeDouble(this.m_struct_curr_market.total_volumes-this.m_struct_prev_market.total_volumes,4);
      this.m_is_change_volume=(this.m_change_volume_value!=0 ? true : false);
      this.m_is_trade_event=true;
      this.SavePrevValues();
     }
  }
//+------------------------------------------------------------------------+
//| Select market orders or positions from the collection with the time    |
//| from begin_time to end_time                                            |
//+------------------------------------------------------------------------+
CArrayObj* CMarketCollection::GetListByTime(const datetime begin_time=0,const datetime end_time=0)
  {
   CArrayObj* list=new CArrayObj();
   if(list==NULL)
     {
      ::Print(DFUN,TextByLanguage("Ошибка создания временного списка","Error creating temporary list"));
      return NULL;
     }
   datetime begin=begin_time,end=(end_time==0 ? END_TIME : end_time);
   list.FreeMode(false);
   ListStorage.Add(list);
   m_order_instance.SetProperty(ORDER_PROP_TIME_OPEN,begin);
   int index_begin=m_list_all_orders.SearchGreatOrEqual(&m_order_instance);
   if(index_begin==WRONG_VALUE)
      return list;
   m_order_instance.SetProperty(ORDER_PROP_TIME_OPEN,end);
   int index_end=m_list_all_orders.SearchLessOrEqual(&m_order_instance);
   if(index_end==WRONG_VALUE)
      return list;
   for(int i=index_begin; i<=index_end; i++)
      list.Add(m_list_all_orders.At(i));
   return list;
  }
//+------------------------------------------------------------------+
