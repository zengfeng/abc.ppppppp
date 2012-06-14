package game.module.map.move
{
	import com.commUI.alert.Alert;
	import com.utils.Vector2D;
	import game.module.map.animal.Animal;
	import game.module.map.animal.AnimalType;


	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-31 ����12:34:47
	 * 移动驱动
	 */
	public class MoveDrive
	{
		/** 移动驱动管理器 */
		protected static var _manager : MoveManager;
		/** 移动者 */
		protected var _mover : IMover;
		/** 质量 */
		protected var _mass : Number = 1;
		/** 最大速度 */
		protected var _maxSpeed : Number = 6;
		/** 位置 */
		protected var _position : Vector2D = new Vector2D();
		/** 目标位置 */
		protected var _targetPostion : Vector2D = new Vector2D();
		/** 速度向量 */
		protected var _velocity : Vector2D = new Vector2D();
		private var _maxForce : Number = 100;
		private var _steeringForce : Vector2D = new Vector2D();
		private var _stopThreshold : Number = 10;
		private var _arrivalThreshold : Number = 10;
		private var _wanderAngle : Number = 0;
		private var _wanderDistance : Number = 10;
		private var _wanderRadius : Number = 5;
		private var _wanderRange : Number = 1;
		private var _pathIndex : int = 0;
		private var _pathThreshold : Number = 20;
		private var _avoidDistance : Number = 300;
		private var _avoidBuffer : Number = 20;
		private var _inSightDist : Number = 200;
		private var _tooCloseDist : Number = 60;

		public function get steeringForce() : Vector2D
		{
			return _steeringForce;
		}

		public function get targetPostion() : Vector2D
		{
			return _targetPostion;
		}

		public function get mover() : IMover
		{
			return _mover;
		}

		/** 移动驱动管理器 */
		public function get manager() : MoveManager
		{
			if (_manager == null)
			{
				_manager = MoveManager.instance;
			}
			return _manager;
		}

		function MoveDrive(mover : IMover) : void
		{
			_mover = mover;
			_position.x = _mover.x;
			_position.y = _mover.y;
			maxSpeed = _maxSpeed;

			var animal : Animal = _mover as Animal;
			if (animal.animalType == AnimalType.SELF_PLAYER)
			{
				alertStr = "_velocity = " + _velocity + "  _position = " + _position + "\n" + alertStr;
				// setTimeout(manager.addMoveDrive, 2000, this);
			}
			// manager.addMoveDrive(this);
		}

		public var alert : Alert;
		public var alertStr : String = "";

		public function callFun(type : String) : Boolean
		{
			if (type != Alert.CLOSE_EVENT)
			{
				alertStr = "";
				alert.text = alertStr;
				return false;
			}
			return true;
		}

		public function update() : void
		{
			_steeringForce.truncate(_maxForce);
			_steeringForce = _steeringForce.divide(_mass);
			_velocity = _velocity.add2(_steeringForce);
			_steeringForce = new Vector2D();

			_velocity.truncate(_maxSpeed);
			_position = _position.add2(_velocity);
			_mover.moveTo(_position.x, _position.y);
			if (_position.dist(_targetPostion) <= _stopThreshold)
			{
				if (isFollwPath == false)
				{
					stopMove();
				}
				else
				{
					followPath(pathData);
				}
			}
			else if (_position.dist(_targetPostion) <= _arrivalThreshold && isFollwPath == false)
			{
				arrive(_targetPostion);
			}
		}

		/** 停止移动 */
		public function stopMove() : void
		{
			_velocity.zero();
			_steeringForce.zero();
			_mover.stopMove();
			manager.removeDrive(this);
		}

		public function setTargetPostion(x : int, y : int) : void
		{
			_targetPostion.x = x;
			_targetPostion.y = y;
			_mover.go(_targetPostion.x, _targetPostion.y);
			_mover.turn(_targetPostion.x, _targetPostion.y);
			_velocity.zero();
			_steeringForce.zero();
			manager.addMoveDrive(this);
		}

		/** 质量 */
		public function set mass(value : Number) : void
		{
			_mass = value;
		}

		public function get mass() : Number
		{
			return _mass;
		}

		/** 最大速度 */
		public function set maxSpeed(value : Number) : void
		{
			_maxSpeed = value;
			if (_maxSpeed > 0 && _maxSpeed <= 4)
			{
				_stopThreshold = 5;
				_arrivalThreshold = 20;
			}
			else if (_maxSpeed > 4 && _maxSpeed <= 8)
			{
				_stopThreshold = 5;
				_arrivalThreshold = 40;
			}
			else if (_maxSpeed > 8 && _maxSpeed <= 12)
			{
				_stopThreshold = 10;
				_arrivalThreshold = 100;
			}
			else if (_maxSpeed > 12 && _maxSpeed <= 20)
			{
				_stopThreshold = 20;
				_arrivalThreshold = 200;
			}
			else if (_maxSpeed > 20 && _maxSpeed <= 30)
			{
				_stopThreshold = 30;
				_arrivalThreshold = 400;
			}
			else if (_maxSpeed > 30 && _maxSpeed <= 40)
			{
				_stopThreshold = 30;
				_arrivalThreshold = 200;
			}
		}

		public function get maxSpeed() : Number
		{
			return _maxSpeed;
		}

		/** 位置 */
		public function set position(value : Vector2D) : void
		{
			_position = value;
			if (_mover)
			{
				_mover.setPostion(_position.x, _position.x);
			}
		}

		public function get position() : Vector2D
		{
			if (_position && _mover)
			{
				_position.x = _mover.x;
				_position.y = _mover.y;
			}
			return _position;
		}

		/** 速度向量 */
		public function set velocity(value : Vector2D) : void
		{
			_velocity = value;
		}

		public function get velocity() : Vector2D
		{
			return _velocity;
		}

		public function set maxForce(value : Number) : void
		{
			_maxForce = value;
		}

		public function get maxForce() : Number
		{
			return _maxForce;
		}

		public function set arriveThreshold(value : Number) : void
		{
			_arrivalThreshold = value;
		}

		public function get arriveThreshold() : Number
		{
			return _arrivalThreshold;
		}

		public function set wanderDistance(value : Number) : void
		{
			_wanderDistance = value;
		}

		public function get wanderDistance() : Number
		{
			return _wanderDistance;
		}

		public function set wanderRadius(value : Number) : void
		{
			_wanderRadius = value;
		}

		public function get wanderRadius() : Number
		{
			return _wanderRadius;
		}

		public function set wanderRange(value : Number) : void
		{
			_wanderRange = value;
		}

		public function get wanderRange() : Number
		{
			return _wanderRange;
		}

		public function set pathIndex(value : int) : void
		{
			_pathIndex = value;
		}

		public function get pathIndex() : int
		{
			return _pathIndex;
		}

		public function set pathThreshold(value : Number) : void
		{
			_pathThreshold = value;
		}

		public function get pathThreshold() : Number
		{
			return _pathThreshold;
		}

		public function set avoidDistance(value : Number) : void
		{
			_avoidDistance = value;
		}

		public function get avoidDistance() : Number
		{
			return _avoidDistance;
		}

		public function set avoidBuffer(value : Number) : void
		{
			_avoidBuffer = value;
		}

		public function get avoidBuffer() : Number
		{
			return _avoidBuffer;
		}

		public function set inSightDist(value : Number) : void
		{
			_inSightDist = value;
		}

		public function get inSightDist() : Number
		{
			return _inSightDist;
		}

		public function set tooCloseDist(value : Number) : void
		{
			_tooCloseDist = value;
		}

		public function get tooCloseDist() : Number
		{
			return _tooCloseDist;
		}

		/** 寻找 */
		public function seek(target : Vector2D) : void
		{
			setTargetPostion(target.x, target.y);

			var desiredVelocity : Vector2D = target.subtract2(_position);
			desiredVelocity.normalize2();
			desiredVelocity = desiredVelocity.multiply(_maxSpeed);
			var force : Vector2D = desiredVelocity.subtract2(_velocity);
			_steeringForce = _steeringForce.add2(force);
		}

		public function flee(target : Vector2D) : void
		{
			var desiredVelocity : Vector2D = target.subtract2(_position);
			desiredVelocity.normalize2();
			desiredVelocity = desiredVelocity.multiply(_maxSpeed);
			var force : Vector2D = desiredVelocity.subtract2(_velocity);
			_steeringForce = _steeringForce.subtract2(force);
		}

		public function arrive(target : Vector2D) : void
		{
			var desiredVelocity : Vector2D = target.subtract2(_position);
			desiredVelocity.normalize2();

			var dist : Number = _position.dist(target);
			if (dist > _arrivalThreshold)
			{
				desiredVelocity = desiredVelocity.multiply(_maxSpeed);
			}
			else
			{
				desiredVelocity = desiredVelocity.multiply(_maxSpeed * dist / _arrivalThreshold);
			}

			var force : Vector2D = desiredVelocity.subtract2(_velocity);
			_steeringForce = _steeringForce.add2(force);
		}

		public function pursue(target : MoveDrive) : void
		{
			var lookAheadTime : Number = position.dist(target.position) / _maxSpeed;
			var predictedTarget : Vector2D = target.position.add2(target.velocity.multiply(lookAheadTime));
			seek(predictedTarget);
		}

		public function evade(target : MoveDrive) : void
		{
			var lookAheadTime : Number = position.dist(target.position) / _maxSpeed;
			var predictedTarget : Vector2D = target.position.subtract2(target.velocity.multiply(lookAheadTime));
			flee(predictedTarget);
		}

		public function wander() : void
		{
			var center : Vector2D = velocity.clone2().normalize2().multiply(_wanderDistance);
			var offset : Vector2D = new Vector2D(0);
			offset.length = _wanderRadius;
			offset.angle = _wanderAngle;
			_wanderAngle += Math.random() * _wanderRange - _wanderRange * .5;
			var force : Vector2D = center.add2(offset);
			_steeringForce = _steeringForce.add2(force);
		}

		// public function avoid(circles:Array):void
		// {
		// for(var i:int = 0; i < circles.length; i++)
		// {
		// var circle:Circle = circles[i] as Circle;
		// var heading:Vector2D = _velocity.clone().normalize();
		//
		//		        //  vector between circle and vehicle:
		// var difference:Vector2D = circle.position.subtract(_position);
		// var dotProd:Number = difference.dotProd(heading);
		//
		//		        //  if circle is in front of vehicle...
		// if(dotProd > 0)
		// {
		//		            //  vector to represent "feeler" arm
		// var feeler:Vector2D = heading.multiply(_avoidDistance);
		//		            //  project difference vector onto feeler
		// var projection:Vector2D = heading.multiply(dotProd);
		//		            //  distance from circle to feeler
		// var dist:Number = projection.subtract(difference).length;
		//
		//		            //  if feeler intersects circle (plus buffer),
		//		            //  and projection is less than feeler length,
		//		            //  we will collide, so need to steer
		// if(dist < circle.radius + _avoidBuffer &&
		// projection.length < feeler.length)
		// {
		//		                //  calculate a force +/- 90 degrees from vector to circle
		// var force:Vector2D = heading.multiply(_maxSpeed);
		// force.angle += difference.sign(_velocity) * Math.PI / 2;
		//
		//		                //  scale this force by distance to circle.
		//		                //  the further away, the smaller the force
		// force = force.multiply(1.0 - projection.length /
		// feeler.length);
		//
		//		                //  add to steering force
		// _steeringForce = _steeringForce.add(force);
		//
		//		                //  braking force
		// _velocity = _velocity.multiply(projection.length / feeler.length);
		// }
		// }
		// }
		// }
		private var isFollwPath : Boolean = false;
		private var pathData : Vector.<Vector2D>;

		public function followPath(pathData : Vector.<Vector2D>) : void
		{
			if (pathData == null) return;
			isFollwPath = true;
			this.pathData = pathData;

			var wayPoint : Vector2D = this.pathData.shift();
			if (this.pathData.length == 0) isFollwPath = false;
			seek(wayPoint);
		}

		public function flock(moveDriveList : Array) : void
		{
			var averageVelocity : Vector2D = _velocity.clone2();
			var averagePosition : Vector2D = new Vector2D();
			var inSightCount : int = 0;
			for (var i : int = 0; i < moveDriveList.length; i++)
			{
				var moveDrive : MoveDrive = moveDriveList[i] as MoveDrive;
				if (moveDrive != this && inSight(moveDrive))
				{
					averageVelocity = averageVelocity.add2(moveDrive.velocity);
					averagePosition = averagePosition.add2(moveDrive.position);
					if (tooClose(moveDrive)) flee(moveDrive.position);
					inSightCount++;
				}
			}
			if (inSightCount > 0)
			{
				averageVelocity = averageVelocity.divide(inSightCount);
				averagePosition = averagePosition.divide(inSightCount);
				seek(averagePosition);
				_steeringForce.add2(averageVelocity.subtract2(_velocity));
			}
		}

		public function inSight(moveDrive : MoveDrive) : Boolean
		{
			if (_position.dist(moveDrive.position) > _inSightDist) return false;
			var heading : Vector2D = _velocity.clone2().normalize2();
			var difference : Vector2D = moveDrive.position.subtract2(_position);
			var dotProd : Number = difference.dotProd(heading);

			if (dotProd < 0) return false;
			return true;
		}

		public function tooClose(moveDrive : MoveDrive) : Boolean
		{
			return _position.dist(moveDrive.position) < _tooCloseDist;
		}
	}
}
