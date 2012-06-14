package game.module.groupBattle
{
	import flash.geom.Rectangle;
	import flash.geom.Point;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-16 ����2:25:02
	 * 椭圆
	 * 椭圆公式        
	 * ball.x = centerX + Math.cos(angle) * radiusX;
	 * ball.y = centerY + Math.sin(angle) * radiusY;
	 * angle += drawSpeed;
	 */
	public class GBEllipse
	{
		public var centerX : int = 0;
		public var centerY : int = 0;
		public var radiusX : int = 100;
		public var radiusY : int = 50;
		public var angle : Number = 0;
		public var drawSpeed : Number = 0.1;

		function GBEllipse(radiusX : int = 100, radiusY : int = 50, centerX : int = 0, centerY : int = 0) : void
		{
			this.radiusX = radiusX;
			this.radiusY = radiusY;
			this.centerX = centerX;
			this.centerY = centerY;
		}

		/** 随机获得面积内的点 */
		public function getRandomAreaPoint() : Point
		{
			var point : Point = new Point();
			var angle : Number = Math.random() * 2 * Math.PI;
			var radiusX : Number = Math.random() * this.radiusX;
			var radiusY : Number = Math.random() * this.radiusY;
			point.x = centerX + Math.cos(angle) * radiusX;
			point.y = centerY + Math.sin(angle) * radiusY;
			return point;
		}

		/** 内半径X */
		public var innerRadiuX : int = 300;

		/** 随机获休息区域内的一点 */
		public function getRandomRestAreaPoint(groupId : int) : Point
		{
			var minAngle : Number;
			var maxAngle : Number;
			var centerX : int = this.centerX;
			var radiusX : int = this.radiusX;
			if (groupId == GBSystem.GROUP_A_ID)
			{
				minAngle = 0.5 * Math.PI;
				maxAngle = 1.5 * Math.PI;
				centerX -= innerRadiuX;
			}
			else
			{
				minAngle = -0.5 * Math.PI;
				maxAngle = 0.5 * Math.PI;
				centerX += innerRadiuX;
			}
			radiusX -= innerRadiuX;
			var angle : Number;
			angle = minAngle + Math.random() * (maxAngle - minAngle);

			var point : Point = new Point();
			radiusX = Math.random() * radiusX;
			var radiusY : Number = Math.random() * this.radiusY;
			point.x = centerX + Math.cos(angle) * radiusX;
			point.y = centerY + Math.sin(angle) * radiusY;
			return point;
		}

		/** 随机获休息区域内的一点 */
		public function getRandomVSAreaPoint(groupId : int) : Point
		{
			var point : Point = new Point();
			var rect : Rectangle = new Rectangle();
			var aa : int = 100;
			if (groupId == GBSystem.GROUP_A_ID)
			{
				rect.x = centerX - innerRadiuX - aa;
				rect.y = centerY - radiusY;

				rect.width = innerRadiuX + aa;
				rect.height = 2 * radiusY;
			}
			else
			{
				rect.x = centerX;
				rect.y = centerY - radiusY;

				rect.width = innerRadiuX - aa;
				rect.height = radiusY * 2;
			}

			point.x = rect.x + Math.floor(Math.random() * rect.width);
			point.y = rect.y + Math.floor(Math.random() * rect.height);
			return point;
		}

		/** 判断这个点是否在休息区域 */
		public function isInAreaRest(x : int, y : int) : Boolean
		{
			var isIn : Boolean = isInArea(x, y);
			if (isIn == false)
			{
				return false;
			}

			// isIn = !isInAreaVS(x, y);
			isIn = x <= 1836 || x >= 2019;
			return isIn;
		}

		/** 判断这个是是否在战斗区域 */
		public function isInAreaVS(x : int, y : int) : Boolean
		{
			var isIn : Boolean = isInArea(x, y);
			if (isIn == false)
			{
				return false;
			}

			// var rect : Rectangle = new Rectangle();
			// rect.x = centerX - innerRadiuX;
			// rect.y = centerY - radiusY;
			// rect.width = innerRadiuX * 2;
			// rect.height = radiusY * 2;
			// return rect.x <= x && x <= (rect.x + rect.width);
			return x > 1836 && x < 2019;
		}

		/** 判断这个点是否在面积区域内 */
		public function isInArea(x : int, y : int) : Boolean
		{
			var dx : Number = x - centerX;
			var dy : Number = y - centerY;
			var angle : Number = Math.atan2(dy, dx);
			var radiusX : Number = dx / Math.cos(angle);
			var radiusY : Number = dy / Math.cos(angle);
			if (radiusX <= this.radiusX && radiusY <= this.radiusY)
			{
				return true;
			}
			return false;
		}
	}
}
