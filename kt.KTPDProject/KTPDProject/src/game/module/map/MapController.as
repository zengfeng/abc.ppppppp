package game.module.map
{
	import game.core.user.StateManager;
	import game.manager.SignalBusManager;
	import game.manager.ViewManager;
	import game.module.map.animal.Animal;
	import game.module.map.animal.AnimalDictionary;
	import game.module.map.animal.AnimalManager;
	import game.module.map.animal.AnimalType;
	import game.module.map.animal.EscortAnimal;
	import game.module.map.animal.MonsterAnimal;
	import game.module.map.animal.NpcAnimal;
	import game.module.map.animal.PlayerAnimal;
	import game.module.map.animal.SelfPlayerAnimal;
	import game.module.map.animalManagers.FollowManager;
	import game.module.map.animalManagers.PlayerManager;
	import game.module.map.animalstruct.EscortStruct;
	import game.module.map.animalstruct.MonsterStruct;
	import game.module.map.animalstruct.NpcStruct;
	import game.module.map.animalstruct.PetStruct;
	import game.module.map.animalstruct.PlayerStruct;
	import game.module.map.animalstruct.SelfPlayerStruct;
	import game.module.map.layers.ElementLayer;
	import game.module.map.layers.ForegroundLayer;
	import game.module.map.playerVisible.PlayerTolimitManager;
	import game.module.map.preload.MapPreloadManager;
	import game.module.map.preload.MapUnloadManager;
	import game.module.map.struct.GateStruct;
	import game.module.map.struct.MapStruct;
	import game.module.map.ui.DuplMapUIC;
	import game.module.map.ui.NextDo;
	import game.module.map.utils.LinkTable;
	import game.module.map.utils.MapFrameRate;
	import game.module.map.utils.MapPosition;
	import game.module.map.utils.MapTo;
	import game.module.map.utils.MapUtil;
	import game.module.map.utils.PieceMangager;
	import game.module.map.utils.ResKey;
	import game.module.map.utils.SwfClass;
	import game.module.mapClanEscort.MCEController;
	import game.module.mapConvoy.ConvoyController;
	import game.module.mapFeast.FeastController;
	import game.module.mapFishing.FishingController;
	import game.module.quest.QuestUtil;

	import gameui.manager.UIManager;

	import maps.auxiliarys.MapStage;
	import maps.layers.lands.LandLayer;
	import maps.layers.lands.installs.LandInstall;
	import maps.loads.expands.PathLoader;
	import maps.preloads.MapPreload;

	import net.LibData;
	import net.RESManager;
	import net.SWFLoader;

	import com.greensock.TweenLite;
	import com.utils.UrlUtils;
	import com.utils.Vector2D;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-26 ����2:59:56
	 */
	public class MapController
	{
		function MapController(singleton : Singleton) : void
		{
			singleton;
			init();
		}

		/** 单例对像 */
		private static var _instance : MapController;

		/** 获取单例对像 */
		public static function get instance() : MapController
		{
			if (_instance == null)
			{
				_instance = new MapController(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 当前地图数据 */
		private var curData : CurrentMapData = CurrentMapData.instance;
		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 容器 */
		public var container : Sprite = ViewManager.instance.getContainer(ViewManager.MAP_CONTAINER);
		/** 元素层 */
		public var elementLayer : ElementLayer;
		/** 前景层 */
		private var foregroundLayer : ForegroundLayer;
		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 资源加载管理器 */
		private var res : RESManager = RESManager.instance;
		/** 地图帧工具 */
		private var mapFrameRate : MapFrameRate = MapFrameRate.instance;
		/** 地图位置工具 */
		public var mapPosition : MapPosition = MapPosition.instance;
		/** 动物管理器 */
		private var animalManager : AnimalManager = AnimalManager.instance;
		/** 动物字典 */
		private var animalDictionary : AnimalDictionary = AnimalDictionary.instance;
		/** 协议 */
		private var proto : MapProto = MapProto.instance;
		/** 链表工具 */
		public var linkTable : LinkTable = new LinkTable();
		/**  预载管理器 */
		public var mapPreloadMananger : MapPreloadManager = MapPreloadManager.instance;
		/** 卸载管理器 */
		public var mapUnloadManager : MapUnloadManager = MapUnloadManager.instance;
		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 地图数据结构 */
		private var _mapStruct : MapStruct;

		/** 地图数据结构 */
		public function get mapStruct() : MapStruct
		{
			if (_mapStruct == null)
			{
				_mapStruct = curData.mapStruct;
			}
			return _mapStruct;
		}

		/** 地图ID */
		public function get mapId() : uint
		{
			if (mapStruct == null) return 0;
			return mapStruct.id;
		}

		/** 美术资源地图ID */
		public function get assetsMapId() : uint
		{
			if (mapStruct == null) return 0;
			return mapStruct.assetsMapId;
		}

		/** 获得自己玩家位置 */
		public function get selfPlayerPostion() : Point
		{
			return new Point(elementLayer.selfPlayer.x, elementLayer.selfPlayer.y);
		}

		/** 获取自己玩家动物 */
		public function get selfPlayerAnimal() : SelfPlayerAnimal
		{
			return animalManager.selfPlayer;
		}

		/** 自己玩家位置 */
		private var _selfPosition : Vector2D = new Vector2D();

		/** 自己玩家位置 */
		public function get selfPosition() : Vector2D
		{
			if (elementLayer.selfPlayer)
			{
				_selfPosition.x = elementLayer.selfPlayer.x;
				_selfPosition.y = elementLayer.selfPlayer.y;
			}
			else
			{
				_selfPosition.x = curData.setupPostion.x;
				_selfPosition.y = curData.setupPostion.y;
			}
			return _selfPosition;
		}

		/** 是否能鼠标点击移动 */
		private var _enMouseMove : Boolean = true;

		/** 是否能鼠标点击移动 */
		public function get enMouseMove() : Boolean
		{
			return _enMouseMove;
		}

		public function set enMouseMove(value : Boolean) : void
		{
			_enMouseMove = value;
			if (value == false)
			{
				clearInterval(mouseDownTimer);
				if (selfPlayerAnimal) selfPlayerAnimal.stopMove();
			}
		}

		/** 地图到某地工具 */
		private var _mapTo : MapTo;

		/** 地图到某地工具 */
		private function get mapTo() : MapTo
		{
			if (_mapTo == null)
			{
				_mapTo = MapTo.instance;
			}
			return _mapTo;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 是否安装 */
		private var _isSetup : Boolean = false;

		/** 是否安装 */
		public function get isSetup() : Boolean
		{
			return _isSetup;
		}

		/** 安装完成 */
		private function setupComplete() : void
		{
			_isSetup = true;

			// 运行地图改变监听函数
			MapSystem.runChangeMapCallFun();
			FollowManager.instance.reset();
			// duplMapController.mapSetupComplete();
			ConvoyController.instance.mapSetupComplete();
			FishingController.instance.mapSetupComplete();
			MCEController.instance.initEscor();
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 初始化 */
		public function init() : void
		{
			// 背景层
			// backgroundLayer = new BackgroundLayer();
			// container.addChild(backgroundLayer);
			// 元素层
			elementLayer = new ElementLayer();
			container.addChild(elementLayer);

			// 前景层
			foregroundLayer = new ForegroundLayer();
			container.addChild(foregroundLayer);

			SignalBusManager.setupMap.add(preSetupMap);
			NpcSignals.aiStart.add(npcAIStart);
			NpcSignals.aiStop.add(npcAIStop);
			NpcSignals.aiHit.add(hitNpc);
			NpcSignals.add.add(addNpc);
			NpcSignals.remove.add(removeNpc);
		}

		/** 显示地图 */
		public function show() : void
		{
			if (container.parent == null)
			{
				UIManager.root.addChildAt(container, 0);
			}
		}

		/** 隐藏地图 */
		public function hide() : void
		{
			if (container.parent != null)
			{
				container.parent.removeChild(container);
			}
		}

		/** 所有AVATAR活动 */
		public function activityAllAvatar() : void
		{
			if (animalManager.selfPlayer) animalManager.selfPlayer.stand();
			var animal : Animal;

			for (var i : int = 0; i < animalManager.monsterList.length; i++)
			{
				animal = animalManager.monsterList[i];
				animal.stand();
			}

			for (i = 0; i < animalManager.npcList.length; i++)
			{
				animal = animalManager.npcList[i];
				animal.stand();
			}
		}

		/** 预设地图前清理 */
		public function preClear() : void
		{
			if (mapId == 0) return;
			PieceMangager.instance.clear();
			mapUnloadManager.unload();
			// 如果当前地图是蜀山论剑
			if (MapUtil.isGroupBattleMap(mapId) == true)
			{
				// GBSystem.quit();
			}
		}

		/** 清理 */
		public function clear() : void
		{
			while (aiNpcList.length > 0)
			{
				aiNpcList.shift();
			}
			// 地图数据结构
			_mapStruct = null;
			// 当前地图数据
			curData.clear();
			// 地图位置工具
			mapPosition.clear();
			// 地图帧工具
			mapFrameRate.clear();
			// 背景层
			// backgroundLayer.clear();
			// 动物管理
			animalManager.clear();
			// 元素层
			elementLayer.clear();
			// 链表
			linkTable.clearTable();
			PlayerTolimitManager.instance.clear();

			enMouseMove = true;
			show();
		}

		private var landInstall : LandInstall = LandInstall.instance;
		private var mapPreload : MapPreload = MapPreload.instance;

		/** 安装前 */
		public function preSetupMap(mapId : uint, selfPostion : Point) : void
		{
			preClear();

			// 是否安装
			_isSetup = false;
			curData.mapId = mapId;
			var mapStruct : MapStruct = curData.mapStruct;
			var landIsFullMode : Boolean = mapId > 20;
			var mapPosition : Vector2D = MapUtil.getMapPostion(new Vector2D(selfPostion.x, selfPostion.y), mapId);
			landInstall.preset(mapId, mapStruct.mapWH.x, mapStruct.mapWH.y, landIsFullMode);
			mapPreload.reset(mapId, -mapPosition.x, -mapPosition.y, mapStruct.mapWH.x, mapStruct.mapWH.y, MapStage.stageWidth, MapStage.stageHeight, mapStruct.assetsMapId, landIsFullMode);
			mapPreload.signalComplete.add(setupMap);

			MapPreloadManager.instance.show();
			MapPreloadManager.instance.setLoadMapProgress(0);
			// 设置自己玩家起始位置
			if (selfPostion)
			{
				curData.setupPostion.x = selfPostion.x;
				curData.setupPostion.y = selfPostion.y;
			}
			mapPreload.startLoad();
			return;
		}

		/** 安装 */
		public function setupMap() : void
		{
			// 清理
			clear();
			// 是否安装
			_isSetup = true;
			Path.reset(PathLoader.instance.getData());
			landInstall.install();
			PathLoader.instance.unloadAndStop(true);
			// 更新UI显示状态
			ViewManager.refreshShowState();
			// 初始化 地图块平铺加载工具
			mapPosition.tileLoad.initData(mapStruct.mapWH, mapStruct.singlePieceHW, MapUtil.stageWH);
			// 如果自己玩家数据结构不为空
			if (curData.selfPlayerStruct && MapUtil.isStoryMode == false)
			{
				addSelfPlayer(curData.selfPlayerStruct);
			}
			// 加载八卦阵(出口入口)
			loadGate();
			// 设置地图位置
			mapPosition.updatePosition(false);

			// 添加NPC列表
			addNpcList(curData.setupNpcList);
			// 添加其他玩家列表
			if (MapUtil.isDungeonMap(mapId) == false)
			{
				addPlayerList(PlayerManager.instance.getPlayerList());
			}

			// 添加怪物列表
			addMonsterList(curData.setupMonsterList);

			// 点击地图称动
			elementLayer.addEventListener(MouseEvent.CLICK, onClickMap);
			elementLayer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownMap);
			elementLayer.addEventListener(MouseEvent.MOUSE_UP, onMouseUpMap);
			elementLayer.stage.addEventListener(KeyboardEvent.KEY_DOWN, gofreeGate);

			// 主城
			if (MapUtil.isMainMap(mapId) == true)
			{
				if ( FeastController.instance.hasBegin )
				{
					FeastController.instance.setup();
				}
			}

			duplMapUIVisible(MapUtil.isDungeonMap(mapId));

			// 安装完成
			setupComplete();
		}

		// ===========================================
		private var duplMapUIC : DuplMapUIC = DuplMapUIC.instance;

		private function duplMapUIVisible(visible : Boolean) : void
		{
			duplMapUIC.visible = visible;
			if (visible == false)
			{
				NpcSignals.gotoNextAI.remove(gotoBattle);
				SelfPlayerSignal.severTransport.remove(checkRestNextDo);
				MapSingles.sendLeaveDuplMap.clear();
				return;
			}

			duplMapUIC.nextDoButton.onClickGotoBattleCall = gotoBattle;
			duplMapUIC.nextDoButton.onClickGotoExitCall = gotoExitGate;
			duplMapUIC.onClickExitCall = proto.cs_leaveMap;
			if (GateOpened.getState(1))
			{
				setNextDo(NextDo.GOTO_EXIT);
			}
			else
			{
				setNextDo(NextDo.GOTO_BATTLE);
			}
			NpcSignals.gotoNextAI.add(gotoBattle);
			MapSingles.sendLeaveDuplMap.add(proto.cs_leaveMap);
			// setNextDo(NextDo.GOTO_EXIT);
		}

		/** 去打下一个怪 */
		private function gotoBattle() : void
		{
			MapSystem.mapTo.toAvatarPosition(gotoBattleX, gotoBattleY, null);
			trace("gotoBattle", gotoBattleX, gotoBattleY);
			SelfPlayerSignal.severTransport.add(checkRestNextDo);
			setNextDo(NextDo.WALKING);
			SignalBusManager.selfStartWalk.add(checkRestNextDo);
		}

		private function setNextDo(what : String) : void
		{
			SignalBusManager.selfStartWalk.remove(checkRestNextDo);
			duplMapUIC.nextDoButton.nextDo = what;
		}

		private function gotoExitGate() : void
		{
			var point : Point = MapUtil.getGateCenter(MapUtil.getDuplParentMapId(mapId), mapId);
			if (point == null)
			{
				point = MapUtil.getGateCenter(MapSystem.PRE_MAP_ID, mapId);
			}

			if (point)
			{
				SignalBusManager.selfStartWalk.add(checkRestNextDo);
				MapSystem.mapTo.toAvatarPosition(point.x, point.y, proto.cs_leaveMap);
				return;
			}

			proto.cs_leaveMap();
		}

		private function checkRestNextDo() : void
		{
			SignalBusManager.selfStartWalk.remove(checkRestNextDo);
			SelfPlayerSignal.severTransport.remove(checkRestNextDo);
			duplMapUIC.nextDoButton.nextDo = duplMapUIC.nextDoButton.nextDo;
		}

		// ===========================================
		public function gofreeGate(e : KeyboardEvent) : void
		{
			if (e.ctrlKey == true)
			{
				if (e.keyCode > Keyboard.NUMBER_0 && e.keyCode <= Keyboard.NUMBER_9)
				{
					var mapId : int = parseInt(String.fromCharCode(e.keyCode));
					proto.cs_changeMap(mapId);
				}
			}
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		public function onClickMap(event : MouseEvent = null) : void
		{
			if (enMouseMove == false)
			{
				if (MapUtil.isStoryMode == false && MapUtil.isDungeonMap() == false) StateManager.instance.checkMsg(23);
				return;
			}
			clearInterval(mouseDownTimer);
			mouseWalk();
		}

		private var mouseDownTimer : uint;

		private function onMouseDownMap(event : MouseEvent) : void
		{
			if (enMouseMove == false) return;
			clearInterval(mouseDownTimer);
			mouseDownTimer = setInterval(mouseWalk, 300);
			elementLayer.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpMap);
		}

		private function onMouseUpMap(event : MouseEvent) : void
		{
			if (elementLayer.stage) elementLayer.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpMap);
			clearInterval(mouseDownTimer);
		}

		private function mouseWalk() : void
		{
			mapTo.clickMapWalk(elementLayer.mouseX, elementLayer.mouseY);
			// mapTo.clear(false);
			// selfPlayerAnimal.walk(elementLayer.mouseX, elementLayer.mouseY);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 加载八卦阵(出口入口) */
		private function loadGate() : void
		{
			if (SwfClass.Gate)
			{
				setupGateList();
				return;
			}
			var url : String;
			var key : String;
			url = UrlUtils.FILE_GATE;
			key = ResKey.gate;
			res.load(new LibData(url, key, true), loadGate_onComplete, [key]);
		}

		/** 加载完加载八卦阵(出口入口) */
		private function loadGate_onComplete(key : String) : void
		{
			// 读取加载
			var loader : SWFLoader = RESManager.getLoader(key);
			if (loader == null) return;
			SwfClass.Gate = loader.getClass("Gate");
			// 安装载八卦阵(出口入口)列表
			setupGateList();
		}

		/** 安装载八卦阵(出口入口)列表 */
		private function setupGateList() : void
		{
			if (SwfClass.Gate == null) return;
			var linkGates : Dictionary = mapStruct.linkGates;
			for each (var gateStruct:GateStruct in linkGates)
			{
				elementLayer.addGate(gateStruct);
				setGateOpenClose(gateStruct.id, GateOpened.getState(gateStruct.id));
			}
			GateOpened.signalState.add(setGateOpenClose);
		}

		public function setGateOpenClose(gateId : int, isOpen : Boolean) : void
		{
			var gate : DisplayObject = elementLayer.getGateById(gateId);
			if (isOpen == false)
			{
				(gate as MovieClip).gotoAndStop(1);
				gate.visible = false;
				gate.alpha = 0;
			}
			else
			{
				gate.visible = true;
				(gate as MovieClip).gotoAndPlay(1);
				TweenLite.to(gate, 1, {alpha:1});
			}
		}

		/** 八卦阵(出口入口)列表显示或隐藏 */
		public function gateListVisible(value : Boolean) : void
		{
			var gate : DisplayObject;
			// var index : int = elementLayer.getMaxIndexBE();
			// index += 1;
			for (var i : int = 0; i < elementLayer.gateList.length; i++)
			{
				gate = elementLayer.gateList[i];
				if (value == false)
				{
					// if (gate.parent) gate.parent.removeChild(gate);
					(gate as MovieClip).gotoAndStop(1);
					gate.visible = false;
					gate.alpha = 0;
				}
				else
				{
					// elementLayer.addChildAt(gate, index);
					gate.visible = true;
					(gate as MovieClip).gotoAndPlay(1);
					TweenLite.to(gate, 1, {alpha:1});
				}
			}
		}

		/**  设置某个八卦阵(出口入口)显示或隐藏 */
		public function setGateVisible(toMapId : int, value : Boolean = true) : void
		{
			if (MapUtil.isDungeonMap(toMapId) == true)
			{
				toMapId = Math.floor(toMapId / 100) * 100 + 1;
			}

			var gate : DisplayObject = elementLayer.getGate(toMapId);
			if (gate != null)
			{
				if (value == true)
				{
					gate.visible = true;
					TweenLite.to(gate, 1, {alpha:1});
				}
				else
				{
					gate.visible = false;
					gate.alpha = 0;
				}
			}
		}

		/** 到达八卦阵(出口入口) */
		public function arriveGate(toMapId : int, mapId : int = 0, gateId : int = 0) : void
		{
			if (mapId <= 0) mapId = this.mapId;
			if (toMapId == MapSystem.PRE_MAP_ID)
			{
				proto.cs_changeMap(toMapId);
				return;
			}
			proto.cs_CSUseGate(gateId);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 自己玩家移动 */
		public function selfPlayerMove(selfPlayerAnimal : SelfPlayerAnimal) : void
		{
			// 设置地图位置,根据自己玩家位置
			if (MapSystem.mapMoveIsBindSelfPlayer == true)
			{
				mapPosition.updatePosition();
			}
			// BWMapController.instance.checkInArea();
			FeastController.instance.moved();
		}

		/** 自己玩家停止移动 */
		public function selfPlayerStopMove(selfPlayerAnimal : SelfPlayerAnimal) : void
		{
			if (MapSystem.mapMoveIsBindSelfPlayer == true)
			{
				// 停止地图移动
				mapPosition.isMove = false;
			}
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 添加自己玩家 */
		public function addSelfPlayer(playerStruct : SelfPlayerStruct = null) : SelfPlayerAnimal
		{
			if (playerStruct == null ) playerStruct = curData.selfPlayerStruct;
			if (playerStruct)
			{
				var selfPlayerAnimal : SelfPlayerAnimal = addPlayer(playerStruct) as SelfPlayerAnimal;
				selfPlayerAnimal.stopMove();
				selfPlayerAnimal.addMoveCallFun(selfPlayerMove);
				selfPlayerAnimal.addstopMoveCallFun(selfPlayerStopMove);
				mapPosition.center();
				if (playerStruct.model == 20 || StateManager.instance.isPractice())
				{
					selfPlayerAnimal.sitdownAction();
				}

				// 将自己添加到自己阵营
				// if (MapUtil.isDungeonMap(mapId) == true) armyManager.selfGroup.add(selfPlayerAnimal);
				return selfPlayerAnimal;
			}
			return null;
		}

		/** 添加玩家列表 */
		public function addPlayerList(playerList : Vector.<PlayerStruct>) : void
		{
			for (var i : int = 0; i < playerList.length; i++)
			{
				addPlayer(playerList[i]);
			}
		}

		/** 添加玩家 */
		public function addPlayer(playerStruct : PlayerStruct) : PlayerAnimal
		{
			if (isSetup == false) return null;
			var animal : PlayerAnimal = animalManager.addAnimal(playerStruct) as PlayerAnimal;
			if (MapUtil.isStoryMode == true) animal.hide();
			if (animal && playerStruct.model == 20)
			{
				animal.sitdownAction();
			}
			return animal;
		}

		/** 移除玩家 */
		public function removePlayer(playerId : uint) : void
		{
			animalManager.removeAnimal(playerId, AnimalType.PLAYER);
		}

		/** 初始化玩家Avatar */
		public function initPlayerAvatar(playerStruct : PlayerStruct) : void
		{
			if (isSetup == false) return;

			var animal : PlayerAnimal = animalManager.getAnimal(playerStruct.id, AnimalType.PLAYER) as PlayerAnimal;
			if (animal == null) return;
			animal.initAvatar();
		}

		/** 更新玩家Avatar */
		public function updateAvatar(id : int) : void
		{
			if (isSetup == false) return;

			var animal : PlayerAnimal = animalManager.getAnimal(id, AnimalType.PLAYER) as PlayerAnimal;
			if (animal == null) return;
			animal.updateAvatar();
		}

		/** 更新玩家位置 */
		public function updatePlayerPosition(playerStruct : PlayerStruct) : void
		{
			if (isSetup == false) return;
			var animal : PlayerAnimal = animalManager.getAnimal(playerStruct.id, AnimalType.PLAYER) as PlayerAnimal;
			if (animal == null) return;
			animal.walk2();
		}

		/** 传送 */
		public function transport(playerStruct : PlayerStruct) : void
		{
			if (isSetup == false) return;
			var animal : PlayerAnimal = animalManager.getAnimal(playerStruct.id, AnimalType.PLAYER) as PlayerAnimal;
			if (animal == null) return;
			var fromX : int = animal.x;
			var fromY : int = animal.y;
			animal.transport(playerStruct.toX, playerStruct.toY);
			animal.stopMove();
			// animal.moveTo(playerStruct.toX, playerStruct.toY);
			if (playerStruct is SelfPlayerStruct)
			{
				var dx : int = animal.x - fromX;
				var dy : int = animal.y - fromY;
				var d : int = Math.sqrt(dx * dx + dy * dy);
				if (d > 30)
				{
					MapPosition.instance.center();
				}
			}
		}

		/** 添加NPC列表 */
		public function addNpcList(npcIdList : Vector.<uint>) : void
		{
			if (npcIdList == null) return;
			for (var i : int = 0; i < npcIdList.length; i++)
			{
				addNpc(npcIdList[i]);
			}
		}

		private var aiNpcList : Vector.<uint> = new Vector.<uint>();

		/** 添加NPC */
		public function addNpc(npcId : uint, isCreateStruct : Boolean = false, x : int = 0, y : int = 0) : NpcAnimal
		{
			var npcStruct : NpcStruct = mapStruct.getNpcStruct(npcId);
			if (isCreateStruct == true && npcStruct == null)
			{
				npcStruct = new NpcStruct();
				npcStruct.id = npcId;

				if (x != 0 && y != 0)
				{
					npcStruct.x = x;
					npcStruct.y = x;
					var point : Point = new Point(npcStruct.x, npcStruct.y);
					npcStruct.standPostion.push(point);
				}
			}

			if (npcStruct == null) return null;
			var npcAnimal : NpcAnimal = animalManager.addAnimal(npcStruct) as NpcAnimal;
			if (MapUtil.isStoryMode == true) npcAnimal.hide();
			if (npcStruct.isHit)
			{
				npcAnimal.startupAI();
				var index : int = aiNpcList.indexOf(npcId);
				if (index == -1)
				{
					aiNpcList.push(npcId);
					setNextNpc();
				}
			}
			return npcAnimal;
		}

		/** 移除NPC */
		public function removeNpc(npcId : uint) : void
		{
			animalManager.removeAnimal(npcId, AnimalType.NPC);
			var index : int = aiNpcList.indexOf(npcId);
			if (index != -1)
			{
				aiNpcList.splice(index, 1);
				setNextNpc();
			}
		}

		private function setNextNpc() : void
		{
			if (aiNpcList.length == 0)
			{
				setNextDo(NextDo.GOTO_EXIT);
			}
			else
			{
				setNextDo(NextDo.GOTO_BATTLE);
				aiNpcList.sort(sortNpcList);
				var point : Point = MapUtil.getNpcPosition(aiNpcList[0]);
				gotoBattleX = point.x;
				gotoBattleY = point.y;
			}
		}

		private function sortNpcList(a : int, b : int) : Number
		{
			return a - b;
		}

		private var gotoBattleX : int = 0;
		private var gotoBattleY : int = 0;

		/** 设置NPC显示状态 */
		public function setNpcVisible(npcId : uint, visible : Boolean) : void
		{
			var npcAnimal : NpcAnimal = animalManager.getNpc(npcId);
			curData.setNpcVisible(npcId, visible);
			if (visible == true)
			{
				if (npcAnimal == null)
				{
					addNpc(npcId);
				}
			}
			else
			{
				if (npcAnimal) removeNpc(npcId);
			}
		}

		private function npcAIStart(npcId : int) : void
		{
			var npcAnimal : NpcAnimal = animalManager.getNpc(npcId);
			if (npcAnimal)
			{
				npcAnimal.aiStart();
			}
		}

		private function npcAIStop(npcId : int) : void
		{
			var npcAnimal : NpcAnimal = animalManager.getNpc(npcId);
			if (npcAnimal)
			{
				npcAnimal.aiStop();
			}
		}

		private function hitNpc(npcId : int) : void
		{
			trace("hitNpc-------QuestUtil.npcClick");
			QuestUtil.npcClick(npcId);
		}

		/** 添加怪物 */
		public function addMonsterList(monsterList : Vector.<MonsterStruct>) : void
		{
			if (monsterList == null) return;
			var monsterStruct : MonsterStruct;
			for (var i : int = 0; i < monsterList.length; i++)
			{
				monsterStruct = monsterList[i];
				addMonster(monsterStruct);
			}
		}

		/** 添加怪物 */
		public function addMonster(monsterStruct : MonsterStruct) : MonsterAnimal
		{
			if (monsterStruct == null) return null;
			var monsterAnimal : MonsterAnimal = animalManager.addAnimal(monsterStruct) as MonsterAnimal;
			// monsterAnimal.addBattleeCallFun(duplMapController.monsterBattleCallFun);
			//			//  将怪物添加到副本怪物阵营
			// armyManager.dungeonMonsterGroup.add(monsterAnimal);
			return monsterAnimal;
		}

		/** 移除怪物 */
		public function removeMonster(wave : uint) : void
		{
			elementLayer.removeAnimal(wave, AnimalType.MONSTER);
		}

		/** 添加护送者 */
		public function addEscort(escortStruct : EscortStruct) : EscortAnimal
		{
			if (escortStruct == null) return null;
			var escortAnimal : EscortAnimal = animalManager.addAnimal(escortStruct) as EscortAnimal;
			return escortAnimal;
		}

		/** 移除护送者 */
		public function removeEscort(id : int) : void
		{
			elementLayer.removeAnimal(id, AnimalType.ESCORT);
		}

		/** 添加宠物 */
		public function addPet(petStruct : PetStruct) : void
		{
		}

		/** 移除宠物 */
		public function removePet(petStruct : PetStruct) : void
		{
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 震荡 */
		public function shake() : void
		{
			var displayObject : DisplayObject = container;
			var x : int = displayObject.x;
			var y : int = displayObject.y;

			var offset : Number = 6;
			if (mapPosition.isMove == true)
			{
				offset = 20;
			}

			var fun : Function = function(offsetX : Number, offsetY : Number) : void
			{
				displayObject.x = x + offsetX;
				displayObject.y = y + offsetY;
			};

			var offsetX : Number = 0;
			var offsetY : Number = 0;
			for (var i : int = 0; i < 10; i++)
			{
				offsetX = Math.random() * offset;
				offsetY = Math.random() * offset;
				setTimeout(fun, 100 * i, offsetX, offsetY);
				setTimeout(fun, 100 * i + 50, 0, 0);
			}
		}

		/** 截屏 */
		public function printScreen(centerX : int, centerY : int, width : uint = 0, height : uint = 0) : BitmapData
		{
			if (width == 0)
			{
				width = flash.system.Capabilities.screenResolutionX;
			}

			if (height == 0)
			{
				height = flash.system.Capabilities.screenResolutionY;
			}
			var halfScreenWidth : int = width / 2;
			var halfScreenHeight : int = height / 2;
			var mapWidth : int = mapStruct.mapWH.x;
			var mapHeight : int = mapStruct.mapWH.y;
			if (centerX < halfScreenWidth)
			{
				width = centerX;
			}

			if (centerX + halfScreenWidth > mapWidth)
			{
				width = Math.min(mapWidth - centerX, width);
			}

			if (centerY < halfScreenHeight)
			{
				height = centerY;
			}

			if (centerY + halfScreenHeight > mapHeight)
			{
				height = Math.min(mapHeight - centerY, height);
			}

			// var clipRect:Rectangle = new Rectangle();
			// clipRect.x = centerX - width / 2;
			// clipRect.y = centerY - height / 2;
			// clipRect.width = width;
			// clipRect.height = height;
			var matrix : Matrix = new Matrix();
			matrix.tx -= centerX - width / 2;
			matrix.ty -= centerY - height / 2;

			// Alert.show(clipRect.x + "," + clipRect.y + "         " + clipRect.width + "," + clipRect.height);
			var bitmapData : BitmapData = new BitmapData(width, height, false, 0xFF0000);
			bitmapData.draw(LandLayer.instance, matrix);
			return bitmapData;
		}
	}
}
class Singleton
{
}
