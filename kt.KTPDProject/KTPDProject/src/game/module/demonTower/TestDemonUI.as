package game.module.demonTower {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import game.module.duplMap.DuplMapData;
	import game.module.duplMap.DuplUtil;
	import game.module.duplMap.data.DuplStruct;
	import game.module.duplMap.data.LayerStruct;
	import game.module.duplPanel.view.WindowHook;
	import game.module.map.animalstruct.MonsterStruct;
	import gameui.controls.GButton;
	import gameui.data.GButtonData;



	/**
	 * @author Lv
	 */
	public class TestDemonUI extends Sprite {
		public function TestDemonUI() {
			initView();
		}

		/** 单例对像 */
		private static var _instance : TestDemonUI;

		/** 获取单例对像 */
		public static function get instance() : TestDemonUI {
			if (_instance == null) {
				_instance = new TestDemonUI();
			}
			return _instance;
		}

		private function initView() : void {
			var buttonData : GButtonData;
			var button : GButton;

			buttonData = new GButtonData();
			buttonData.labelData.text = "挂机面板";
			button = new GButton(buttonData);
			addChild(button);
			button.addEventListener(MouseEvent.CLICK, hookPanel);

			buttonData = new GButtonData();
			buttonData.labelData.text = "buttonDefault";
			button = new GButton(buttonData);
			addChild(button);
			button.addEventListener(MouseEvent.CLICK, buttonDefault);
			buttonData = new GButtonData();
			buttonData.labelData.text = "button start";
			button = new GButton(buttonData);
			addChild(button);
			button.addEventListener(MouseEvent.CLICK, buttonState_start);
			buttonData = new GButtonData();
			buttonData.labelData.text = "button fast";
			button = new GButton(buttonData);
			addChild(button);
			button.addEventListener(MouseEvent.CLICK, buttonState_fast);
			buttonData.labelData.text = "button noNum";
			button = new GButton(buttonData);
			addChild(button);
			button.addEventListener(MouseEvent.CLICK, buttonState_noNum);
			
			var duplId:int;
			var layerId:int;
			var duplMapId:int;
			DuplUtil.getDuplId(201); //200
			DuplUtil.getLayerId(201); //1
			DuplUtil.getDuplMapId(200, 1); //201
			
			duplMapId = 202;
			duplId = DuplUtil.getDuplId(duplMapId);
			layerId = DuplUtil.getLayerId(duplMapId);
			
			var duplStruct:DuplStruct = DuplMapData.instance.getDuplStruct(duplId);
			duplStruct.name;
			
			for(var i:int = 2; i <= 6; i+= 2)
			{
				var layerStruct:LayerStruct = duplStruct.layerDic[i];
				var monsterStruct:MonsterStruct =layerStruct.getIconMonster();
				monsterStruct.name;
//				monsterStruct
			}
			
//			var layerStruct:LayerStruct = DuplMapData.instance.getLayerStruct(duplId, layerId);
//			var monsterStruct:MonsterStruct =layerStruct.getIconMonster();
//			monsterStruct.name;
			
			

			for (var i1 : int = 0; i1 < numChildren; i1++) {
				var dis : DisplayObject = getChildAt(i1);
				dis.x = i1 * 100;
			}

			x = 500;
			y = 50;
		}

		private function buttonState_noNum(event : MouseEvent) : void {
			windowHook.buttonState_noNum();
		}

		private function buttonState_fast(event : MouseEvent) : void {
			windowHook.buttonState_fast();
		}

		private function buttonState_start(event : MouseEvent) : void {
			windowHook.buttonState_start();
		}

		private function buttonDefault(event : MouseEvent) : void {
			windowHook.buttonState_default();
		}

		private var windowHook : WindowHook;

		private function hookPanel(event : MouseEvent) : void {
			if (windowHook == null) windowHook = new WindowHook();
			windowHook.visible = true;
			windowHook.buttonState_default();
		}
	}
}
