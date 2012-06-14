package maps.elements
{
	import maps.MapMath;
	import maps.auxiliarys.MapPoint;
	import maps.elements.animations.SimpleAnimation;
	import maps.elements.proessors.AttackerProcessor;
	import maps.elements.proessors.DefenderProcessor;
	import maps.elements.proessors.FollowerProcessor;
	import maps.elements.proessors.LeaderProcessor;
	import maps.elements.proessors.MoveProessorFactory;
	import maps.elements.proessors.WalkProcessor;

	import com.signalbus.Signal;

	// ============================
	// @author ZengFeng (zengfeng75[AT]163.com) 2012-6-1
	// ============================
	public class Element
	{
		// ==============
		// 稳定信息
		// ==============
		protected var name : String;
		protected var colorStr : String;
		// ==============
		// 位置信息
		// ==============
		protected var speed : int;
		protected var position : MapPoint = new MapPoint();
		protected var walking : Boolean;
		// ==============
		// 处理器及回调
		// ==============
		protected var walkProcessor : WalkProcessor;
		protected var attackerProcessor : AttackerProcessor;
		protected var defenderProcessor : DefenderProcessor;
		protected var followerProcessor : FollowerProcessor;
		protected var leaderProcessor : LeaderProcessor;
		protected var animation : SimpleAnimation;
		// ==============
		// 抛出信息
		// ==============
		protected var signalWalkStart : Signal = new Signal();
		// args=[fromX, fromY, toX, toY]
		protected var signalWalkTurn : Signal = new Signal(int, int, int, int);
		protected var signalWalkEnd : Signal = new Signal();
		// args=[x, y]
		protected var signalUpdatePosition : Signal = new Signal(int, int);
		// args=[speed]
		protected var signalChangeSpeed : Signal = new Signal(Number);
		// args=[toX, toY]
		protected var signalTransportTo : Signal = new Signal(int, int);
		protected var signalQuit : Signal = new Signal();

		function Element() : void
		{
			walkProcessor = new WalkProcessor();
		}

		public function destory() : void
		{
			quit();
			walkProcessor.destory();
			animation.destory();
			animation = null;
			signalWalkStart.clear();
			signalWalkTurn.clear();
			signalWalkEnd.clear();
			signalChangeSpeed.clear();
			signalUpdatePosition.clear();
			signalQuit.clear();
		}

		protected function setAnimation(animation : SimpleAnimation) : void
		{
			this.animation = animation;
			signalWalkTurn.add(animation.run);
			signalWalkEnd.add(animation.stand);
		}

		public function initPosition(x : int, y : int, speed : int, walking : Boolean, walkTime : Number, fromX : int, fromY : int, toX : int, toY : int) : void
		{
			this.speed = speed;
			this.walking = walking;
			position.x = x;
			position.y = y;
			walkProcessor.reset(position, speed, setPosition, walkStart, walkTurn, walkEnd, MoveProessorFactory.TIME);
			signalChangeSpeed.add(walkProcessor.changeSpeed);
			if (walking == false)
			{
				setPosition(x, y);
				return;
			}

			var distance : Number = MapMath.distance(fromX, fromY, toX, toY);
			var length : Number = speed * walkTime;
			if (length >= distance)
			{
				setPosition(toX, toY);
				return;
			}

			var radian : Number = MapMath.radian(fromX, fromY, toX, toY);
			x = MapMath.radianPointX(radian, length, fromX);
			y = MapMath.radianPointY(radian, length, fromY);
			setPosition(x, y);
			walkLineTo(toX, toY);
		}

		public function setPosition(x : int, y : int) : void
		{
			position.x = x;
			position.y = y;
			animation.setPosition(x, y);
			signalUpdatePosition.dispatch(x, y);
		}

		// =======================
		// 站立朝向
		// =======================
		private var standDirectionPoint : MapPoint = new MapPoint();

		protected function setStandDirection(targetX : int, targetY : int) : void
		{
			standDirectionPoint.x = targetX;
			standDirectionPoint.y = targetY;
			signalWalkEnd.remove(animation.stand);
			signalWalkEnd.add(standDirection);
		}

		protected function cancelStandDirection() : void
		{
			signalWalkEnd.remove(standDirection);
			signalWalkEnd.add(animation.stand);
		}

		protected function standDirection() : void
		{
			cancelStandDirection();
			animation.standDirection(standDirectionPoint.x, standDirectionPoint.y);
		}

		// =======================
		// 走路
		// =======================
		public function transportTo(toX : int, toY : int) : void
		{
			walkStop();
			setPosition(toX, toY);
			signalTransportTo.dispatch(toX, toY);
		}

		protected function walkStart() : void
		{
			walking = true;
			signalWalkStart.dispatch();
		}

		protected function walkEnd() : void
		{
			walking = false;
			signalWalkEnd.dispatch();
		}

		protected function walkTurn(fromX : int, fromY : int, toX : int, toY : int) : void
		{
			signalWalkTurn.dispatch(fromX, fromY, toX, toY);
		}


		public function walkStop() : void
		{
			walkProcessor.stop();
		}

		public function walkAddPathPoint(x : int, y : int) : void
		{
			walkProcessor.addPathPoint(x, y);
		}

		public function removePathLastPoint() : void
		{
			walkProcessor.removePathLastPoint();
		}

		public function walkSetPath(path : Vector.<MapPoint>) : void
		{
			walkProcessor.setPath(path);
		}

		public function walkPathTo(toX : int, toY : int) : void
		{
			walkProcessor.pathTo(toX, toY);
		}

		public function walkLineTo(toX : int, toY : int) : void
		{
			walkProcessor.lineTo(toX, toY);
		}

		// =======================
		// 速度
		// =======================
		public function changeSpeed(speed : Number) : void
		{
			this.speed = speed;
			dispatchSpeed(this.speed);
		}

		protected function recoverSpeed() : void
		{
			dispatchSpeed(this.speed);
		}

		protected function dispatchSpeed(speed : Number) : void
		{
			signalChangeSpeed.dispatch(speed);
		}

		// =======================
		// 战斗
		// =======================
		public function attack(element : Element) : void
		{
			if (attackerProcessor)
			{
				attackerProcessor.destory();
			}
			attackerProcessor = new AttackerProcessor();
			element.addAttaker(this);
			var defenderProcessor : DefenderProcessor = element.defenderProcessor;
			signalQuit.add(attackerProcessor.destory);
			signalWalkEnd.remove(animation.stand);
			signalWalkEnd.add(attackerProcessor.walkEnd);
			attackerProcessor.reset(defenderProcessor, position, element.x, element.y, cancelAttack, walkLineTo, animation.attack);
		}

		public function cancelAttack(destoryed : Boolean = false) : void
		{
			if (attackerProcessor == null) return;
			signalQuit.remove(attackerProcessor.destory);
			signalWalkEnd.remove(attackerProcessor.walkEnd);
			signalWalkEnd.add(animation.stand);
			if (!destoryed) attackerProcessor.destory();
			attackerProcessor = null;
			walkStop();
		}

		protected function generateDefenderProcessor() : void
		{
			defenderProcessor = new DefenderProcessor();
			defenderProcessor.reset(destoryDefenderProcessor);
			signalUpdatePosition.add(defenderProcessor.move);
			signalQuit.add(defenderProcessor.destory);
		}

		protected function destoryDefenderProcessor(destoryed : Boolean = false) : void
		{
			if (defenderProcessor == null) return;
			signalUpdatePosition.remove(defenderProcessor.move);
			signalQuit.remove(defenderProcessor.destory);
			if (!destoryed) defenderProcessor.destory();
			defenderProcessor = null;
		}

		protected function addAttaker(element : Element) : void
		{
			if (defenderProcessor == null)
			{
				generateDefenderProcessor();
			}
			defenderProcessor.addAttacker(element.attackerProcessor);
		}

		// =======================
		// 跟随
		// =======================
		public function follow(element : Element) : void
		{
			if (followerProcessor)
			{
				followerProcessor.destory();
			}
			followerProcessor = new FollowerProcessor();
			element.addFollower(this);
			var leaderProcessor : LeaderProcessor = element.leaderProcessor;
			signalQuit.add(followerProcessor.destory);
			followerProcessor.reset(leaderProcessor, position, cancelFollow, dispatchSpeed, transportTo, walkAddPathPoint, removePathLastPoint, setStandDirection);
		}

		public function cancelFollow(destoryed : Boolean = false) : void
		{
			if (followerProcessor == null) return;
			recoverSpeed();
			cancelStandDirection();
			signalQuit.remove(followerProcessor.destory);
			if (!destoryed) followerProcessor.destory();
			followerProcessor = null;
		}

		protected function generateLeaderProcessor() : void
		{
			leaderProcessor = new LeaderProcessor();
			leaderProcessor.reset(destoryLeaderProcessor, position, speed, walking);
			signalQuit.add(leaderProcessor.destory);
			signalWalkStart.add(leaderProcessor.walkStart);
			signalWalkTurn.add(leaderProcessor.walkTurn);
			signalWalkEnd.add(leaderProcessor.walkEnd);
			signalChangeSpeed.add(leaderProcessor.changeSpeed);
			signalTransportTo.add(leaderProcessor.transport);
		}

		protected function destoryLeaderProcessor(destoryed : Boolean = false) : void
		{
			if (leaderProcessor == null) return;
			signalQuit.remove(leaderProcessor.destory);
			signalWalkStart.remove(leaderProcessor.walkStart);
			signalWalkTurn.remove(leaderProcessor.walkTurn);
			signalWalkEnd.remove(leaderProcessor.walkEnd);
			signalChangeSpeed.remove(leaderProcessor.changeSpeed);
			signalTransportTo.remove(leaderProcessor.transport);
			if (!destoryed) leaderProcessor.destory();
			leaderProcessor = null;
		}

		protected function addFollower(element : Element) : void
		{
			if (leaderProcessor == null)
			{
				generateLeaderProcessor();
			}
			leaderProcessor.addFollower(element.followerProcessor);
		}

		// =======================
		// 共用方法
		// =======================
		public function quit() : void
		{
			walkStop();
			signalQuit.dispatch();
		}

		public function die() : void
		{
		}

		public function revive() : void
		{
		}

		// =======================
		// GETER&SETER
		// =======================
		public function get x() : int
		{
			return position.x;
		}

		public function get y() : int
		{
			return position.y;
		}
	}
}
