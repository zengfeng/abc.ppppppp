package game.module.searchTreasure {
	import com.commUI.UIPlayerStatus;
	import com.commUI.alert.Alert;
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import game.core.user.StateManager;
	import game.core.user.UserData;
	import game.module.bossWar.BossWarSystem;
	import game.module.mapBossWar.BWMapController;
	import game.module.mapClanBossWar.MCBWController;
	/**
	 * @author Lv
	 */
	public class SearchTreasureControl {
		private static var _instance :SearchTreasureControl;
		
		//伤害列表  k:玩家id
		public static var playerHarmToBossList:Dictionary = new Dictionary();
		public static var playerharmListVec:Vector.<Object> = new Vector.<Object>();
		
		public function SearchTreasureControl(control:Control):void{
		}
		public static function get instance():SearchTreasureControl{
			if(_instance == null){
				_instance = new SearchTreasureControl(new Control());
			}
			return _instance;
		}
		 // 点击按钮复活
//        public function fun() : void
//        {
//			StateManager.instance.checkMsg(43,[ProxySearchTreasure.playerReliveGold],alertCallFFH);
//        }
//        private function alertCallFFH(type : String) : Boolean
//        {
//            switch(type)
//            {
//                case Alert.OK_EVENT:
//                    ProxySearchTreasure.instance.goldPlayerRelive();
//                    break;
//                case Alert.CANCEL_EVENT:
//                    break;
//            }
//            return true;
//        }

        // 复活时间倒计时    为0时
        public function funTimer() : void
        {
            ProxySearchTreasure.instance.myPlayerReLive();
        }
		
		public function get controller():MCBWController
        {
            return MCBWController.instance;
        }
		//申请进入家族寻宝
		public function applyJoin(): void{
			
		}
		private var uic : SearhTreasureUI;
		
		private var _uiPlayerStatus:UIPlayerStatus = UIPlayerStatus.instance;
		
		//进入家族寻宝
		public function join():void{
			 BossWarSystem.isJoin = true;
			controller.enter();
			setupUI();
		}
		//加载UI
		public function setupUI():void{
			uic = SearhTreasureUI.instance;
			uic.show();
			var id:int = ProxySearchTreasure.bossID;
			var level:int = ProxySearchTreasure.bossLevel;
			//setHarmToBossList();
			//setBossTimer();
			uic.bloodBox.getBossName(id,level);
		}
		//卸载UI
		public function uninstallUI():void{
			 BossWarSystem.isJoin = false;
			controller.quit();
			uic.clear();
		}
		//玩家为族长在地穴未开启时点击
		public function setupSelectDateUI():void{
			
		}
		//关闭族长打开的日期选择面板
		public function uninstallSelectDateUI():void{
			
		}
		//申请推出家族寻宝
		public function applyOut():void{
			ProxySearchTreasure.instance.outToCrypt();
		}
		//更新Boss血量  harm:对boss的伤害
		public function refreshBossBlood(upBlood:int):void{
			if (uic == null ) return;
			var total:uint = ProxySearchTreasure.bossTotalBlood;
			var harm:uint = ProxySearchTreasure.bossRestBlood;
			var img:Vector.<Bitmap> = ProxySearchTreasure.bossBloodVec;
			uic.bloodBox.refreshBossBlood(upBlood,harm,total,img);
		}
		private var nameVec:Vector.<String> = new Vector.<String>();
		private var colorVec:Vector.<uint> = new Vector.<uint>();
		private var bloodVec:Vector.<uint> = new Vector.<uint>();
		//更新玩家对boss伤害排名
		public function refreshRanking():void{
			if (uic == null ) return;
			//清空 重新push
			if(nameVec.length>0)clearnVec();
			var total:uint = ProxySearchTreasure.bossTotalBlood;
			uic.familyPlayer.addRankPanel(nameVec, colorVec, bloodVec, total);
		}
		//设置boss战的时间 boss名称  boss级别等  一次设置
		public function setBossTimer():void{
			var timer:int = ProxySearchTreasure.warTimer;
			var bossID:int = ProxySearchTreasure.bossID;
			var bossLevel:int = ProxySearchTreasure.bossLevel;
			if (uic == null ) return;
			uic.familyPlayer.setChallageLastTimer(timer);
			uic.bloodBox.getBossName(bossID, bossLevel);
			refreshBossBlood(0);
		}
		//更新boss战伤害列表
		public function setHarmToBossList():void{
			var myID:int = UserData.instance.playerId;
			var harm:uint = 0;
			var total:uint;
			if (uic == null ) return;
			total = ProxySearchTreasure.bossTotalBlood;
			if(nameVec.length>0)
				clearnVec();
			else if(nameVec.length == 0)
				pushToVec();
			uic.familyPlayer.addRankPanel(nameVec, colorVec, bloodVec, total);
			if(SearchTreasureControl.playerHarmToBossList[myID])
				harm = SearchTreasureControl.playerHarmToBossList[myID].dmg;
			uic.familyPlayer.myHeroBloodToBoss(harm,total);
		}
		//玩家自己对boss的伤害
		public function myPlayerToBossHarm():void{
			var total:uint = ProxySearchTreasure.bossTotalBlood;
			if (uic == null ) return;
//			uic.familyPlayer.myHeroBloodToBoss(,total)
		}
//--------------------------------------------------------------------------------
		//清空 重新push
		private function clearnVec() : void {
			while(nameVec.length>0){
				nameVec.splice(0, 1);
				colorVec.splice(0, 1);
				bloodVec.splice(0, 1);
			}
			
			pushToVec();
		}

		private function pushToVec() : void {
			for each(var obj:Object in playerharmListVec){
				var name:String = obj.name;
				var color:String = obj.color;
				var blood:uint = obj.dmg;
				if(blood == 0)return;
				nameVec.push(name);
				colorVec.push(color);
				bloodVec.push(blood);
			}
		}
		
		
		//TODO
		public function setReviveTime(playerReliveTimer : uint) : void {
			_uiPlayerStatus.setCDTime(playerReliveTimer);
			_uiPlayerStatus.cdQuickenBtnCall = ProxySearchTreasure.instance.goldPlayerRelive ;
			_uiPlayerStatus.cdCompleteCall = funTimer ;
			_uiPlayerStatus.cdTimer.setTimersTip(10);
		}
		
		//TODO
		public function stopReviveTime() : void {
			_uiPlayerStatus.stopCDTime();
		}
		
	}
}
class Control{}