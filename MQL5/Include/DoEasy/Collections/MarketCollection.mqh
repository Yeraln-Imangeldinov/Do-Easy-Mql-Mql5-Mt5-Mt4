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
#include <Arrays\ArrayObj.mqh>
#include "Select.mqh"
#include "..\Objects\MarketPending.mqh"
#include "..\Objects\MarketPosition.mqh"
//+------------------------------------------------------------------+
//| Collection of market orders and positions                        |
//+------------------------------------------------------------------+
class CMarketCollection
  {
private:
   struct MqlDataCollection
     {
      long           hash_sum_acc;           // Hash sum of all orders and positions on the account
      int            total_pending;          // Number of pending orders on the account
      int            total_positions;        // Number of positions on the account
      double         total_volumes;          // Total volume of orders and positions on the account
     };
   MqlDataCollection m_struct_curr_market;   // Current data on market orders and positions on the account
   MqlDataCollection m_struct_prev_market;   // Previous data on market orders and positions on the account
   CArrayObj         m_list_all_orders;      // List of pending orders and positions on the account
   bool              m_is_trade_event;       // Trading event flag
   bool              m_is_change_volume;     // Total volume change flag
   double            m_change_volume_value;  // Total volume change value
   int               m_new_positions;        // Number of new positions
   int               m_new_pendings;         // Number of new pending orders
   //--- Save the current values of the account data status as previous ones
   void              SavePrevValues(void)             { this.m_struct_prev_market=this.m_struct_curr_market;   }
public:
   //--- Return the number of (1) new pending orders, (2) new positions, (3) occurred trading event flag
   int               NewOrders(void)    const         { return this.m_new_pendings;                            }
   int               NewPosition(void)  const         { return this.m_new_positions;                           }
   bool              IsTradeEvent(void) const         { return this.m_is_trade_event;                          }
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
   m_list_all_orders.Sort(SORT_BY_ORDER_TIME_OPEN);
   ::ZeroMemory(this.m_struct_prev_market);
   this.m_struct_prev_market.hash_sum_acc=WRONG_VALUE;
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
         ::Print(DFUN,TextByLanguage("Не удалось добавить ордер в список","Failed to add order to list"));
         delete order;
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
      this.m_new_pendings=this.m_struct_curr_market.total_pending-this.m_struct_prev_market.total_pending;
      this.m_new_positions=this.m_struct_curr_market.total_positions-this.m_struct_prev_market.total_positions;
      this.m_change_volume_value=::NormalizeDouble(this.m_struct_curr_market.total_volumes-this.m_struct_prev_market.total_volumes,4);
      this.m_is_change_volume=(this.m_change_volume_value!=0 ? true : false);
      this.m_is_trade_event=true;
      this.SavePrevValues();
     }
  }
//+------------------------------------------------------------------+
