package game.module.mapWorld
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	public class WorldMapSWF extends Sprite implements IWorldMapSWF
	{
		public var leaveButton : DisplayObject;
		public var mapIconOnDic : Dictionary = new Dictionary();
		public var mapIconOn_1 : DisplayObject;
		public var mapIconOn_2 : DisplayObject;
		public var mapIconOn_3 : DisplayObject;
		public var mapIconOn_4 : DisplayObject;
		public var mapIconOn_5 : DisplayObject;
		public var mapIconOn_6 : DisplayObject;
		public var mapIconOn_7 : DisplayObject;
		public var mapIconOn_8 : DisplayObject;
		public var mapIconOn_9 : DisplayObject;
		public var mapIconOn_10 : DisplayObject;
		public var mapIconOn_11 : DisplayObject;
		public var mapIconOn_12 : DisplayObject;
		public var mapIconOn_20 : DisplayObject;
		public var wayOn : MovieClip;
		public var mapIconOffDic : Dictionary = new Dictionary();
		public var mapIconOff_1 : DisplayObject;
		public var mapIconOff_2 : DisplayObject;
		public var mapIconOff_3 : DisplayObject;
		public var mapIconOff_4 : DisplayObject;
		public var mapIconOff_5 : DisplayObject;
		public var mapIconOff_6 : DisplayObject;
		public var mapIconOff_7 : DisplayObject;
		public var mapIconOff_8 : DisplayObject;
		public var mapIconOff_9 : DisplayObject;
		public var mapIconOff_10 : DisplayObject;
		public var mapIconOff_11 : DisplayObject;
		public var mapIconOff_12 : DisplayObject;
		public var mapIconOff_20 : DisplayObject;

		public function WorldMapSWF()
		{
			mapIconOnDic[1] = mapIconOn_1;
			mapIconOnDic[2] = mapIconOn_2;
			mapIconOnDic[3] = mapIconOn_3;
			mapIconOnDic[4] = mapIconOn_4;
			mapIconOnDic[5] = mapIconOn_5;
			mapIconOnDic[6] = mapIconOn_6;
			mapIconOnDic[7] = mapIconOn_7;
			mapIconOnDic[8] = mapIconOn_8;
			mapIconOnDic[9] = mapIconOn_9;
			mapIconOnDic[10] = mapIconOn_10;
			mapIconOnDic[11] = mapIconOn_11;
			mapIconOnDic[12] = mapIconOn_1;
			mapIconOnDic[20] = mapIconOn_20;

			mapIconOffDic[1] = mapIconOff_1;
			mapIconOffDic[2] = mapIconOff_2;
			mapIconOffDic[3] = mapIconOff_3;
			mapIconOffDic[4] = mapIconOff_4;
			mapIconOffDic[5] = mapIconOff_5;
			mapIconOffDic[6] = mapIconOff_6;
			mapIconOffDic[7] = mapIconOff_7;
			mapIconOffDic[8] = mapIconOff_8;
			mapIconOffDic[9] = mapIconOff_9;
			mapIconOffDic[10] = mapIconOff_10;
			mapIconOffDic[11] = mapIconOff_11;
			mapIconOffDic[12] = mapIconOff_1;
			mapIconOffDic[20] = mapIconOff_20;

			leaveButton.addEventListener(MouseEvent.CLICK, leaveButton_clickHandler);
		}

		/** 点击离开按钮 */
		private function leaveButton_clickHandler(event : MouseEvent) : void
		{
			if (leaveClickCall != null) leaveClickCall.apply();
		}

		/** 离开按钮回调 */
		private var _leaveClickCall : Function;

		public function get leaveClickCall() : Function
		{
			return _leaveClickCall;
		}

		public function set leaveClickCall(fun : Function) : void
		{
			_leaveClickCall = fun;
		}

		/** 去某个地图回调 */
		private var _toMapCall : Function;

		public function set toMapCall(fun : Function) : void
		{
			_toMapCall = fun;
		}

		public function get toMapCall() : Function
		{
			return _toMapCall;
		}

		/** 开放某个地图 */
		public function mapOn(mapId : int) : void
		{
			mapSwitch(mapId, true);
		}

		/** 封印某个地图 */
		public function mapOff(mapId : int) : void
		{
			mapSwitch(mapId, false);
		}

		private var mapOnOffDic : Dictionary = new Dictionary();

		/** 设置是否显示 */
		public function mapSwitch(mapId : int, on : Boolean) : void
		{
			if (mapOnOffDic[mapId] != null && mapOnOffDic[mapId] == on)
			{
				return;
			}

			mapOnOffDic[mapId] = on;
			// 获取开放地图图标
			var displayObject : DisplayObject = getMapIconOn(mapId);
			if (displayObject == null) return;
			displayObject.visible = on;
			if (displayObject.visible == true) displayObject.addEventListener(MouseEvent.CLICK, mapBtnOnClick);
			// 获取封印地图图标
			displayObject = getMapIconOff(mapId);
			displayObject.visible = !on;
			trace(mapId);
			if (on)
			{
				// 获取开放地图路线
				if (mapId == 20)
				{
					wayOn.gotoAndStop(4);
				}
				else
				{
					wayOn.gotoAndStop(mapId);
				}
			}
		}

		private function mapBtnOnClick(event : MouseEvent) : void
		{
			var displayObject : DisplayObject = event.target as DisplayObject;
			var arr : Array = displayObject.name.split("_");
			var mapId : int = parseInt(arr[arr.length - 1]);
			if (toMapCall != null) toMapCall.apply(null, [mapId]);
		}

		/** 获取开放地图图标 */
		public function getMapIconOn(mapId : int) : DisplayObject
		{
			return mapIconOnDic[mapId];
		}

		/** 获取封印地图图标 */
		public function getMapIconOff(mapId : int) : DisplayObject
		{
			return mapIconOffDic[mapId];
		}

		/** 获取地图位置 */
		public function getMapPosition(mapId : int) : Point
		{
			var displayObject : DisplayObject = getMapIconOn(mapId);
			if (displayObject == null) return null;
			var point : Point = new Point(displayObject.x, displayObject.y);
			point.x += displayObject.width / 2;
			point.y += displayObject.height / 2;
			return point;
		}
	}
}
