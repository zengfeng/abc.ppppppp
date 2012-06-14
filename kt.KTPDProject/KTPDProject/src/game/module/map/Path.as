package game.module.map
{
	import maps.layers.lands.LandLayer;
	import game.module.map.layers.ElementLayer;
	import maps.auxiliarys.PointShape;
	import flash.utils.setTimeout;
	import flash.utils.getTimer;
	import flash.utils.clearTimeout;

	import cmodule.pathc.CLibInit;

	import game.module.map.utils.MapUtil;

	import maps.auxiliarys.MapMath;

	import com.signalbus.Signal;
	import com.utils.UIUtil;
	import com.utils.Vector2D;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;

	// ============================
	// @author ZengFeng (zengfeng75[AT]163.com) 2012-5-30
	// ============================
	public class Path
	{
		/** 单例对像 */
		private static var _instance : Path;

		/** 获取单例对像 */
		private static  function get instance() : Path
		{
			if (_instance == null)
			{
				_instance = new Path(new Singleton());
			}
			return _instance;
		}

		function Path(singleton : Singleton) : void
		{
			singleton;

			lib = new CLibInit();
			arithmetic = lib.init();
			setPathSizeFun = arithmetic["setMapSize"];
			writePathDataFun = arithmetic["setMapData"];
			findPathFun = arithmetic["findMapPath"];
			setBlockFun = arithmetic["setBlock"];

			findByteArray = new ByteArray();
			findByteArray.endian = Endian.LITTLE_ENDIAN;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		private var lib : CLibInit;
		private var arithmetic : *;
		private var setPathSizeFun : Function;
		private var writePathDataFun : Function;
		private var setBlockFun : Function;
		private var findPathFun : Function;
		private var writeComplete : Boolean = false;
		private var width : int;
		private var height : int;
		private var tileData : Vector.<uint> = new  Vector.<uint>();
		private var alchemyByteArray : ByteArray = new ByteArray();
		public static var signalWriteProgress : Signal = new Signal(uint, uint);
		public static var signalWriteComplete : Signal = new Signal();

		/** 重设 */
		public function reset(byteArray : ByteArray) : void
		{
			if (byteArray == null || byteArray.length == 0)
			{
				throw new Error("Path::reset 数据出错，有可能path文件不存在");
				return;
			}
			clearup();
			signalWriteComplete.add(initBarrier);
			decodePathFile(byteArray);
			writeData();
		}

		/** 清理 */
		public function clearup() : void
		{
			writeComplete = false;
			alchemyByteArray.clear();
			tileData = new Vector.<uint>();
//			while (tileData.length > 0)
//			{
//				tileData.shift();
//			}
			var arr : Array = [];
			for (var key:String in openedBarrierDic)
			{
				arr.push(key);
			}

			while (arr.length > 0)
			{
				delete openedBarrierDic[arr.pop()];
			}

			openedBarrierDic[0] = false;
			openedBarrierDic[255] = true;
		}

		/** 初始化路障 */
		private function initBarrier() : void
		{
			setBarrier(255, true);
			var dic : Dictionary = BarrierOpened.dic;
			for (var key:String in dic)
			{
				setBarrier(parseInt(key), dic[key]);
			}
			BarrierOpened.signalState.add(setBarrier);
		}

		/** 反编码path文件数据 */
		private function decodePathFile(ba : ByteArray) : void
		{
			width = ba.readInt() ;
			height = ba.readInt() ;
			while ( ba.position < ba.length )
			{
				var b : int = ba.readByte() ;
				b = b >= 0 ? b : ((-1 ^ b) ^ 0xFF) ;

				var rep : int = ba.readByte() ;
				rep = rep >= 0 ? rep : ((-1 ^ rep) ^ 0xFF) ;

				for ( var i : int = 0 ; i < rep ; ++i )
				{
					tileData.push(b);
				}
			}
			testShowData();
			ba.clear();
		}

		// ====================
		// 测试显示
		// ====================
		private var testBitmapData : BitmapData;

		private function testShowData() : void
		{
			return;
			if (testBitmapData == null) testBitmapData = new BitmapData(width, height, true, 0xFFFF0000);
			if (testBitmapData.width != width && testBitmapData.height != height)
			{
				testBitmapData.dispose();
				testBitmapData = new BitmapData(width, height, true, 0xFFFF0000);
			}

			var pathX : int;
			var pathY : int;
			var color : int;
			var arr : Array = [];
			for (var i : int = 0; i < tileData.length; i++)
			{
				pathY = int(i / (width));
				pathX = i - pathY * width;
				color = tileData[i];
				if (arr.indexOf(color) == -1)
				{
					arr.push(color);
				}

				if (isOpened(pathX, pathY))
				{
					color = 0xFFFFFFFF;
				}
				else
				{
					color = 0xFF000000;
				}
				testBitmapData.setPixel32(pathX, pathY, color);
			}

			while (arr.length > 0)
			{
				trace(arr.shift());
			}
			var bitmap : Bitmap = new Bitmap();
			bitmap.bitmapData = testBitmapData;
			UIUtil.stage.addChild(bitmap);
		}

		// =======================
		// 写入寻路数据
		// =======================
		private function writeData() : void
		{
			writeComplete = false;
			clearTimeout(writePathTimer);
			setPathSizeFun(width, height);
			line = 0;
			lineNum = 128 ;
			testWriteDataClear();
			startWriteData();
		}

		private var line : int;
		private var lineNum : int = 128;
		private var writePathTime : int;
		private var writePathTimer : uint;

		private function startWriteData() : void
		{
			clearTimeout(writePathTimer);
			writePathTime = writePathTime;
			while (line < height)
			{
				if ((height - line ) < lineNum) lineNum = height - line;
				writeDataLine(line, lineNum);
				line += lineNum;
				signalWriteProgress.dispatch(line, height);
				if (getTimer() - writePathTime > 100)
				{
					writePathTimer = setTimeout(startWriteData, 20);
					return;
				}
			}
			writeComplete = true;
			signalWriteComplete.dispatch();
			testWriteDataShow();
		}

		private function writeDataLine(line : int, lineNum : int) : void
		{
			encodAlchemyByteArray(line, lineNum);
			alchemyByteArray.position = 0;
			writePathDataFun(line, lineNum, alchemyByteArray);
			alchemyByteArray.clear();
		}

		/** 编码炼金术所需数据 */
		private function encodAlchemyByteArray(line : int, lineNum : int) : void
		{
			var i : int = line * width;
			var end : int = i + lineNum * width;
			alchemyByteArray.clear();
			alchemyByteArray.position = 0;
			for (i; i < end; i++)
			{
//				testWriteData.push(tileData[i]);
				alchemyByteArray.writeByte(tileData[i]);
			}
		}

		// =======================
		// 测试
		// =======================
		private var testWriteData : Vector.<uint> = new Vector.<uint>();
		private var testBitmapData2 : BitmapData;
		private var testBitmap2 : Bitmap = new Bitmap();

		private function testWriteDataClear() : void
		{
			return;
			while (testWriteData.length > 0)
			{
				testWriteData.shift();
			}
		}

		private function testWriteDataShow() : void
		{
			return;
			var tileData : Vector.<uint>= testWriteData;
			var testBitmapData : BitmapData = testBitmapData2;
			var height:int = tileData.length / width;
			if (testBitmapData == null) testBitmapData = new BitmapData(width, height, true, 0xFFDDDDDD);
			if (testBitmapData.width != width && testBitmapData.height != height)
			{
				testBitmapData.dispose();
				testBitmapData = new BitmapData(width, height, true, 0xFFDDDDDD);
			}
			testBitmapData2 = testBitmapData;
			if (tileData.length != this.tileData.length)
			{
				trace("写入数据有错", tileData.length, this.tileData.length);
			}

			var pathX : int;
			var pathY : int;
			var color : int;
			var arr : Array = [];
			for (var i : int = 0; i < this.tileData.length; i++)
			{
				pathY = int(i / (width));
				pathX = i - pathY * width;
				color = tileData[i];
				if (arr.indexOf(color) == -1)
				{
					arr.push(color);
				}
				
				if(color == 255)
				{
					color = 0xFFFFFFFF;
				}
				else if(color == 0)
				{
					color = 0xFF000000;
				}
				else if(color == 1)
				{
					color = 0xFFFF0000;
				}
				else if(color == 2)
				{
					color = 0xFFFFFF00;
				}
				else if(color == 3)
				{
					color = 0xFF0000FF;
				}

//				if (isOpened(pathX, pathY))
//				{
//					color = 0xFFFFFFFF;
//				}
//				else
//				{
//					color = 0xFF000000;
//				}
				testBitmapData.setPixel32(pathX, pathY, color);
			}

			while (arr.length > 0)
			{
				trace(arr.shift());
			}
			testBitmap2.bitmapData = testBitmapData;
			UIUtil.stage.addChild(testBitmap2);
		}

		// =======================
		// 设置关卡开放
		// =======================
		private var openedBarrierDic : Dictionary = new Dictionary();

		private function setBarrier(barrierId : uint, isOpened : Boolean) : void
		{
			openedBarrierDic[barrierId] = isOpened;
			setBlockFun(barrierId, isOpened ? 1 : 0);
			testShowData();
		}

		/** 获取路径点的颜色ID */
		private function getPixel(pathX : int, pathY : int) : int
		{
			var index : int = pathY * width + pathX;
			if(index > tileData.length) return 0;
			return tileData[index];
		}

		/** 获取路径点是否开放 */
		private function isOpened(pathX : int, pathY : int) : Boolean
		{
			return openedBarrierDic[getPixel(pathX, pathY)];
		}

		// =======================
		// 寻路
		// =======================
		private var mapPoint : Point;
		private var pathFromX : int;
		private var pathFromY : int;
		private var pathToX : int;
		private var pathToY : int;
		private var pathFromPoint : Point;
		private var pathToPoint : Point;
		private var findByteArray : ByteArray;

		public function find(mapFromX : int, mapFromY : int, mapToX : int, mapToY : int, pushList : Vector.<Vector2D> = null) : Vector.<Vector2D>
		{
			if (pushList == null) pushList = new Vector.<Vector2D>();
			while (pushList.length > 0)
			{
				mapPoint = pushList.shift();
			}
			if (writeComplete == false)
			{
				pushList.push(new Vector2D(mapToX, mapToY));
				return pushList;
			}
			
			testFromPoint2.x = mapFromX - testFromPoint.width / 4;
			testFromPoint2.y = mapFromY - testFromPoint.height / 4;
			testToPoint2.x = mapToX - testFromPoint.width / 4;
			testToPoint2.y = mapToY - testFromPoint.height / 4;

			pathFromX = MapUtil.mapToPathX(mapFromX);
			pathFromY = MapUtil.mapToPathY(mapFromY);
			pathToX = MapUtil.mapToPathX(mapToX);
			pathToY = MapUtil.mapToPathY(mapToY);
			pathFromPoint = getLatestCanWalkPoint(pathFromX, pathFromY);
			pathToPoint = getLatestCanWalkPoint(pathToX, pathToY);
			if (pathFromPoint == null || pathToPoint == null) return pushList;
			findByteArray.position = 0;
			findPathFun(pathFromPoint.x, pathFromPoint.y, pathToPoint.x, pathToPoint.y, findByteArray);
			trace("from,to", getPixel(pathFromPoint.x, pathFromPoint.y), getPixel(pathToPoint.x, pathToPoint.y), pathFromPoint.x, pathFromPoint.y, pathToPoint.x, pathToPoint.y);
			findByteArray.position = 0;
			while (findByteArray.position < findByteArray.length)
			{
				var x : int = findByteArray.readInt();
				var y : int = x >>> 16;
				x &= 0xFFFF;
				pushList.push(new Vector2D(MapUtil.pathToMapX(x), MapUtil.pathToMapY(y)));
			}
			findByteArray.clear();

			if (pushList.length > 1)
			{
				mapPoint = pushList[0];
				var distance : Number = MapMath.distance(mapFromX, mapFromY, mapPoint.x, mapPoint.y);
				if (distance < 40)
				{
					pushList.shift();
				}
			}
			testShowFindPoint();
			return pushList;
		}
		
		private var testFromPoint:PointShape = new PointShape();
		private var testToPoint:PointShape = new PointShape();
		private var testFromPoint2:PointShape = new PointShape();
		private var testToPoint2:PointShape = new PointShape();
		private function testShowFindPoint():void
		{
			return;
			clearTimeout(testHideFindPointTimer);
			testFromPoint.x = pathFromPoint.x * 16 - testFromPoint.width / 2;
			testFromPoint.y = pathFromPoint.y * 16 - testFromPoint.height / 2;
			
			testToPoint.x = pathToPoint.x * 16 - testToPoint.width / 2;
			testToPoint.y = pathToPoint.y * 16 - testToPoint.height / 2;
			testFromPoint2.scaleX = testFromPoint2.scaleY = 0.5;
			testToPoint2.scaleX = testToPoint2.scaleY = 0.5;
			LandLayer.instance.addChild(testFromPoint);
			LandLayer.instance.addChild(testToPoint);
			LandLayer.instance.addChild(testFromPoint2);
			LandLayer.instance.addChild(testToPoint2);
			
			testHideFindPointTimer = setTimeout(testHideFindPoint, 5000);
		}
		
		private var testHideFindPointTimer:uint = 0;
		private function testHideFindPoint():void
		{
			return;
			if(testFromPoint.parent)
			{
				testFromPoint.parent.removeChild(testFromPoint);
				testToPoint.parent.removeChild(testToPoint);
				testFromPoint2.parent.removeChild(testFromPoint2);
				testToPoint2.parent.removeChild(testToPoint2);
			}
		}

		/** 获取最近能走的点 */
		private function getLatestCanWalkPoint(pathX : int, pathY : int) : Point
		{
			var point : Point = new Point(pathX, pathY);
			if (isOpened(point.x, point.y)) return point;

			var step : uint = 1;
			var isFind : Boolean = false;
			while (!isFind)
			{
				// 左边
				if (point.x - step > 0)
				{
					if (isOpened(point.x - step, point.y))
					{
						isFind = true;
						point.x -= step;
						return point;
					}
				}

				// 右边
				if (point.x + step < width)
				{
					if (isOpened(point.x + step, point.y))
					{
						isFind = true;
						point.x += step;
						return point;
					}
				}

				// 上边
				if (point.y - step > 0)
				{
					if (isOpened(point.x, point.y - step))
					{
						isFind = true;
						point.y -= step;
						return point;
					}
				}

				// 下边
				if (point.y + step > 0)
				{
					if (isOpened(point.x, point.y + step))
					{
						isFind = true;
						point.y += step;
						return point;
					}
				}

				// 左上
				if (point.x - step > 0 && point.y - step > 0)
				{
					if (isOpened(point.x - step, point.y - step))
					{
						isFind = true;
						point.x -= step;
						point.y -= step;
						return point;
					}
				}

				// 右上
				if (point.x + step < width && point.y - step > 0)
				{
					if (isOpened(point.x + step, point.y - step))
					{
						isFind = true;
						point.x += step;
						point.y -= step;
						return point;
					}
				}

				// 左下
				if (point.x - step > 0 && point.y + step < height)
				{
					if (isOpened(point.x - step, point.y + step))
					{
						isFind = true;
						point.x -= step;
						point.y += step;
						return point;
					}
				}

				// 右下
				if (point.x + step < width && point.y + step < height)
				{
					if (isOpened(point.x + step, point.y + step))
					{
						isFind = true;
						point.x += step;
						point.y += step;
						return point;
					}
				}

				step += 2;
				if (step >= 500) break;
			}
			return null;
		}

		// =========================
		// 静态方法
		// =========================
		/** 重设 */
		public static function reset(byteArrray : ByteArray) : void
		{
			instance.reset(byteArrray);
		}

		/** 设置路障 */
		public static function setBarrier(barrierId : uint, isOpen : Boolean) : void
		{
			instance.setBarrier(barrierId, isOpen);
		}

		/** 寻路 */
		public static function find(mapFromX : int, mapFromY : int, mapToX : int, mapToY : int, pushList : Vector.<Vector2D> = null) : Vector.<Vector2D>
		{
			return instance.find(mapFromX, mapFromY, mapToX, mapToY, pushList);
		}
	}
}
class Singleton
{
}