package maps.elements
{
	import cmodule.pathc.CLibInit;

	import maps.MapMath;
	import maps.MapUtil;
	import maps.auxiliarys.MapPoint;
	import maps.auxiliarys.MapPointPool;

	import com.signalbus.Signal;

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

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

			findByteArray = new ByteArray();
			findByteArray.endian = Endian.LITTLE_ENDIAN;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		private var lib : CLibInit;
		private var arithmetic : *;
		private var setPathSizeFun : Function;
		private var writePathDataFun : Function;
		private var findPathFun : Function;
		private var bitmapDataSource : BitmapData;
		private var bitmapData : BitmapData;
		private var writeComplete : Boolean = false;
		public static var signalWriteProgress : Signal = new Signal(uint, uint);
		public static var signalWriteComplete : Signal = new Signal();

		public function reset(bitmapData : BitmapData) : void
		{
			clearup();
			bitmapDataSource = bitmapData;
			this.bitmapData = bitmapData;
			writeData();
		}

		public function clearup() : void
		{
			writeComplete = false;
			clearTimeout(writePathTimer);
			byteArray.clear();
			if (bitmapData)
			{
				bitmapData.dispose();
				bitmapDataSource.dispose();
			}
		}

		// =======================
		// 设置关卡开放
		// =======================
		public function openPass(passColor : uint) : void
		{
			if (passColor == 0 || bitmapData == null) return;
			if (passColor < 0xFF000000) passColor = passColor | 0xFF000000;
			var pt : Point = new Point(0, 0);
			var rect : Rectangle = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
			var threshold : uint = passColor;
			var color : uint = 0xFFFFFFFF;
			var maskColor : uint = 0x11111111;
			bitmapData.threshold(bitmapData, rect, pt, "==", threshold, color, maskColor, true);
			writeData();
		}

		public function closePass(passColor : uint) : void
		{
			if (passColor == 0 || bitmapDataSource == null || bitmapData == null) return;

			var rect : Rectangle = bitmapDataSource.getColorBoundsRect(0xFFFFFF, passColor, true);
			var pt : Point = new Point(rect.x, rect.y);
			bitmapData.copyPixels(bitmapDataSource, rect, pt);
			writeData();
		}

		// =======================
		// 写入寻路数据
		// =======================
		private function writeData() : void
		{
			writeComplete = false;
			clearTimeout(writePathTimer);
			setPathSizeFun(bitmapData.width, bitmapData.height);
			rectangle.width = bitmapData.width;
			totalLineNum = bitmapData.height;
			line = 0;
			lineNum = 128;
			startWriteData();
		}

		private var byteArray : ByteArray = new ByteArray();
		private var rectangle : Rectangle = new Rectangle(0, 0, 0, 1);
		private var totalLineNum : int;
		private var line : int;
		private var lineNum : int = 128;
		private var writePathTime : int;
		private var writePathTimer : uint;

		private function startWriteData() : void
		{
			clearTimeout(writePathTimer);
			writePathTime = writePathTime;
			while (line < totalLineNum)
			{
				if (totalLineNum - line < lineNum) lineNum = totalLineNum - line;
				writeDataLine(line, lineNum);
				line += lineNum;
				signalWriteProgress.dispatch(line, totalLineNum);
				if (getTimer() - writePathTime > 100)
				{
					writePathTimer = setTimeout(startWriteData, 20);
					return;
				}
			}
			writeComplete = true;
			signalWriteComplete.dispatch();
		}

		private function writeDataLine(line : int, lineNum : int) : void
		{
			byteArray.clear();
			rectangle.y = line;
			rectangle.height = lineNum;
			byteArray = bitmapData.getPixels(rectangle);
			byteArray.position = 0;
			writePathDataFun(line, lineNum, byteArray);
			byteArray.clear();
		}

		// =======================
		// 寻路
		// =======================
		private var pathPoinList : Vector.<MapPoint> = new Vector.<MapPoint>();
		private var mapPoint : MapPoint;
		private var mapPointPool : MapPointPool = MapPointPool.instance;
		private var pathFromX : int;
		private var pathFromY : int;
		private var pathToX : int;
		private var pathToY : int;
		private var pathFromPoint : MapPoint;
		private var pathToPoint : MapPoint;
		private var findByteArray : ByteArray;

		public function find(mapFromX : int, mapFromY : int, mapToX : int, mapToY : int, pushList : Vector.<MapPoint> = null) : Vector.<MapPoint>
		{
			if (pushList == null) pushList = pathPoinList;
			while (pushList.length > 0)
			{
				mapPoint = pushList.shift();
				mapPoint.destory();
			}
			if (writeComplete == false)
			{
				pushList.push(mapPointPool.getObject(mapToX, mapToY));
				return pushList;
			}

			pathFromX = MapUtil.mapToPathX(mapFromX);
			pathFromY = MapUtil.mapToPathY(mapFromY);
			pathToX = MapUtil.mapToPathX(mapToX);
			pathToY = MapUtil.mapToPathY(mapToY);
			pathFromPoint = getLatestCanWalkPoint(pathFromX, pathFromY);
			pathToPoint = getLatestCanWalkPoint(pathToX, pathToY);
			if (pathFromPoint == null || pathToPoint == null) return pushList;
			findPathFun(pathFromPoint.x, pathFromPoint.y, pathToPoint.x, pathToPoint.y, findByteArray);
			pathFromPoint.destory();
			pathToPoint.destory();

			findByteArray.position = 0;
			while (findByteArray.position < findByteArray.length)
			{
				var x : int = findByteArray.readInt();
				var y : int = x >>> 16;
				x &= 0xFFFF;
				pushList.push(mapPointPool.getObject(MapUtil.pathToMapX(x), MapUtil.pathToMapY(y)));
			}
			findByteArray.clear();

			if (pushList.length > 1)
			{
				mapPoint = pushList[0];
				var distance : Number = MapMath.distance(mapFromX, mapFromY, mapPoint.x, mapPoint.y);
				if (distance < 50)
				{
					pushList.shift();
				}
			}
			return pushList;
		}

		/** 获取最近能走的点 */
		private function getLatestCanWalkPoint(pathX : int, pathY : int) : MapPoint
		{
			var point : MapPoint = mapPointPool.getObject(pathX, pathY);
			var color : uint = bitmapData.getPixel(point.x, point.y);
			if (color == 0xFFFFFF) return point;

			var step : uint = 1;
			var isFind : Boolean = false;
			while (!isFind)
			{
				// 左边
				if (point.x - step > 0)
				{
					color = bitmapData.getPixel(point.x - step, point.y);
					if (color == 0xFFFFFF)
					{
						isFind = true;
						point.x -= step;
						return point;
					}
				}

				// 右边
				if (point.x + step < bitmapData.width)
				{
					color = bitmapData.getPixel(point.x + step, point.y);
					if (color == 0xFFFFFF)
					{
						isFind = true;
						point.x += step;
						return point;
					}
				}

				// 上边
				if (point.y - step > 0)
				{
					color = bitmapData.getPixel(point.x, point.y - step);
					if (color == 0xFFFFFF)
					{
						isFind = true;
						point.y -= step;
						return point;
					}
				}

				// 下边
				if (point.y + step > 0)
				{
					color = bitmapData.getPixel(point.x, point.y + step);
					if (color == 0xFFFFFF)
					{
						isFind = true;
						point.y += step;
						return point;
					}
				}

				// 左上
				if (point.x - step > 0 && point.y - step > 0)
				{
					color = bitmapData.getPixel(point.x - step, point.y - step);
					if (color == 0xFFFFFF)
					{
						isFind = true;
						point.x -= step;
						point.y -= step;
						return point;
					}
				}

				// 右上
				if (point.x + step < bitmapData.width && point.y - step > 0)
				{
					color = bitmapData.getPixel(point.x + step, point.y - step);
					if (color == 0xFFFFFF)
					{
						isFind = true;
						point.x += step;
						point.y -= step;
						return point;
					}
				}

				// 左下
				if (point.x - step > 0 && point.y + step < bitmapData.height)
				{
					color = bitmapData.getPixel(point.x - step, point.y + step);
					if (color == 0xFFFFFF)
					{
						isFind = true;
						point.x -= step;
						point.y += step;
						return point;
					}
				}

				// 右下
				if (point.x + step < bitmapData.width && point.y + step < bitmapData.height)
				{
					color = bitmapData.getPixel(point.x + step, point.y + step);
					if (color == 0xFFFFFF)
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
		public static function reset(bitmapData : BitmapData) : void
		{
			instance.reset(bitmapData);
		}

		/** 开放关卡 */
		public static function openPass(passColor : uint) : void
		{
			instance.openPass(passColor);
		}

		/** 关闭关卡 */
		public static function closePass(passColor : uint) : void
		{
			instance.closePass(passColor);
		}

		/** 寻路 */
		public static function find(mapFromX : int, mapFromY : int, mapToX : int, mapToY : int, pushList : Vector.<MapPoint> = null) : Vector.<MapPoint>
		{
			return instance.find(mapFromX, mapFromY, mapToX, mapToY, pushList);
		}
	}
}
class Singleton
{
}