package com.commUI.tooltip
{
	import gameui.core.GComponent;
	import gameui.manager.UIManager;

	import com.greensock.TweenLite;

	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;

	public class ToolTipManager
	{
		// ===============================================================
		// @单例
		// ===============================================================
		private static var __instance : ToolTipManager;

		public static function get instance() : ToolTipManager
		{
			if (!__instance)
				__instance = new ToolTipManager();
			return __instance;
		}

		public function ToolTipManager() : void
		{
			if (__instance)
				throw (Error("Singleton Error"));
		}

		// ===============================================================
		// @属性
		// ===============================================================
		private var _toolTips : Dictionary = new Dictionary();
		private var _targetRegister : Dictionary = new Dictionary();
		private var _toolTip : ToolTip;
		private var _target : InteractiveObject;
		private var _enabled : Boolean = true;

		// ===============================================================
		// @方法
		// ===============================================================
		public function set enabled(value : Boolean) : void
		{
			if (_toolTip)
			{
				if (!_enabled && value)
					_toolTip.show();
				else if (!value)
					_toolTip.hide();
			}

			_enabled = value;
		}

		public function get target() : InteractiveObject
		{
			return _target;
		}

		/*
		 * 注册ToolTip鼠标事件
		 * dataPrivider 可以是String/Function/GComponent
		 */
		public function  registerToolTip(target : InteractiveObject, toolTipClass : Class = null, dataProvider : * = null) : void
		{
			if (!target)
				return;
			if (!toolTipClass)
				toolTipClass = ToolTip;

			_targetRegister[target] = {toolTipClass:toolTipClass, dataProvider:dataProvider};

			target.addEventListener(MouseEvent.ROLL_OVER, toolTip_rollOverHandler);
			target.addEventListener(MouseEvent.ROLL_OUT, toolTip_rollOutHandler);
		}

		/*
		 * 注销ToolTip鼠标事件
		 */
		public function destroyToolTip(target : InteractiveObject) : void
		{
			if (_targetRegister[target])
			{
				if (_target == target)
				{
					hideTip();
				}
				target.removeEventListener(MouseEvent.ROLL_OVER, toolTip_rollOverHandler);
				target.removeEventListener(MouseEvent.ROLL_OUT, toolTip_rollOutHandler);
				delete _targetRegister[target];
			}
		}

		public function refreshToolTip(target : InteractiveObject) : void
		{
			// //trace("refreshToolTip" + target);

			if (target == _target)
				updateTip();
		}

		public function toolTip_rollOverHandler(event : MouseEvent) : void
		{
			if (!_enabled)
				return;
			// //trace("鼠标进入");

//			onShowTip(event);
		}

		private function onShowTip(event : MouseEvent) : void
		{
			if (_toolTip)
				hideTip();

			_target = event.target as InteractiveObject;

			updateTip();
		}

		private function updateTip() : void
		{
			if (!_target) return;

			var toolTipClass : Class = _targetRegister[_target]["toolTipClass"];
			var dataProvider : * = _targetRegister[_target]["dataProvider"];

			var oldToolTip : ToolTip = _toolTip;
			_toolTip = getToolTip(toolTipClass);
			if (oldToolTip && oldToolTip != _toolTip)
				oldToolTip.hide();

			if (UIManager.dragModal)
				_toolTip.visible = false;
			else
				_toolTip.visible = true;

//			//trace("updateToolTip");
			if (dataProvider != null)
			{
				if (dataProvider is Function)
					_toolTip.source = dataProvider();
				else if (dataProvider is GComponent)
					_toolTip.source = (dataProvider as GComponent).source;
				else if (dataProvider is String)
					_toolTip.source = dataProvider;
				else
					_toolTip.source = dataProvider;
			}
			else if (_target is GComponent)
				_toolTip.source = (_target as GComponent).source;

			// if (_target is GComponent)
			// (_target as GComponent).toolTip = _toolTip;

			_target.addEventListener(MouseEvent.MOUSE_MOVE, toolTip_mouseMoveHandler);
			if (_target.stage)
				layout(_target.stage.mouseX, _target.stage.mouseY);
			UIManager.root.addChild(_toolTip);

			TweenLite.to(_toolTip, 0.3, {alpha:1});
		}

		private function toolTip_mouseMoveHandler(event : MouseEvent) : void
		{
			layout(event.stageX, event.stageY);
		}

		private function toolTip_rollOutHandler(event : MouseEvent) : void
		{
			// //trace("鼠标移出");
			// if (_toolTip)
			// TweenLite.to(_toolTip, 0.3, {alpha:0, onComplete:onHideTip, onCompleteParams:[event]});
			setTimeout(onHideTip, 0, event);
		}

		private function onHideTip(event : MouseEvent) : void
		{
			var target : InteractiveObject = event.target as InteractiveObject;
			if (target != _target)
			{
		//		//trace("hide fail");
				return;
			}

			hideTip();
		}

		private function hideTip() : void
		{
			if (_target)
			{
				// if (_target is GComponent)
				// (_target as GComponent).toolTip = null;
				_target.removeEventListener(MouseEvent.MOUSE_MOVE, toolTip_mouseMoveHandler);
				_target = null;
			}

			if (_toolTip)
			{
				_toolTip.hide();
				_toolTip = null;
			}
		}

		private function layout(stageX : Number, stageY : Number) : void
		{
			var offset : Point = new Point(stageX, stageY);
			offset.x += 10;
			offset.y += 10;

			if (_toolTip.data.alginMode == 0)
			{
				if (offset.x + _toolTip.width + 10 > UIManager.stage.stageWidth)
					offset.x = offset.x - (_toolTip.width + 10);
				else
					offset.x += 10;

				if (offset.y + _toolTip.height > UIManager.stage.stageHeight && _toolTip.height < offset.y)
					offset.y -= _toolTip.height;

				if (offset.y + _toolTip.height > UIManager.stage.stageHeight && _toolTip.height > offset.y)
					offset.y = UIManager.root.height / 2 - _toolTip.height / 2;
			}
			else if (_toolTip.data.alginMode == 1)
			{
				if (offset.x + _toolTip.width > UIManager.stage.stageWidth)
					offset.x -= _target.width + _toolTip.width;

				if (offset.y + _toolTip.height > UIManager.stage.stageHeight)
					offset.y -= _toolTip.height + _target.height ;

				offset.y -= _target.height + _toolTip.height;
			}
			_toolTip.moveTo(offset.x, offset.y);
			// TweenLite.to(_toolTip, 0.17, {x:offset.x, y:offset.y});
		}

		// ===============================================================
		// @容器
		// ===============================================================
		// reuse ToolTip
		public function getToolTip(toolTipClass : Class, source : *=null, context : *=null) : ToolTip
		{
			if (!toolTipClass is ToolTip)
				return null;

			var toolTip : ToolTip = _toolTips[toolTipClass];

			if (!toolTip)
			{
				toolTip = newToolTip(toolTipClass, source, context);
				_toolTips[toolTipClass] = toolTip;
			}

			return toolTip;
		}

		// create new ToolTip
		public function newToolTip(toolTipClass : Class, source : * = null, context : *= null) : ToolTip
		{
			if (!toolTipClass is ToolTip)
				return null;

			var toolTipData : ToolTipData = new ToolTipData();
			var toolTip : ToolTip = new toolTipClass(toolTipData);

			toolTip.source = source;

			cacheToolTip(toolTipClass, toolTip);

			return toolTip;
		}

		private function cacheToolTip(toolTipClass : Class, toolTip : ToolTip) : void
		{
			if (!_toolTips[toolTipClass])
				_toolTips[toolTipClass] = toolTip;
		}
	}
}
