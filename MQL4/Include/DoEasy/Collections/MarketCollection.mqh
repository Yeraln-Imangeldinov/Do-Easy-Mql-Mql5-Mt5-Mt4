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
#include "OrderControl.mqh"
//+------------------------------------------------------------------+
//| Collection of market orders and positions                        |
//+------------------------------------------------------------------+
class CMarketCollection : public CListObj
  {
private:
   struct MqlDataCollection
     {
      ulong          hash_sum_acc;           // Hash sum of all orders and positions on the account
      int            total_market;           // Number of market orders on the account
      int            total_pending;          // Number of pending orders on the account
      int            total_positions;        // Number of positions on the account
      double         total_volumes;          // Total volume of orders and positions on the account
     };
   MqlDataCollection m_struct_curr_market;   // Current data on market orders and positions on the account
   MqlDataCollection m_struct_prev_market;   // Previous data on market orders and positions on the account
   CListObj          m_list_all_orders;      // List of pending orders and positions on the account
   CArrayObj         m_list_control;         // List of control orders
   CArrayObj         m_list_changed;         // List of changed orders
   COrder            m_order_instance;       // Order object for searching by property
   ENUM_CHANGE_TYPE  m_change_type;          // Order change type
   bool              m_is_trade_event;       // Trading event flag
   bool              m_is_change_volume;     // Total volume change flag
   double            m_change_volume_value;  // Total volume change value
   ulong             m_k_pow;                // Ratio for converting the price into a hash sum
   int               m_new_market_orders;    // Number of new market orders
   int               m_new_positions;        // Number of new positions
   int               m_new_pendings;         // Number of new pending orders
//--- Save the current values of the account data status as previous ones
   void              SavePrevValues(void)                                                                { this.m_struct_prev_market=this.m_struct_curr_market;                  }
//--- Convert order data into a hash sum value
   ulong             ConvertToHS(COrder* order) const;
//--- Add an order or a position to the list of pending orders and positions on an account and sets the data on market orders and positions on the account
   bool              AddToListMarket(COrder* order);
//--- (1) Create and add a control order to the list of control orders, (2) a control order to the list of changed control orders
   bool              AddToListControl(COrder* order);
   bool              AddToListChanges(COrderControl* order_control);
//--- Remove an order by a ticket or a position ID from the list of control orders
   bool              DeleteOrderFromListControl(const ulong ticket,const ulong id);
//--- Return the control order index in the list by a position ticket and ID
   int               IndexControlOrder(const ulong ticket,const ulong id);
//--- The handler of an existing order/position change event
   void              OnChangeEvent(COrder* order,const int index);
public:
//--- Return the list of (1) all pending orders and open positions, (2) modified orders and positions
   CArrayObj*        GetList(void)                                                                       { return &this.m_list_all_orders;                                       }
   CArrayObj*        GetListChanges(void)                                                                { return &this.m_list_changed;                                          }
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
   this.m_list_control.Clear();
   this.m_list_control.Sort();
   this.m_list_changed.Clear();
   this.m_list_changed.Sort();
   this.m_k_pow=(ulong)pow(10,6);
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
   this.m_list_all_orders.Clear();
#ifdef __MQL4__
   int total=::OrdersTotal();
   for(int i=0; i<total; i++)
     {
      if(!::OrderSelect(i,SELECT_BY_POS)) continue;
      long ticket=::OrderTicket();
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::OrderType();
      //--- Position
      if(type==ORDER_TYPE_BUY || type==ORDER_TYPE_SELL)
        {
         CMarketPosition *position=new CMarketPosition(ticket);
         if(position==NULL) continue;
         //--- Get the control order index by a position ticket and ID
         int index=this.IndexControlOrder(ticket,position.PositionID());
         //--- Add a position object to the list of market orders and positions
         if(!this.AddToListMarket(position))
            continue;
         //--- If there is no order in the list of control orders and positions, add it
         if(index==WRONG_VALUE)
           {
            if(!this.AddToListControl(position))
              {
               ::Print(DFUN_ERR_LINE,TextByLanguage("Не удалось добавить контрольный ордер ","Failed to add a control order "),position.TypeDescription()," #",position.Ticket());
              }
           }
         //--- If the order is already present in the list of control orders, check it for changed properties
         if(index>WRONG_VALUE)
           {
            this.OnChangeEvent(position,index);
           }
        }
      //--- Pending order
      else
        {
         CMarketPending *order=new CMarketPending(ticket);
         if(order==NULL) continue;
         //--- Get the control order index by a position ticket and ID
         int index=this.IndexControlOrder(ticket,order.PositionID());
         //--- Add a pending order object to the list of market orders and positions
         if(!this.AddToListMarket(order))
            continue;
         //--- If there is no order in the list of control orders and positions, add it
         if(index==WRONG_VALUE)
           {
            if(!this.AddToListControl(order))
              {
               ::Print(DFUN_ERR_LINE,TextByLanguage("Не удалось добавить контрольный ордер ","Failed to add control order "),order.TypeDescription()," #",order.Ticket());
              }
           }
         //--- If the order is already present in the list of control orders, check it for changed properties
         if(index>WRONG_VALUE)
           {
            this.OnChangeEvent(order,index);
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
      //--- Add a position object to the list of market orders and positions
      if(!this.AddToListMarket(position))
         continue;
      //--- Get the control order index by a position ticket and ID
      int index=this.IndexControlOrder(ticket,position.PositionID());
      //--- If there is no order in the list of control orders, add it
      if(index==WRONG_VALUE)
        {
         if(!this.AddToListControl(position))
           {
            ::Print(DFUN_ERR_LINE,TextByLanguage("Не удалось добавить контрольую позицию ","Failed to add control position "),position.TypeDescription()," #",position.Ticket());
           }
        }
      //--- If the order is already present in the list of control orders, check it for changed properties
      else if(index>WRONG_VALUE)
        {
         this.OnChangeEvent(position,index);
        }
     }
//--- Orders
   int total_orders=::OrdersTotal();
   for(int i=0; i<total_orders; i++)
     {
      ulong ticket=::OrderGetTicket(i);
      if(ticket==0) continue;
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)::OrderGetInteger(ORDER_TYPE);
      //--- Market order
      if(type<ORDER_TYPE_BUY_LIMIT)
        {
         CMarketOrder *order=new CMarketOrder(ticket);
         if(order==NULL) continue;
         //--- Add a market order object to the list of market orders and positions
         if(!this.AddToListMarket(order))
            continue;
        }
      //--- Pending order
      else
        {
         CMarketPending *order=new CMarketPending(ticket);
         if(order==NULL) continue;
         //--- Add a pending order object to the list of market orders and positions
         if(!this.AddToListMarket(order))
            continue;
         //--- Get the control order index by a position ticket and ID
         int index=this.IndexControlOrder(ticket,order.PositionID());
         //--- If there is no order in the list of control orders, add it
         if(index==WRONG_VALUE)
           {
            if(!this.AddToListControl(order))
              {
               ::Print(DFUN_ERR_LINE,TextByLanguage("Не удалось добавить контрольный ордер ","Failed to add control order "),order.TypeDescription()," #",order.Ticket());
              }
           }
         //--- If the order is already present in the list of control orders, check it for changed properties
         else if(index>WRONG_VALUE)
           {
            this.OnChangeEvent(order,index);
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
//+------------------------------------------------------------------+
//| The handler of an existing order/position change event           |
//+------------------------------------------------------------------+
void CMarketCollection::OnChangeEvent(COrder* order,const int index)
  {
   COrderControl* order_control=this.m_list_control.At(index);
   if(order_control!=NULL)
     {
      this.m_change_type=order_control.ChangeControl(order);
      ENUM_CHANGE_TYPE change_type=(order.Status()==ORDER_STATUS_MARKET_POSITION ? CHANGE_TYPE_ORDER_TAKE_PROFIT : CHANGE_TYPE_NO_CHANGE);
      if(this.m_change_type>change_type)
        {
         order_control.SetNewState(order);
         if(!this.AddToListChanges(order_control))
           {
            ::Print(DFUN,TextByLanguage("Не удалось добавить модифицированный ордер в список изменённых ордеров","Could not add modified order to list of modified orders"));
           }
        }
     }
  }
//+----------------------------------------------------------------------+
//| Select market orders or positions from the collection with the time  |
//| from begin_time to end_time                                          |
//+----------------------------------------------------------------------+
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
//+--------------------------------------------------------------------------------+
//| Add an order or a position to the list of orders and positions on the account  |
//+--------------------------------------------------------------------------------+
bool CMarketCollection::AddToListMarket(COrder *order)
  {
   if(order==NULL)
      return false;
   ENUM_ORDER_STATUS status=order.Status();
   if(this.m_list_all_orders.InsertSort(order))
     {
      if(status==ORDER_STATUS_MARKET_POSITION)
        {
         this.m_struct_curr_market.hash_sum_acc+=order.GetProperty(ORDER_PROP_TIME_UPDATE_MSC)+this.ConvertToHS(order);
         this.m_struct_curr_market.total_volumes+=order.Volume();
         this.m_struct_curr_market.total_positions++;
         return true;
        }
      if(status==ORDER_STATUS_MARKET_PENDING)
        {
         this.m_struct_curr_market.hash_sum_acc+=this.ConvertToHS(order);
         this.m_struct_curr_market.total_volumes+=order.Volume();
         this.m_struct_curr_market.total_pending++;
         return true;
        }
     }
   else
     {
      ::Print(DFUN,order.TypeDescription()," #",order.Ticket()," ",TextByLanguage("не удалось добавить в список","failed to add to list"));
      delete order;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Return an order index by a ticket in the list of control orders  |
//+------------------------------------------------------------------+
int CMarketCollection::IndexControlOrder(const ulong ticket,const ulong id)
  {
   int total=this.m_list_control.Total();
   for(int i=0;i<total;i++)
     {
      COrderControl* order=this.m_list_control.At(i);
      if(order==NULL)
         continue;
      if(order.PositionID()==id && order.Ticket()==ticket)
         return i;
     }
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Create and add an order to the list of control orders            |
//+------------------------------------------------------------------+
bool CMarketCollection::AddToListControl(COrder *order)
  {
   if(order==NULL)
      return false;
   COrderControl* order_control=new COrderControl(order.PositionID(),order.Ticket(),order.Magic(),order.Symbol());
   if(order_control==NULL)
      return false;
   order_control.SetTime(order.TimeOpenMSC());
   order_control.SetTimePrev(order.TimeOpenMSC());
   order_control.SetVolume(order.Volume());
   order_control.SetTime(order.TimeOpenMSC());
   order_control.SetTypeOrder(order.TypeOrder());
   order_control.SetTypeOrderPrev(order.TypeOrder());
   order_control.SetPrice(order.PriceOpen());
   order_control.SetPricePrev(order.PriceOpen());
   order_control.SetStopLoss(order.StopLoss());
   order_control.SetStopLossPrev(order.StopLoss());
   order_control.SetTakeProfit(order.TakeProfit());
   order_control.SetTakeProfitPrev(order.TakeProfit());
   if(!this.m_list_control.Add(order_control))
     {
      delete order_control;
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|Create and add a control order to the list of changed orders      |
//+------------------------------------------------------------------+
bool CMarketCollection::AddToListChanges(COrderControl* order_control)
  {
   if(order_control==NULL)
      return false;
   COrderControl* order_changed=new COrderControl(order_control.PositionID(),order_control.Ticket(),order_control.Magic(),order_control.Symbol());
   if(order_changed==NULL)
      return false;
   order_changed.SetTime(order_control.Time());
   order_changed.SetTimePrev(order_control.TimePrev());
   order_changed.SetVolume(order_control.Volume());
   order_changed.SetTypeOrder(order_control.TypeOrder());
   order_changed.SetTypeOrderPrev(order_control.TypeOrderPrev());
   order_changed.SetPrice(order_control.Price());
   order_changed.SetPricePrev(order_control.PricePrev());
   order_changed.SetStopLoss(order_control.StopLoss());
   order_changed.SetStopLossPrev(order_control.StopLossPrev());
   order_changed.SetTakeProfit(order_control.TakeProfit());
   order_changed.SetTakeProfitPrev(order_control.TakeProfitPrev());
   order_changed.SetChangedType(order_control.GetChangeType());
   if(!this.m_list_changed.Add(order_changed))
     {
      delete order_changed;
      return false;
     }
   return true;
  }
//+---------------------------------------------------------------------+
//| Convert the order price and its type into a number for the hash sum |
//+---------------------------------------------------------------------+
ulong CMarketCollection::ConvertToHS(COrder *order) const
  {
   if(order==NULL)
      return 0;
   ulong price=ulong(order.PriceOpen()*this.m_k_pow);
   ulong stop=ulong(order.StopLoss()*this.m_k_pow);
   ulong take=ulong(order.TakeProfit()*this.m_k_pow);
   ulong type=order.TypeOrder();
   ulong ticket=order.Ticket();
   return price+stop+take+type+ticket;
  }
//+------------------------------------------------------------------+
