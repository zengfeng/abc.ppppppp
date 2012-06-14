package game.module.mapWorld
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import game.module.map.MapSystem;
    import game.module.mapClanEscort.MCEController;
    import gameui.controls.GButton;
    import gameui.data.GButtonData;



	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-13 ����6:20:18
	 */
	public class TestMapWorldUi extends Sprite
	{
		public function TestMapWorldUi()
		{
			initView();
		}

		/** 单例对像 */
		private static var _instance : TestMapWorldUi;

		/** 获取单例对像 */
		public static function get instance() : TestMapWorldUi
		{
			if (_instance == null)
			{
				_instance = new TestMapWorldUi();
			}
			return _instance;
		}

		/** 控制器 */
		private var _controller : MCEController;

		/** 控制器 */
		public function get controller() : MCEController
		{
			if (_controller == null)
			{
				_controller = MCEController.instance;
			}
			return _controller;
		}

		private function initView() : void
		{
			var buttonData : GButtonData;
			var button : GButton;

			buttonData = new GButtonData();
			buttonData.labelData.text = "世界地图";
			button = new GButton(buttonData);
			 addChild(button);
			button.addEventListener(MouseEvent.CLICK, open);

			buttonData = new GButtonData();
			buttonData.labelData.text = "去地图";
			button = new GButton(buttonData);
			 addChild(button);
			button.addEventListener(MouseEvent.CLICK, toMap);

			buttonData = new GButtonData();
			buttonData.labelData.text = "去Npc";
			button = new GButton(buttonData);
			 addChild(button);
			button.addEventListener(MouseEvent.CLICK, toNpc);

			buttonData = new GButtonData();
			buttonData.labelData.text = "去副本";
			button = new GButton(buttonData);
			 addChild(button);
			button.addEventListener(MouseEvent.CLICK, toCopy);

			for (var i : int = 0; i < numChildren; i++)
			{
				var dis : DisplayObject = getChildAt(i);
				dis.x = i * 100;
			}

			x = 500;
			y = 180;
		}

		private function toCopy(event : MouseEvent) : void
		{
		}

		private function toNpc(event : MouseEvent) : void
		{
			MapSystem.mapTo.toNpc(106, 2);
		}

		private function toMap(event : MouseEvent) : void
		{
			MapSystem.mapTo.toMap(2, 3601, 822);
		}

		private function open(event : MouseEvent) : void
		{
			WorldMapController.instance.open();
		}
	}
}
