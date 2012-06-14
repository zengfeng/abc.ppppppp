package game.module.bossWar {
	import flash.display.Sprite;
	import flash.display.Stage;
	import game.manager.ViewManager;
	import game.module.duplMap.ui.NextDoButton;
	import gameui.manager.UIManager;



	/**
	 * @author 1
	 */
	public class BossWarUIC extends Sprite {
		
		function BossWarUIC(singleton : Singleton):void
		{
			singleton;
			initViews();
            
            mouseEnabled = false;
            mouseChildren = false;
		}
		
		/** 单例对像 */
		private static var _instance : BossWarUIC;
		/** 获取单例对像 */
		public static function get instance() : BossWarUIC {
			if (_instance == null) {
				_instance = new BossWarUIC(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		
		public var bloodBox : BossBloodBoxPanel;
		public var harmRanking : BossHarmRanking;
		private var _viewManager : ViewManager;
        public var nextDoButton:NextDoButton;
		

		private function get viewManager() : ViewManager {
			if (_viewManager == null) {
				_viewManager = ViewManager.instance;
			}
			return _viewManager;
		}

		private var _stage : Stage;

		override public function get stage() : Stage {
			if (_stage == null) {
				_stage = UIManager.stage;
			}
			return _stage;
		}

		public function clear() : void {
			ViewManager.removeStageResizeCallFun(stageResize);
			hide();
		}

		private function stageResize(stage:Stage = null, preStageWidth:Number = 0, preStageHeight:Number = 0) : void {
			if(bloodBox == null) return;
			bloodBox.x = (stage.stageWidth - bloodBox.width) / 2 + 70;
			bloodBox.y = 15;
			harmRanking.x = stage.stageWidth - harmRanking.width - 10;
			harmRanking.y = 200;
            nextDoButton.x = (stage.stageWidth - nextDoButton.width) / 2;
		}

		public function initViews() : void {
			bloodBox = new BossBloodBoxPanel();
			bloodBox.x = (stage.stageWidth - bloodBox.width) / 2  + 70;
			bloodBox.y = 15;
			addChild(bloodBox);
			
			harmRanking = new BossHarmRanking();
			harmRanking.x = stage.stageWidth - harmRanking.width - 10;
			harmRanking.y = 200;
			addChild(harmRanking);
			viewManager.addToStage(this);
			ViewManager.addStageResizeCallFun(stageResize);
            
			nextDoButton = new NextDoButton();
            nextDoButton.x = (stage.stageWidth - nextDoButton.width) / 2;
            nextDoButton.y = 85;
		}
		
		public function show():void
		{
			if(this.parent == null) viewManager.addToStage(this);
			if(nextDoButton.parent == null) viewManager.addToStage(nextDoButton);
		}
		
		public function hide():void
		{
			if(this.parent) this.parent.removeChild(this);
			if(nextDoButton.parent)  nextDoButton.parent.removeChild(nextDoButton);
		}
	}
}

class Singleton
{
	
}
