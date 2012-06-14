package game.module.map
{
	import game.core.user.UserData;
	import game.module.map.animal.AnimalManager;
	import game.module.map.animalManagers.GlobalPlayerManager;
	import game.module.map.animalManagers.HidePlayerManager;
	import game.module.map.animalManagers.PlayerInfoManager;
	import game.module.map.animalManagers.PlayerManager;
	import game.module.map.animalstruct.PlayerStruct;
	import game.module.map.animalstruct.SelfPlayerStruct;
	import game.module.map.playerVisible.PlayerTolimitManager;
	import game.module.map.utils.MapUtil;
	import game.net.core.Common;
	import game.net.data.CtoS.CSAvatarChange;
	import game.net.data.CtoS.CSAvatarInfo;
	import game.net.data.CtoS.CSLeaveCity;
	import game.net.data.CtoS.CSSwitchCity;
	import game.net.data.CtoS.CSTransport;
	import game.net.data.CtoS.CSUseGate;
	import game.net.data.CtoS.CSWalkTo;
	import game.net.data.StoC.PlayerPosition;
	import game.net.data.StoC.SCAvatarInfo;
	import game.net.data.StoC.SCAvatarInfo.PlayerAvatar;
	import game.net.data.StoC.SCAvatarInfoChange;
	import game.net.data.StoC.SCBarrier;
	import game.net.data.StoC.SCCityEnter;
	import game.net.data.StoC.SCCityLeave;
	import game.net.data.StoC.SCCityPlayers;
	import game.net.data.StoC.SCMultiAvatarInfoChange;
	import game.net.data.StoC.SCNPCReaction;
	import game.net.data.StoC.SCPlayerWalk;
	import game.net.data.StoC.SCTransport;

	import log4a.Logger;

	import com.commUI.alert.Alert;

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.utils.getTimer;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-4 ����12:29:10
	 */
	public class MapProto extends EventDispatcher
	{
		public function MapProto(singleton : Singleton, target : IEventDispatcher = null)
		{
			singleton;
			super(target);
			sToC();
		}

		/** 单例对像 */
		private static var _instance : MapProto;

		/** 获取单例对像 */
		static public function get instance() : MapProto
		{
			if (_instance == null)
			{
				_instance = new MapProto(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 全局玩家数据管理 */
		private var globalPlayerManager : GlobalPlayerManager = GlobalPlayerManager.instance;
		/** 玩家(地图)数据结构管理 */
		private var playerManager : PlayerManager = PlayerManager.instance;
		/** 隐藏玩家(地图)数据结构管理 */
		private var hidePlayerManager : HidePlayerManager = HidePlayerManager.instance;
		/** 动物管理器 */
		private var animalManager : AnimalManager = AnimalManager.instance;
		/** 玩家信息玩管理器 */
		private var playerInfoManager : PlayerInfoManager = PlayerInfoManager.instance;

		/** 自己玩家ID */
		private function get selfPlayerId() : int
		{
			return UserData.instance.playerId;
		}

		/** 协议监听 */
		private function sToC() : void
		{
			// 0x22 自己玩家进入新地图
			Common.game_server.addCallback(0x22, changeMap);
			// 0x24 设置NPC是否显示
			Common.game_server.addCallback(0x24, setNpcVisible);
			// 0x21 玩家进入地图
			Common.game_server.addCallback(0x21, playerEnter);
			// 0x28 玩家Avatar信息
			Common.game_server.addCallback(0x28, playerAvatarInfo);
			// 0x27 玩家avatar信息改变
			Common.game_server.addCallback(0x27, playerAvatarInfoChange);
			// 0x23 玩家离开
			Common.game_server.addCallback(0x23, playerLeave);
			// 0x20 玩家走路
			Common.game_server.addCallback(0x20, playerWalk);
			// 协议监听 -- 0x25 直接传送
			Common.game_server.addCallback(0x25, sc_transport);
			// 0x26
			Common.game_server.addCallback(0x26, multipleAvatarChange);
			// 0x2A  开放/关闭路障/传送点
			Common.game_server.addCallback(0x2A, sc_barrier);
		}

		/** 协议监听 --  0x2A  开放/关闭路障/传送点 */
		private function sc_barrier(msg : SCBarrier) : void
		{
			if (msg.barrierID > 100 )
			{
				GateOpened.setState(msg.barrierID - 100, msg.open);
			}
			else
			{
				BarrierOpened.setState(msg.barrierID, msg.open);
			}
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 协议监听 -- 0x25 传送 */
		private function sc_transport(msg : SCTransport) : void
		{
			var playerStruct : PlayerStruct;
			playerStruct = globalPlayerManager.getPlayer(msg.playerId);
			if (playerStruct == null) return;
			playerStruct.x = msg.myXy & 0x3FFF;
			playerStruct.y = msg.myXy >> 14;
			playerStruct.toX = playerStruct.x;
			playerStruct.toY = playerStruct.y;

			Logger.debug("player : " + playerStruct.name + " x : " + playerStruct.x + " y : " + playerStruct.y) ;
			if (MapSystem.hideServerMode == false)
			{
				// 传送
				MapSystem.transport(playerStruct);
				if (playerStruct.id == selfPlayerId)
				{
					SelfPlayerSignal.severTransport.dispatch();
				}
			}
		}

		/** 玩家离开 */
		private function playerLeave(msg : SCCityLeave) : void
		{
			if (MapSystem.hideServerMode == false)
			{
				playerManager.removePlayer(msg.playerId);
				// 地图移除玩家
				MapSystem.removePlayer(msg.playerId);

				var avatarInfo : SCAvatarInfoChange = new SCAvatarInfoChange();
				avatarInfo.id = msg.playerId;
				avatarInfo.model = 0;
				globalPlayerManager.playerAvatarInfoChange(avatarInfo);
			}
			else
			{
				hidePlayerManager.removePlayer(msg.playerId);
			}
		}

		/** 玩家走路 */
		private function playerWalk(msg : SCPlayerWalk) : void
		{
			var playerStruct : PlayerStruct = globalPlayerManager.getPlayer(msg.playerId);
			if (playerStruct == null) return;
			playerStruct.startWalkTime = getTimer();
			playerStruct.toX = msg.xy & 0x3FFF;
			playerStruct.toY = msg.xy >> 14;
			Logger.info("msg.hasFromXY" + msg.hasFromXY);
			if (msg.hasFromXY)
			{
				playerStruct.x = msg.fromXY & 0x3FFF;
				playerStruct.y = msg.fromXY >> 14;
			}
			else
			{
				playerStruct.x = playerStruct.toX;
				playerStruct.y = playerStruct.toY;
			}

			// Logger.info("玩家走路:palyerId="+ playerStruct.id+"  playerStruct.toX=" + playerStruct.toX + "  playerStruct.toY=" + playerStruct.toY + " playerStruct.x=" + playerStruct.x + " playerStruct.y" + playerStruct.y);

			if (playerStruct.toWalkedTime > 0) playerStruct.toWalkedTime = 0;
			// //  trace("playerStruct.toX = " + playerStruct.toX + "   playerStruct.toY =" + playerStruct.toY + "   playerStruct.x=" + playerStruct.x + "   playerStruct.y=" + playerStruct.y);
			// Alert.show("玩家走路");
			if (MapSystem.hideServerMode == false)
			{
				// 更新玩家位置
				MapSystem.updatePlayerPosition(playerStruct);
			}
		}

		/** 玩家Avatar信息 */
		private function playerAvatarInfo(msg : SCAvatarInfo) : void
		{
			for (var i : int = 0; i < msg.players.length; i++)
			{
				var avatarInfo : PlayerAvatar = msg.players[i];
				globalPlayerManager.playerAvatarInfo(avatarInfo);
				// if (avatarInfo.id == selfPlayerId)
				// {
				// var curMapData : CurrentMapData = CurrentMapData.instance;
				//                    //  自己玩家
				// var selfPlayerStruct : SelfPlayerStruct = curMapData.selfPlayerStruct;
				// selfPlayerStruct.mergeSCAvatarInfo(avatarInfo);
				// MapSystem.updatePlayerAvatar(selfPlayerStruct);
				// continue;
				// }
				// globalPlayerManager.playerAvatarInfo(avatarInfo);
			}
		}

		/** 玩家avatar信息改变 */
		public function playerAvatarInfoChange(msg : SCAvatarInfoChange) : void
		{
			globalPlayerManager.playerAvatarInfoChange(msg);
		}

		/** 玩家进入地图（非自己） */
		private function playerEnter(msg : SCCityEnter) : void
		{
			var positionInfo : PlayerPosition = msg.playerPos;

			var playerStruct : PlayerStruct;
			playerStruct = globalPlayerManager.getPlayer(positionInfo.playerId);
			if (playerStruct == null)
			{
				playerStruct = new PlayerStruct();
				playerStruct.id = positionInfo.playerId;
				globalPlayerManager.addPlayer(playerStruct);
			}
			playerStruct.x = positionInfo.xy & 0x3FFF;
			playerStruct.y = positionInfo.xy >> 14;
			if (positionInfo.hasToXy)
			{
				playerStruct.toX = positionInfo.toXy & 0x3FFF;
				playerStruct.toY = positionInfo.toXy >> 14;
			}
			else
			{
				playerStruct.toX = playerStruct.x;
				playerStruct.toY = playerStruct.y;
			}

			if (positionInfo.hasWhen)
			{
				playerStruct.toWalkedTime = positionInfo.when;
				Alert.show(playerStruct.toWalkedTime + "   " + playerStruct.x + "   " + playerStruct.y + "   " + playerStruct.toX + "   " + playerStruct.toY);
			}
			else
			{
				playerStruct.toWalkedTime = 0;
			}
			playerStruct.startWalkTime = 0;

			playerStruct.newAvatarVer = positionInfo.avatarVer & 0x1F;
			playerStruct.model = positionInfo.avatarVer >> 5;

			if (playerStruct.avatarVer != playerStruct.newAvatarVer)
			{
				if (PlayerTolimitManager.instance.enable == false) cs_avatarInfo(playerStruct.id);
			}

			if (MapSystem.hideServerMode == false)
			{
				playerManager.addPlayer(playerStruct);
				// 地图加入玩家
				if ( globalPlayerManager.enterModel(playerStruct)  )
					MapSystem.addPlayer(playerStruct);
			}
			else
			{
				hidePlayerManager.addPlayer(playerStruct);
			}
		}

		/** 设置NPC是否显示 */
		private function setNpcVisible(msg : SCNPCReaction) : void
		{
			if ( msg.reactionId == 1)
			{
				NpcSignals.add.dispatch(msg.npcId);
			}
			else
			{
				NpcSignals.remove.dispatch(msg.npcId);
			}

			// MapSystem.setNpcVisible(msg.npcId, msg.reactionId == 1 ? true : false);
			//
			// if (MapSystem.hideServerMode == true)
			// {
			// MapHideServer.instance.setNpcVisible(msg.npcId, msg.reactionId == 1 ? true : false);
			// }
		}

		/** 自己玩家进入新地图 */
		private function changeMap(msg : SCCityPlayers) : void
		{
			if(msg.cityId > 100)
			{
				msg.openBarriers.push(3);
			}
			GateOpened.clear();
			BarrierOpened.clear();
			var i : int;
			var length : int = msg.openBarriers.length;
			for (i = 0; i < length; i++)
			{
				var barriersId : int = msg.openBarriers[i];
				if (barriersId > 100)
				{
					GateOpened.setState(barriersId - 100, true);
				}
				else
				{
					BarrierOpened.setState(barriersId, true);
				}
			}

			//			//  如果是副本地图
			// if (MapUtil.isDungeonMap(msg.cityId)) return;
			// 设置地图是否是隐藏服务器模式
			MapSystem.setHideServerMode(false, false);
			hidePlayerManager.clear();
			var curMapData : CurrentMapData = CurrentMapData.instance;
			var selfPostion : Point = new Point(msg.myX, msg.myY);
			Logger.debug("msg.myX, msg.myY ===>" + msg.myX, msg.myY);
			// 切换地图时间
			MapSystem.changeMapTime = getTimer();
			// 自己玩家
			var selfPlayerStruct : SelfPlayerStruct = curMapData.selfPlayerStruct;
			selfPlayerStruct.id = UserData.instance.playerId;
			selfPlayerStruct.name = UserData.instance.playerName;
			selfPlayerStruct.x = selfPostion.x;
			selfPlayerStruct.y = selfPostion.y;
			selfPlayerStruct.model = msg.model;
			selfPlayerStruct.toWalkedTime = 0;
			// playerManager.addPlayer(selfPlayerStruct);
			// 地图加入NPC
			curMapData.setupNpcList = msg.npcId;
			curMapData.setupMonsterList = null;
			// 玩家列表
			playerManager.clear();
			var playerStruct : PlayerStruct;

			// 临时
			var csAvatarPlayerIdList : Array = [];
			for (i = 0; i < msg.players.length; i++)
			{
				var positionInfo : PlayerPosition = msg.players[i];
				if (positionInfo.playerId == selfPlayerId) continue;
				playerStruct = globalPlayerManager.getPlayer(positionInfo.playerId);
				if (playerStruct == null)
				{
					playerStruct = new PlayerStruct();
					playerStruct.id = positionInfo.playerId;
					globalPlayerManager.addPlayer(playerStruct);

					// 临时
					csAvatarPlayerIdList.push(playerStruct.id);
				}
				playerStruct.x = positionInfo.xy & 0x3FFF;
				playerStruct.y = positionInfo.xy >> 14;
				if (positionInfo.hasToXy)
				{
					playerStruct.toX = positionInfo.toXy & 0x3FFF;
					playerStruct.toY = positionInfo.toXy >> 14;
				}
				else
				{
					playerStruct.toX = playerStruct.x;
					playerStruct.toY = playerStruct.y;
				}

				if (positionInfo.hasWhen)
				{
					playerStruct.toWalkedTime = positionInfo.when;
					// Alert.show(playerStruct.toWalkedTime + "   " + playerStruct.x + "   " + playerStruct.y + "   " + playerStruct.toX + "   " + playerStruct.toY);
				}
				else
				{
					playerStruct.toWalkedTime = 0;
				}

				playerStruct.startWalkTime = 0;
				playerStruct.newAvatarVer = positionInfo.avatarVer & 0x1F;
				playerStruct.model = positionInfo.avatarVer >> 5;
				// Alert.show("playerStruct.newAvatarVer = " +playerStruct.newAvatarVer + " playerStruct.avatarVer=" +playerStruct.avatarVer);
				if (playerStruct.avatarVer != playerStruct.newAvatarVer)
				{
					if (PlayerTolimitManager.instance.enable == false) csAvatarPlayerIdList.push(playerStruct.id);
				}
				playerManager.addPlayer(playerStruct);
			}
			// 临时
			if (PlayerTolimitManager.instance.enable == false) cs_avatarInfo(0, csAvatarPlayerIdList);
			// 安装地图
			MapSystem.setupMap(msg.cityId, selfPostion);
			selfPlayerStruct.checkVer();
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 0x22 使用传送点 */
		public function cs_CSUseGate(gateId : int) : void
		{
			// cs_changeMap(200 + gateId);
			// return;
			if (MapController.instance.selfPlayerAnimal) MapController.instance.selfPlayerAnimal.stopMove();
			var msg : CSUseGate = new CSUseGate();
			msg.gateId = gateId;
			Common.game_server.sendMessage(0x22, msg);
		}

		/** 0x23 离开地图 */
		public function cs_leaveMap() : void
		{
			if (MapController.instance.selfPlayerAnimal) MapController.instance.selfPlayerAnimal.stopMove();
			var msg : CSLeaveCity = new CSLeaveCity();
			Common.game_server.sendMessage(0x23, msg);
		}

		/** 0x24 切换地图 */
		public function cs_changeMap(mapId : uint) : void
		{
			if (MapController.instance.selfPlayerAnimal) MapController.instance.selfPlayerAnimal.stopMove();
			var msg : CSSwitchCity = new CSSwitchCity();
			msg.cityId = mapId;
			Common.game_server.sendMessage(0x24, msg);
		}

		/** 0x25 直接传送 */
		public function cs_transport(toX : int, toY : int, mapId : int = 0) : void
		{
			if (animalManager.selfPlayer)
			{
				animalManager.selfPlayer.stopMove();
			}
			var msg : CSTransport = new CSTransport();
			msg.cityId = mapId <= 0 ? MapUtil.getCurrentMapId() : mapId;
			msg.toX = toX;
			msg.toY = toY;
			if (toX == 0 && toY == 0)
			{
				var point : Point = MapUtil.getGateStandPosition(mapId, mapId);
				msg.toX = point.x;
				msg.toY = point.y;
			}
			Common.game_server.sendMessage(0x25, msg);
		}

		/** 0x20 告诉其他玩家自己位置 */
		public function cs_moveTo(toX : int, toY : int, fromX : int = 0, fromY : int = 0) : void
		{
			var msg : CSWalkTo = new CSWalkTo();
			msg.toX = toX;
			msg.toY = toY;
			if (fromX != 0)
			{
				msg.fromX = fromX;
				msg.fromY = fromY;
			}
			// Logger.info("告诉服务器我要走到:msg.toX=" + msg.toX + "  msg.toY=" + msg.toY + " msg.fromX=" + msg.fromX + " msg.fromY" + msg.fromY);
			Common.game_server.sendMessage(0x20, msg);
		}

		/** 0x27 请求Avatar改变信息 */
		public function cs_avatarInfoChange(playerId : int, playerIdList : Array = null) : void
		{
			var msg : CSAvatarChange = new CSAvatarChange();
			if (playerId > 0) msg.playerId.push(playerId);
			if (playerIdList && playerIdList.length > 0)
			{
				while (playerIdList.length > 0)
				{
					playerId = playerIdList.shift();
					if (msg.playerId.indexOf(playerId) == -1)
					{
						msg.playerId.push(playerId);
					}
				}
			}
			if (msg.playerId.length <= 0) return;
			Common.game_server.sendMessage(0x27, msg);
		}

		/** 0x28 请求名字模型等信息 */
		public function cs_avatarInfo(playerId : int, playerIdList : Array = null) : void
		{
			var msg : CSAvatarInfo = new CSAvatarInfo();
			if (playerId > 0) msg.playerId.push(playerId);
			if (playerIdList && playerIdList.length > 0)
			{
				while (playerIdList.length > 0)
				{
					playerId = playerIdList.shift();
					if (msg.playerId.indexOf(playerId) == -1)
					{
						msg.playerId.push(playerId);
					}
				}
			}
			if (msg.playerId.length <= 0) return;
			Common.game_server.sendMessage(0x28, msg);
		}

		/** 多玩家avatar同时发生改变 */
		public function multipleAvatarChange(msg : SCMultiAvatarInfoChange) : void
		{
			globalPlayerManager.multipleAvatarInfoChange(msg);
		}
	}
}
class Singleton
{
}