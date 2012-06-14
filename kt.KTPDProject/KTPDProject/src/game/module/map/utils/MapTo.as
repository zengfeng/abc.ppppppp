package game.module.map.utils
{
	import com.commUI.alert.Alert;
	import game.module.map.MapSingles;
	import game.core.user.StateManager;
	import game.manager.EnWalkManager;
	import game.manager.SignalBusManager;
	import game.module.duplMap.DuplUtil;
	import game.module.duplPanel.DuplPanelQuest;
	import game.module.groupBattle.GBProto;
	import game.module.map.MapController;
	import game.module.map.MapProto;
	import game.module.map.NpcSignals;
	import game.module.map.animal.AnimalManager;
	import game.module.map.animal.SelfPlayerAnimal;
	import game.module.map.struct.GateStruct;
	import game.module.mapWorld.WorldMapController;

	import log4a.Logger;

	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-11 ����9:10:06
	 */
	public class MapTo
	{
		function MapTo(singleton : Singleton) : void
		{
			singleton;
			EnWalkManager.continueWalk.add(continueMapTo);
		}

		/** 单例对像 */
		private static var _instance : MapTo;

		/** 获取单例对像 */
		public static  function get instance() : MapTo
		{
			if (_instance == null)
			{
				_instance = new MapTo(new Singleton());
			}
			return _instance;
		}

		private  var continueMapToObj : Object = null;

		private  function continueMapTo() : void
		{
			if (continueMapToObj == null)
			{
				return;
			}
			var funName : String = continueMapToObj["fun"];
			var args : Array = continueMapToObj["args"];
			switch(funName)
			{
				case "clickMapWalk":
					this.clickMapWalk(args[0], args[1]);
					break;
				case "toNpc":
					this.toNpc(args[0], args[1], args[2], args[3], args[4]);
					break;
				case "toMap":
					this.toMap(args[0], args[1], args[2], args[3], args[4], args[5]);
					break;
				case "toAvatarPosition":
					this.toAvatarPosition(args[0], args[1], args[2], args[3]);
					break;
				case "toGate":
					this.toGate(args[0], args[1], args[2], args[3], args[4], args[5]);
					break;
				case "transportTo":
					this.transportTo(args[0], args[1], args[2], args[3], args[4]);
					break;
				case "openWorldMap":
					this.openWorldMap();
					break;
				case "toGroupBattle":
					this.toGroupBattle();
					break;
			}
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 控制器 */
		private static var _controller : MapController;
		/** 动物管理器 */
		private var animalManager : AnimalManager = AnimalManager.instance;
		/** 地图位置工具 */
		private var _mapPosition : MapPosition;

		/** 控制器 */
		public static function get controller() : MapController
		{
			if (_controller == null)
			{
				_controller = MapController.instance;
			}
			return _controller;
		}

		/** 获取自己玩家动物 */
		public function get selfPlayerAnimal() : SelfPlayerAnimal
		{
			return animalManager.selfPlayer;
		}

		/** 当前地图ID */
		public function get currMapId() : uint
		{
			return controller.mapId;
		}

		/** 地图位置工具 */
		public function get mapPosition() : MapPosition
		{
			if (_mapPosition == null)
			{
				_mapPosition = MapPosition.instance;
			}
			return _mapPosition;
		}

		/** 世界地图控制器 */
		private var _worldMapController : WorldMapController;

		/** 世界地图控制器 */
		public function get worldMapController() : WorldMapController
		{
			if (_worldMapController == null)
			{
				_worldMapController = WorldMapController.instance;
			}
			return _worldMapController;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 路线 */
		public var route : Vector.<uint> = new Vector.<uint>();
		/** 目标地图 */
		public var targetMapId : uint = 0;
		/** 目标位置 */
		public var targetPosition : Point = new Point();
		/** 朝向位置 */
		public var directionPosition : Point = new Point();
		/** 位置范围 */
		public var radius : uint = 200;
		/** 回调函数 */
		public var callFun : Function;
		/** 回调函数参数 */
		public var callFunArgs : Array;
		/** 是否使用中 */
		private var _employ : Boolean = false;
		private  var setTimerOutTimer : uint = 0;

		/** 是否使用中 */
		public function get employ() : Boolean
		{
			return _employ;
		}

		public function set employ(value : Boolean) : void
		{
			if (value == false)
			{
				trace(00000);
			}

			if (value == false)
			{
				clear();
			}
			_employ = value;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 清理 */
		public function clear(force : Boolean = true) : void
		{
			if (_employ == false && force == false) return;
			// 路线
			while (route.length > 0)
			{
				route.shift();
			}
			clearTimeout(setTimerOutTimer);
			// 目标地图
			targetMapId = 0;
			// 目标位置
			targetPosition = null;
			directionPosition.x = 0;
			directionPosition.y = 0;
			// 位置范围
			radius = 60;
			// 回调函数
			callFun = null;
			// 回调函数参数
			callFunArgs = null;
			// 是否使用中
			_employ = false;
			// if (continueMapToObj) SignalBusManager.continueMapTo.remove(continueMapTo);
			continueMapToObj = null;
		}

		/** 到达 */
		public function arrive() : void
		{
			Logger.info("MapTo.arrive()");
			if (selfPlayerAnimal.playerStruct.model == 20 || StateManager.instance.isPractice())
			{
				selfPlayerAnimal.sitdownAction();
			}
			else if (directionPosition.x != 0 && directionPosition.y != 0)
			{
				selfPlayerAnimal.stopMove();
				selfPlayerAnimal.standDirection(directionPosition.x, directionPosition.y);
			}
			if (callFun != null) callFun.apply(null, callFunArgs);
		}

		/** 验证是否到达 */
		public function checkArrive() : void
		{
			// Alert.show("MapTo.checkArrive()");
			if (employ == false) return;
			// 如果是本地图
			if (targetMapId == currMapId || targetMapId <= 0)
			{
				var distance : Number = Point.distance(selfPlayerAnimal.position, targetPosition);
				if (distance <= radius)
				{
					arrive();
					clear();
				}
				else
				{
					toCurMap(targetPosition.x, targetPosition.y);
				}
			}
			else if (route.length > 0)
			{
				var toMapId : uint = route.shift();
				toCurGate(toMapId);
			}
			else
			{
				// clear();
			}
		}

		/** 查找路线 */
		public function findRoute(toMapId : uint = 0) : void
		{
			// 初始化路线
			while (route.length > 0)
			{
				route.shift();
			}

			toMapId = (toMapId > 0 ? toMapId : (targetMapId > 0 ? targetMapId : currMapId));
			if (toMapId == currMapId)
			{
				targetMapId = toMapId;
				return;
			}

			// route.push(toMapId);
			targetMapId = toMapId;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 去国战 */
		public function toGroupBattle() : void
		{
			if (EnWalkManager.checkEnWalk(EnWalkManager.TO_GROUP_BATTLE) == false)
			{
				continueMapToObj = new Object();
				continueMapToObj["fun"] = "toGroupBattle";
				return;
			}
			clear(false);
			GBProto.instance.cs_enter();
		}

		/** 打开世界地图 */
		public function openWorldMap() : void
		{
			if (EnWalkManager.checkEnWalk(EnWalkManager.OPEN_WORLD_MAP) == false)
			{
				continueMapToObj = new Object();
				continueMapToObj["fun"] = "openWorldMap";
				return;
			}
			clear(false);
			WorldMapController.instance.open();
		}

		/** 点击地图走路走路 */
		public function  clickMapWalk(x : int, y : int) : void
		{
			if (EnWalkManager.checkEnWalk(EnWalkManager.CLICK_MAP_WALK) == false)
			{
				continueMapToObj = new Object();
				continueMapToObj["fun"] = "clickMapWalk";
				continueMapToObj["args"] = [x, y];
				controller.enMouseMove = false;
				setTimeout(function() : void
				{
					controller.enMouseMove = true;
				}, 1000);
				return;
			}
			clear(false);
			selfPlayerAnimal.walk(x, y);
		}

		/** 去本地图某个位置(只有走路方式) */
		private  function toCurMap(x : int = 0, y : int = 0) : void
		{
			selfPlayerAnimal.walkPass(x, y);
		}

		/** 去本地图八卦阵(出口入口) */
		public function toCurGate(toMapId : uint, stand : Boolean = false) : void
		{
			var position : Point;
			if (stand == false)
			{
				position = MapUtil.getGateCenter(toMapId);
			}
			else
			{
				position = MapUtil.getGateStandPosition(toMapId);
			}

			if (position)
			{
				toCurMap(position.x, position.y);
			}
		}

		/** 去avatar位置 */
		public function toAvatarPosition(x : int, y : int, callFun : Function, callFunArgs : Array = null) : void
		{
			if (EnWalkManager.checkEnWalk(EnWalkManager.TO_AVATAR_POSITION) == false)
			{
				continueMapToObj = new Object();
				continueMapToObj["fun"] = "toAvatarPosition";
				continueMapToObj["args"] = [x, y, callFun, callFunArgs];
				return;
			}

			var point : Point = selfPlayerAnimal.position;
			var dx : Number = point.x - x;
			var dy : Number = point.y - y;
			var distance : Number = Math.sqrt(dx * dx + dy * dy) ;
			var maxdistance : int = MapUtil.isDungeonMap() == false ? 300 : 2;
			directionPosition.x = x;
			directionPosition.y = y;
			if (distance <= maxdistance)
			{
				this.callFun = callFun;
				this.callFunArgs = callFunArgs;
				arrive();
				clear();
				return;
			}
			maxdistance = MapUtil.isDungeonMap() == false ? 100 : 2;
			point = MapUtil.getDistancePoint(x, y, point.x, point.y, 100);
			toMap(0, point.x, point.y, false, callFun, callFunArgs);
		}
		
		private var delayToMapArgs : Array;

		private function delayToMap() : void
		{
			MapSingles.setupMapComplete.remove(delayToMap);
			toMap(delayToMapArgs[0], delayToMapArgs[1], delayToMapArgs[2], delayToMapArgs[3], delayToMapArgs[4], delayToMapArgs[5]);
		}

		/** 去某地图 */
		public function toMap(mapId : uint = 0, x : int = 0, y : int = 0, flashStep : Boolean = false, callFun : Function = null, callFunArgs : Array = null) : void
		{
			if (EnWalkManager.checkEnWalk(EnWalkManager.TO_MAP) == false)
			{
				continueMapToObj = new Object();
				continueMapToObj["fun"] = "toMap";
				continueMapToObj["args"] = [mapId, x, y, flashStep, callFun, callFunArgs];
				return;
			}
			clear();
			
			//如果当前地图是副本
			if (MapUtil.isDungeonMap(MapUtil.getCurrentMapId()) && MapUtil.isCurrentMapId(mapId) == false)
			{
				var currentMapId : int ;
				var parentMapId : int ;
				currentMapId = MapUtil.getCurrentMapId();
				parentMapId = MapUtil.getDuplParentMapId(currentMapId);
				if (parentMapId == mapId)
				{
					delayToMapArgs =  [mapId, x, y, flashStep, callFun, callFunArgs];
					MapSingles.setupMapComplete.add(delayToMap);
					MapSingles.sendLeaveDuplMap.dispatch();
					return;
				}
				else
				{
					if (MapUtil.isDungeonMap(mapId) == false)
					{
						delayToMapArgs =  [mapId, x, y, flashStep, callFun, callFunArgs];
						MapSingles.setupMapComplete.add(delayToMap);
						worldMapController.toMap(mapId, true);
						return;
					}
					else
					{
						Alert.show("去副本位置不准你用 toMap ,请用toDuplNpc");
						return;
					}
				}
			}
			targetPosition = new Point(x, y);
			directionPosition.x = x;
			directionPosition.y = y;
			findRoute(mapId);
			this.callFun = callFun;
			this.callFunArgs = callFunArgs;
			employ = true;
			checkArrive();
			if (employ == false) return;

			if (MapUtil.isCurrentMapId(mapId) == false && flashStep == false)
			{
				worldMapController.toMap(mapId, true);
			}

			if (flashStep == true )
			{
				transportTo(x, y, mapId, callFun, callFunArgs);
			}
		}

		private var delayToNpcArgs : Array;

		private function delayToNpc() : void
		{
			MapSingles.setupMapComplete.remove(delayToNpc);
			toNpc(delayToNpcArgs[0], delayToNpcArgs[1], delayToNpcArgs[2], delayToNpcArgs[3], delayToNpcArgs[4]);
		}

		/** 去某NPC */
		public function toNpc(npcId : int, mapId : uint = 0, flashStep : Boolean = false, callFun : Function = null, callFunArgs : Array = null) : void
		{
			if (EnWalkManager.checkEnWalk(EnWalkManager.TO_NPC) == false)
			{
				continueMapToObj = new Object();
				continueMapToObj["fun"] = "toNpc";
				continueMapToObj["args"] = [npcId, mapId, flashStep, callFun, callFunArgs];
				return;
			}
			clear();
			if (MapUtil.isActiveMap(mapId))
			{
			}
			else if (MapUtil.isDungeonMap(MapUtil.getCurrentMapId()) && MapUtil.isCurrentMapId(mapId) == false)
			{
				var currentMapId : int ;
				var parentMapId : int ;
				currentMapId = MapUtil.getCurrentMapId();
				parentMapId = MapUtil.getDuplParentMapId(currentMapId);
				if (parentMapId == mapId)
				{
					delayToNpcArgs = [npcId, mapId, flashStep, callFun, callFunArgs];
					MapSingles.setupMapComplete.add(delayToNpc);
					MapSingles.sendLeaveDuplMap.dispatch();
					return;
				}
				else
				{
					if (MapUtil.isDungeonMap(mapId) == false)
					{
						delayToNpcArgs = [npcId, mapId, flashStep, callFun, callFunArgs];
						MapSingles.setupMapComplete.add(delayToNpc);
						worldMapController.toMap(mapId, true);
						return;
					}
					else
					{
						Alert.show("去副本NPC不准你用 toNpc ,请用toDuplNpc");
						return;
					}
				}
			}
			var position : Point;
			position = MapUtil.getNpcPosition(npcId, mapId);
			directionPosition.x = position.x;
			directionPosition.y = position.y;
			if (MapUtil.isCurrentMapId(mapId) == true)
			{
				if (position != null)
				{
					var dist : Number = Point.distance(position, MapUtil.selfPlayerPosition);
					if (dist <= 200)
					{
						this.callFun = callFun;
						this.callFunArgs = callFunArgs;
						arrive();
						clear();
						return;
					}
				}
			}
			if (npcId < 4000)
			{
				position = MapUtil.getNpcStandPosition(npcId, mapId);
			}
			else
			{
				position = MapUtil.getNpcPosition(npcId, mapId);
			}
			if (position == null) return;
			targetPosition = position;
			findRoute(mapId);
			this.callFun = callFun;
			this.callFunArgs = callFunArgs;
			employ = true;
			checkArrive();
			if (employ == false) return;

			if (MapUtil.isCurrentMapId(mapId) == false && flashStep == false)
			{
				worldMapController.toMap(mapId, true);
			}

			if (flashStep == true && targetPosition)
			{
				transportTo(targetPosition.x, targetPosition.y, mapId, callFun, callFunArgs);
			}
		}

		/** 去八卦阵(出口入口) */
		public function toGate(toMapId : uint, mapId : uint = 0, stand : Boolean = false, flashStep : Boolean = false, callFun : Function = null, callFunArgs : Array = null) : void
		{
			if (EnWalkManager.checkEnWalk(EnWalkManager.TO_GATE) == false)
			{
				continueMapToObj = new Object();
				continueMapToObj["fun"] = "toGate";
				continueMapToObj["args"] = [toMapId, mapId, stand, flashStep, callFun, callFunArgs];
				return;
			}

			clear();
			if (stand == false)
			{
				targetPosition = MapUtil.getGateCenter(toMapId, mapId);
			}
			else
			{
				targetPosition = MapUtil.getGateStandPosition(toMapId, mapId);
			}

			directionPosition.x = 0;
			directionPosition.y = 0;
			findRoute(mapId);
			this.callFun = callFun;
			this.callFunArgs = callFunArgs;
			employ = true;
			checkArrive();
			if (employ == false) return;

			if (MapUtil.isCurrentMapId(mapId) == false && flashStep == false)
			{
				worldMapController.toMap(mapId, true);
			}

			if (flashStep == true && targetPosition)
			{
				transportTo(targetPosition.x, targetPosition.y, mapId, callFun, callFunArgs);
			}
		}

		public function toDuplNpc(toDuplMapId : int) : void
		{
			if (MapUtil.isCurrentMapId(toDuplMapId))
			{
				NpcSignals.gotoNextAI.dispatch();
				return;
			}

			var parentMapId : int = MapUtil.getDuplParentMapId(toDuplMapId);
			var currentMapId : int = MapUtil.getCurrentMapId();
			if (MapUtil.isDungeonMap(currentMapId) == false)
			{
				toGate(toDuplMapId, parentMapId, false, false, arriveGate, [toDuplMapId]);
				return;
			}
			var currentPasrentMapId : int = MapUtil.getDuplParentMapId(currentMapId);
			if (currentPasrentMapId == parentMapId)
			{
				this.toDuplMapId = toDuplMapId;
				MapSingles.setupMapComplete.add(delayToDupelMap);
				MapSingles.sendLeaveDuplMap.dispatch();
				return;
			}
			else
			{
				this.toDuplMapId = toDuplMapId;
				MapSingles.setupMapComplete.add(delayToDupelMap);
				worldMapController.toMap(parentMapId, true);
				return;
			}
		}

		private function arriveGate(toDuplMapId : int) : void
		{
			var gateStruct : GateStruct = MapUtil.getGateStruct(toDuplMapId);
			if (gateStruct)
			{
				this.toDuplMapId = toDuplMapId;
				MapSingles.setupMapComplete.add(delayToDupelMap);
				MapProto.instance.cs_CSUseGate(gateStruct.id);
			}
		}

		private var toDuplMapId : int;

		private function delayToDupelMap() : void
		{
			MapSingles.setupMapComplete.remove(delayToDupelMap);
			toDuplNpc(toDuplMapId);
		}

		/** 传送 (不验证消费)  */
		public function transportTo(x : int, y : int, mapId : int = 0, callFun : Function = null, callFunArgs : Array = null) : void
		{
			if (EnWalkManager.checkEnWalk(EnWalkManager.TRANSPORT_TO) == false)
			{
				continueMapToObj = new Object();
				continueMapToObj["fun"] = "transportTo";
				continueMapToObj["args"] = [x, y, mapId, callFun, callFunArgs];
				return;
			}
			clear();
			targetPosition = new Point(x, y);
			this.callFun = callFun;
			this.callFunArgs = callFunArgs;
			employ = true;
			MapProto.instance.cs_transport(x, y, mapId);
			if (mapId == MapUtil.getCurrentMapId()) setTimerOutTimer = setTimeout(checkArrive, 1000);
		}
	}
}
class Singleton
{
}