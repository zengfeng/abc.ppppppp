package com.commUI
{
	import log4a.Logger;

	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.layout.GLayout;
	import gameui.manager.UIManager;

	import net.RESManager;

	import com.greensock.TweenLite;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author yangyiqiang
	 */
	public class CommonLoading extends GComponent
	{
		private function initData() : void
		{
			_base.width = UIManager.stage.stageWidth;
			_base.height = UIManager.stage.stageWidth;
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

		private function initView() : void
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
		}

		private var _action : MovieClip;

		private function addAction() : void
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
			TweenLite.to(_topSprite, 2, {y:endY - _topSprite.height, onComplete:super.hide, overwrite:0});
			TweenLite.to(_bottonSprite, 2, {y:endY, overwrite:0});
		}

		private function initHandler(event : Event) : void
		{
			Logger.debug("initHandler");
			if (!_action) return;
			_action["update"]("", 0);
			_topSprite.x = _action.x;
			_bottonSprite.x = _action.x;
			_topSprite.y = -400 + _action.y + 30;
			_bottonSprite.y = _action.y + 600;
		}

		private var _msg : String = "";

		private function changeHandler(event : Event) : void
		{
			if (isSetupMapProgress || isLoadMapProgress) return;
			if (RESManager.instance.model) RESManager.instance.model.calc();
			_msg = "正在加载资源 (" + RESManager.instance.model.done + "/" + RESManager.instance.model.total + ")  " + RESManager.instance.model.speed + " KB/S";
			if (_action)
				updateProgress(_msg, RESManager.instance.model.progress);
		}

		private function completeHandler(event : Event) : void
		{
			Logger.debug("completeHandler");
			_action["update"]("", 100);
			RESManager.instance.model.removeEventListener(Event.COMPLETE, completeHandler);
			this.removeEventListener(Event.ENTER_FRAME, changeHandler);
			if (_isCompleteHide)
				onStop();
		}

		private var _isCompleteHide : Boolean = true;

		public function startShow(isCompleteHide : Boolean = true) : void
		{
			UIManager.root.addChild(this);
			_isCompleteHide = isCompleteHide;
		}

		public function CommonLoading()
		{
			_base = new GComponentData();
			initData();
			super(_base);
			initView();
			RESManager.instance.model.addEventListener(Event.INIT, initHandler);
			RESManager.instance.model.addEventListener(Event.COMPLETE, completeHandler);
			RESManager.instance.model.addEventListener(Event.CHANGE, changeHandler);
		}

		public function setShow() : void
		{
			this.removeEventListener(Event.ENTER_FRAME, changeHandler);
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

		public function open() : void
		{
			this.removeEventListener(Event.ENTER_FRAME, changeHandler);
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

		public function updateProgress(text : String = null, progress : int = 100) : void
		{
			if (!_action) return;
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

		override protected function onShow() : void
		{
			super.onShow();
			GLayout.layout(this);
			this.addEventListener(Event.ENTER_FRAME, changeHandler);
			UIManager.stage.addEventListener(Event.RESIZE, stageResizeHandler2);
		}

		override public function hide() : void
		{
			this.removeEventListener(Event.ENTER_FRAME, changeHandler);
			onStop();
		}
	}
}
