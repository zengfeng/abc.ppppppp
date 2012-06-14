package game.module.map.utils
{
	import com.utils.Vector2D;

	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import game.core.user.UserData;
	import game.module.bossWar.BossWarSystem;
	import game.module.map.CurrentMapData;
	import game.module.map.MapController;
	import game.module.map.MapModel;
	import game.module.map.MapSystem;
	import game.module.map.animal.AnimalManager;
	import game.module.map.animal.SelfPlayerAnimal;
	import game.module.map.animal.StoryAnimal;
	import game.module.map.animalstruct.NpcStruct;
	import game.module.map.animalstruct.SelfPlayerStruct;
	import game.module.map.struct.GateStruct;
	import game.module.map.struct.MapStruct;
	import game.module.mapConvoy.ConvoyController;
	import game.module.mapFeast.FeastController;
	import game.module.mapFishing.FishingController;
	import game.module.mapStory.StoryController;
	import game.module.mapWorld.WorldMapUtil;

	import gameui.manager.UIManager;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-28 ����4:53:16
	 */
	public class MapUtil
	{
		/** 自己玩家ID */
		public static function get selfPlayerId() : int
		{
			return UserData.instance.playerId;
		}

		private static var _stage : Stage;

		/** FlashPlayer场景舞台 */
		public static function get stage() : Stage
		{
			if (_stage == null)
			{
				_stage = UIManager.root.stage;
			}
			return _stage;
		}

		/** FlashPlayer场景舞台宽高 */
		public static function get stageWH() : Point
		{
			return new Point(stage.stageWidth, stage.stageHeight);
		}

		/** FlashPlayer场景舞台中心点 */
		public static function get stageCenter() : Point
		{
			return new Point(int(stage.stageWidth / 2), int(stage.stageHeight / 2));
		}

		// ------------------ //
		/** 当前地图数据 */
		private static var _currentMapData : CurrentMapData;

		public static function get currentMapData() : CurrentMapData
		{
			if (_currentMapData == null)
			{
				_currentMapData = CurrentMapData.instance;
			}
			return _currentMapData;
		}

		/** 地图数据结构 */
		public static function getMapStruct(mapId : uint = 0) : MapStruct
		{
			var mapStruct : MapStruct;
			if (mapId <= 0)
			{
				mapStruct = currentMapData.mapStruct;
				if (mapStruct == null) mapStruct = MapModel.instance.getMapStruct(UserData.instance.loginMapId);
			}
			else
			{
				mapStruct = MapModel.instance.getMapStruct(mapId);
			}
			return mapStruct;
		}

		/** 获取当前地图ID */
		public static function getCurrentMapId() : int
		{
			var mapStruct : MapStruct = getMapStruct();
			if (mapStruct == null)
			{
				return 0;
			}

			return mapStruct.id;
		}

		/** 获取世界地图ID */
		public static function getWorldMapId(mapId : int = 0) : int
		{
			return WorldMapUtil.getWorldMapId(mapId);
		}

		/** 获取父地图ID */
		public static function getDuplParentMapId(mapId : int) : int
		{
			return int(mapId / 100);
		}

		/** 判断是不是当前地图 */
		public static function isCurrentMapId(mapId : int) : Boolean
		{
			var currMapId : int = getCurrentMapId();
			return mapId == currMapId || mapId <= 0;
		}

		/** 获取八卦阵(出口入口)站立位置 */
		public static function getGateStandPosition2(gateStruct : GateStruct) : Point
		{
			return gateStruct.standPosition;
		}

		/** 是否存在地图 */
		public static function isHaveMap(mapId : uint) : Boolean
		{
			return getMapStruct(mapId) != null ? true : false;
		}

		// ------------------ //
		/** 地图控制器 */
		private static var _controller : MapController;

		public static function get controller() : MapController
		{
			if (_controller == null)
			{
				_controller = MapController.instance;
			}
			return _controller;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 获取自己剧情玩家动物 */
		public static function get selfStoryPlayerAnimal() : StoryAnimal
		{
			return AnimalManager.instance.selfStory;
		}

		/** 获取自己玩家动物 */
		public static function get selfPlayerAnimal() : SelfPlayerAnimal
		{
			return AnimalManager.instance.selfPlayer;
		}

		/** 获取自己玩家数据结构 */
		public static function get selfPlayerStruct() : SelfPlayerStruct
		{
			return currentMapData.selfPlayerStruct;
		}

		/** 获取自己玩家位置 */
		public static function get selfPlayerPosition() : Point
		{
			var point : Point = new Point();
			if (selfPlayerAnimal)
			{
				point.x = selfPlayerAnimal.x;
				point.y = selfPlayerAnimal.y;
			}
			else if (selfStoryPlayerAnimal)
			{
				point.x = selfStoryPlayerAnimal.x;
				point.y = selfStoryPlayerAnimal.y;
			}
			else
			{
				point.x = currentMapData.selfPlayerStruct.x;
				point.y = currentMapData.selfPlayerStruct.y;
			}
			return point;
		}

		/** 获取地图位置 */
		public static function get mapPosition() : Point
		{
			return new Point(controller.elementLayer.x, controller.elementLayer.y);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 屏幕位置转地图位置 */
		public static function stageToMap(postion : Point, replace : Boolean = false) : Point
		{
			var toPostion : Point;
			toPostion = controller.elementLayer.globalToLocal(postion);
			if (replace)
			{
				postion.x = toPostion.x;
				postion.y = toPostion.y;
				return postion;
			}
			return toPostion;
		}

		/** 地图位置转屏幕位置 */
		public static function mapToStage(postion : Point, replace : Boolean = false) : Point
		{
			var toPostion : Point;
			toPostion = controller.elementLayer.localToGlobal(postion);
			if (replace)
			{
				postion.x = toPostion.x;
				postion.y = toPostion.y;
				return postion;
			}
			return toPostion;
		}

		/** 路径位置转地图位置 */
		public static function pathToMap(postion : Point, replace : Boolean = false, mapId : uint = 0) : Point
		{
			var toPostion : Point = replace == false ? new Point() : postion;
			var mapStruct : MapStruct = getMapStruct(mapId);

			toPostion.x = postion.x * mapStruct.pathPercentage;
			toPostion.y = postion.y * mapStruct.pathPercentage;
			return toPostion;
		}

		/** 路径位置转地图位置X */
		public static function pathToMapX(x : int, mapId : uint = 0) : int
		{
			var toX : int = 0;
			var mapStruct : MapStruct = getMapStruct(mapId);

			toX = x * mapStruct.pathPercentage;
			return toX;
		}

		/** 路径位置转地图位置Y */
		public static function pathToMapY(y : int, mapId : uint = 0) : int
		{
			var toY : int = 0;
			var mapStruct : MapStruct = getMapStruct(mapId);

			toY = y * mapStruct.pathPercentage;
			return toY;
		}

		/** 地图位置转路径位置 */
		public static function mapToPath(postion : Point, replace : Boolean = false, mapId : uint = 0) : Point
		{
			var toPostion : Point = replace == false ? new Point() : postion;
			var mapStruct : MapStruct = getMapStruct(mapId);

			toPostion.x = int(postion.x / mapStruct.pathPercentage);
			toPostion.y = int(postion.y / mapStruct.pathPercentage);
			return toPostion;
		}

		/** 地图位置转路径位置X */
		public static function mapToPathX(x : int, mapId : uint = 0) : int
		{
			var toX : int = 0;
			var mapStruct : MapStruct = getMapStruct(mapId);

			toX = int(x / mapStruct.pathPercentage);
			return toX;
		}

		/** 地图位置转路径位置Y */
		public static function mapToPathY(y : int, mapId : uint = 0) : int
		{
			var toY : int = 0;
			var mapStruct : MapStruct = getMapStruct(mapId);

			toY = int(y / mapStruct.pathPercentage);
			return toY;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 获取地图NPC数据结构 */
		public static function getNpcStruct(npcId : int, mapId : int = 0) : NpcStruct
		{
			var mapStruct : MapStruct = getMapStruct(mapId);
			if (mapStruct == null) return null;
			return mapStruct.npcDic[npcId];
		}

		/** 获取地图NPC位置 */
		public static function getNpcPosition(npcId : int, mapId : int = 0) : Point
		{
			var npcStruct : NpcStruct = getNpcStruct(npcId, mapId);
			if (npcStruct == null) return null;
			return npcStruct.position;
		}

		/** 获取地图NPC站立位置 */
		public static function getNpcStandPosition(npcId : int, mapId : int = 0) : Point
		{
			var npcStruct : NpcStruct = getNpcStruct(npcId, mapId);
			if (npcStruct == null) return null;
			var index : int = Math.floor(npcStruct.standPostion.length * Math.random());
			return npcStruct.standPostion[index];
		}

		/** 获取地图八卦阵(出口入口)字典 */
		public static function getGateStructDic(mapId : int = 0) : Dictionary
		{
			var mapStruct : MapStruct = getMapStruct(mapId);
			return mapStruct.linkGates;
		}

		/** 获取地图去某地图的八卦阵(出入口) */
		public static function getGateStruct(toMapId : int = 0, mapId : int = 0) : GateStruct
		{
			var mapStruct : MapStruct = getMapStruct(mapId);
			if (toMapId == mapId || toMapId <= 0 || toMapId == mapStruct.id)
			{
				return mapStruct.freeGate;
			}
			else
			{
				return mapStruct.linkGates[toMapId];
			}
		}

		/** 获取地图八卦阵(出入口)位置 */
		public static function getGatePosition(toMapId : int = 0, mapId : int = 0) : Point
		{
			var gateStruct : GateStruct = getGateStruct(toMapId, mapId);
			if (gateStruct == null) return null;
			return gateStruct.position;
		}

		/** 获取地图八卦阵(出入口)位置 */
		public static function getGateCenter(toMapId : int = 0, mapId : int = 0) : Point
		{
			var position : Point = getGatePosition(toMapId, mapId);
			if (position == null) return null;
			return new Point(position.x + 70, position.y + 40);
		}

		/** 获取地图八卦阵(出入口)站立位置 */
		public static function getGateStandPosition(toMapId : int = 0, mapId : int = 0) : Point
		{
			var gateStruct : GateStruct = getGateStruct(toMapId, mapId);
			if (gateStruct == null) return null;
			return gateStruct.standPosition;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 是否在屏幕边沿 */
		public static function isStageEdge(selfX : int, selfY : int) : Boolean
		{
			var point : Point = mapToStage(new Point(selfX, selfY), true);
			var v : Number = 2.4;

			if (point.x < stage.stageWidth / v)
			{
				return true;
			}
			else if (stage.stageWidth - point.x < stage.stageWidth / v)
			{
				return true;
			}
			else if (point.y < stage.stageHeight / v)
			{
				return true;
			}
			else if (stage.stageHeight - point.y < stage.stageHeight / v)
			{
				return true;
			}
			return false;
		}

		/** 根据自己的位置,获取地图位置 */
		public static function getMapPostion(selfPostion : Vector2D, mapId : uint = 0) : Vector2D
		{
			var mapPostion : Vector2D = new Vector2D();
			var mapStruct : MapStruct;
			var mapWH : Point;
			var stageCenter : Point = MapUtil.stageCenter;
			if (mapId > 0)
			{
				mapStruct = getMapStruct(mapId);
			}
			else
			{
				mapStruct = currentMapData.mapStruct;
			}
			if (mapStruct == null) return null;
			mapWH = mapStruct.mapWH;
			var stageWidth : Number = stage.stageWidth;
			var stageHeight : Number = stage.stageHeight;
			stageCenter.x = stageWidth / 2;
			stageCenter.y = stageHeight / 2;

			// 如果地图宽度小场景
			if (mapWH.x <= stageWidth)
			{
				mapPostion.x = int((stageWidth - mapWH.x) / 2);
			}
			else
			{
				// 左边沿
				if (selfPostion.x <= stageCenter.x)
				{
					mapPostion.x = 0;
				}
				// 右边沿
				else if (selfPostion.x > mapWH.x - stageCenter.x )
				{
					mapPostion.x = stageWidth - mapWH.x;
				}
				else
				{
					mapPostion.x = stageCenter.x - selfPostion.x;
				}
			}

			// 如果地图高度小场景
			if (mapWH.y <= stageHeight)
			{
				mapPostion.y = int((stageHeight - mapWH.y) / 2);
			}
			else
			{
				// 上边沿
				if (selfPostion.y <= stageCenter.y)
				{
					mapPostion.y = 0;
				}
				// 下边沿
				else if (selfPostion.y >= mapWH.y - stageCenter.y )
				{
					mapPostion.y = stageHeight - mapWH.y;
				}
				else
				{
					mapPostion.y = stageCenter.y - selfPostion.y;
				}
			}

			return mapPostion;
		}

		/** 获取地图移动范围 */
		public static function getMapPostionRectangle(rect : Rectangle = null, mapId : uint = 0) : Rectangle
		{
			if (rect == null) rect = new Rectangle();
			var mapStruct : MapStruct;
			var mapWH : Point;
			if (mapId > 0)
			{
				mapStruct = getMapStruct(mapId);
			}
			else
			{
				mapStruct = currentMapData.mapStruct;
			}
			mapWH = mapStruct.mapWH;
			var stageWidth : Number = stage.stageWidth ;
			var stageHeight : Number = stage.stageHeight ;

			// 如果地图宽度小场景
			if (mapWH.x <= stageWidth)
			{
				rect.x = int((stageWidth - mapWH.x) / 2);
				rect.width = rect.x;
			}
			else
			{
				rect.x = 0;
				rect.width = stageWidth - mapWH.x;
			}

			// 如果地图高度小场景
			if (mapWH.y <= stageHeight)
			{
				rect.y = int((stageHeight - mapWH.y) / 2);
				rect.height = rect.y;
			}
			else
			{
				rect.y = 0;
				rect.height = stageHeight - mapWH.y;
			}

			return rect;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 是否是正常大地图 */
		public static function isGigMap(mapId : int = 0) : Boolean
		{
			if (mapId == 0)
			{
				mapId = getCurrentMapId();
			}
			return mapId > 0 && mapId <= MapSystem.MAX_NORMAL_MAP_ID;
		}

		/** 是否是副本地图 */
		public static function isDungeonMap(mapId : int = 0) : Boolean
		{
			if (mapId == 0)
			{
				mapId = getCurrentMapId();
			}
			return mapId >= MapSystem.MIN_DUNGEON_MAP_ID && mapId < MapSystem.MAX_DUNGEON_MAP_ID;
		}

		/** 是否是特殊地图 */
		public static function isSpecialMap(mapId : int = 0) : Boolean
		{
			if (mapId == 0)
			{
				mapId = getCurrentMapId();
			}
			return mapId >= MapSystem.MIN_SPECIAL_MAP_ID;
		}

		/** 是否是蜀山论剑地图 */
		public static function isGroupBattleMap(mapId : int = 0) : Boolean
		{
			if (mapId == 0)
			{
				mapId = getCurrentMapId();
			}
			return mapId == MapSystem.GROUPBATTLE_MAP_ID;
		}

		/** 是否是主城 */
		public static function isMainMap(mapId : int = 0) : Boolean
		{
			if (mapId == 0)
			{
				mapId = getCurrentMapId();
			}
			return mapId == MapSystem.MAIN_MAP_ID;
		}

		/** 是否是派对地图 */
		public static function isFeastMap(mapId : int = 0) : Boolean
		{
			if (mapId == 0)
			{
				mapId = getCurrentMapId();
			}
			return mapId == MapSystem.FEAST_MAP_ID;
		}

		/** 是否是BOSS战地图 */
		public static function isBossWarMap(mapId : int = 0) : Boolean
		{
			if (mapId == 0)
			{
				mapId = getCurrentMapId();
			}
			return mapId == MapSystem.BOSS_WAR_MAP_ID;
		}

		/** 是否是家主城地图  */
		public static function isClanMainMap(mapId : int = 0) : Boolean
		{
			if (mapId == 0)
			{
				mapId = getCurrentMapId();
			}
			return mapId == MapSystem.CLAN_MAIN_MAP_ID;
		}

		/** 是否是家庭BOSS地图  */
		public static function isClanBossMap(mapId : int = 0) : Boolean
		{
			if (mapId == 0)
			{
				mapId = getCurrentMapId();
			}
			return mapId == MapSystem.CLAN_BOSS_MAP_ID;
		}

		public static function isClanEscorMap(mapId : int = 0) : Boolean
		{
			if ( mapId == 0 )
				mapId = getCurrentMapId() ;
			return mapId == MapSystem.CLAN_ESCORT_MAP_ID ;
		}

		public static function isActiveMap(mapId : int = 0) : Boolean
		{
			if ( mapId == 0 )
			{
				mapId = getCurrentMapId() ;
			}
			
			if(isDungeonMap(mapId))
			{
				return false;
			}
			
			if(isGigMap(mapId))
			{
				return false;
			}
			return true;
		}

		/** 是否是剧情模式 */
		public static function get isStoryMode() : Boolean
		{
			return StoryController.instance.isIn;
		}

		/** 是否在活动中 */
		public static function get isActiveing() : Boolean
		{
			return BossWarSystem.isJoin == true || ConvoyController.instance.selfIsConvoying == true || FishingController.instance.selfIsFishing == true || FeastController.instance.feastStatus != 0 || MapUtil.isClanEscorMap();
		}

		/** 获取离某个坐标距离一段的坐标 */
		public static function getDistancePoint(x : Number, y : Number, directionX : Number, directionY : Number, distance : Number) : Point
		{
			var dx : Number = directionX - x;
			var dy : Number = directionY - y;
			var angle : Number = Math.atan2(dy, dx) * 180 / Math.PI ;
			var point : Point = new Point();

			point.x = Math.cos(angle) * distance;
			point.y = Math.sin(angle) * distance;
			point.x += x;
			point.y += y;
			return point;
		}

		/** 获取走一段距离要多长时间 */
		public static function getDistanceWlakTime(distance : Number, speed : Number) : Number
		{
			return distance / speed * 100;
		}

		/** 获取玩家AVATAR方向ID */
		public static function getPlayerAvatarDirection(x : int, y : int, targetX : int, targetY : int) : int
		{
			var x_distance : Number = x - targetX;
			var y_distance : Number = y - targetY;
			var angle : Number = Math.atan2(y_distance, x_distance) * 180 / Math.PI;
			var direction : int;
			if (angle < 0)
			{
				angle += 360;
			}
			if (angle >= 337.5 || angle < 22.5)
			{
				direction = 3;
			}
			else if (angle >= 22.5 && angle < 67.5)
			{
				direction = 2;
			}
			else if (angle >= 67.5 && angle < 112.5)
			{
				direction = 1;
			}
			else if (angle >= 112.5 && angle < 157.5)
			{
				direction = 2;
			}
			else if (angle >= 157.5 && angle < 202.5)
			{
				direction = 3;
			}
			else if (angle >= 202.5 && angle < 247.5)
			{
				direction = 4;
			}
			else if (angle >= 247.5 && angle < 292.5)
			{
				direction = 5;
			}
			else if (angle >= 292.5 && angle < 337.5)
			{
				direction = 4;
			}
			return direction;
		}
	}
}
