package game.module.tasteTea
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import game.manager.ViewManager;
	import gameui.manager.UIManager;



	/**
	 * @author Lv
	 */
	public class TasteTeaUI extends Sprite {
		private static var _instance:TasteTeaUI;
		public var tastePanel:TastePanel;
		public function TasteTeaUI(control:Control) {
			control;
			initViews();
		}
		
		public static function get instance():TasteTeaUI{
			if(_instance == null){
				_instance = new TasteTeaUI(new Control());
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

		private function initViews() : void {
			tastePanel = new TastePanel();
			tastePanel.x = (stage.stageWidth - tastePanel.width) / 2;
			tastePanel.y = (stage.stageHeight - tastePanel.height) / 2;
			addChild(tastePanel);
			viewManager.addToStage(this);
			ViewManager.addStageResizeCallFun(stageResize);
			
		}
		
		private function stageResize(...arg) : void {
			if(tastePanel == null) return;
			tastePanel.x = (stage.stageWidth - tastePanel.width) / 2;
			tastePanel.y = (stage.stageHeight - tastePanel.height) / 2;
		}
		
		public function clear() : void {
			this.removeChild(tastePanel);
			ViewManager.removeStageResizeCallFun(stageResize);
			hide();
		}
		
		public function show():void
		{
			if(this.parent == null) initViews();
			tastePanel.x = (stage.stageWidth - tastePanel.width) / 2;
			tastePanel.y = (stage.stageHeight - tastePanel.height) / 2;
		}
		
		public function hide():void
		{
			if(this.parent) this.parent.removeChild(this);
		}
	}
}
class Control{}
