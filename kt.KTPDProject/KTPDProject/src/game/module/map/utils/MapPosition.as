package game.module.map.utils
{
	import maps.layers.lands.installs.LandInstall;

	import game.manager.SignalBusManager;
	import game.manager.ViewManager;
	import game.module.map.CurrentMapData;
	import game.module.map.MapController;
	import game.module.map.MapProto;
	import game.module.map.MapSystem;
	import game.module.map.animal.AnimalManager;
	import game.module.map.animal.SelfPlayerAnimal;
	import game.module.map.layers.ElementLayer;
	import game.module.map.layers.ElementName;
	import game.module.map.preload.LibDataUtil;
	import game.module.map.preload.MapUnloadManager;
	import game.module.map.struct.MapStruct;

	import net.LibData;
	import net.RESManager;
	import net.SWFLoader;

	import com.greensock.TweenLite;
	import com.utils.Vector2D;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-5 ����10:00:54
	 */
	public class MapPosition
	{
		function MapPosition(singleton : Singleton) : void
		{
			singleton;
			ViewManager.addStageResizeCallFun(stageResize);
			SignalBusManager.selfStartWalk.add(selfStartWalk);
			SignalBusManager.selfEndWalk.add(selfEndWalk);
			enMouseMove = true;
		}

		/** 单例对像 */
		private static var _instance : MapPosition;

		/** 获取单例对像 */
		static public function get instance() : MapPosition
		{
			if (_instance == null)
			{
				_instance = new MapPosition(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		public function clear() : void
		{
			_mapStruct = null;
			// 地图块管理工具
			pieceMangager.clear();
			// 地图帧工具
			mapFrameRate.clear();

			drawing = false;
			clearTimeout(startDrawPiecelTimer);
			while (loadedPieceCache.length > 0)
			{
				loadedPieceCache.pop();
			}
			loaderUnloadAndStopAll();

			if (moveToTweenLite) moveToTweenLite.kill();
			// 擦除缩略图一小块区域
			eraseThumbnailRect.width = 0;
			eraseThumbnailRect.height = 0;

			while (noEraseThumbnailList.length > 0)
			{
				noEraseThumbnailList.shift();
			}
			// 擦除缩略图setTimeout
			clearTimeout(eraseThumbnailTimeOut);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 地图数据结构 */
		private var _mapStruct : MapStruct;
		/** 控制器 */
		private var _controller : MapController;
		/** 元素层 */
		private var _elementLayer : ElementLayer;
		/** 当前地图数据 */
		private var currentMapData : CurrentMapData = CurrentMapData.instance;
		/** 地图帧工具 */
		private var mapFrameRate : MapFrameRate = MapFrameRate.instance;
		/** 地图块管理工具 */
		public var pieceMangager : PieceMangager = PieceMangager.instance;
		/** 地图块平铺加载工具 */
		public var tileLoad : TileLoad = new TileLoad();
		/** 资源加载管理器 */
		private var res : RESManager = RESManager.instance;

		/** 控制器 */
		public function get controller() : MapController
		{
			if (_controller == null)
			{
				_controller = MapController.instance;
			}
			return _controller;
		}

		/** 元素层 */
		public function get elementLayer() : ElementLayer
		{
			if (_elementLayer == null)
			{
				_elementLayer = controller.elementLayer;
			}
			return _elementLayer;
		}

		/** 地图数据结构 */
		public function get mapStruct() : MapStruct
		{
			if (_mapStruct == null)
			{
				_mapStruct = controller.mapStruct;
			}
			return _mapStruct;
		}

		/** 地图ID */
		public function get mapId() : uint
		{
			return mapStruct.id;
		}

		/** 美术资源地图ID */
		public function get assetsMapId() : uint
		{
			return mapStruct.assetsMapId;
		}

		/** 获取自己玩家动物 */
		public function get selfPlayerAnimal() : SelfPlayerAnimal
		{
			return AnimalManager.instance.selfPlayer;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 地图位置范围 */
		private var postionRectangle : Rectangle = new Rectangle();
		/** 地图位置 */
		private var postion : Vector2D = new Vector2D();
		/** 自己玩家上一次位置 */
		private var preSelfPostion : Vector2D = new Vector2D();
		/** 自己玩家位置 */
		private var selfPostion : Vector2D = new Vector2D();
		/** 地图移动速度 */
		private var mapVelocity : Vector2D = new Vector2D();
		/** 是否正在移动中 */
		private var _isMove : Boolean = false;

		/** 是否正在移动中 */
		public function get isMove() : Boolean
		{
			return _isMove;
		}

		public function set isMove(value : Boolean) : void
		{
			if (_isMove == value) return;
			_isMove = value;

			if (value)
			{
				EnterFrameListener.add(onMoveing);
				// elementLayer.addEventListener(Event.ENTER_FRAME, onMoveing);
			}
			else
			{
				EnterFrameListener.remove(onMoveing);
				// elementLayer.removeEventListener(Event.ENTER_FRAME, onMoveing);
			}
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 把自己玩家居中 */
		public function center() : void
		{
			EnterFrameListener.remove(onMoveing);
			// elementLayer.removeEventListener(Event.ENTER_FRAME, onMoveing);
			if (elementLayer.selfPlayer)
			{
				selfPostion.x = elementLayer.selfPlayer.x;
				selfPostion.y = elementLayer.selfPlayer.y;
			}
			else
			{
				selfPostion.x = currentMapData.setupPostion.x;
				selfPostion.y = currentMapData.setupPostion.y;
			}

			postion = MapUtil.getMapPostion(selfPostion);
			if (postion == null) return;
			elementLayer.moveTo(postion.x, postion.y);
			preSelfPostion.x = selfPostion.x;
			preSelfPostion.y = selfPostion.y;
			// 加载屏幕内的地图块
			loadPieceInScreen(true);
		}

		/** 设置地图位置,根据自己玩家位置 */
		public function updatePosition(isSetup : Boolean = false) : void
		{
			if (isSetup)
			{
				EnterFrameListener.remove(onMoveing);
				// elementLayer.removeEventListener(Event.ENTER_FRAME, onMoveing);
				selfPostion.x = currentMapData.setupPostion.x;
				selfPostion.y = currentMapData.setupPostion.y;
				postion = MapUtil.getMapPostion(selfPostion);
				elementLayer.moveTo(postion.x, postion.y);
				preSelfPostion.x = selfPostion.x;
				preSelfPostion.y = selfPostion.y;
				// 加载屏幕内的地图块
				loadPieceInScreen(isSetup);
			}
			else
			{
				selfPostion.x = elementLayer.selfPlayer.x;
				selfPostion.y = elementLayer.selfPlayer.y;
				// postion = MapUtil.getMapPostion(selfPostion);
				// elementLayer.moveTo(postion.x, postion.y);
				//                //  加载屏幕内的地图块
				// loadPieceInScreen();
				// return;

				// 自己玩家全局位置
				var selfGlobalPostion : Point = new Point(selfPostion.x, selfPostion.y);
				// 自己玩家上一次全局位置
				var preSelfGlobalPostion : Point = new Point(preSelfPostion.x, preSelfPostion.y);

				selfGlobalPostion = elementLayer.localToGlobal(selfGlobalPostion);
				preSelfGlobalPostion = elementLayer.localToGlobal(preSelfGlobalPostion);
				// 自己玩家到场景舞台距离
				var selfToStageCenterDis : Number = Point.distance(MapUtil.stageCenter, selfGlobalPostion);
				// 自己玩家上一次到场景舞台距离
				var preSelfToStageCenterDis : Number = Point.distance(MapUtil.stageCenter, preSelfGlobalPostion);

				// 计算地图移动速度
				mapVelocity.x = preSelfPostion.x - selfPostion.x;
				mapVelocity.y = preSelfPostion.y - selfPostion.y;

				// 如果玩家不在Stage中间区块并且向远离Stage中间的地方移动
				if (MapUtil.isStageEdge(selfPostion.x, selfPostion.y) && selfToStageCenterDis > preSelfToStageCenterDis)
				{
					isMove = true;
				}
				else
				{
					isMove = false;
				}
				// 设置上一次玩家位置
				preSelfPostion.x = selfPostion.x;
				preSelfPostion.y = selfPostion.y;
			}
		}

		/** 进入移动帧频 */
		public function onMoveing(event : Event = null) : void
		{
			postion.x += mapVelocity.x;
			postion.y += mapVelocity.y;

			selfPostion.x = elementLayer.selfPlayer.x;
			selfPostion.y = elementLayer.selfPlayer.y;
			// 验证地图是否到了边界外
			postionRectangle = MapUtil.getMapPostionRectangle(postionRectangle);
			if (postion.x <= postionRectangle.width)
			{
				postion.x = postionRectangle.width;
			}
			else if (postion.x >= postionRectangle.x)
			{
				postion.x = postionRectangle.x;
			}

			if (postion.y <= postionRectangle.height)
			{
				postion.y = postionRectangle.height;
			}
			else if (postion.y >= postionRectangle.y)
			{
				postion.y = postionRectangle.y;
			}
			// 移动地图
			elementLayer.moveTo(postion.x, postion.y);

			// 加载屏幕内的地图块
			loadPieceInScreen();

			// 如果玩家走到了Stage中间区块就停止移动
			if (MapUtil.isStageEdge(selfPostion.x, selfPostion.y) == false)
			{
				isMove = false;
			}
		}

		private var landInstall : LandInstall = LandInstall.instance;
		private var loadPieceInScreenNum:int = 0;

		/** 加载屏幕内的地图块 */
		public function loadPieceInScreen(isSetup : Boolean = false) : void
		{
			loadPieceInScreenNum ++;
			if(!isSetup && loadPieceInScreenNum < 20)
			{
				return;
			}
			loadPieceInScreenNum = 0;
			landInstall.loadMapPosition(-elementLayer.x, -elementLayer.y);
			return;
			if (MapUtil.isDungeonMap(mapId) == true && isSetup == false) return;
			mapFrameRate.loadPieceFrame++;
			if (mapFrameRate.loadPieceIsRun(isSetup) == false) return;
			var rec : Rectangle;
			if (MapUtil.isDungeonMap(mapId))
			{
				rec = tileLoad.loadAll();
			}
			else
			{
				rec = tileLoad.load(elementLayer.x, elementLayer.y, MapUtil.stageWH);
			}
			// var i:int = 0;
			for (var pieceY : int = rec.y; pieceY <= rec.height; pieceY++)
			{
				for (var pieceX : int = rec.x; pieceX <= rec.width; pieceX++)
				{
					var key : String = ResKey.piece(assetsMapId, pieceX, pieceY);
					if (pieceMangager.isAlreadySetLoad(key) == true) continue;
					// 加载地图块
					loadPiece(pieceX, pieceY);
					// setTimeout(loadPiece, i*150, pieceX, pieceY);
					// i++;
					pieceMangager.pushAlreadySetLoad(key);
				}
			}
		}

		/** 加载地图块 */
		private function loadPiece(x : int, y : int) : void
		{
			var libData : LibData = LibDataUtil.mapPiece(assetsMapId, x, y);
			MapUnloadManager.instance.add(libData);
			pieceMangager.loadKeyList.push(libData.key);
			if (MapUtil.isDungeonMap(mapId) )
			{
				res.load(libData, loadPiecel_onComplete, [assetsMapId, x, y, libData]);
			}
			else
			{
				res.load(libData, loadPiecel_onComplete2, [assetsMapId, x, y, libData]);
			}
		}

		public var loadedPieceCache : Vector.<Array> = new Vector.<Array>();

		/** 加载完地图块 */
		private function loadPiecel_onComplete2(assetsMapId : uint, x : int, y : int, libData : LibData) : void
		{
			loadedPieceCache.push([assetsMapId, x, y, libData]);
			if ( drawing == false) startDrawPiecel();
		}

		private var startDrawPiecelTime : uint;
		private var startDrawPiecelTimer : uint;
		private var drawing : Boolean = false;

		public function startDrawPiecel() : void
		{
			var arr : Array;
			clearTimeout(startDrawPiecelTimer);
			startDrawPiecelTime = getTimer();
			drawing = true;
			// Logger.info("drawing");
			while (loadedPieceCache.length > 0)
			{
				arr = loadedPieceCache.pop();
				loadPiecel_onComplete(arr[0], arr[1], arr[2], arr[3]);
				if (getTimer() - startDrawPiecelTime > 10)
				{
					clearTimeout(startDrawPiecelTimer);
					startDrawPiecelTimer = setTimeout(startDrawPiecel, 160);
					return;
				}
			}
			drawing = false;
		}

		/** 加载完地图块 */
		private function loadPiecel_onComplete(assetsMapId : uint, x : int, y : int, libData : LibData) : void
		{
			// 如果之前已经加载完了就返回
			var key : String = libData.key;
			// 如果加载的不是当前地图的就返回
			if (this.assetsMapId != assetsMapId)
			{
				res.remove(key);
				MapUnloadManager.instance.remove(libData);
				return;
			}
			if (pieceMangager.isLoadComplete(key)) return;
			pieceMangager.pusLoadComplete(key);

			// 如果场景中有了就删除
			var elementName : String = ElementName.piece(x, y);
			var displayObjcet : DisplayObject = elementLayer.land.getChildByName(elementName);
			if (displayObjcet) displayObjcet.parent.removeChild(displayObjcet);
			// 读取加载
			var loader : SWFLoader = RESManager.getLoader(key);
			if (loader == null) return;
			// var bitmapData:BitmapData =new (loader.getClass("localPiece")) as BitmapData ;
			// var pieceKey:String = y+"_"+x;
			// var bitmap:Bitmap =  elementLayer.piecelDic[pieceKey];
			// bitmap.bitmapData = bitmapData;

			var bitmap : Bitmap = new Bitmap(new (loader.getClass("localPiece")) as BitmapData);
			bitmap.smoothing = true;
			bitmap.x = x * mapStruct.singlePieceHW.x;
			bitmap.y = y * mapStruct.singlePieceHW.y;
			elementLayer.land.addChild(bitmap);
			waitLoaderUnloadAndStopList.push(libData);
			// 清除加载缓存
			// res.remove(key);
			// MapUnloadManager.instance.remove(libData);
			// 擦除缩略图
			// eraseThumbnailTimeOut = setTimeout(eraseThumbnail, 1500, x, y);
			// eraseThumbnail(x, y);
		}

		private var waitLoaderUnloadAndStopList : Vector.<LibData> = new Vector.<LibData>();

		public function loaderUnloadAndStopAll() : void
		{
			while (waitLoaderUnloadAndStopList.length > 0)
			{
				loaderUnloadAndStop(waitLoaderUnloadAndStopList.pop());
			}
		}

		public function selfStartWalk() : void
		{
			kilStartLoaderUnloadAndStop = true;
		}

		public function selfEndWalk() : void
		{
			kilStartLoaderUnloadAndStop = false;
			startLoaderUnloadAndStop();
		}

		private var kilStartLoaderUnloadAndStop : Boolean = false;

		public function startLoaderUnloadAndStop() : void
		{
			// Logger.info("startLoaderUnloadAndStop");
			while (waitLoaderUnloadAndStopList.length > 0 && !kilStartLoaderUnloadAndStop)
			{
				loaderUnloadAndStop(waitLoaderUnloadAndStopList.pop());
			}
		}

		public function loaderUnloadAndStop(libData : LibData) : void
		{
			res.remove(libData.key);
			MapUnloadManager.instance.remove(libData);
		}

		/** 擦除缩略图一小块区域 */
		private var eraseThumbnailRect : Rectangle = new Rectangle();
		/** 没擦除缩略图一小块区域列表 */
		private var noEraseThumbnailList : Vector.<Point> = new Vector.<Point>();
		/** 擦除缩略图setTimeout */
		private var eraseThumbnailTimeOut : uint;

		/** 擦除缩略图 */
		private function eraseThumbnail(x : int, y : int) : void
		{
			if (eraseThumbnailRect.width == 0)
			{
				eraseThumbnailRect.width = mapStruct.singlePieceHW.x / mapStruct.miniPercentage;
				eraseThumbnailRect.height = mapStruct.singlePieceHW.y / mapStruct.miniPercentage;
			}
			eraseThumbnailRect.x = x * mapStruct.singlePieceHW.x / mapStruct.miniPercentage;
			eraseThumbnailRect.y = y * mapStruct.singlePieceHW.y / mapStruct.miniPercentage;
			if (elementLayer.thumbnail)
			{
				elementLayer.thumbnail.fillRect(eraseThumbnailRect, 0x00000000);

				while (noEraseThumbnailList.length > 0)
				{
					var point : Point = noEraseThumbnailList.shift();
					eraseThumbnail(point.x, point.y);
				}
			}
			else
			{
				noEraseThumbnailList.push(new Point(x, y));
			}
		}

		/** 闪步(快送传送) */
		public function flashStep(x : int, y : int, mapId : int = 0) : void
		{
			if (mapId <= 0 || mapId == this.mapId)
			{
				selfPlayerAnimal.stopMove();
				selfPlayerAnimal.moveTo(x, y);
				center();
				setTimeout(MapTo.instance.checkArrive, 300);
			}
			else
			{
//				if (MapUtil.isDungeonMap(mapId)) return;
				selfPlayerAnimal.stopMove();
				MapProto.instance.cs_transport( x, y, mapId);
			}
		}

		private var moveToMoveing : Boolean = false;
		private var moveToPreSpendTime : Number = -1;
		private var moveToPreTargetX : int = 0;
		private var moveToPreTargetY : int = 0;
		private var moveToTweenLite : TweenLite;

		/** 
		 * 地图移动
		 * @param spendTime 花费时间 (-1：为自动计算时间，0：为瞬间跳动，1：为固定预时间， 大于为1为自己设置时间)
		 */
		public function moveTo(x : int, y : int, spendTime : Number = -1) : void
		{
			moveToPreSpendTime = spendTime;
			moveToPreTargetX = x;
			moveToPreTargetY = y;
			var toPosition : Point = MapUtil.getMapPostion(new Vector2D(x, y));
			var distance : Number = Point.distance(toPosition, postion);
			if (distance <= 5) return;

			if (spendTime == 0)
			{
				// 移动地图
				elementLayer.moveTo(toPosition.x, toPosition.y);
				// 加载屏幕内的地图块
				loadPieceInScreen(true);
				return;
			}
			else if (spendTime == -2)
			{
				spendTime = 2;
			}
			else if (spendTime < 0)
			{
				spendTime = distance / 120;
			}

			var updateFun : Function = function() : void
			{
				loadPieceInScreen();
				postion.x = elementLayer.x;
				postion.y = elementLayer.y;
			};

			var complete : Function = function() : void
			{
				moveToMoveing = false;
			};

			moveToMoveing = true;
			moveToTweenLite = TweenLite.to(elementLayer, spendTime, {x:toPosition.x, y:toPosition.y, onUpdate:updateFun, onComplete:complete});
		}

		/** 是否可以鼠标所在屏幕方向移动地图 */
		private var _enMouseMove : Boolean = false;

		/** 是否可以鼠标所在屏幕方向移动地图 */
		public function get enMouseMove() : Boolean
		{
			return _enMouseMove;
		}

		public function set enMouseMove(value : Boolean) : void
		{
			_enMouseMove = value;
			if (_enMouseMove == true)
			{
				MapUtil.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
			else
			{
				MapUtil.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}

		public function onMouseMove(event : MouseEvent = null) : void
		{
			if (event.ctrlKey)
			{
				var stage : Stage = MapUtil.stage;

				if (stage.mouseX > stage.stageWidth * 0.25 && stage.mouseX < stage.stageWidth * 0.75 && stage.mouseY > stage.stageHeight * 0.25 && stage.mouseY < stage.stageHeight * 0.75)
				{
					if (moveToTweenLite) moveToTweenLite.kill();
					return;
				}
				moveTo(elementLayer.mouseX, elementLayer.mouseY, -2);
			}
			else
			{
				if (moveToTweenLite) moveToTweenLite.kill();
			}
		}

		/** 场景舞台大小变化 */
		private function stageResize(stage : Stage = null, preStageWidth : Number = 0, preStageHeight : Number = 0) : void
		{
			if (MapSystem.mapMoveIsBindSelfPlayer == true)
			{
				if (isMove == false) moveTo(selfPostion.x, selfPostion.y, 2);
			}
			else
			{
				if (moveToMoveing == false)
				{
					 var x : int = (preStageWidth - stage.stageWidth) / 2;
					 var y : int = (preStageHeight - stage.stageHeight) / 2;
					 x = x - elementLayer.x + preStageWidth / 2;
					 y = y - elementLayer.y + preStageHeight / 2;

					moveTo(x, y, 2);
				}
				else
				{
					moveTo(moveToPreTargetX, moveToPreTargetY, moveToPreSpendTime);
				}
			}
		}
	}
}
class Singleton
{
}