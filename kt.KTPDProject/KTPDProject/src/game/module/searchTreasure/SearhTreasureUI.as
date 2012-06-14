package game.module.searchTreasure {
	import flash.display.Sprite;
	import flash.display.Stage;
	import game.manager.ViewManager;
	import game.module.bossWar.BossBloodBoxPanel;
	import game.module.bossWar.BossHarmRanking;
	import gameui.manager.UIManager;
	/**
	 * @author Lv
	 */
	public class SearhTreasureUI extends Sprite {
		private static var _instance :SearhTreasureUI;
		public function SearhTreasureUI(control:Control):void{
			control;
			initViews();
		}
		
		public static function get instance():SearhTreasureUI{
			if(_instance == null){
				_instance = new SearhTreasureUI(new Control());
				_instance.mouseChildren=false;
                _instance.mouseEnabled=false;
			}
			return _instance;
		}
		
		private var _stage : Stage;
		override public function get stage() : Stage {
			if (_stage == null) {
				_stage = UIManager.stage;
			}
			return _stage;
		}
		
		private var _viewManager : ViewManager;
		
		private function get viewManager() : ViewManager {
			if (_viewManager == null) {
				_viewManager = ViewManager.instance;
			}
			return _viewManager;
		}
		
		public var familyPlayer:BossHarmRanking;
		public var bloodBox : BossBloodBoxPanel;
		public var cryptSearch:CryptSearch;
		
		
		private function initViews() : void {
			bloodBox = new BossBloodBoxPanel();
			bloodBox.x = (stage.stageWidth - bloodBox.width) / 2;
			bloodBox.y = 10;
			addChild(bloodBox);
			
			familyPlayer = new BossHarmRanking();
			familyPlayer.x = stage.stageWidth - familyPlayer.width - 2;
			familyPlayer.y = (stage.stageHeight - familyPlayer.height) / 2;
			addChild(familyPlayer);
		}
		
		public function showTipsBox():void{
			cryptSearch = new CryptSearch();
			cryptSearch.x = (stage.stageWidth - bloodBox.width) / 2;
			cryptSearch.y = (stage.stageHeight - bloodBox.height) / 2;
			addChild(cryptSearch);
		}
		public function hidTipsBox():void{
			removeChild(cryptSearch);
		}
		
		public function clear() : void {
			ViewManager.removeStageResizeCallFun(stageResize);
			hide();
		}

		private function stageResize(stage:Stage = null, preStageWidth:Number = 0, preStageHeight:Number = 0) : void {
			if(bloodBox == null) return;
			bloodBox.x = (stage.stageWidth - bloodBox.width) / 2;
			bloodBox.y = 10;
			familyPlayer.x = stage.stageWidth - familyPlayer.width - 2;
			familyPlayer.y = (stage.stageHeight - familyPlayer.height) / 2;
		}
		public function show():void
		{
			if(this.parent == null) viewManager.addToStage(this);
		}
		
		public function hide():void
		{
			if(this.parent) this.parent.removeChild(this);
		}
		
	}
}
class Control{}
