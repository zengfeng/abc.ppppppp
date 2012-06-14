package game.module.demonTower
{
	import game.core.menu.MenuManager;
	import game.core.menu.MenuType;
	import game.module.duplMap.data.DuplStruct;
	import game.net.core.Common;
	import game.net.data.CtoC.CCSendDemonToMassage;
	/**
	 * @author Lv
	 */
	public class DemonContral {
		private static var _instance:DemonContral;
		public function DemonContral(contral:Contral):void{}
		public static function get instance():DemonContral{
			if(_instance == null)
				_instance = new DemonContral(new Contral());
			return _instance;
		}
		private var _demonDown:DemonDownPanel;
		private var _demonUp:DemonUpPanel;
		public function get demonDown():DemonDownPanel{
			if(_demonDown == null)
				_demonDown = new DemonDownPanel();
			return _demonDown;
		}
		
		public function get demonUp():DemonUpPanel{
			if(_demonUp == null)
				_demonUp = new DemonUpPanel();
			return _demonUp;
		}
		
//		private var _demon:DemonTowerView;
		//主面板
//		public function stepUp():void{
//			if(_demon == null){
//				_demon = new DemonTowerView();
//				changeBossCave();
//				_demonUp.starInto();
//			}
//			_demon.show();
//		}
		
		public function hangUpOpenView():void{
			if(!DemonProxy.isOpend)return;
			MenuManager.getInstance().openMenuView(MenuType.LOCK_DEMON_TOWER);
		}
		
		public function quitDemon():void{
			if(!DemonProxy.isOpend)return;
			MenuManager.getInstance().closeMenuView(MenuType.LOCK_DEMON_TOWER);
		}
		
		public function refreshView():void{
			if(!DemonProxy.isOpend)return;
			var cmd:CCSendDemonToMassage = new CCSendDemonToMassage();
			Common.game_server.sendCCMessage(0xFFF9,cmd);
		}
		
		//改变要挑战的层boss	
		public function changeLayerBoss(demon:DuplStruct):void{
			if(!DemonProxy.isOpend)return;
			_demonDown.refreshData(demon);
		}
		
		//开启新的downPanle
		public function OpenWindowDown():void{
			if(!DemonProxy.isOpend)return;
			_demonUp.OpenDownPenl();
			refreshView();
		}
		//刷新挑战次数
		public function refreshChallenTiemr():void{
			if(!DemonProxy.isOpend)return;
			_demonDown.refreshText();
		}
		//刷新boss洞穴
		public function changeBossCave():void{
			if(!DemonProxy.isOpend)return;
			_demonUp.refreshData();
			changeStarInto();
		}
		public function changeStarInto():void{
			if(!DemonProxy.isOpend)return;
			_demonUp.starInto();
		}
		//开放boss
		public function openBoss():void{
			if(!DemonProxy.isOpend)return;
			_demonDown.refreshMonster();
		}
		
//		Common.game_server.executeCallback(new RequestData(0xffff2, "hiuh"));
//			Common.game_server.addCallback(0xffff2, callback);
//		}
//
//		private function callback(str:String) : void {
//		}
		
	}
}
class Contral{}
