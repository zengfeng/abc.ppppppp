package game.module.mapClanBossWar
{
	import game.module.battle.view.BTSystem;
	import game.module.map.BarrierOpened;
	import game.module.map.CurrentMapData;
	import game.module.map.MapProto;
	import game.module.map.MapSystem;
	import game.module.map.animal.AnimalManager;
	import game.module.map.animal.PlayerAnimal;
	import game.module.map.animal.SelfPlayerAnimal;
	import game.net.core.Common;
	import game.net.data.StoC.SCPlayerWalk;
	import game.net.data.StoC.SCTransport;

	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;


	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-13 ����2:28:53
	 */
	public class MCBWController
	{
		function MCBWController(singleton : Singleton) : void
		{
			singleton;
		}

		/** 单例对像 */
		private static var _instance : MCBWController;
//		private var _uiPlayerStatus:UIPlayerStatus = UIPlayerStatus.instance ;

		/** 获取单例对像 */
		public static function get instance() : MCBWController
		{
			if (_instance == null)
			{
				_instance = new MCBWController(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 当前地图数据 */
		private var _currData : CurrentMapData;

		/** 当前地图数据 */
		public function get currData() : CurrentMapData
		{
			if (_currData == null)
			{
				_currData = CurrentMapData.instance;
			}
			return _currData;
		}

		private var animalManger : AnimalManager = AnimalManager.instance;

		public function get selfPlayer() : SelfPlayerAnimal
		{
			return animalManger.selfPlayer;
		}

		public function getPlayer(playerId : int) : PlayerAnimal
		{
			return animalManger.getPlayer(playerId);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 进入 */
		public function enter() : void
		{
			// 清理死亡玩家
			clearDiePlayer();
			// initPathPass();

			// 协议监听 -- 0x20 玩家走路
			Common.game_server.addCallback(0x20, sc_playerWalk);
			// 协议监听 -- 0x25 直接传送
			Common.game_server.addCallback(0x25, sc_transport);
			enterTime = getTimer();
		}

		private var enterTime : Number = 0;

		/** 退出 */
		public function quit() : void
		{
			// 协议监听 -- 0x20 玩家走路
			Common.game_server.removeCallback(0x20, sc_playerWalk);
			// 协议监听 -- 0x25 直接传送
			Common.game_server.removeCallback(0x25, sc_transport);

			// 复活
			revive();
			// 复活所有死亡玩家
			reviveAllDiePlayer();
			// 清理死亡玩家
			clearDiePlayer();
		}

		/** 进入地图时初始化关卡 */
		public function initPathPass() : void
		{
			if (isSelfDie == false)
			{
				openDiePassPath();
			}
			else
			{
				setPlayerDie(selfPlayer.id);
			}
		}

		/** 开放复活路口 */
		private function openDiePassPath() : void
		{
			BarrierOpened.setState(MCBWConfig.diePassColor, true);
		}

		/** 关闭复活路口 */
		private function closeDiePassPath() : void
		{
			BarrierOpened.setState(MCBWConfig.diePassColor, false);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 自己是否死亡 */
		private var isSelfDie : Boolean = false;

		/** 玩家走路 */
		private function sc_playerWalk(msg : SCPlayerWalk) : void
		{
			if (MapSystem.hideServerMode == false)
			{
                var toX : int = msg.xy & 0x3FFF;
                var toY : int = msg.xy >> 14;
				checkPlayerIsReive(msg.playerId, toX, toY);
			}
		}

		/** 协议监听 -- 0x25 传送 */
		private function sc_transport(msg : SCTransport) : void
		{
			checkPlayerIsDie(msg.playerId);
		}

		/** 死亡玩家列表 */
		private var diePlayerList : Vector.<uint> = new Vector.<uint>();

		/** 加入死亡玩家 */
		private function addDiePlayer(playerId : int) : void
		{
			var index : int = diePlayerList.indexOf(playerId);
			if (index == -1)
			{
				diePlayerList.push(playerId);
			}
		}

		/** 移除死亡玩家 */
		private function removeDiePlayer(playerId : int) : void
		{
			var index : int = diePlayerList.indexOf(playerId);
			if (index != -1)
			{
				diePlayerList.splice(index, 1);
			}
		}

		/** 清理死亡玩家 */
		private function clearDiePlayer() : void
		{
			while (diePlayerList.length > 0)
			{
				diePlayerList.shift();
			}
		}

		/** 是否死亡 */
		private function isDie(playerId : int) : Boolean
		{
			return diePlayerList.indexOf(playerId) != -1;
		}

		/** 检查玩家是否复活 */
		private function checkPlayerIsReive(playerId : int, x : int, y : int) : void
		{
			if (isDie(playerId) == false)
			{
				return;
			}

			if (x < 850 && y < 1315)
			{
				return;
			}

			if (isInReviveArea(x, y) == false)
			{
				revive(playerId);
			}
		}

		/** 是否在复活区域 */
		private function isInReviveArea(x : Number, y : Number) : Boolean
		{
			return x > MCBWConfig.reviveArea.x && y > MCBWConfig.reviveArea.y;
		}

		/** 检查玩家是否死亡 */
		private function checkPlayerIsDie(playerId : int) : void
		{
			if (isDie(playerId) == false)
			{
				return;
			}

			setPlayerDie(playerId);
		}

		/** 设置自己玩家死亡 */
		private function setSelfPlayerDie() : void
		{
			// Alert.show("设置自己玩家死亡");
			setPlayerDie(selfPlayer.id);
		}

//		private var _battleEndCallObj : Object;

//		private function get battleEndCallObj() : Object
//		{
//			if (_battleEndCallObj == null)
//			{
//				_battleEndCallObj = new Object();
//				_battleEndCallObj["fun"] = setSelfPlayerDie;
//				_battleEndCallObj["arg"] = [];
//			}
//			return _battleEndCallObj;
//		}

		/** 死亡 */
		public function die(playerId : int = 0) : void
		{
			if (playerId == selfPlayer.id || playerId == 0)
			{
				isSelfDie = true;
				selfPlayer.stopMove();
				BTSystem.INSTANCE().addEndCall(setSelfPlayerDie);
			}
			else
			{
				addDiePlayer(playerId);
				if (getTimer() - enterTime > 1000)
				{
					setTimeout(setPlayerBattle, 500, playerId);
				}
				else
				{
					setPlayerDie(playerId);
				}
				// setPlayerBattle(playerId);
			}
			// Alert.show(playerId + "  DIE");
		}

		/** 设置玩家战斗状态 */
		public function setPlayerBattle(playerId : int) : void
		{
			var playerAnimal : PlayerAnimal;
			if (playerId == selfPlayer.id || playerId == 0)
			{
				playerAnimal = selfPlayer;
			}
			else
			{
				playerAnimal = getPlayer(playerId);
			}

			if (playerAnimal)
			{
				playerAnimal.attackAction(1344, 1476);
			}
		}

		/** 设置玩家死亡状态 */
		public function setPlayerDie(playerId : int) : void
		{
			var playerAnimal : PlayerAnimal;
			if (playerId == selfPlayer.id || playerId == 0)
			{
				closeDiePassPath();
				playerAnimal = selfPlayer;
				deliveryToDieArea();
				isSelfDie = true;
			}
			else
			{
				playerAnimal = getPlayer(playerId);
				addDiePlayer(playerId);
			}

			if (playerAnimal)
			{
				playerAnimal.die();
				setTimeout(playerAnimal.walk, 800, playerAnimal.x + 10, playerAnimal.y + 10);
//				playerAnimal.stand();
			}
		}

		/** 复活所有死亡玩家 */
		public function reviveAllDiePlayer() : void
		{
			while (diePlayerList.length > 0)
			{
				revive(diePlayerList.shift());
			}
		}

		/** 复活 */  //TODO :stop revive time;
		public function revive(playerId : int = 0) : void
		{
			var playerAnimal : PlayerAnimal;
			if (playerId == selfPlayer.id || playerId == 0)
			{
				BTSystem.INSTANCE().removeEndCall(setSelfPlayerDie);
				openDiePassPath();
//				stopReviveTime();
				playerAnimal = selfPlayer;
				isSelfDie = false;
			}
			else
			{
				playerAnimal = getPlayer(playerId);
				removeDiePlayer(playerId);
			}

			if (playerAnimal) playerAnimal.revive();
		}

		/** 设置复活时间 */
//		public function setReviveTime(time : int) : void
//		{
//			_uiPlayerStatus.setCDTime(time);
//			_uiPlayerStatus.cdQuickenBtnCall = fastReviveButtonClickCall ;
//			_uiPlayerStatus.cdCompleteCall = reviveCompleteCall ;
//			_uiPlayerStatus.cdTimer.setTimersTip(10);
////			if (selfPlayer)
////			{
////				selfPlayer.uiDieTimer.buttonClickCall = fastReviveButtonClickCall;
////				selfPlayer.uiDieTimer.completeCall = reviveCompleteCall;
////				selfPlayer.setDieTime(time);
////			}
//		}

//		/** 设置快速复活按钮的tips **/
//		public function setReviveBtnTips(pic : int) : void
//		{
//			selfPlayer.uiDieTimer.setTimersTip(pic);
//		}
//
//		/** 停止复活时间 */
//		public function stopReviveTime() : void
//		{
//			if (selfPlayer)
//			{
//				selfPlayer.stopDieTime();
//			}
//		}

//		/** 快速复活按钮 点击事件 */
//		public var fastReviveButtonClickCall : Function;
//		/** 复活时间到了 */
//		public var reviveCompleteCall : Function;

		/** 传送到复活区域 */
		private function deliveryToDieArea() : void
		{
			var position : Point = getRandomDieAreaPoint();
			// selfPlayer.moveTo(position.x, position.y);
			// MapPosition.instance.center();
			MapProto.instance.cs_transport(position.x, position.y);
		}

		/** 随机复活区域 */
		private function getRandomDieAreaPoint() : Point
		{
			return MCBWConfig.dieArea.getRandomAreaPoint();
		}
	}
}
class Singleton
{
}