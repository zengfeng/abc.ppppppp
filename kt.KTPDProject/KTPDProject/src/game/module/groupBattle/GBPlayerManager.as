package game.module.groupBattle
{
	import flash.utils.Dictionary;
	import game.module.groupBattle.ui.UiFontSortBox;


	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-12 ����6:31:39
	 * 玩家管理器
	 */
	public class GBPlayerManager
	{
		function GBPlayerManager(singleton : Singleton) : void
		{
			singleton;
		}

		/** 单例对像 */
		private static var _instance : GBPlayerManager;

		/** 获取单例对像 */
		public static function get instance() : GBPlayerManager
		{
			if (_instance == null)
			{
				_instance = new GBPlayerManager(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 组字典 */
		private var groupDic : Dictionary = new Dictionary();
		/** A组 */
		public var groupA : GBGroup;
		/** B组 */
		public var groupB : GBGroup;
		/** A组副本 */
		public var groupAc : GBGroup;
		/** B组副本 */
		public var groupBc : GBGroup;
		/** 自己玩家 */
		public var selfPlayer : GBSelfPlayer;
		/** 连杀前三名玩家列表 */
		private var _fontSortPlayerList : Vector.<GBPlayer> = new Vector.<GBPlayer>();
		/** 第一名连杀 */
		private var _aGbPlayer : GBPlayer;
		/** 第二名连杀 */
		private var _bGbPlayer : GBPlayer;
		/** 第三名连杀 */
		private var _cGbPlayer : GBPlayer;
		/** 排名面板 */
		private var _fontSort : UiFontSortBox;

		/** 组始化组 */
		public function initGroup(groupLevel : int) : void
		{
			var group : GBGroup;
			group = new GBGroup();
			group.id = 0;
			group.groupAB = GBSystem.GROUP_A_ID;
			group.name = "朱雀组";
			group.color = GBConfig.GROUP_COLOR_A;
			group.colorStr = GBConfig.GROUP_COLOR_STR_A;
			group.minLevel = 20;
			group.maxLevel = 69;
			groupDic[group.id] = group;

			group = new GBGroup();
			group.id = 1;
			group.groupAB = GBSystem.GROUP_B_ID;
			group.name = "玄武组";
			group.color = GBConfig.GROUP_COLOR_B;
			group.colorStr = GBConfig.GROUP_COLOR_STR_B;
			group.minLevel = 20;
			group.maxLevel = 69;
			groupDic[group.id] = group;

			group = new GBGroup();
			group.id = 2;
			group.groupAB = GBSystem.GROUP_A_ID;
			group.name = "青龙组";
			group.color = GBConfig.GROUP_COLOR_A;
			group.colorStr = GBConfig.GROUP_COLOR_STR_A;
			group.minLevel = 70;
			group.maxLevel = -1;
			groupDic[group.id] = group;

			group = new GBGroup();
			group.id = 3;
			group.groupAB = GBSystem.GROUP_B_ID;
			group.name = "白虎组";
			group.color = GBConfig.GROUP_COLOR_B;
			;
			group.colorStr = GBConfig.GROUP_COLOR_STR_B;
			;
			group.minLevel = 70;
			group.maxLevel = -1;
			groupDic[group.id] = group;

			if (groupLevel == GBSystem.GROUP_LEVEL_1)
			{
				groupA = groupDic[0];
				groupB = groupDic[1];
				groupAc = groupDic[2];
				groupBc = groupDic[3];
			}
			else
			{
				groupA = groupDic[2];
				groupB = groupDic[3];
				groupAc = groupDic[0];
				groupBc = groupDic[1];
			}
		}

		/** 获取组,根据组Id */
		public function getGroup(groupId : int) : GBGroup
		{
			return groupDic[groupId];
		}

		/** 获取玩家 */
		public function getPlayer(playerId : int) : GBPlayer
		{
			if (groupA == null) return null;
			var gbPlayer : GBPlayer = groupA.getPlayer(playerId);
			if (gbPlayer == null)
			{
				gbPlayer = groupB.getPlayer(playerId);
			}
			return gbPlayer;
		}

		/** 获取玩家列表 */
		public function getPlayerList(groupId : uint = 0) : Vector.<GBPlayer>
		{
			var list : Vector.<GBPlayer> = new Vector.<GBPlayer>();
			var group : GBGroup;
			if (groupId > 0)
			{
				group = getGroup(groupId);
				list = group.getPlayerList();
			}
			else
			{
				list = groupA.getPlayerList();
				list = list.concat(groupB.getPlayerList());
			}
			return list;
		}

		/** 添加玩家 */
		public function addPlayer(gbPlayer : GBPlayer) : void
		{
			var group : GBGroup = getGroup(gbPlayer.groupId);
			group.addPlayer(gbPlayer);
		}

		/** 移除玩家 */
		public function removePlayer(playerId : uint) : void
		{
			var gbPlayer : GBPlayer = getPlayer(playerId);
			if (gbPlayer)
			{
				gbPlayer.quit();
			}
		}

		/** 更新玩家 */
		public function updatePlayer() : void
		{
		}

		/** 清理 */
		public function clear() : void
		{
			var group : GBGroup;
			for (var key:String in groupDic)
			{
				group = groupDic[key];
				if (group) group.clear();
				delete groupDic[key];
			}

			groupA = null;
			groupB = null;

			while (_fontSortPlayerList.length > 0)
			{
				_fontSortPlayerList.shift();
			}
		}

		/** 连杀前三名玩家列表 */
		public function get fontSortPlayerList() : Vector.<GBPlayer>
		{
			return _fontSortPlayerList;
		}

		public function set fontSortPlayerList(list : Vector.<GBPlayer>) : void
		{
			if (firstPlayerCall != null && list != null && list.length > 0)
			{
				for (var i : int = 0; i < 1; i++)
				{
					var gbPlayer : GBPlayer;
					gbPlayer = list[i];
					firstPlayerCall.apply(null, [gbPlayer.playerName, gbPlayer.colorStr, gbPlayer.maxKillCount]);
				}
			}
			// if (fontSort)
			// {
			// var gbPlayer : GBPlayer;
			// for (var i : int = 0; i < list.length; i++)
			// {
			// if (i >= 3) break;
			// gbPlayer = list[i];
			// fontSort.setPalyer(i + 1, gbPlayer.playerName, gbPlayer.colorStr, gbPlayer.killCount);
			// }
			//
			// for (i = list.length; i < 3; i++)
			// {
			// fontSort.setPalyer(i + 1, null);
			// }
			// }
		}

		/** 排名面板 */
		public function get fontSort() : UiFontSortBox
		{
			return _fontSort;
		}

		public function set fontSort(fontSort : UiFontSortBox) : void
		{
			_fontSort = fontSort;
			if (_fontSort)
			{
				fontSortPlayerList = fontSortPlayerList;
			}
		}

		/** 第一名玩家回调方法 */
		private var _firstPlayerCall : Function;

		public function get firstPlayerCall() : Function
		{
			return _firstPlayerCall;
		}

		public function set firstPlayerCall(fun : Function) : void
		{
			_firstPlayerCall = fun;
			if (_firstPlayerCall != null)
			{
				fontSortPlayerList = fontSortPlayerList;
			}
		}
	}
}
class Singleton
{
}
