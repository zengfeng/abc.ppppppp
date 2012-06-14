package com.commUI
{
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.layout.GLayout;
	import gameui.manager.UIManager;

	import net.LoadModel;
	import net.RESManager;

	import com.greensock.TweenLite;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author yangyiqiang
	 */
	public class LoaderPanel extends GComponent
	{
		/** 单例对像 */
		private static var _instance : LoaderPanel;

		/** 获取单例对像 */
		public static function get instance() : LoaderPanel
		{
			if (_instance == null)
			{
				_instance = new LoaderPanel();
			}
			return _instance;
		}

		protected var _model : LoadModel;

		private function initData() : void
		{
			_base.width = UIManager.stage.stageWidth;
			_base.height = UIManager.stage.stageWidth;
		}

		override protected function onShow() : void
		{
			super.onShow();
			GLayout.layout(this);
			this.addEventListener(Event.ENTER_FRAME, changeHandler);
			UIManager.stage.addEventListener(Event.RESIZE, stageResizeHandler2);
		}

	    public function stageResizeHandler2(event:Event) : void
		{
			this.graphics.clear();
			this.graphics.beginFill(0x000000);
			this.graphics.drawRect(0, 0, UIManager.stage.stageWidth, UIManager.stage.stageHeight);
			this.graphics.endFill();
			_action.x = (UIManager.stage.stageWidth - 1280) / 2;
			_action.y = (UIManager.stage.stageHeight - 600) / 2;
			_topSprite.x = _action.x;
			_bottonSprite.x = _action.x;
			_topSprite.y = -400 + _action.y + 30;
			_bottonSprite.y = _action.y + 600;
		}

		protected function initView() : void
		{
			this.graphics.beginFill(0x000000);
			this.graphics.drawRect(0, 0, UIManager.stage.stageWidth, UIManager.stage.stageHeight);
			this.graphics.endFill();
			addAction();
			this.mouseEnabled = true;
			this.mouseChildren = false;
			_topSprite = new Sprite();
			_topSprite.graphics.beginFill(0x000000);
			// _topSprite.graphics.beginFill(0x0000ff);
			_topSprite.graphics.drawRect(0, 0, 1300, 400);
			_topSprite.graphics.endFill();
			_bottonSprite = new Sprite();
			_bottonSprite.graphics.beginFill(0x000000);
			// _bottonSprite.graphics.beginFill(0xff00ff);
			_bottonSprite.graphics.drawRect(0, 0, 1300, 400);
			_bottonSprite.graphics.endFill();
			_topSprite.x = _action.x;
			_bottonSprite.x = _action.x;
			_topSprite.y = -400 + _action.y + 130;
			_bottonSprite.y = _action.y + 600;
			addChild(_topSprite);
			addChild(_bottonSprite);
			this.addEventListener(Event.REMOVED, onRemoved);
		}

		private function onRemoved(event : Event) : void
		{
			removeModelEvents();
			this.removeEventListener(Event.ENTER_FRAME, changeHandler);
		}

		private var _action : MovieClip;

		protected function addAction() : void
		{
			_action = RESManager.getLoader("loading").getContent() as MovieClip;
			if (!_action) return;
			_action.x = (UIManager.stage.stageWidth - 1280) / 2;
			_action.y = (UIManager.stage.stageHeight - 600) / 2;
			_action.gotoAndStop(0);
			addChild(_action);
		}

		private var _topSprite : Sprite;

		private var _bottonSprite : Sprite;

		private function onStop() : void
		{
			var endY : int = _action.y + 320;
			TweenLite.to(_topSprite, 2, {y:endY - _topSprite.height, onComplete:clear, overwrite:0});
			TweenLite.to(_bottonSprite, 2, {y:endY, overwrite:0});
		}

		private function clear() : void
		{
			super.hide();
		}

		private function addModelEvents() : void
		{
			_model.addEventListener(Event.INIT, initHandler);
			_model.addEventListener(Event.CHANGE, changeHandler);
			_model.addEventListener(Event.COMPLETE, completeHandler);
		}

		private function removeModelEvents() : void
		{
			if (_model == null) return;
			_model.removeEventListener(Event.INIT, initHandler);
			_model.removeEventListener(Event.CHANGE, changeHandler);
			_model.removeEventListener(Event.COMPLETE, completeHandler);
			this.removeEventListener(Event.ENTER_FRAME, changeHandler);
		}

		private function initHandler(event : Event) : void
		{
			if (!_action) return;
			_action["update"]("", 0);
			_topSprite.x = _action.x;
			_bottonSprite.x = _action.x;
			_topSprite.y = -400 + _action.y + 30;
			_bottonSprite.y = _action.y + 600;
		}

		private function changeHandler(event : Event) : void
		{
			if (isSetupMapProgress || isLoadMapProgress) return;
			if (_model) _model.calc();
			if (_action && _model)
			{
				_action["update"]("正在加载资源 (" + _model.done + "/" + _model.total + ")  " + _model.speed + " KB/S", _model.progress);
			}
		}

		private var _isCompleteHide : Boolean = true;

		public function startShow(isCompleteHide : Boolean = true) : void
		{
			UIManager.root.addChild(this);
			_isCompleteHide = isCompleteHide;
		}

		private function completeHandler(event : Event) : void
		{
			_action["update"]("", 100);
			if (_isCompleteHide)
			{
				onStop();
			}
		}

		public function LoaderPanel()
		{
			_base = new GComponentData();
			initData();
			super(_base);
			initView();
		}

		public function set model(value : LoadModel) : void
		{
			if (_model) removeModelEvents();
			_model = value;
			if (_model) addModelEvents();
		}

		public function setShow() : void
		{
			if (_action) _action["update"]("", 0);
			_topSprite.x = _action.x;
			_bottonSprite.x = _action.x;
			_topSprite.y = -400 + _action.y + 30;
			_bottonSprite.y = _action.y + 600;

			_action.visible = true;
			addChildAt(_action, 0);
			visible = true;
			UIManager.root.addChild(this);
		}

		override public function hide() : void
		{
			this.removeEventListener(Event.ENTER_FRAME, changeHandler);
			model = null;
			onStop();
		}

		public function open() : void
		{
			if (_action) _action["update"]("", 0);
			_topSprite.x = _action.x;
			_bottonSprite.x = _action.x;
			_topSprite.y = -400 + _action.y + 30;
			_bottonSprite.y = _action.y + 600;

			_action.visible = true;
			addChildAt(_action, 0);
			visible = true;
			UIManager.root.addChild(this);
			this.removeEventListener(Event.ENTER_FRAME, changeHandler);
			removeModelEvents();
			_model = null;
		}

		public function close() : void
		{
			onStop();
		}

		public function updateProgress(text : String, progress : int) : void
		{
			_action["update"](text, progress);
		}

		public var isSetupMapProgress : Boolean = false;

		public function setupMapProgress(progress : int) : void
		{
			updateProgress("正在安装地图中....", progress);
		}

		public var isLoadMapProgress : Boolean = false;

		public function loadMapProgress(progress : int) : void
		{
			updateProgress("正在加载地图中....", progress);
		}
	}
}
