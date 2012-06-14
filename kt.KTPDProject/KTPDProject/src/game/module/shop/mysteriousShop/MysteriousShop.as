package game.module.shop.mysteriousShop
{
	import com.commUI.GCommonWindow;
	import com.commUI.alert.Alert;
	import com.commUI.tooltip.ToolTip;
	import com.commUI.tooltip.ToolTipManager;
	import com.utils.StringUtils;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import game.core.item.Item;
	import game.core.item.ItemManager;
	import game.core.user.StateManager;
	import game.core.user.UserData;
	import game.definition.UI;
	import game.manager.ViewManager;
	import game.module.shop.itemVo.GoodItem;
	import game.module.shop.staticValue.ShopStaticValue;
	import game.module.trade.unused.MyGoodsListItem;
	import game.net.core.Common;
	import game.net.data.CtoC.CCUserDataChangeUp;
	import game.net.data.CtoS.CSSecretStoreFlush;
	import game.net.data.CtoS.CSSecretStoreQuery;
	import game.net.data.StoC.SCSecretStoreBuy;
	import game.net.data.StoC.SCSecretStoreQuery;
	import gameui.controls.GButton;
	import gameui.controls.GLabel;
	import gameui.core.GAlign;
	import gameui.data.GButtonData;
	import gameui.data.GLabelData;
	import gameui.data.GTitleWindowData;
	import gameui.layout.GLayout;
	import gameui.manager.UIManager;
	import net.AssetData;









	/**
	 * @author Lv
	 */
	public class MysteriousShop extends GCommonWindow {
		//刷新按钮
		private var refreshBtn:GButton;
		private var goodsItem:MysteriousItem;
		private var mysteriousListDic:Dictionary = new Dictionary();
		private var goodsNumArr:Array = new Array();
		
		public function MysteriousShop() {
			_data = new GTitleWindowData();
			super(_data);
			initEvents();
		}
		override protected function initData() : void {
			_data.width = 616;
			_data.height = 298;
			_data.parent = ViewManager.instance.uiContainer;
			_data.allowDrag = true;		
			super.initData();	
		}

		private function initEvents() : void {
			Common.game_server.addCallback(0x1C8, sCSecretStoreQuery);
			refreshBtn.addEventListener(MouseEvent.MOUSE_DOWN, onRefreshGoods);
			Common.game_server.addCallback(0xFFF1, cCUserDataChangeUp);
		}


		private function cCUserDataChangeUp(e:CCUserDataChangeUp) : void {
			if(itemVec.length!=0)return;
			requestGoods();
		}
		private function removeEvent():void{
			Common.game_server.removeCallback(0xFFF1, cCUserDataChangeUp);
			Common.game_server.removeCallback(0x1C8, sCSecretStoreQuery);
		}

		private function onRefreshGoods(e:MouseEvent) : void {
			var myGolds:int = UserData.instance.gold;
			if(myGolds > 49)
			{
				refreshListShop();
			}else
				StateManager.instance.checkMsg(4);
			
		}
		//刷新列表
		private function refreshListShop() : void {
			StateManager.instance.checkMsg(286,[50],alertCallFFH);
		}
		
		private function alertCallFFH(type : String) : Boolean
		{
			switch(type)
			{
				case Alert.OK_EVENT:
					sendcToSSuccess();
					break;
				case Alert.CANCEL_EVENT:
					break;
			}
			return true;
		}

		private function sendcToSSuccess() : void {
			var cmd:CSSecretStoreFlush = new CSSecretStoreFlush();
			Common.game_server.sendMessage(0x1C9,cmd);
		}
		//获取神秘商店列表
		private function sCSecretStoreQuery(e:SCSecretStoreQuery) : void {
			var goodsVe:Vector.<uint> = ShopStaticValue.mysteriousShopGoodsIDVe;
			if(goodsVe.length != 0)refreshList();
			var picDic:Dictionary = ShopStaticValue.mysteriousShopPicDic;
			var itemVe:Vector.<uint> = e.items;
			for(var i:int= 0; i < itemVe.length;i++)
			{
				var id:int = itemVe[i]>>16;
				var pic:int = itemVe[i]&0xFF;
				var num:int = (itemVe[i]>>8)&0xFF;
				goodsNumArr.push(num);
				goodsVe.push(id);
				picDic[i] = pic;
			}
			addGoods();
		}
		//请求神秘商店列表
		private function requestGoods() : void {
			var cmd:CSSecretStoreQuery = new CSSecretStoreQuery();
			Common.game_server.sendMessage(0x1C8,cmd);
		}
		
		override protected function initViews() : void
		{
			title = "神秘商店";
			requestGoods();
			addBG();
			addPanel();
			
			super.initViews();
		}
		private var itemVec:Vector.<MysteriousItem> = new Vector.<MysteriousItem>();
		private function addGoods() : void {
			if(itemVec.length>0)clreanVec();
			var goodsVe:Vector.<uint> = ShopStaticValue.mysteriousShopGoodsIDVe;
			for(var i:int = 0; i < 5; i++)
			{
				var id:int = goodsVe[i];
				var item:Item = ItemManager.instance.newItem(id);
				goodsItem = new MysteriousItem(i);
				goodsItem.refresh(item);
				goodsItem.x = 28 + (goodsItem.width + 5) * i;
				goodsItem.y = -7;
				_contentPanel.addChild(goodsItem);
				mysteriousListDic[i] = goodsItem;
				itemVec.push(goodsItem);
				if(ShopStaticValue.mysteriousShopPicDic[i] == 0)
				{
					goodsItem.hideThisPanel();
				}
			}
		}

		private function clreanVec() : void {
			while(itemVec.length>0){
				itemVec.splice(0, 1);
			}
			for(var K:String in mysteriousListDic) {
				delete mysteriousListDic[K];
			}
		}
		private function refreshList():void{
			var picDic:Dictionary = ShopStaticValue.mysteriousShopPicDic;
			var goodsVe:Vector.<uint> = ShopStaticValue.mysteriousShopGoodsIDVe;
			for(var k:String in mysteriousListDic)
			{
				var item:MysteriousItem = mysteriousListDic[k] as MysteriousItem;
				_contentPanel.removeChild(item);
				delete  mysteriousListDic[k];
			}
			for(var i:String in picDic)
			{
				delete  picDic[i];
			}
			while (goodsVe.length > 0) {
				goodsVe.splice(0, 1);
			}
		}

		private function addPanel() : void {
			var data:GLabelData = new GLabelData();
			data.text = "神秘商店每晚12:00刷新，该店不收绑定元宝";
			data.textColor = 0x2F1F00;
			data.textFieldFilters = [];
			data.filters = [];
			data.x = 28;
			data.y = 266;
			data.width = 300;
			var text:GLabel = new GLabel(data);
			_contentPanel.addChild(text);
			
			var databtn:GButtonData = new GButtonData();
			databtn.labelData.text = "刷新物品";
			databtn.x = 494;
			databtn.y = 262;
			databtn.width = 80;
			data.height = 30;
			refreshBtn = new GButton(databtn);
			_contentPanel.addChild(refreshBtn);
			var str:String = "花费"+StringUtils.addColor("50","#FFFF00")+"元宝全部刷新";
			ToolTipManager.instance.registerToolTip(refreshBtn,ToolTip,str);
		}

		private function addBG() : void {
			var bg:Sprite = UIManager.getUI(new AssetData(UI.CAST_SUTRA_PANEL_BG));
			bg.x = 4;
			bg.width = 603;
			bg.height = 294;
			_contentPanel.addChild(bg);
			
			var bg2:Sprite = UIManager.getUI(new AssetData(UI.COMMON_BACKGROUND03));
			bg2.width = 563;
			bg2.height = 211;
			bg2.y = 40;
			bg2.x = 23;
			_contentPanel.addChild(bg2);
		}
		override public function show():void
		{
			this.align = new GAlign((UIManager.stage.stageWidth - this.width) / 2,-1,(UIManager.stage.stageHeight - this.height) / 2,-1);
			GLayout.layout(this);
			super.show();
			initEvents();
		}
		override public function hide():void{
			super.hide();
			removeEvent();
		}
	}
}
