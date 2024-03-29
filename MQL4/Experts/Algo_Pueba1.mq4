//+------------------------------------------------------------------+
//|                                                  Algo_Pueba1.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input int RVIperiod=40;

//--- Variables de todo el programa
double stop_loss;
double take_profit;
int ticket1;
int TiempoAhora,TiempoAnterior;
int ordenes_abiertas;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ticket1=0;
   stop_loss=0;
   take_profit=0;
   TiempoAhora=TiempoAnterior= 0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
//filtro para evitar multiples trades
   if(!Filtro())return;

//Calculo del riesgo para ser usado en una posible operacion (temporal hasta que se calcule el lote con ATR)
   double lote=0.01;

//Acciones a realizar si existen ordenes abiertas (buscar cerrarlas con indicador RVI)
   ordenes_abiertas=OrdersTotal();
   int Slippage=3;
   if(ordenes_abiertas>0)
     {
      for(int i=ordenes_abiertas-1;i>=0;i--)
        {
         OrderSelect(i,SELECT_BY_POS);
         int tipo_orden=OrderType();
         bool result=false;

         //Cerrar operaciones de compra 
         if(tipo_orden==OP_BUY && CloseIndicator(OP_BUY)==true)
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),Slippage,Red);
            break;
           }
         //Cerrar operaciones de venta
         else if(tipo_orden==OP_SELL && CloseIndicator(OP_SELL)==true)
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),Slippage,Red);
            break;
           }

         if(result==false)
           {
            Alert("Order ",OrderTicket()," failed to close. Error:",GetLastError());
            Sleep(3000);
           }
        }
     }

//-----------------------------------0------------------------------------------------------- 
//Buscar señal ya que NO existen ordenes abiertas 
   else
     {
      if(ConfirmationIndicator1()==1)
        {
         ticket1=OrderSend(NULL,OP_BUY,lote,Ask,7,stop_loss,take_profit,NULL,1,0,clrBlue);
         Sleep(3000);
         Comment("Compra");
         if(ticket1>0)
           {
            TiempoAnterior=Time[0];
            Comment("Compra exitosa");
           }
         else Comment("Error en compra");
        }
      else if(ConfirmationIndicator1()==2)
        {
         ticket1=OrderSend(NULL,OP_SELL,lote,Bid,7,stop_loss,take_profit,NULL,1,0,clrBlue);
         Sleep(3000);
         Comment("Venta");
         if(ticket1>0)
           {
            TiempoAnterior=Time[0];
            Comment("Venta exitosa");
           }
         else Comment("Error en venta");
        }
      else if(ConfirmationIndicator1()==0)
         Comment("Nada");
     }
  }
//+------------------------------------------------------------------+

/* ---- INDICATOR FUNCTIONS -----------------------------------------------------------
 Algo: 
       1)ATR
       2)Baseline:_______*MA
       3)Confirmation1:__*Absolute strenght index (ASH)
       4)Confirmation2:__*SSL
       5)Volume:_________*TDFI
       6)Exit:___________*RVI 
*/

//+------------------------------------------------------------------+
//|1)ATR          
//|Return: float con el lote de la operación.
//+------------------------------------------------------------------+
double ATRindicator(int tipo_operacion)
  {
   double atr_actual=iATR(NULL,PERIOD_D1,14,1);
   double lot=0.01;

   return(lot);
  }
//+------------------------------------------------------------------+
//|2)Baseline: MA         
//|Return: 
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|3)Confirmation1: ASH       
//|Return: 1-compra, 2-venta , 0-ninguna de las anteriores
//+------------------------------------------------------------------+
int ConfirmationIndicator1()
  {
   double Valor_compra_actual=iCustom(NULL,PERIOD_D1,"Favoritos\\ASH personalizado",2,1);
   double Valor_venta_actual=iCustom(NULL,PERIOD_D1,"Favoritos\\ASH personalizado",3,1);
   double Valor_compra_pasada=iCustom(NULL,PERIOD_D1,"Favoritos\\ASH personalizado",2,2);
   double Valor_venta_pasada=iCustom(NULL,PERIOD_D1,"Favoritos\\ASH personalizado",3,2);
   int resultadoASH=0;

//Caso si hay una opcion de venta 
   if(Valor_venta_actual>Valor_compra_actual && Valor_compra_pasada>Valor_venta_pasada)
      resultadoASH=2;
//Caso si hay una opcion de compra 
   else if(Valor_venta_actual<Valor_compra_actual && Valor_compra_pasada<Valor_venta_pasada)
      resultadoASH=1;
//Si no hay opcion de venta o compra
   else
      resultadoASH=0;

   return(resultadoASH);
  }
//+------------------------------------------------------------------+
//|4)Confirmation2: SSL   
//|Return: 1-compra 2-venta 3-ninguna de las anteriores  
//+------------------------------------------------------------------+
//int ConfirmationIndicator2()




//+------------------------------------------------------------------+
//|5)Volume:          
//|Return: 
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|6)Exit: RVI          
//|Return: true(close) or false(not close) 
//+------------------------------------------------------------------+ 
bool CloseIndicator(int tipo_operacion)
  {
   double Valor_base_actual=iRVI(NULL,PERIOD_D1,RVIperiod,MODE_MAIN,1);
   double Valor_signal_actual=iRVI(NULL,PERIOD_D1,RVIperiod,MODE_SIGNAL,1);
   double Valor_base_pasada=iRVI(NULL,PERIOD_D1,RVIperiod,MODE_MAIN,2);
   double Valor_signal_pasada=iRVI(NULL,PERIOD_D1,RVIperiod,MODE_SIGNAL,2);
   bool resultadoRVI=0;

//Si la linea roja cruza la verde hacia arriba (cierro una compra)
   if(Valor_signal_actual>Valor_base_actual && Valor_base_pasada>Valor_signal_pasada && tipo_operacion==OP_BUY)
      resultadoRVI=true;
//Si la linea verde cruza la roja hacia arriba (cierro una venta)
   else if(Valor_signal_actual<Valor_base_actual && Valor_base_pasada<Valor_signal_pasada && tipo_operacion==OP_SELL)
      resultadoRVI=true;
//Si no hay opcion de venta o compra
   else
      resultadoRVI=false;

   return(resultadoRVI);

  }
//------------------- FUNCIONES EXTRA PARA EL EA --------------------------

/*
//Funcion para cerrar operaciones 
void CloseOrdersAndPO()
{
int Slippage=3;
int total = OrdersTotal();
  
for(int i=total-1;i>=0;i--)
{
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;
    
    switch(type)
    {
      //Close opened long positions
      case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), Slippage, Red );
                          break;
      
      //Close opened short positions
      case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), Slippage, Red );
                          break;

      //Close pending orders
      case OP_BUYLIMIT  :
      case OP_BUYSTOP   :
      case OP_SELLLIMIT :
      case OP_SELLSTOP  : result = OrderDelete( OrderTicket() );
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
      Sleep(3000);
    }  
}
}
*/

//Funcion de filtro
bool Filtro()
  {
   TiempoAhora=Time[0];
   if(TiempoAnterior==TiempoAhora)return(false);
   else return(true);
  }
//+------------------------------------------------------------------+
