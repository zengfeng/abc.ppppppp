package game.module.searchTreasure {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import gameui.data.GRadioButtonData;
	import gameui.controls.GRadioButton;
	import gameui.skin.SkinStyle;
	import net.AssetData;
	import gameui.containers.GPanel;
	import gameui.data.GPanelData;

	/**
	 * @author Lv
	 */
	public class CryptTimerItem extends GPanel {
		public var selectBox:GRadioButton;
		private var dataArr:Array = ["周 一","周 二","周 三","周 四","周 五","周 六","周 日"];
		private var dataNum:int;
		private var bg:Sprite;
		public function CryptTimerItem(data:int) {
			_data = new GPanelData();
			dataNum = data;
			initData();
			super(_data);
			initView();
			initEvent();
		}

		private function initData() : void {
			_data.width = 313;
			_data.height = 22;
			_data.bgAsset = new AssetData(SkinStyle.emptySkin);
		}
		public function get DataNum():int{
			return dataNum;
		}

		private function initEvent() : void {
//			selectBox.addEventListener(MouseEvent.MOUSE_DOWN ,onClick);
		}
		
		private function onClick(even:MouseEvent):void
		{
//			even.stopPropagation();
		}

		private function initView() : void {
			addBG();
			addPanl();
		}

		private function addBG() : void {
			bg = new Sprite();
			bg.graphics.beginFill(0x555555);
			bg.graphics.drawRect(0,0,313, 22);
			bg.graphics.endFill();
			_content.addChild(bg);
			bg.alpha = 0.3;
		}
		
		public function ExChangeColorBG(exChange:Boolean):void{
			if(exChange){
				bg.graphics.clear();
				bg.graphics.beginFill(0xCC6699);
				bg.graphics.drawRect(0,0,313, 22);
				bg.graphics.endFill();
			}
			else{
				bg.graphics.clear();
				bg.graphics.beginFill(0x555555);
				bg.graphics.drawRect(0,0,313, 22);
				bg.graphics.endFill();
			}
		}
		
		private function addPanl() : void {
			var data:GRadioButtonData = new GRadioButtonData();
			data.labelData.textFormat.size = 12;
//			data.padding = 0;
			//data.upAsset = new AssetData(UI.RADIO_BUTTON_UNSELECTED);
//			data.selectedUpIcon = new AssetData(UI.RADIO_BUTTON_SELECTED);
//			data.upIcon = new AssetData(UI.RADIO_BUTTON_UNSELECTED);
			data.labelData.text =  "  "+dataArr[dataNum];
			data.x = 22;
			data.y = 5;
			selectBox = new GRadioButton(data);
			_content.addChild(selectBox); 
		}
	}
}
