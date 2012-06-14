package game.module.tasteTea {
	import game.manager.VersionManager;
	import game.core.menu.MenuManager;
	import game.core.menu.MenuType;
	import game.core.user.StateManager;
	import game.core.user.UserData;
	import game.definition.UI;
	import game.net.core.Common;
	import game.net.data.CtoS.CSGuildDrinkTea;

	import gameui.containers.GPanel;
	import gameui.controls.GButton;
	import gameui.controls.GImage;
	import gameui.controls.GLabel;
	import gameui.data.GButtonData;
	import gameui.data.GImageData;
	import gameui.data.GLabelData;
	import gameui.data.GPanelData;
	import gameui.manager.UIManager;

	import net.AssetData;

	import com.utils.ColorUtils;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author Lv
	 */
	public class TeaItem extends GPanel {
		
		private var teaBtn:GButton;
		private var img:GImage;
		private var teaName:GLabel;
		private var upgradeHonour:GLabel;
		private var consumeMoney:GLabel;
		private var imgBoxColor:int;  			// 0: 绿色   1：蓝色  2：紫色
		private var moneyKinds:int;           //1：元宝    2：银币
		private var nameTea:String;
		private static const iconbg:Array = [UI.ROUND_ICON_BACKGROUND_GREEN,UI.ROUND_ICON_BACKGROUND_BLUE,UI.ROUND_ICON_BACKGROUND_VIOLET];
		/**
		 * color:图片地板的颜色  1: 蓝色   2：紫色  3：黄色
		 * kinds:需要话费钱币的种类  1：元宝    2：银币
		 * name:茶的名称
		 */
		public function TeaItem(color:int,kinds:int,name:String) {
			_data = new GPanelData();
			initData();
			imgBoxColor = color;
			moneyKinds = kinds;
			nameTea = name;
			super(_data);
			initView();
			initEvent();
		}

		private function initData() : void {
			_data.width = 146;
			_data.height = 96;
			_data.bgAsset=new AssetData(UI.SHOP_ITEM_BACKGROUND);   //取消背景
		}

		private function initEvent() : void {
			teaBtn.addEventListener(MouseEvent.CLICK, onMouseDown);
		}

		private function onMouseDown(event : MouseEvent) : void {
			var num:int = imgBoxColor;
			var silve:uint = UserData.instance.silver;
			var gold:uint = UserData.instance.gold + UserData.instance.goldB;
			if(num == 0){
				if(silve < money){
					StateManager.instance.checkMsg(129);
					return;
				}
			}else{
				if(gold < money){ 
					StateManager.instance.checkMsg(4);
					return;
				}
			}
			
			var cmd:CSGuildDrinkTea = new CSGuildDrinkTea();
			cmd.sel = num;
			Common.game_server.sendMessage(0x2D1,cmd);
			MenuManager.getInstance().closeMenuView(MenuType.TASTTEA);
		}

		private function initView() : void {
			addBG();
			addPanel();
		}

		private function addBG() : void {
			
			var icon:Sprite = UIManager.getUI(new AssetData(iconbg[imgBoxColor]));
			icon.x = 8;
			icon.y = 14;
			_content.addChild(icon);
			
			var data:GImageData = new GImageData();
			data.x = 30;
			data.y = 8;
			img = new GImage(data);
			img.url = VersionManager.instance.getUrl("assets/ico/guildaction/tea_" + imgBoxColor.toString() + ".png");
			_content.addChild(img);
			
			var iconGlod:Sprite ;
			switch(moneyKinds){
				case 1:
					iconGlod = UIManager.getUI(new AssetData(UI.MONEY_ICON_GOLD));
					break;
				case 2:
					iconGlod = UIManager.getUI(new AssetData(UI.MONEY_ICON_SILVER));
					break;
			}
			iconGlod.x = 96;
			iconGlod.y = 50;
			_content.addChild(iconGlod);
//			var iconHonour:Sprite = UIManager.getUI(new AssetData(UI.MONEY_ICON_HONOUR));
//			iconHonour.x = 59;
//			iconHonour.y = 89;
//			_content.addChild(iconHonour);
		}
		private var money:int;
		/**
		 * honourNum:可以获得的声望数
		 * goldNum:所需要兑换的元宝数
		 */
		public function setContent(honourNum:int,goldNum:int): void{
			money = goldNum;
			upgradeHonour.text = "+" + String(honourNum);
			consumeMoney.text = String(goldNum);
//			img.source = path;
		}
		//实现按钮不可用
		public function visibelBtn():void
		{
			teaBtn.enabled = false;
		}

		private function addPanel() : void {
			var dataBtn:GButtonData = new GButtonData();
			dataBtn.labelData.text = "品茶";
			dataBtn.width = 60;
			dataBtn.height = 23;
			dataBtn.x = 44;
			dataBtn.y = 68;
			teaBtn = new GButton(dataBtn);
			_content.addChild(teaBtn);
			var data:GLabelData = new GLabelData();
			data.text = nameTea;
			data.textColor = ColorUtils.TEXTCOLOROX[imgBoxColor+2] ;
			data.x = 61;
			data.y = 9;
			data.textFormat.size = 14;
			data.textFormat.bold = true ;
			data.textFieldFilters = [] ;
			teaName = new GLabel(data);
			_content.addChild(teaName);
			data.clone();
			data.textFormat.size = 12 ;
			data.textFormat.bold = false ;
			data.textColor = 0;
			data.text = "修为：";
			data.x = 60;
			data.y = 28;
			var text1:GLabel = new GLabel(data);
			_content.addChild(text1);
			data.clone();
			data.textFormat.color = ColorUtils.TEXTCOLOROX[2];
			data.text = "0000";
			data.x = 99;
			upgradeHonour = new GLabel(data);
			_content.addChild(upgradeHonour);
			data.clone();
			data.text = "消耗：";
			data.textFormat.color = 0 ;
			data.x = 60;
			data.y = 45;
			var text2:GLabel = new GLabel(data);
			_content.addChild(text2);
			data.clone();
			data.text = "0000";
			data.x = 109;
			consumeMoney = new GLabel(data);
			_content.addChild(consumeMoney);
		}
	}
}
