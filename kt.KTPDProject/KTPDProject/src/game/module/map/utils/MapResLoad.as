package game.module.map.utils
{
	import game.config.StaticConfig;
	import game.core.avatar.AvatarManager;
	import game.core.avatar.AvatarType;
	import game.manager.RSSManager;
	import game.module.duplMap.data.LayerStruct;
	import game.module.map.CurrentMapData;
	import game.module.map.animalstruct.MonsterStruct;
	import game.module.map.struct.MapStruct;
	import game.module.quest.VoBase;
	import game.net.core.Common;

	import net.LibData;
	import net.RESManager;
	import net.SWFLoader;

	import com.commUI.CommonLoading;
	import com.utils.UrlUtils;

	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;




	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-9 ����10:22:45
	 */
	public class MapResLoad
	{
		function MapResLoad(singleton : Singleton) : void
		{
			singleton;
		}

		/** 单例对像 */
		private static var _instance : MapResLoad;

		/** 获取单例对像 */
		static public function get instance() : MapResLoad
		{
			if (_instance == null)
			{
				_instance = new MapResLoad(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		private var res : RESManager = RESManager.instance;
		private var load_lm : CommonLoading;
		private var loadCompleteFun : Function;
		private var avatarManager : AvatarManager = AvatarManager.instance;
		private var silentLoadBreak : Boolean = false;
		private var silentLoadTimeList : Vector.<uint> = new Vector.<uint>();
		/** 当前地图数据 */
		private var _curData : CurrentMapData;

		/**  */
		/** 当前地图数据 */
		public function get curData() : CurrentMapData
		{
			if (_curData == null)
			{
				_curData = CurrentMapData.instance;
			}
			return _curData;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		public function clear(mapId : int) : void
		{
			if (mapId <= 0) return;
			silentLoadBreak = true;
			while (silentLoadTimeList.length > 0)
			{
				clearTimeout(silentLoadTimeList.shift());
			}
			var key : String ;
			var libData : LibData;
			var list : Vector.<LibData>;
			// 缩略图
			key = ResKey.thumbnail(mapId);
			res.remove(key);
			// 地图寻路数据
			key = ResKey.pathDataSwf(mapId);
			res.remove(key);
			// 地图块
			list = mapPiece(mapId);
			for (var i : int = 0; i < list.length; i++)
			{
				libData = list[i];
				res.remove(libData.key);
			}
			// 怪物
			list = monsterAvatar(mapId);
			for (i = 0; i < list.length; i++)
			{
				libData = list[i];
				res.remove(libData.key);
			}
		}

		public function load(mapId : int, loadCompleteFun : Function = null) : void
		{
			silentLoadBreak = false;
			this.loadCompleteFun = loadCompleteFun;
			// if (MapUtil.isHaveMap(mapId) == false)
			// {
			// loadComplete();
			// return;
			// }

			if (load_lm == null)
			{
				load_lm = Common.getInstance().loadPanel;
			}

			var libData : LibData;
			var list : Vector.<LibData>;
			// 缩略图
			if (MapUtil.isDungeonMap(mapId) == false)
			{
				libData = thumbnail(mapId);
				res.add(new SWFLoader(libData));
			}
			// 地图寻路数据
			libData = pathDataSwf(mapId);
			res.add(new SWFLoader(libData));
			// 八卦阵(入口出口)
			libData = gate();
			res.add(new SWFLoader(libData));

			// 自己玩家走路的Avatar
			libData = selfPlayerAvatar();
			res.add(new SWFLoader(libData));

			// 自己玩家战斗的Avatar
			if (MapUtil.isDungeonMap(mapId))
			{
				libData = selfPlayerBattleAvatar();
				res.add(new SWFLoader(libData));
			}
			// 地图块
			list = mapPiece(mapId);
			for (var i : int = 0; i < list.length; i++)
			{
				libData = list[i];
				res.add(new SWFLoader(libData));
			}
			// 怪物
			list = monsterAvatar(mapId);
			for (i = 0; i < list.length; i++)
			{
				libData = list[i];
				res.add(new SWFLoader(libData));
			}

			if (MapUtil.isDungeonMap(mapId))
			{
				res.add(new SWFLoader(new LibData(StaticConfig.cdnRoot + "assets/ui/Numbers.swf", "Numbers")));
				res.add(new SWFLoader(new LibData(StaticConfig.cdnRoot + "assets/avatar/battle/die.swf", "diessss")));
				res.add(new SWFLoader(new LibData(StaticConfig.cdnRoot + "assets/ui/battle/commBg.jpg", "battleBg")));
			}

			res.addEventListener(Event.COMPLETE, loadComplete);
			res.startLoad();

			load_lm.startShow();
		}

		private function loadComplete(event : Event = null) : void
		{
			load_lm.hide();
			res.removeEventListener(Event.COMPLETE, loadComplete);
			if (loadCompleteFun != null)
			{
				loadCompleteFun.apply();
			}
		}

		/** 沉默加载 */
		public function silentLoad(mapId : uint) : void
		{
			if (MapUtil.isHaveMap(mapId) == false) return;
			var libData : LibData;
			var list : Vector.<LibData>;
			var allList : Vector.<LibData> = new Vector.<LibData>();
			// 缩略图
			libData = thumbnail(mapId);
			allList.push(libData);
			// 地图寻路数据
			libData = pathDataSwf(mapId);
			allList.push(libData);
			// 八卦阵(入口出口)
			libData = gate();
			allList.push(libData);

			// 自己玩家走路的Avatar
			libData = selfPlayerAvatar();
			allList.push(libData);

			// 自己玩家战斗的Avatar
			if (MapUtil.isDungeonMap(mapId))
			{
				libData = selfPlayerBattleAvatar();
				allList.push(libData);
			}
			// 地图块
			list = mapPiece(mapId);
			allList = allList.concat(list);
			// 怪物
			list = monsterAvatar(mapId);
			allList = allList.concat(list);

			for (var i : int = 0; i < allList.length; i++)
			{
				// res.load(allList[i]);
				var tiem : uint = setTimeout(res.load, i * 100, allList[i]);
				silentLoadTimeList.push(tiem);
			}
		}

		/** 沉默加载 */
		public function silentLoad2(mapId : uint) : void
		{
			if (MapUtil.isHaveMap(mapId) == false) return;
			var libData : LibData;
			var list : Vector.<LibData>;
			var allList : Vector.<LibData> = new Vector.<LibData>();
			// 缩略图
			libData = thumbnail(mapId);
			res.load(libData);
			// 地图寻路数据
			libData = pathDataSwf(mapId);
			res.load(libData);
			// 八卦阵(入口出口)
			libData = gate();
			res.load(libData);

			// 自己玩家走路的Avatar
			libData = selfPlayerAvatar();
			res.load(libData);

			// 自己玩家战斗的Avatar
			if (MapUtil.isDungeonMap(mapId))
			{
				libData = selfPlayerBattleAvatar();
				res.load(libData);
			}
			// 地图块
			list = mapPiece(mapId);
			for (var i : int = 0; i < list.length; i++)
			{
				libData = list[i];
				res.load(libData);
			}
			// 怪物
			list = monsterAvatar(mapId);
			for (i = 0; i < list.length; i++)
			{
				libData = list[i];
				res.load(libData);
			}
		}

		public function thumbnail(mapId : uint) : LibData
		{
			var url : String = UrlUtils.getMapThumbnail(mapId);
			var key : String = ResKey.thumbnail(mapId);
			return new LibData(url, key, true);
		}

		public function pathDataSwf(mapId : uint) : LibData
		{
			var url : String = UrlUtils.getMapPathDataSwf(mapId);
			var key : String = ResKey.pathDataSwf(mapId);
			return new LibData(url, key, true);
		}

		public function gate() : LibData
		{
			var url : String = UrlUtils.FILE_GATE;
			var key : String = ResKey.gate;
			return new LibData(url, key, true);
		}

		public function mapPiece(mapId : uint) : Vector.<LibData>
		{
			var list : Vector.<LibData> = new Vector.<LibData>();
			var mapStruct : MapStruct = MapUtil.getMapStruct(mapId);
			var pieceRepeatHW : Point = new Point();

			var libData : LibData;
			pieceRepeatHW.x = Math.ceil(mapStruct.mapWH.x / mapStruct.singlePieceHW.x) - 1;
			pieceRepeatHW.y = Math.ceil(mapStruct.mapWH.y / mapStruct.singlePieceHW.y) - 1;
			for (var y : int = 0; y <= pieceRepeatHW.y; y++)
			{
				for (var x : int = 0; x <= pieceRepeatHW.x; x++)
				{
					var key : String = ResKey.piece(mapId, x, y);
					var url : String = UrlUtils.getMapPiece2(mapId, x, y);
					libData = new LibData(url, key, true);
					list.push(libData);
				}
			}
			return list;
		}

		public function selfPlayerAvatar() : LibData
		{
			var key : uint = avatarManager.getUUId(curData.selfPlayerStruct.heroId, AvatarType.PLAYER_RUN, curData.selfPlayerStruct.cloth);
			var url : String = UrlUtils.getAvatar(key);
			return new LibData(url, key.toString(), true);
		}

		public function selfPlayerBattleAvatar() : LibData
		{
			var key : uint = avatarManager.getUUId(curData.selfPlayerStruct.heroId, AvatarType.PLAYER_RUN, curData.selfPlayerStruct.cloth);
			var url : String = UrlUtils.getAvatar(key);
			return new LibData(url, key.toString(), true);
		}

		public function npcAvatar() : Vector.<LibData>
		{
			var list : Vector.<LibData> = new Vector.<LibData>();
			if (curData.setupNpcList == null || curData.setupNpcList.length == 0) return list;
			for (var i : int = 0; i < curData.setupNpcList.length; i++)
			{
			}

			return list;
		}

		public function monsterAvatar(mapId : uint) : Vector.<LibData>
		{
			var list : Vector.<LibData> = new Vector.<LibData>();
			if (MapUtil.isDungeonMap(mapId) == false) return list;
			if (curData.setupMonsterList == null || curData.setupMonsterList.length == 0) return list;
			// var voLayer : VoLayer = DungeonModel.instance.getVoLayer3(mapId);
			var voLayer : LayerStruct;
			if (voLayer == null) return list;
			var monsterStruct : MonsterStruct;
			var key : uint;
			var url : String;
			var libData : LibData;
			var battleAvatarKeyDic : Dictionary = new Dictionary();
			for (var i : int = 0; i < voLayer.monsterList.length; i++)
			{
				monsterStruct = voLayer.monsterList[i];
				// key = avatarManager.getUUId(monsterStruct.monsterId, AvatarType.MONSTER_TYPE, 0);
				// if (avatarKeyDic[key] == null)
				// {
				// url = UrlUtils.getAvatar(key);
				// libData = new LibData(url, key.toString(), true);
				// list.push(libData);
				// }

				for (var j : int = 0; j < monsterStruct.monsterIdList.length; j++)
				{
					var voBase : VoBase = RSSManager.getInstance().getNpcById(monsterStruct.monsterIdList[j]);
					if (voBase)
					{
						key = avatarManager.getUUId(voBase.avatarId, AvatarType.MONSTER_TYPE, 0);
						if (battleAvatarKeyDic[key] == null)
						{
							url = UrlUtils.getAvatar(key);
							libData = new LibData(url, key.toString(), true);
							list.push(libData);
						}
					}
				}
			}
			return list;
		}
	}
}
class Singleton
{
}
