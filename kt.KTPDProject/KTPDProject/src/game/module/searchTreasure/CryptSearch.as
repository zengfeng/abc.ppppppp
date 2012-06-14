package game.module.searchTreasure {
	import gameui.manager.UIManager;
	import net.AssetData;
	import flash.display.Sprite;
	import com.commUI.alert.Alert;
	import gameui.data.GButtonData;
	import gameui.controls.GButton;
	import gameui.data.GLabelData;
	import gameui.controls.GLabel;
	import flash.events.MouseEvent;
	import com.commUI.GCommonWindow;

	import gameui.data.GTitleWindowData;

	/**
	 * @author Lv
	 */
	public class CryptSearch extends GCommonWindow {
		private var dataItem:CryptTimerItem;
		private var sureBtn:GButton;
		private var dataItemVec:Vector.<CryptTimerItem> = new Vector.<CryptTimerItem>();
		public function CryptSearch() {
			_data = new GTitleWindowData();
			super(_data);
			initEvents();
		}
		
		override protected function initData() : void {
			_data.width = 316;
			_data.height = 355;
//			_data.parent = ViewManager.instance.uiContainer;
			_data.allowDrag = true;	
			super.initData();	
		}

		private function initEvents() : void {
		}
		//继承右上角的关闭按钮
//		override protected function onClickClose(event : MouseEvent) : void{
////			TasteTeaControl.instance.uninstallUI();
//		 }
		
		override protected function initViews() : void
		{
			title = "地穴寻宝";	
			super.initViews();
			addBG();
			addPanel();
			addPanelStatic();
		}

		private function addBG() : void {
			var bg:Sprite = UIManager.getUI(new AssetData("packPanelIoc"));
			bg.width = 316;
			bg.height = 279;
			bg.y = 42;
			_contentPanel.addChild(bg);
		}

		private function addPanelStatic() : void {
			var data:GLabelData = new GLabelData();
			data.text = "可选时间列表";
			data.textFormat.size = 12;
			data.x = 118;
			data.y = 55;
			var txt:GLabel = new GLabel(data);
			_contentPanel.addChild(txt);
			data.clone();
			data.text = "活动默认开启时间为周末晚上17：15，如需修改请在此时间前活动尚未开启前，族长保有随时修改的权利。";
			data.width = 238;
			data.x = 37;
			data.y = 237;
			var txt2:GLabel = new GLabel(data);
			_contentPanel.addChild(txt2);
			
			var databtn:GButtonData = new GButtonData();
			databtn.labelData.text = "确认";
			databtn.x = 130;
			databtn.y = 290;
			sureBtn = new GButton(databtn);
			_contentPanel.addChild(sureBtn);
		}

		private function addPanel() : void {
			if(dataItemVec.length > 0)clearnMC();
			for(var i:int = 0 ; i < 7; i++){
				dataItem = new CryptTimerItem(i);
				dataItem.y = 75 + (dataItem.height + 1) * i;
				_contentPanel.addChild(dataItem);
				dataItem.addEventListener(MouseEvent.MOUSE_DOWN, ondown);
				dataItemVec.push(dataItem);
			}
			
		}
		private var item:CryptTimerItem;
		private function ondown(event : MouseEvent) : void {
			item = event.currentTarget as CryptTimerItem;
			enabledItem();
			item.selectBox.selected = true;
			item.ExChangeColorBG(true);
			Alert.show(item.DataNum);
		}

		private function enabledItem() : void {
			for each(var item:CryptTimerItem in dataItemVec){
				item.selectBox.selected = false;
				item.ExChangeColorBG(false);
			}
		}

		private function clearnMC() : void {
			while(dataItemVec.length>0){
				dataItemVec.splice(0, 1);
			}
		}
	}
}
