package game.module.bossWar {
	import com.commUI.alert.Alert;
	import com.commUI.button.ExitButton;
	import game.core.user.StateManager;
	import game.core.user.UserData;
	import game.manager.ViewManager;
	import game.module.map.MapSystem;
	import game.module.mapBossWar.BWMapController;


	/**
	 * @author Lv
	 */
	public class BossWarControl {
		private static var _instance : BossWarControl;
		// 参加boss战的玩家的颜色   前10名
		public static var joinBossWarPlayerColor : Vector.<uint> = new Vector.<uint>();
		// 参加boss战的玩家名称    前10名
		public static var joinBossWarPlayerName : Vector.<String> = new Vector.<String>();
		// 参加boss战的玩家对boss的一次伤害总值     前10名
		public static var joinBossWarPlayerBlood : Vector.<uint> = new Vector.<uint>();
		// 玩家自己对boss的伤害
		public static var mypalyeToBossHarm : uint = 0;
		// 玩家自己死亡的时间
		public static var myPlayerDieTimer : uint;
		public static var hasMyPlayerDieTimer:Boolean = false;
		public static var isKindsApple : int = 5;
		public static var myHeroID : int;

		public function BossWarControl(s : Control) : void {
			bwMapController.fastReviveButtonClickCall = fun;
			bwMapController.reviveCompleteCall = funTimer;
		}

		private var playReviveAlert:Alert;
		// 点击按钮复活
		public function fun() : void {
			playReviveAlert = StateManager.instance.checkMsg(43, [ProxyBossWar.revivePic], alertCallFFH);
		}

		private function alertCallFFH(type : String) : Boolean {
			switch(type) {
				case Alert.OK_EVENT:
					ProxyBossWar.instance.bossWarGoldRelive();
					break;
				case Alert.CANCEL_EVENT:
					break;
			}
			return true;
		}

		// 复活时间倒计时    为0时
		public function funTimer() : void {
			ProxyBossWar.instance.myPlayerRelive();
			if(playReviveAlert)
			{
				playReviveAlert.close();
			}
		}

		public static function get instance() : BossWarControl {
			if (_instance == null) {
				_instance = new BossWarControl(new Control());
			}
			return _instance;
		}

		private var _bwMapController : BWMapController;

		private function get bwMapController() : BWMapController {
			if (_bwMapController == null) {
				_bwMapController = BWMapController.instance;
			}
			return _bwMapController;
		}

		// BOSS战开放   时间到
		public function bossWarTiemrStar() : void {
		}

		// BOSS出现
		public function sc_open() : void {
		}

		// boss战结束
		public function sc_close() : void {
//			bwMapController.close();
			sc_quit();
		}

		/**
		 * 推出boss战面板
		 */
		public function sc_quit() : void {
			BossWarSystem.isJoin = false;
			bwMapController.quit();
			ViewManager.refreshShowState();
			if (uic) {
				uic.clear();
			}
            ExitButton.instance.setVisible(false, null);
		}

		public function cs_quit() : void {
			ProxyBossWar.instance.quickBossWar();
		}

		public function cs_join() : void {
			sc_join();
		}
		
		public function sc_join() : void {
			BossWarSystem.isJoin = true;
			bwMapController.enter();
			ViewManager.refreshShowState();
			setupUI();
            ExitButton.instance.setVisible(true, cs_quit);
		}

		private var uic : BossWarUIC;

		public function setupUI() : void {
			uic = BossWarUIC.instance;
            bwMapController.nextDoButton = uic.nextDoButton;
			uic.show();
			bossWarTimerShow();
			timer();
			bossHarmRowList();
		}

		// boss战某玩家状态   死亡   id  玩家id
		public function bossWarPalyerStaticDie(id : int) : void {
			var tiemr : int = BossWarControl.myPlayerDieTimer;
			bwMapController.die(id);
			if (id == UserData.instance.playerId) {
				if(!BossWarControl.hasMyPlayerDieTimer)
					bwMapController.setReviveTime(tiemr);
				bwMapController.setReviveBtnTips(ProxyBossWar.revivePic);
			}
		}

		// boss战某玩家状态   复活  id  玩家id
		public function bossWarPlayerStaticRelive(id : int) : void {
			bwMapController.revive(id);
		}

		/**
		 * 申请boss信息
		 */
		public function ApplicationCS() : void {
			ProxyBossWar.instance;
		}

		/**
		 * 进入boss战后屏蔽的面板
		 */
		public  function shieldedPanel() : void {
			ApplicationCS();
		}

		/**
		 * 英雄死亡
		 */
		public function heroDie() : void {
			MapSystem.selfPlayerAnimal.die();
		}

		/**
		 * Boss血量变化控制
		 */
		public function bossBloodControl() : void {
			if (uic == null ) return;
			var upBlood : uint = ProxyBossWar.bossHarmValue;
			var total : int = ProxyBossWar.bossBloodTotal;
			var harmNow : int = ProxyBossWar.bossBloodNow;
			uic.bloodBox.refreshBossBlood(upBlood, harmNow, total, ProxyBossWar.bossBloodVec);
		}

		/**
		 * 刷新boss战的时间
		 */
		public function bossWarTimerShow() : void {
			if (uic == null ) return;
			var total : int = ProxyBossWar.bossBloodTotal;
			var harmNow : uint = ProxyBossWar.bossBloodNow;
			var upBlood : uint = ProxyBossWar.bossHarmValue;
			uic.bloodBox.refreshBossBlood(upBlood, harmNow, total, ProxyBossWar.bossBloodVec);
			// myPalyerHarmBoss();
		}

		/**
		 * 更新boss伤害的玩家排序列表
		 */
		public function bossHarmRowList() : void {
			var name : Vector.<String> = BossWarControl.joinBossWarPlayerName;
			var color : Vector.<uint> = BossWarControl.joinBossWarPlayerColor;
			var Blood : Vector.<uint> = BossWarControl.joinBossWarPlayerBlood;
			var total : uint = ProxyBossWar.bossBloodTotal;
			if (uic == null ) return;
			uic.harmRanking.addRankPanel(name, color, Blood, total);
		}

		/**
		 * 玩家自己对boss的伤害更新
		 */
		public function myPalyerHarmBoss() : void {
			var total : uint = ProxyBossWar.bossBloodTotal;
			var harm : uint = BossWarControl.mypalyeToBossHarm;
			if (uic == null ) return;
			uic.harmRanking.myHeroBloodToBoss(harm, total);
		}

		public function timer() : void {
			var id : int = ProxyBossWar.bossID;
			var level : int = ProxyBossWar.bossLevel;
			if (uic == null ) return;
			uic.harmRanking.setChallageLastTimer(ProxyBossWar.bossWarData);
			uic.bloodBox.getBossName(id, level);
		}

		// 清空玩家对boss的伤害列表
		public function playerToBossHarmList() : void {
			if (uic == null ) return;
			uic.harmRanking.removeList();
			uic.harmRanking.clearnMyHeroBlood();
		}
	}
}
class Control {
}