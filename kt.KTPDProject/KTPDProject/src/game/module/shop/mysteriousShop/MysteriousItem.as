package game.module.shop.mysteriousShop {
	import com.commUI.alert.Alert;
	import com.commUI.icon.ItemIcon;
	import com.utils.UICreateUtils;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import game.core.item.Item;
	import game.core.user.StateManager;
	import game.core.user.UserData;
	import game.net.core.Common;
	import game.net.data.CtoS.CSSecretStoreBuy;
	import game.net.data.StoC.SCSecretStoreBuy;
	import gameui.controls.GButton;
	import gameui.controls.GLabel;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.data.GButtonData;
	import gameui.data.GLabelData;
	import net.AssetData;
	import net.RESManager;

	/**
	 * @author Lv
	 */
	public class MysteriousItem extends GComponent {
		private var bg:MovieClip;
		private var itemImg:ItemIcon;
		private var itemName:GLabel;
		private var goldPic:goldText;
		private var btn:GButton;
		private var itemGoods:Item;
		// 购买位置
		private var grid:int;
		public function MysteriousItem(gr:int) {
			_base = new GComponentData();
			initData();
			grid = gr;
			super(_base);
			initView();
			initEvent();
		}

		private function initData() : void {
			_base.width = 106;
			_base.height = 253;
		}

		private function initEvent() : void {
			btn.addEventListener(MouseEvent.CLICK, onclick);
			Common.game_server.addCallback(0x1CA, sCSecretStoreBuy);
		}

		private function initView() : void {
			addBG();
			addImgItem();
			addText();
			addBtn();
		}
		
		public function refresh(item:Item):void{
			itemGoods = item;
			refreshItem();
			refreshGoodsName();
			refreshGoodsPic();
			shwoPanel();
			bg.gotoAndStop(1);
		}
		private function shwoPanel():void{
			itemImg.visible = true;
			itemName.visible = true;
			goldPic.visible = true;
			btn.visible = true;
		}
		private function hideShowPanel():void{
			itemImg.visible = false;
			itemName.visible = false;
			goldPic.visible = false;
			btn.visible = false;
		}
		public function hideThisPanel():void{
			hideShowPanel();
			bg.gotoAndStop(30);
		}
		private function onclick(event : MouseEvent) : void {
			var myGolds:int = UserData.instance.gold;
			if(myGolds > 9)
				sendcToS();
			else
				StateManager.instance.checkMsg(4);
		}

		private function sCSecretStoreBuy(e:SCSecretStoreBuy) : void {
			if(grid != e.itemPos)return;
			hideShowPanel();
			bg.gotoAndPlay(2);
		}

		private function sendcToS() : void {
			StateManager.instance.checkMsg(288,[10,itemGoods.htmlName],alertCallFFH);
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
			var cmd : CSSecretStoreBuy = new CSSecretStoreBuy();
			cmd.itemPos = grid;
			Common.game_server.sendMessage(0x1CA, cmd);
		}

		private function refreshGoodsPic() : void {
			goldPic.refreshPic(String(10));
		}

		private function refreshGoodsName() : void {
			itemName.text = itemGoods.htmlName;
		}

		private function refreshItem() : void {
			if(itemGoods.id == 1800)
				itemGoods.nums = 5;
			else
				itemGoods.nums = 1;
			itemImg.source = itemGoods;
			
		}
		
		private function addBtn() : void {
			goldPic = new goldText();
			goldPic.y = 176;
			goldPic.x = 23;
			this.addChild(goldPic);
			var data:GButtonData = new GButtonData();
			data.labelData.text = "购买";
			data.y = 211;
			data.width = 50;
			data.height = 22;
			data.x = (106-data.width)/2;
			btn = new GButton(data);
			this.addChild(btn);
		}

		private function addText() : void {
			var data:GLabelData = new GLabelData();
			data.y = 156;
			data.textFormat = new TextFormat(null,null,null,null,null,null,null,null,TextFormatAlign.CENTER);
			data.width = 106;
			data.textFieldFilters = [];
			itemName = new GLabel(data);
			this.addChild(itemName);
		}

		private function addImgItem() : void {
			itemImg = UICreateUtils.createItemIcon({x:28, y:92, showBg:true, showBorder:true, showNums:true, showToolTip:true});
			addChild(itemImg);
		}

		private function addBG() : void {
			bg = RESManager.getMC(new AssetData("MysteriousItem"));
			bg.y = 51.2;
			bg.cacheAsBitmap=true;
			addChild(bg);
			
		}
	}
}
import net.AssetData;
import gameui.manager.UIManager;
import gameui.data.GLabelData;
import gameui.controls.GLabel;
import flash.display.Sprite;
class goldText extends Sprite{
	private var gold:Sprite;
	private var pic:GLabel;
	public function goldText():void{
		var data:GLabelData = new GLabelData();
		data.text = "价格：";
		data.textColor = 0x2F1F00;
		data.textFieldFilters = [];
		var text:GLabel = new GLabel(data);
		this.addChild(text);
		gold = UIManager.getUI(new AssetData("MoneyIcon_Gold"));
		gold.x = text.x + text.width;
		gold.y = 3;
		this.addChild(gold);
		data.clone();
		data.text = "10";
		data.x = gold.x +gold.width;
		pic = new GLabel(data);
		this.addChild(pic);
	}
	public function refreshPic(Pic:String = "10"):void{
		pic.text = Pic;
	}
}
