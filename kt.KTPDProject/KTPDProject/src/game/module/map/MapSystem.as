package game.module.map
{
	import com.greensock.TweenLite;
	import com.utils.Vector2D;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import game.core.avatar.AvatarNpc;
	import game.manager.MouseManager;
	import game.module.map.animal.Animal;
	import game.module.map.animal.AnimalDictionary;
	import game.module.map.animal.AnimalManager;
	import game.module.map.animal.AnimalType;
	import game.module.map.animal.PlayerAnimal;
	import game.module.map.animal.SelfPlayerAnimal;
	import game.module.map.animalManagers.HidePlayerManager;
	import game.module.map.animalstruct.MonsterStruct;
	import game.module.map.animalstruct.PetStruct;
	import game.module.map.animalstruct.PlayerStruct;
	import game.module.map.animalstruct.SelfPlayerStruct;
	import game.module.map.layers.ElementLayer;
	import game.module.map.utils.MapPosition;
	import game.module.map.utils.MapTo;
	import game.module.map.utils.MapUtil;
	import game.module.quest.QuestUtil;



	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-26 ����2:55:29
	 */
	public class MapSystem
	{
		/** 当前地图数据 */
		private static var currentMapData : CurrentMapData = CurrentMapData.instance;

		/** 模型 */
		private static var model : MapModel = MapModel.instance;

		/** 去地图某个地方的工具 */
		public static var mapTo : MapTo = MapTo.instance;

		/** 动物管理器 */
		private static var animalManager : AnimalManager = AnimalManager.instance;

		/** 动物字典 */
		private static var animalDictionary : AnimalDictionary = AnimalDictionary.instance;

		/** 路径图比例尺 */
		public static var PATH_PERCENTAGE : uint = 16;

		/** 八卦阵(出口入口)大小 */
		public static var gateSize : int = 400;

		/** 八卦阵(出口入口)一半大小 */
		public static var gateHalfSize : int = 50;

		/** 切换地图时间 */
		public static var changeMapTime : Number = 0;

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 回当上一地图ID */
		public static const PRE_MAP_ID:int = 10101;
		
		/** 最大正常地图 */
		public static const MAX_NORMAL_MAP_ID : int = 29;

		/** 最小副本地图ID */
		public static const MIN_DUNGEON_MAP_ID : int = 100;
		/** 最大副本地图ID */
		public static const MAX_DUNGEON_MAP_ID : int = 10000;

		/** 最小特殊地图ID */
		public static const MIN_SPECIAL_MAP_ID : int = 1000000;

		/** 蜀山论剑地图ID */
		public static const GROUPBATTLE_MAP_ID : int = 1000001;

		/** 主城地图ID */
		public static const MAIN_MAP_ID : int = 20;

		/** 家族主城地图ID */
		public static const CLAN_MAIN_MAP_ID : int = 30;

		/** 家族运镖地图ID */
		public static const CLAN_ESCORT_MAP_ID : int = 31;

		/** 家族BOSS地图ID */
		public static const CLAN_BOSS_MAP_ID : int = 32;

		/** BOSS战地图 */
		public static const BOSS_WAR_MAP_ID :int = 41 ;
        
		/** 派对地图 */
		public static const FEAST_MAP_ID :int = 42 ;

		/** 是否显示路径 */
		public static var debugShowPath : Boolean = false;

		/** 是否在副本地图中 */
		public static function get isEnterDungeon() : Boolean
		{
			return MapUtil.isDungeonMap(controller.mapId);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 控制器 */
		private static var _controller : MapController ;

		/** 元素层 */
		private static var _elementLayer : ElementLayer ;

		/** 地图位置工具 */
		private static var _mapPosition : MapPosition;

		/** 控制器 */
		public static function get controller() : MapController
		{
			if (_controller == null)
			{
				_controller = MapController.instance;
			}
			return _controller;
		}

		/** 元素层 */
		public static function get elementLayer() : ElementLayer
		{
			if (_elementLayer == null)
			{
				_elementLayer = controller.elementLayer;
			}
			return _elementLayer;
		}

		/** 地图位置工具 */
		private static function get mapPosition() : MapPosition
		{
			if (_mapPosition == null)
			{
				_mapPosition = MapPosition.instance;
			}
			return _mapPosition;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 地图移动是否绑定自己玩家 */
		private static var _mapMoveIsBindSelfPlayer : Boolean = true;

		/** 地图移动是否绑定自己玩家 */
		public static function get mapMoveIsBindSelfPlayer() : Boolean
		{
			return _mapMoveIsBindSelfPlayer;
		}

		public static function set mapMoveIsBindSelfPlayer(value : Boolean) : void
		{
			_mapMoveIsBindSelfPlayer = value;
		}
		
		/** 是否能选中其他玩家 */
		public static var enSelectOtherPlayer:Boolean = true;

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 地图是否是隐藏服务器模式 */
		private static var _hideServerMode : Boolean = false;

		/** 地图是否是隐藏服务器模式 */
		public static function get hideServerMode() : Boolean
		{
			if (MapUtil.isGroupBattleMap() == true) return true;
			return _hideServerMode;
		}

		public static function set hideServerMode(value : Boolean) : void
		{
			_hideServerMode = value;
		}

		/** 设置地图是否是隐藏服务器模式 */
		public static function setHideServerMode(isHideServer : Boolean, isSync : Boolean = false) : void
		{
			_hideServerMode = isHideServer;
			if (isSync == true)
			{
				if (_hideServerMode == true)
				{
					HidePlayerManager.instance.syncFromPlayerManagerList();
				}
				else
				{
					HidePlayerManager.instance.syncToPlayerManagerList();
				}
			}
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 
		 * 移动地图到(x, y)
		 * @param spendTime 花费时间 (-1：为自动计算时间，0：为瞬间跳动，1：为固定预时间， 大于为1为自己设置时间)
		 */
		public static function mapMoveTo(x : int, y : int, spendTime : Number = -1) : void
		{
			mapPosition.moveTo(x, y, spendTime);
		}

		/** 是否可以鼠标所在屏幕方向移动地图 */
		public static function set enMouseMoveMap(value : Boolean) : void
		{
			mapPosition.enMouseMove = value;
		}

		public static function get enMouseMoveMap() : Boolean
		{
			return mapPosition.enMouseMove;
		}

		/** 是否能鼠标点击控制玩家 */
		public static function get enMouseClickMovePlayer() : Boolean
		{
			return controller.enMouseMove;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
//		/** 去某地图 */
//		public static function toMap(id : uint = 0, x : int = 0, y : int = 0, flashStep : Boolean = false, callFun : Function = null, callFunArgs : Array = null) : void
//		{
//			mapTo.toMap(id, x, y, flashStep, callFun, callFunArgs);
//		}
//
//		/** 去avatar位置 */
//		public static function toAvatarPosition(x : int, y : int, callFun : Function, callFunArgs : Array = null) : void
//		{
//			mapTo.toAvatarPosition(x, y, callFun, callFunArgs);
//		}
//
//		/** 去某NPC */
//		public static function toNpc(npcId : int, mapId : uint = 0, flashStep : Boolean = false, callFun : Function = null, callFunArgs : Array = null) : void
//		{
//			mapTo.toNpc(npcId, mapId, flashStep, callFun, callFunArgs);
//		}
//
//		/** 去八卦阵(出口入口) */
//		public static function toGate(toMapId : uint, mapId : uint = 0, stand : Boolean = false, flashStep:Boolean = false,  callFun : Function = null, callFunArgs : Array = null) : void
//		{
//			mapTo.toGate(toMapId, mapId, stand, flashStep, callFun, callFunArgs);
//		}
//
//		/** 去某怪物 */
//		public static function toMonster(wave : uint, mapId : uint = 0, callFun : Function = null) : void
//		{
//		}
//
//		/** 去某玩家 */
//		public static function toPlayer(playerId : uint, mapId : uint = 0, callFun : Function = null) : void
//		{
//		}
//
//		/** 去某位置 */
//		public static function toPostion(x : int, y : int, mapId : uint = 0, callFun : Function = null) : void
//		{
//		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 安装地图 */
		public static function setupMap(mapId : uint, selfPostion : Point) : void
		{
			controller.preSetupMap(mapId, selfPostion);
		}

		/** 添加自己玩家 */
		public static function addSelfPlayer(playerStruct : SelfPlayerStruct = null) : SelfPlayerAnimal
		{
			return controller.addSelfPlayer(playerStruct);
		}

		/** 添加玩家列表 */
		public static function addPlayerList(playerList : Vector.<PlayerStruct>) : void
		{
			for (var i : int = 0; i < playerList.length; i++)
			{
				addPlayer(playerList[i]);
			}
		}

		/** 添加玩家 */
		public static function addPlayer(playerStruct : PlayerStruct) : PlayerAnimal
		{
			return controller.addPlayer(playerStruct);
		}

		/** 移除玩家 */
		public static function removePlayer(playerId : uint) : void
		{
			controller.removePlayer(playerId);
		}

		/** 初始化玩家Avatar */
		public static function initPlayerAvatar(playerStruct : PlayerStruct ) : void
		{
			controller.initPlayerAvatar(playerStruct);
		}
		
//		/** 更新玩家Avatar */
//		public static function updateAvatar(msg : SCAvatarInfoChange):void
//		{
//			controller.updateAvatar(msg);
//		}

		/** 更新玩家Avatar */
		public static function updateAvatar( id:int ) : void
		{
			controller.updateAvatar(id );
		}

		/** 更新玩家位置 */
		public static function updatePlayerPosition(playerStruct : PlayerStruct) : void
		{
			controller.updatePlayerPosition(playerStruct);
		}

		/** 传送 */
		public static function transport(playerStruct : PlayerStruct) : void
		{
			controller.transport(playerStruct);
		}

		/** 添加NPC列表 */
		public static function addNpcList(npcIdList : Vector.<uint>) : void
		{
			controller.addNpcList(npcIdList);
		}

		/** 添加NPC */
		public static function addNpc(npcId : uint) : void
		{
			controller.addNpc(npcId);
		}

		/** 移除NPC */
		public static function removeNpc(npcId : uint) : void
		{
			controller.removeNpc(npcId);
		}

		/** 设置NPC显示状态 */
		public static function setNpcVisible(npcId : uint, visible : Boolean) : void
		{
			controller.setNpcVisible(npcId, visible);
		}

		/** 添加怪物 */
		public static function addMonster(monsterStruct : MonsterStruct) : void
		{
		}

		/** 移除怪物 */
		public static function removeMonster(monsterStruct : MonsterStruct) : void
		{
		}

		/** 添加宠物 */
		public static function addPet(petStruct : PetStruct) : void
		{
		}

		/** 移除宠物 */
		public static function removePet(petStruct : PetStruct) : void
		{
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 是否显示其他玩家 */
		private static var _otherPlayerVisible : Boolean = true;

		/** 是否显示其他玩家 */
		public static function get otherPlayerVisible() : Boolean
		{
			return _otherPlayerVisible;
		}

		public static function set otherPlayerVisible(value : Boolean) : void
		{
			_otherPlayerVisible = value;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 获取NPC的Avatar */
		public static function getNpcAvatar(npcId : uint) : AvatarNpc
		{
			return elementLayer.getNpc(npcId);
		}

		/** 获取NPC的Avatar列表 */
		public static function getNpcAvatarList() : Vector.<AvatarNpc>
		{
			return elementLayer.npcList;
		}

		/**  获取自己玩家动物 */
		public static function get selfPlayerAnimal() : SelfPlayerAnimal
		{
			return controller.selfPlayerAnimal;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 地图改变监听函数列表 */
		private static var _changeMapCallFun : Vector.<Function> = new Vector.<Function>();

		/** 添加地图改变监听函数 */
		public static function addChangeMapCallFun(fun : Function) : void
		{
			if (_changeMapCallFun.indexOf(fun) != -1) return;
			_changeMapCallFun.push(fun);
		}

		/** 移除地图改变监听函数 */
		public static function removeChangeMapCallFun(fun : Function) : void
		{
			var index : int = _changeMapCallFun.indexOf(fun);
			if (index == -1) return;
			_changeMapCallFun.splice(index, 1);
		}

		/** 运行地图改变监听函数 */
		public static function runChangeMapCallFun() : void
		{
			for (var i : int = 0; i < _changeMapCallFun.length; i++)
			{
				var fun : Function = _changeMapCallFun[i];
				if (fun != null) fun.apply(null, [controller.mapStruct]);
			}
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 显示地图 */
		public static function show() : void
		{
			controller.show();
		}

		/** 隐藏地图 */
		public static function hide() : void
		{
			controller.hide();
		}

		/** 所有AVATAR活动 */
		public static function activityAllAvatar() : void
		{
		}

		/** 跟随 */
		public static function follow(id : int, type : String = "player", beId : int = 0, beType : String = "selfPlayer") : void
		{
			var animal : Animal;
			var beAnimal : Animal;
			if (type != AnimalType.NPC)
			{
				animal = animalDictionary.getAnimal(id, type);
			}
			else
			{
			}

			if (animal == null) return;
			if (beId == 0 && (beType == AnimalType.SELF_PLAYER || beType == null))
			{
				beAnimal = animalDictionary.selfPlayer;
			}
			else
			{
				beAnimal = animalDictionary.getAnimal(beId, beType);
			}
			if (animal == beAnimal) return;
			animal.followAnimal(beAnimal);
		}

		/** 取消跟随 */
		public static function cancelFollow(id : int, type : String = "player") : void
		{
			var animal : Animal;
			animal = animalDictionary.getAnimal(id, type);
			if (animal == null) return;
			animal.cancelFollowAnimal();
		}

		/** 震荡 */
		public static function shake() : void
		{
			controller.shake();
		}

		/** 缩放 */
		public static function zoom(scale : Number = 1, time : Number = 1.5) : void
		{
			// _zoomValue = scale;
			var offsetScale : Number = controller.container.scaleX - scale;
			if (offsetScale == 0) return;
			var offsetX : Number;
			var offsetY : Number;
			var stageWH : Point = MapUtil.stageWH;
			offsetX = stageWH.x * offsetScale;
			offsetY = stageWH.y * offsetScale;
			offsetX = offsetX / 2 * Math.abs(offsetScale);
			offsetY = offsetY / 2 * Math.abs(offsetScale);
			offsetX = controller.elementLayer.x + offsetX;
			offsetY = controller.elementLayer.y + offsetY;
			offsetX = -offsetX + stageWH.x / 2;
			offsetY = -offsetY + stageWH.y / 2;
			mapPosition.moveTo(offsetX, offsetY, time);
			if (scale >= 1)
			{
				// mapPosition.moveTo(offsetX, offsetY, 0);
				// TweenLite.to(controller.elementLayer, time, {x:offsetX, y:offsetY});
			}
			else
			{
				_stageZoomValue = 1 / scale;
				var toPosition : Point = MapUtil.getMapPostion(new Vector2D(offsetX, offsetY));
				// mapPosition.moveTo(toPosition.x, toPosition.y, time);
				TweenLite.to(controller.elementLayer, time, {x:toPosition.x, y:toPosition.y});
				_stageZoomValue = 0;
			}
			TweenLite.to(controller.container, time, {scaleX:scale, scaleY:scale, overwrite:0});

			// var toPosition : Point = MapUtil.getMapPostion(new Vector2D(offsetX, offsetY));
			// TweenLite.to(controller.elementLayer, time, {x:offsetX, y:offsetY});

			// TweenLite.to(controller.elementLayer, time, {x:toPosition.x, y:toPosition.y});
            
			// var toPosition : Point = MapUtil.getMapPostion(new Vector2D(offsetX, y));
		}

		/** 放大 */
		public static function zoomUp() : void
		{
			zoom(1.1, 2);
		}

		/** 缩小 */
		public static function zoomDown() : void
		{
			zoom(0.5, 2);
		}

		/** 还原大小 */
		public static function zoomRestore() : void
		{
			var time : Number = 2;
			zoom(1, time);
			var fun : Function = function() : void
			{
				controller.container.scaleX = 1;
				controller.container.scaleY = 1;
			};
			setTimeout(fun, time * 1000);
		}

		public static var _zoomValue : Number = 1;

		/** 获取地图缩放值 */
		public static function get zoomValue() : Number
		{
			return controller.container.scaleX;
		}

		public static var _stageZoomValue : Number = 1;

		/** 相对于场景缩放值 */
		public static function get stageZoomValue() : Number
		{
			return _stageZoomValue == 0 ? 1 / zoomValue : _stageZoomValue;
		}

		/** 模拟鼠标点击地图 */
		public static function analogMouseClickMap(stageX : int, stageY : int) : void
		{
			if (enMouseClickMovePlayer == false || QuestUtil.isInAutoRun == true) return;
			MouseManager.mapClickEffect();
			MapSystem.controller.onClickMap();
		}
        
        /** 截屏 */
        public static function printScreen(centerX:int, centerY:int, width:uint = 0, height:uint = 0):BitmapData
        {
            return  controller.printScreen(centerX, centerY, width, height);
        }
	}
}
