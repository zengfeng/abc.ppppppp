package game.module.demonTower {
	import game.module.duplMap.DuplUtil;
	import game.net.core.Common;
	import game.net.data.CtoC.CCVIPLevelChange;
	import game.net.data.CtoS.CSAutoDemon;
	import game.net.data.CtoS.CSAutoDemonComplete;
	import game.net.data.CtoS.CSAutoDemonStop;
	import game.net.data.CtoS.CSChallengeDemon;
	import game.net.data.CtoS.CSQueryDemon;
	import game.net.data.StoC.SCAutoDemon;
	import game.net.data.StoC.SCChallengeDemon;
	import game.net.data.StoC.SCDemonCount;

	/**
	 * @author Lv
	 */
	public class DemonProxy {
		private static var _instance : DemonProxy;
		public static var demonTimes : int;
		// 是否收费  falsh ： 不收费   true：收费
		public static var isCharge : Boolean;
		public static var isOpend : Boolean = false;
		// 未通过挑战次数
		public static var noPassChallengTimes : int;
		// 切换down面板
		public static var openDown:Boolean = false;
		//当前层号
		public static var nowlayerNumbeer:int;
		
		//当前购买1次所需的元宝数
		public static var BUY_ONCE_MONEY:int = 200;
		
		//一次锁妖所需的包裹空位
		public static var NEED_PAGE:int = 3;

		public function DemonProxy(contral : Contral) : void {
			contral;
			cTos();
		}

		public static function get instance() : DemonProxy {
			if (_instance == null)
				_instance = new DemonProxy(new Contral());
			return _instance;
		}

		private function cTos() : void {
			// 更新锁妖次数信息
			Common.game_server.addCallback(0x88, sCDemonCount);
			// 挑战锁妖
			Common.game_server.addCallback(0x89, sCChallengeDemon);
			// 锁妖挂机
			Common.game_server.addCallback(0x8A, sCAutoDemon);
			//VIP 等级改变
			Common.game_server.addCallback(0xFFF7, cCVIPLevelChange);
		}
		//VIP 等级改变
		private function cCVIPLevelChange(e:CCVIPLevelChange) : void {
			if(e.level > 0){
				isShow = true;
				checkManage(DemonProxy.nowlayerNumbeer);
			}
		}

		// 锁妖挂机
		private function sCAutoDemon(msg : SCAutoDemon) : void {
			HangUpPanelContollor.instance.windowHook_scInfo(msg);
		}

		// 挑战锁妖结果
		private function sCChallengeDemon(e : SCChallengeDemon) : void {
			isShow = true;
			checkManage(DemonProxy.nowlayerNumbeer);
		}

		public static var isShow : Boolean = false;
		public static var isHangup : Boolean = false;

		// 更新锁妖次数信息
		private function sCDemonCount(e : SCDemonCount) : void {
			noPassChallengTimes = (e.countLeft >> 7) & 0x3F;
			demonTimes = e.countLeft & 0x3F;
			var con : int = (e.countLeft >> 6) & 1;
			if (con == 1) {
				isCharge = true;
			} else if (con == 0) {
				isCharge = false;
			}
			
//			if (DemonProxy.isShow) {
				DemonContral.instance.refreshView();
//				isShow = false;
//			}
			
			if (openDown) {
				openDown = false;
				DemonContral.instance.OpenWindowDown();
			}
			
			if (isHangup) {
				HangUpPanelContollor.instance.windowHookHangup(demonTimes, !isCharge);
				isHangup = false;
			}
			
			DemonContral.instance.refreshChallenTiemr();
			DemonContral.instance.openBoss();
			
		}

		// -------------------------cToS--------------------------------------------------
		// 挑战锁妖
		public function challengeBoss(index : int) : void {
			var cmd : CSChallengeDemon = new CSChallengeDemon();
			cmd.demonId = index;
			Common.game_server.sendMessage(0x89, cmd);
		}

		// 查询锁妖信息
		public function checkManage(index : int = 0) : void {
//			if (index != 0) openDown = true;
			var cmd : CSQueryDemon = new CSQueryDemon();
			cmd.demonId = index;
			Common.game_server.sendMessage(0x88, cmd);
		}

		// 锁妖挂机
		public function hangupDemon(id : int, num : int) : void {
			var bossID : int = DuplUtil.getDemonBossIdByDuplMapId(id);
			var cmd : CSAutoDemon = new CSAutoDemon();
			cmd.demonId = bossID;
			cmd.count = num;
			Common.game_server.sendMessage(0x8A, cmd);
		}

		// 中止锁妖挂机
		public function stopHangupDemon() : void {
			var cmd : CSAutoDemonStop = new CSAutoDemonStop();
			Common.game_server.sendMessage(0x8B, cmd);
		}

		// 锁妖挂机加速完成
		public function quickenComplete() : void {
			var cmd : CSAutoDemonComplete = new CSAutoDemonComplete();
			Common.game_server.sendMessage(0x8C, cmd);
		}
	}
}
class Contral {
}
