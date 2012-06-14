package game.module.trade.unused
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import game.definition.UI;
	import game.net.core.Common;
	import game.net.data.CtoS.CSBuyout;
	import gameui.containers.GPanel;
	import gameui.controls.GButton;
	import gameui.controls.GLabel;
	import gameui.data.GButtonData;
	import gameui.data.GPanelData;
	import gameui.layout.GLayout;
	import gameui.manager.UIManager;
	import gameui.skin.SkinStyle;
	import net.AssetData;



	
	/**
	 * @author 1
	 */
	public class MyGoodsListItem extends GPanel
	{
		public function MyGoodsListItem(imageID:int=0,goods_name:String=null,goods_counts:int=0,goods_price:int=0)
		{
			_data = new GPanelData();
			_data.width=411.65;
			_data.height=38;
		    _data.bgAsset=new AssetData(SkinStyle.emptySkin);   //取消背景
		    super(_data);
			initView();
		}
		
		private function initView() : void
		{
			addBg();
			addButton();
			_buy.hide();;
			addLabel();
		}
		
		public function initall():void
		{
			(_names[0] as TextField).text="";
			(_counts[0] as TextField).text="";
			
			(_owners[0] as TextField).text="";
			(_pricese[0] as TextField).text="";
			
			_buy.hide();
		}
		
		private function addBg():void
		{
		   var panelBg:Sprite=UIManager.getUI(new AssetData(UI.TRADE_ITEM_EXAMPLE));
		   panelBg.width=35;
		   panelBg.height=35;
		   panelBg.x=2;
		   panelBg.y=0.7;
		   _content.addChild(panelBg);
		   
		   
		   					   //商品深色面板
		   var itemListNameBg:Sprite=UIManager.getUI(new AssetData(UI.TRADE_LISTNAMEBG));
		   itemListNameBg.width=100;
		   itemListNameBg.height=50;
		   itemListNameBg.x=5;
		   itemListNameBg.y=30;
		   _content.addChild(itemListNameBg);
		}
		
		private var clearBtn_Label:GLabel;
		private var _goodsName:String="";
		private var _goodsCount:String="";
		private var _goodsOwner:String="";
		private var _goodsPrice:String="";
		
		private function addLabel():void
		{
	        addItemText(_goodsName, 98.8, 19, 38, 8.2, 12,1);
		    addItemText(_goodsCount, 35, 19, 168, 8.2, 12,2);
		    addItemText(_goodsOwner, 95.8, 19, 237, 8.2, 12,3);
			addItemText(_goodsPrice, 55.3, 19, 375, 8.2, 12,4);
		}
		private var GoodsID:int;
		private var TradeID:int;
		public function refreshLabel(goodsName:String,goodsCount:String,goodsOwner:String,goodsPrice:String,itemId:int,orderId:int,tradeId:int):void
		{
			//var i:int=orderId;
			GoodsID=itemId;
			TradeID=tradeId;
			(_names[0] as TextField).text=goodsName;
			(_counts[0] as TextField).text=goodsCount;
			
			(_owners[0] as TextField).text=goodsOwner;
			(_pricese[0] as TextField).text=goodsPrice;
		//    _goodsName=goodsName;
		//	_goodsCount=goodsCount;
		//	_goodsOwner=goodsOwner;
		//	_goodsPrice=goodsPrice;
		//	addLabel();
		    _buy.show();
			
		}
		
	    private var _buy:GButton;
		
		private function addButton():void
		{
			var data:GButtonData = new GButtonData();
            data.width = 51;
            data.height = 24;
            data.x = 480;
            data.y = 5;
            _buy = new GButton(data);
            _buy.text = "购买";
            _buy.addEventListener(MouseEvent.CLICK, onButtonClick);
            addChild(_buy);			
			
		}
		
		private function onButtonClick(event:MouseEvent):void
		{
			var cmd1:CSBuyout=new CSBuyout();
			cmd1.tradeid=TradeID;
			Common.game_server.sendMessage(0xB9,cmd1); 
		}
		
		private var _names:Array=new Array();
		private var _counts:Array=new Array();
	    private var _owners:Array=new Array();
		private var _pricese:Array=new Array();
	 
	    private function addItemText(text:String,width:int, height:int, x:int, y:int, size:int ,type:int) : TextField //type中 1=名字 2=数量 3=拥有者 4=价格
        {
            var textField:TextField = new TextField();
            var format : TextFormat = new TextFormat();
            format.size = size;
            format.align = TextFormatAlign.CENTER;
            textField.mouseEnabled = false;
            textField.width = width;
            textField.height = height;
            textField.text = text;
            textField.x = x;
            textField.y = y;
            addChild(textField);
			if(type==1)
			{
			 _names.push(textField);
			}
			else if(type==2)
			{
			_counts.push(textField);
			}
			else if(type==3)
			{
			_owners.push(textField);
			}
			else if(type==4)
			{
				_pricese.push(textField);
			}
            return textField;
        }
		
	public function getGoodsId():int
	{
		return GoodsID;
	}	
	
		public function getTradeId():int
	{
		return TradeID;
	}	
	   override public function show():void
		{
			super.show();
			GLayout.layout(this);
		}
		
		override public function hide():void
		{
			
			super.hide();
		}	
	}
}

