package game.module.groupBattle
{
	import com.utils.StringUtils;
	import flash.geom.Point;
	import game.core.user.UserData;
	import game.module.map.CurrentMapData;
	import game.module.map.MapProto;
	import game.module.map.animalManagers.GlobalPlayerManager;
	import game.module.map.animalManagers.PlayerManager;
	import game.module.map.animalstruct.PlayerStruct;
	import game.module.map.animalstruct.SelfPlayerStruct;
	import game.module.userBuffStatus.BuffStatusConfig;
	import game.module.userBuffStatus.BuffStatusManager;
	import game.net.core.Common;
	import game.net.data.CtoS.CSAvatarInfo;
	import game.net.data.CtoS.CSGroupBattleEnter;
	import game.net.data.CtoS.CSGroupBattleGroupData;
	import game.net.data.CtoS.CSGroupBattleInspire;
	import game.net.data.CtoS.CSGroupBattleInstantRevive;
	import game.net.data.CtoS.CSGroupBattleQuit;
	import game.net.data.CtoS.CSGroupBattleVsEnd;
	import game.net.data.StoC.GroupBattleGroupData;
	import game.net.data.StoC.GroupBattlePlayerData;
	import game.net.data.StoC.GroupBattleSortData;
	import game.net.data.StoC.PlayerPosition;
	import game.net.data.StoC.SCAvatarInfo.PlayerAvatar;
	import game.net.data.StoC.SCGroupBattleEnter;
	import game.net.data.StoC.SCGroupBattleGroupDataReply;
	import game.net.data.StoC.SCGroupBattlePlayerEnter;
	import game.net.data.StoC.SCGroupBattlePlayerLeave;
	import game.net.data.StoC.SCGroupBattlePlayerLost;
	import game.net.data.StoC.SCGroupBattlePlayerUpdate;
	import game.net.data.StoC.SCGroupBattleQuit;
	import game.net.data.StoC.SCGroupBattleSortUpdate;
	import game.net.data.StoC.SCGroupBattleTime;
	import game.net.data.StoC.SCGroupBattleUpdate;



	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-12 ����7:00:37
	 */
	public class GBProto
	{
		function GBProto(singleton : Singleton) : void
		{
			singleton;
			sToC();
		}

		/** 单例对像 */
		private static var _instance : GBProto;

		/** 获取单例对像 */
		public static function get instance() : GBProto
		{
			if (_instance == null)
			{
				_instance = new GBProto(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 全局玩家数据管理 */
		private var globalPlayerManager : GlobalPlayerManager = GlobalPlayerManager.instance;
		/** 玩家(地图)数据结构管理 */
		private var playerManager : PlayerManager = PlayerManager.instance;
		/** 玩家(蜀山论剑)数据结构管理 */
		private var gbPlayerManager : GBPlayerManager = GBPlayerManager.instance;
		/** 蜀山论剑控制器 */
		private var gbController : GBController = GBController.instance;

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 协议监听 */
		private function sToC() : void
		{
			// 协议监听 -- 0xC0 参加蜀山论剑
			Common.game_server.addCallback(0xC0, sc_enter);
			// 协议监听 -- 0xC1 退出蜀山论剑
			Common.game_server.addCallback(0xC1, sc_quit);
			// 协议监听 -- 0xC2 蜀山论剑挑战信息更新
			Common.game_server.addCallback(0xC2, sc_GroupBattleUpdate);
			// 协议监听 -- 0xC3 个人状态更新
			Common.game_server.addCallback(0xC3, sc_GroupBattlePlayerUpdate);
			// 协议监听 -- 0xC4 蜀山论剑时间
			Common.game_server.addCallback(0xC4, sc_time);
			// 协议监听 -- 0xC5 蜀山论剑玩家进入
			Common.game_server.addCallback(0xC5, sc_playerEnter);
			// 协议监听 -- 0xC6 蜀山论剑玩家离开
			Common.game_server.addCallback(0xC6, sc_playerLeave);
			// 协议监听 -- 0xC7 蜀山论剑玩家轮空继续等待
			Common.game_server.addCallback(0xC7, sc_playerEmptyWait);
			//            //  协议监听 -- 0xC8 蜀山论剑鼓舞
			// Common.game_server.addCallback(0xC8, sc_inspire);
			// 协议监听 -- 0xC9 蜀山论剑连杀前三名更新
			Common.game_server.addCallback(0xC9, sc_fontSortUpdate);
			// 协议监听 -- 0xCA 蜀山论剑其他组的人数得分返回
			Common.game_server.addCallback(0xCA, sc_groupInfo);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 发送协议[0xC0] -- 参加蜀山论剑 */
		public function cs_enter() : void
		{
			var msg : CSGroupBattleEnter = new CSGroupBattleEnter();
			Common.game_server.sendMessage(0xC0, msg);
		}

		/** 发送协议[0xC1] -- 退出蜀山论剑 */
		public function cs_quit() : void
		{
			var msg : CSGroupBattleQuit = new CSGroupBattleQuit();
			Common.game_server.sendMessage(0xC1, msg);
		}

		/** 发送协议[0xC2] -- 对决完成 */
		public function cs_vsEnd() : void
		{
			var msg : CSGroupBattleVsEnd = new CSGroupBattleVsEnd();
			Common.game_server.sendMessage(0xC2, msg);
		}

		/** 发送协议[0xC3] -- 花费元宝复活 */
		public function cs_fastResurrection() : void
		{
			var msg : CSGroupBattleInstantRevive = new CSGroupBattleInstantRevive();
			Common.game_server.sendMessage(0xC3, msg);
		}

		/** 提升属性(战斗力和HP)方式--元宝 */
		public static const INSPIRE_TYPE_GOLD : uint = 0;
		/** 提升属性(战斗力和HP)方式--银币 */
		public static const INSPIRE_TYPE_SILVER : uint = 1;

		/** 发送协议[0xC8] -- 提升属性(战斗力和HP) */
		public function cs_inspire(type : uint) : void
		{
			var msg : CSGroupBattleInspire = new CSGroupBattleInspire();
			msg.type = type;
			Common.game_server.sendMessage(0xC8, msg);
		}

		/** 发送协议[0xCA] -- 蜀山论剑请求其他组的人数得分 */
		public function cs_groupInfo(groupId : int) : void
		{
			var msg : CSGroupBattleGroupData = new CSGroupBattleGroupData();
			msg.groupId = groupId;
			Common.game_server.sendMessage(0xCA, msg);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 协议监听 -- 0xC0 参加蜀山论剑 */
		private function sc_enter(msg : SCGroupBattleEnter) : void
		{
			// 1:成功 2:失败
			if (msg.result == 2) return;
			var playerData : GroupBattlePlayerData;
			var isInitGroup : Boolean = false;
			playerManager.clear();
			// gbPlayerManager.initGroup(0);
			// testFontSort(msg);

			var csAvatarPlayerIdList : Array = [];
			// 玩家列表
			for (var i : int = 0; i < msg.playerList.length; i++)
			{
				playerData = msg.playerList[i];
				// 0x00:朱雀 0x01:玄武 0x02:青龙 0x03白虎
				if (isInitGroup == false)
				{
					var groupLevel : int = GBUtil.getGroupLevel(playerData.group);
					gbPlayerManager.initGroup(groupLevel);
					isInitGroup = true;
				}
				addPlayer(playerData);
				csAvatarPlayerIdList.push(playerData.playerId);
			}
			// 自己玩家的一些单独信息
			var selfPlayer : GBSelfPlayer = gbPlayerManager.selfPlayer;
			selfPlayer.inspireLevel = msg.inspireLevel;
			selfPlayer.winCount = msg.totalWin;
			selfPlayer.loseCount = msg.totalLose;
			selfPlayer.silver = msg.totalSilver;
			selfPlayer.darksteel = msg.totalDonate;
			BuffStatusManager.instance.updateStatusLevel(BuffStatusConfig.STATUS_ID_INSPIRE, msg.inspireLevel);
            
            csAvatarPlayerIdList.unshift(selfPlayer.id);
            MapProto.instance.cs_avatarInfo(0, csAvatarPlayerIdList);

			// 阵营信息
			var groupData : GroupBattleGroupData;
			var group : GBGroup;
			for (i = 0; i < msg.groupData.length; i++)
			{
				groupData = msg.groupData[i];
				group = gbPlayerManager.getGroup(groupData.group);
				// group.playerCount = groupData.playerNum;
				group.score = groupData.score;
			}

			// 连杀前三名
			var sortData : GroupBattleSortData;
			var gbPlayer : GBPlayer;
			while (gbPlayerManager.fontSortPlayerList.length > 0)
			{
				gbPlayerManager.fontSortPlayerList.shift();
			}

			var playerStruct : PlayerStruct;
			for (i = 0; i < msg.sortList.length; i++)
			{
				sortData = msg.sortList[i];
				playerStruct = GlobalPlayerManager.instance.getPlayer(sortData.playerId);
				gbPlayer = new GBPlayer(playerStruct);
				gbPlayer.id = sortData.playerId;
				gbPlayer.group = GBUtil.getGroup(sortData.group);
				gbPlayer.playerName = sortData.playerName;
				gbPlayer.maxKillCount = sortData.maxKillStreak;
				gbPlayerManager.fontSortPlayerList.push(gbPlayer);
			}

			GBSystem.hasHighlevel = msg.hasHighlevel;

			gbController.setup();
			// 设置蜀山论剑结束时间
			gbController.overTimer = msg.surplusTime;
		}

		/** 协议监听 -- 0xC1 退出蜀山论剑 */
		private function sc_quit(msg : SCGroupBattleQuit) : void
		{
			msg;
			gbController.clear();
		}

		/** 协议监听 -- 0xC2 蜀山论剑挑战信息更新 */
		private function sc_GroupBattleUpdate(msg : SCGroupBattleUpdate) : void
		{
			if (gbController.uiNewsPanel == null) return;
			gbController.uiNewsPanel.appendBattleNews(msg);
			var winPlayer : GBPlayer = gbPlayerManager.getPlayer(msg.winPlayerId);
			var losePlayer : GBPlayer = gbPlayerManager.getPlayer(msg.losePlayerId);
			if (winPlayer == null) return;
			winPlayer.group.score = msg.winGroupScore;
			losePlayer.group.score = msg.loseGroupScore;

			winPlayer.killCount = msg.winPlayerKill;
			losePlayer.killCount = 0;
			if (winPlayer.killCount > winPlayer.maxKillCount)
			{
				winPlayer.maxKillCount = winPlayer.killCount;
			}

			winPlayer.winCount += 1;
			losePlayer.loseCount += 1;

			winPlayer.silver += msg.winSilver;
			losePlayer.silver += msg.loseSilver;

			winPlayer.darksteel += msg.winDonateCnt;
			losePlayer.darksteel += msg.loseDonateCnt;
		}

		/** 协议监听 -- 0xC3 个人状态更新 */
		public function sc_GroupBattlePlayerUpdate(msg : SCGroupBattlePlayerUpdate) : void
		{
			var gbPlayer : GBPlayer = gbPlayerManager.getPlayer(msg.playerId);
			if (gbPlayer == null) return;
			// gbPlayer.playerStatus = msg.playerSatus;

			if (msg.playerSatus == GBPlayerStatus.VS)
			{
				var index : int = GBUtil.vsPositionIndex;
				testIndex("index = " + index);
				gbPlayer.vsPosition = GBUtil.getVSPositionByIndex(index, gbPlayer.groupAB);
				gbPlayer.setPlayerStatus(msg.playerSatus, msg.time);

				gbPlayer = gbPlayerManager.getPlayer(msg.playerId2);
				if (gbPlayer)
				{
					gbPlayer.vsPosition = GBUtil.getVSPositionByIndex(index, gbPlayer.groupAB);
					gbPlayer.setPlayerStatus(msg.playerSatus, msg.time);
				}
			}
			else
			{
				gbPlayer.setPlayerStatus(msg.playerSatus, msg.time);
			}
		}

		private var testIndexStr : String = "";

		public function testIndex(str : String) : void
		{
			// testIndexStr = testIndexStr + "\n" + str;
			// //trace();
			// //trace(testIndexStr);
			// //trace();
		}

		/** 协议监听 -- 0xC4 蜀山论剑时间 */
		private function sc_time(msg : SCGroupBattleTime) : void
		{
		}

		/** 协议监听 -- 0xC5 蜀山论剑玩家进入 */
		private function sc_playerEnter(msg : SCGroupBattlePlayerEnter) : void
		{
			var playerData : GroupBattlePlayerData = msg.playerData;
			if (playerData.playerId == UserData.instance.playerId) return;
			addPlayer(msg.playerData);

            MapProto.instance.cs_avatarInfo(playerData.playerId);
		}

		/** 协议监听 -- 0xC6 蜀山论剑玩家进入 */
		private function sc_playerLeave(msg : SCGroupBattlePlayerLeave) : void
		{
			if (msg.playerId == UserData.instance.playerId) return;
			gbPlayerManager.removePlayer(msg.playerId);
		}

		/** 协议监听 -- 0xC7 蜀山论剑玩家轮空继续等待 */
		private function sc_playerEmptyWait(msg : SCGroupBattlePlayerLost) : void
		{
			var gbPlayer : GBPlayer = gbPlayerManager.getPlayer(msg.playerId);
			gbController.uiNewsPanel.appendEmptyWaitNews(msg);
			if (gbPlayer)
			{
				gbPlayer.silver += msg.silver;
				gbPlayer.darksteel += msg.donateCnt;
				gbPlayer.group.score = msg.groupScore;
			}
		}

		// /** 协议监听 -- 0xC8 蜀山论剑鼓舞 */
		// private function sc_inspire(msg : SCGroupBattleInspire) : void
		// {
		// }
		/** 协议监听 -- 0xC9 蜀山论剑连杀前三名更新 */
		private function sc_fontSortUpdate(msg : SCGroupBattleSortUpdate) : void
		{
			// 连杀前三名
			var sortData : GroupBattleSortData;
			var gbPlayer : GBPlayer;
			while (gbPlayerManager.fontSortPlayerList.length > 0)
			{
				gbPlayerManager.fontSortPlayerList.shift();
			}

			for (i = 0; i < msg.sortList.length; i++)
			{
				sortData = msg.sortList[i];
				gbPlayer = new GBPlayer(null);
				gbPlayer.id = sortData.playerId;
				gbPlayer.group = GBUtil.getGroup(sortData.group);
				gbPlayer.playerName = sortData.playerName;
				gbPlayer.maxKillCount = sortData.maxKillStreak;
				gbPlayerManager.fontSortPlayerList.push(gbPlayer);
				if (gbPlayer.maxKillCount == 0)
				{
					//trace(sortData.maxKillStreak);
				}
			}

			gbPlayerManager.fontSortPlayerList = gbPlayerManager.fontSortPlayerList;
		}

		/** 协议监听 -- 0xCA 蜀山论剑其他组的人数得分返回 */
		private function sc_groupInfo(msg : SCGroupBattleGroupDataReply) : void
		{
			var groupData : GroupBattleGroupData = msg.groupData;
			var group : GBGroup = gbPlayerManager.getGroup(groupData.group);

			if (group)
			{
				group.score = groupData.score;
				group.playerCount = groupData.playerNum;
			}
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 添加玩家 */
		private function addPlayer(playerData : GroupBattlePlayerData) : void
		{
			var gbPlayer : GBPlayer;
			var playerStruct : PlayerStruct;

			playerStruct = globalPlayerManager.getPlayer(playerData.playerId);
			if (playerStruct == null)
			{
				if (playerData.playerId != UserData.instance.playerId)
				{
					playerStruct = new PlayerStruct();
				}
				else
				{
					var curMapData : CurrentMapData = CurrentMapData.instance;
					playerStruct = curMapData.selfPlayerStruct;
				}
			}

			playerStruct.id = playerData.playerId;
			playerStruct.name = playerData.playerName;
			playerStruct.job = playerData.job;
			playerStruct.isMale = playerData.isMale;
			playerStruct.heroId = playerData.job * 2 - (playerData.isMale ? 1 : 0);
            playerStruct.avatarVer = 1;

			var position : Point;
			if (playerData.playerId == UserData.instance.playerId && playerData.playerSatus == GBPlayerStatus.WAIT)
			{
				position = GBUtil.getGroupAB(playerData.group) == GBSystem.GROUP_A_ID ? GBUtil.getRandomPositionGroupA() : GBUtil.getRandomPositionGroupB();
			}
			else
			{
				position = GBUtil.getRandomPosition(GBUtil.getGroupAB(playerData.group), playerData.playerSatus);
			}

			playerStruct.x = position.x;
			playerStruct.y = position.y;

			if (playerData.playerId != UserData.instance.playerId)
			{
				gbPlayer = new GBPlayer(playerStruct);
			}
			else
			{
				gbPlayer = new GBSelfPlayer(playerStruct);
				gbPlayerManager.selfPlayer = gbPlayer as GBSelfPlayer;
			}

			// gbPlayer = playerData.playerId != Common.userData.playerId ? new GBPlayer(playerStruct) : new GBSelfPlayer(playerStruct);
			gbPlayer.groupId = playerData.group;
			gbPlayer.killCount = playerData.killStreak;
			gbPlayer.maxKillCount = playerData.maxKillStreak;
			gbPlayer.winCount = playerData.winCount;
			gbPlayer.loseCount = playerData.loseCount;
			if (playerData.playerSatus == GBPlayerStatus.VS)
			{
				gbPlayer.vsPosition = GBUtil.getVSPositionByIndex(4, gbPlayer.groupAB);
				playerStruct.x = gbPlayer.vsPosition.x;
				playerStruct.y = gbPlayer.vsPosition.y;
			}
			gbPlayer.playerStatus = playerData.playerSatus;

			playerManager.addPlayer(playerStruct);
			gbPlayerManager.addPlayer(gbPlayer);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		public function testEnter() : void
		{
			var msg : SCGroupBattleEnter = new SCGroupBattleEnter();
			msg.result = 1;
			msg.playerList = new Vector.<GroupBattlePlayerData>();

			var playerData : GroupBattlePlayerData = testPlayer(UserData.instance.playerId);
			msg.playerList.push(playerData);

			for (var i : int = 0; i < 50; i++)
			{
				playerData = testPlayer();
				msg.playerList.push(playerData);
			}

			sc_enter(msg);
		}

		public static var i : int = 0;

		public function testPlayer(playerId : uint = 0) : GroupBattlePlayerData
		{
			var playerData : GroupBattlePlayerData = new GroupBattlePlayerData();
			playerData.group = Math.random() > 0.4 ? 0 : 1;
			// playerData.group = 1;
			playerData.playerId = playerId == 0 ? Math.round(Math.random() * 50) : playerId;
			// playerData.playerName = StringUtils.fillStr(i + "", 4);
			playerData.playerName = StringUtils.fillStr(playerData.playerId + "", 4);

			i++;
			playerData.isMale = Math.random() > 0.5;
			playerData.job = Math.floor(Math.random() * 3);
			// 玩家状态 1:在交战区处于休息状态  2:战斗状态 3:等待状态 4:死亡状态
			playerData.playerSatus = 1 + Math.floor(Math.random() * 4);
			// playerData.playerSatus = GBPlayerStatus.VS;
			playerData.waitTime = Math.round(Math.random() * 30);
			playerData.killStreak = Math.round(Math.random() * 10);
			return playerData;
		}

		public function testFontSort(msg : SCGroupBattleEnter) : void
		{
			var sortData : GroupBattleSortData;
			var playerData : GroupBattlePlayerData;
			for (var i : int = 0; i < msg.playerList.length; i++)
			{
				if (i >= 3) break;

				playerData = msg.playerList[i];
				sortData = new GroupBattleSortData();
				sortData.group = playerData.group;
				sortData.playerId = playerData.playerId;
				sortData.playerName = playerData.playerName;
				sortData.maxKillStreak = playerData.maxKillStreak;

				msg.sortList.push(sortData);
			}
		}
	}
}
class Singleton
{
}