package game.module.tasteTea {
	import com.utils.UICreateUtils;
	import com.commUI.GCommonWindow;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import game.core.menu.MenuManager;
	import game.core.menu.MenuType;
	import game.definition.UI;
	import game.manager.ViewManager;
	import gameui.controls.GImage;
	import gameui.controls.GLabel;
	import gameui.core.GAlign;
	import gameui.data.GImageData;
	import gameui.data.GLabelData;
	import gameui.data.GTitleWindowData;
	import gameui.manager.UIManager;
	import net.AssetData;


	/**
	 * @author Lv
	 */
	public class TastePanel extends GCommonWindow {
		
		private var item:TeaItem;
		private var teaArr:Array = ["普通清茶","天山清茶","蓬莱仙茶"];
		private var moneyRollArr:Array = [2,1,1];
		private var moneyArr:Array = [5000,30,100];
		private var honourArr:Array = [50,300,1000];
		private var itemVec:Vector.<TeaItem> = new Vector.<TeaItem>();
		
		public function TastePanel() {
			_data = new GTitleWindowData();
			super(_data);
			initEvents();
		}
		
		override protected function initData() : void {
			_data.width = 470;
			_data.height = 267;
			_data.parent = ViewManager.instance.uiContainer;
			_data.allowDrag = true;	
			super.initData();	
		}
		
		 override protected function onClickClose(event : MouseEvent) : void{
			MenuManager.getInstance().closeMenuView(MenuType.TASTTEA);
		 }

		private function initEvents() : void {
			
		}
		
		override protected function initViews() : void
		{
			title = "品茶";	
			super.initViews();
			addBG();
			addPanel();
		}

		private function addBG() : void {
			var bg:Sprite = UIManager.getUI(new AssetData(UI.PANEL_BACKGROUND));
			bg.width = 461;
			bg.height = 261;
			bg.x = 4;
			bg.y = 2;
			_contentPanel.addChild(bg);
		}

		private function addPanel() : void {
			
			var tbg:Sprite = UICreateUtils.createSprite("taste_tea_background",443,208,13,-53);
			addChild(tbg);
			
			if(itemVec != null)cearnItem();
			for(var i:int = 0 ; i < 3; i++){
				item = new TeaItem(i, moneyRollArr[i],teaArr[i]);
				item.x = 13 + 149 * i;
				item.y = 158;
				item.setContent(honourArr[i], moneyArr[i]);
				itemVec.push(item);
				_contentPanel.addChild(item);
			}
			
		}
		
		/**
		 * 今日不能品茶
		 */
		public function EnableTastTea():void{
			for each(var item:TeaItem in itemVec){
				item.visibelBtn();
			}
		}

		private function cearnItem() : void {
			while(itemVec.length>0){
				itemVec.splice(0, 1);
			}
		}
		
		override public function hide():void{
			this.align = new GAlign((UIManager.stage.stageWidth - this.width) / 2,-1,(UIManager.stage.stageHeight - this.height) / 2,-1);
			super.hide();
		}
		override public function show():void{
			this.align = new GAlign((UIManager.stage.stageWidth - this.width) / 2,-1,(UIManager.stage.stageHeight - this.height) / 2,-1);
			super.show();
		}
	}
}
