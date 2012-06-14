package game.module.map.animal
{
	import game.core.avatar.AvatarThumb;
	import game.module.map.MapController;
	import game.module.map.MapSystem;
	import game.module.map.Path;
	import game.module.map.animalstruct.AbstractStruct;
	import game.module.map.army.ArmyGroup;
	import game.module.map.army.IArmy;
	import game.module.map.layers.ElementLayer;
	import game.module.map.utils.EnterFrameListener;

	import gameui.manager.UIManager;

	import com.commUI.alert.Alert;
	import com.signalbus.Signal;
	import com.utils.FilterUtils;
	import com.utils.Vector2D;
	import com.utils.dataStruct.LinkList;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.getTimer;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-30 ����10:30:18
	 * 动物。人是动物，怪也是动物。一切皆是生灵
	 */
	public class Animal extends AnimalAction implements IAnimal
	{
		public var signalUpdatePosition : Signal = new Signal();
		public var signalQuit : Signal = new Signal();
		/** 动物管理器 */
		protected var animalManager : AnimalManager = AnimalManager.instance;
		// /** Avatar */
		// protected var _avatar : AvatarThumb;
		/** 数据结构 */
		protected var _struct : AbstractStruct;
		/** 链表节点 */
		public var linkNode : AnimationLinkNode;
		/** 路径数据 */
		public var pathData : Vector.<Vector2D> = new Vector.<Vector2D>();
		/** 移动速度 */
		protected var _speed : int = 20;
		/** 现在位置 */
		protected var _position : Vector2D = new Vector2D();
		/** 上一次目标位置 */
		protected var preTargetPostion : Vector2D = new Vector2D();
		/** 目标位置 */
		protected var targetPosition : Vector2D = new Vector2D();
		/** 去目标的路程向量 */
		protected var toTargetDirection : Vector2D = new Vector2D();
		/** 预计时间 */
		protected var et : int;
		/** 开始时间 */
		public var startTime : int;
		/** 状态 */
		public var _status : String = AnimalStatus.STAND;
		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 阵营 */
		public var _armyGroup : ArmyGroup;
		/** 敌方目标 */
		public var _enemy : Animal;
		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		protected static var linkList : LinkList = new LinkList();
		protected static var elementLayer : ElementLayer = MapController.instance.elementLayer;

		function Animal(avatar : AvatarThumb, struct : AbstractStruct) : void
		{
			super(avatar);
			// _avatar = avatar;
			_struct = struct;
			_speed = struct.speed;
			init();
		}

		protected function init() : void
		{
			linkNode = new AnimationLinkNode();
			linkNode.data = avatar;
			if (initCheckIsAddAvatar() == true && visible == true)
			{
				var index : int = linkList.sortAdd(linkNode);
				index += elementLayer.getMaxIndexGate() + 1;
				try
				{
					if (elementLayer) elementLayer.addChildAt(avatar, index);
				}
				catch(error : Error)
				{
					trace(index);
				}
			}
			// var str:String = "index = " + index + "  avatar.y =  " + avatar.y + "   " + struct.name + "   elementLayer.getMaxIndexGate() = " + elementLayer.getMaxIndexGate();
			// testStrIndex(str);
		}

		/** 初始化前检查是否添加AVATAR到地图 */
		protected function initCheckIsAddAvatar() : Boolean
		{
			return true;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		protected var _visible : Boolean = true;

		public function get visible() : Boolean
		{
			return _visible;
		}

		public function set visible(value : Boolean) : void
		{
			if (_visible == value) return;
			_visible = value;
			if (_visible == true)
			{
				var index : int = linkList.sortAdd(linkNode);
				index += elementLayer.getMaxIndexGate() + 1;
				elementLayer.addChildAt(avatar, index);
			}
			else
			{
				linkList.removeNode(linkNode);
				if (avatar.parent) avatar.parent.removeChild(avatar);
			}
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		public function show() : void
		{
			avatar.visible = true;
		}

		public function hide() : void
		{
			avatar.visible = false;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 修炼 */
		public function  practic() : void
		{
		}

		/** 站立 */
		public function stand() : void
		{
			standAction();
			status = AnimalStatus.STAND;
			directionFromStand = true;
		}

		private var directionFromStand : Boolean = true;

		/** 朝向 */
		public function direction(x : int, y : int) : void
		{
			if (x == avatar.x && y == avatar.y) return;

			// var x_distance : Number = avatar.x - x;
			// var y_distance : Number = avatar.y - y;
			// var angle : Number = Math.atan2(y_distance, x_distance) * 180 / Math.PI;
			// trace(angle + "  " + x + " " + y + "    " + avatar.x + " " + avatar.y);
			// var v1 : Vector2D = new Vector2D(x, y);
			// var v2 : Vector2D = new Vector2D(avatar.x, avatar.y);
			// var angleBetween : Number = Vector2D.angleBetween(v1, v2);
			// trace(angleBetween + "   v1 = " + v1+ "   v2 = " + v2 + " (x,y) " + x + " " + y  + "      "+ avatar.x  + " "+ avatar.y);
			//
			// if (angleBetween < 0.008 && directionFromStand == false)
			// {
			// return;
			// }
			avatar.run(x, y, avatar.x, avatar.y);
		}

		/** 表情姿势动作 */
		public function motion() : void
		{
		}

		/** 设置位置, 和moveTo的区别是不会有走路动作 */
		public function setPosition(x : int, y : int) : void
		{
			if (avatar.x == x && avatar.y == y) return;
			position.x = x;
			position.y = y;
			avatar.moveTo(x, y);
			signalUpdatePosition.dispatch(x, y);
		}

		/** 移动到,和setPostion的区别是会有走路动作 */
		public function moveTo(x : int, y : int, isRunBeFollow : Boolean = true) : void
		{
			if (avatar.x == x && avatar.y == y) return;
			avatar.moveTo(x, y);
			runMoveCallFun();
			signalUpdatePosition.dispatch(x, y);
		}

		/** 停止移动 */
		public function stopMove() : void
		{
			if (pathData)
			{
				while (pathData.length > 0)
				{
					pathData.shift();
				}
			}
			EnterFrameListener.remove(updateMove);
			// stage.removeEventListener(Event.ENTER_FRAME, updateMove);
			stand();
			runStopMoveCallFun();
			isMoveing = false;
		}

		/** 死亡 */
		public function die() : void
		{
			avatar.die();
			status = AnimalStatus.DIE;
		}

		/** 复活 */
		public function revive() : void
		{
		}

		/** 退出 */
		public function quit() : void
		{
			stopMove();
			signalQuit.dispatch();
			animalManager.removeAnimal(id, animalType, true);
			status = AnimalStatus.QUIT;
			if (avatar) avatar.player.filters = [];
			// 清理跟随者
			clearFollower();
			if (linkNode != null && visible == true) linkList.removeNode(linkNode);
			linkNode = null;
			clearStopMoveCallFun();
			clearMoveCallFun();
		}

		/** 拐弯处 */
		public function turn(x : int, y : int) : void
		{
		}

		/** 走路 */
		public function walk(toX : int, toY : int) : void
		{
			if (x == toX && y == toY) arriveComplete();
			arrive(toX, toY);
		}

		public function walk2() : void
		{
			if (pathData.length > 0)
			{
				pathData.pop();
				pathData.push(new Vector2D(struct.x, struct.y));
			}
			else
			{
				arrive(struct.x, struct.y);
			}

			pathData.push(new Vector2D(struct.toX, struct.toY));
			startArrive();
		}

		/** 开始走路 */
		protected function startWalk(toX : int, toY : int) : void
		{
			pathData = Path.find(x, y, toX, toY);
			if (pathData == null || pathData.length == 0) return;
			// if (pathData.length > 2)
			// {
			// var dist : Number = position.dist(pathData[0]);
			// if (dist < 100)
			// {
			// pathData.shift();
			// }
			// }

			// pathData = new Vector.<Vector2D>();
			// for (var i : int = 0; i <= 4; i++)
			// {
			//                // //   var placeStruct : MCEPlaceStruct = MCEConfig.getPlace(i);
			// var placeStruct : Point = ConvoyConfig.getWayPoint(i);
			// pathData.push(new Vector2D(placeStruct.x, placeStruct.y));
			//                //  if (i == 100)
			//                //  {
			//                //  moveTo(placeStruct.x, placeStruct.y);
			//                //  }
			// }
			if (MapSystem.debugShowPath == true)
			{
				createPath();
			}

			followPath(pathData);
		}

		/** 自动控制走路 */
		public function autoWalk(toX : int, toY : int) : void
		{
			startWalk(toX, toY);
		}

		public function createPath() : void
		{
		}

		/** 走路完成 */
		protected function walkComplete() : void
		{
		}

		/** 跟随路径 */
		public function followPath(pathData : Vector.<Vector2D>) : void
		{
			var point : Vector2D = pathData.shift();
			if (point == null) return;
			turn(point.x, point.y);
			arrive(point.x, point.y);

			// testTime = 0;
		}

		private var testTime : Number = 0;

		/** 追捕 */
		public function pursue(animal : Animal = null) : void
		{
		}

		/** 漫游 */
		public function wander() : void
		{
		}

		public var isMoveing : Boolean = false;

		public function startArrive() : void
		{
			if (isMoveing == true) return;
			var point : Vector2D = pathData.shift();
			if (point == null) return;
			turn(point.x, point.y);
			arrive(point.x, point.y);
		}

		/** 到达 */
		public function arrive(toX : int, toY : int) : void
		{
			if (animalFollowDrive) animalFollowDrive.moveStart(toX, toY);
			targetPosition.x = toX;
			targetPosition.y = toY;
			preTargetPostion.x = position.x;
			preTargetPostion.y = position.y;
			// 去目标的路程向量
			toTargetDirection = targetPosition.subtract2(position);
			// 离目标点距离
			var distance : Number = toTargetDirection.length;
			// 预计要多少时间到达目标点
			et = distance / speed * 100;
			// trace("到下一个路线点(" + toX + "," + toY + ")要的时间：" + et);
			// 朝向
			direction(toX, toY);
			directionFromStand = false;
			// 开始移动
			startTime = getTimer();
			isMoveing = true;
			EnterFrameListener.add(updateMove);
			// stage.addEventListener(Event.ENTER_FRAME, updateMove);
			status = AnimalStatus.MOVE;
		}

		/** 到达目标点 */
		public function arriveComplete() : void
		{
			if (pathData == null || pathData.length == 0)
			{
				stopMove();
				// 走路完成
				walkComplete();

				// trace("走完这段路要的时间：" + (getTimer() - testTime));
			}
			else
			{
				var point : Vector2D = pathData.shift();
				turn(point.x, point.y);
				arrive(point.x, point.y);
			}
		}

		/** 更新移动 */
		public function updateMove(event : Event = null) : void
		{
			// 运行时间
			var runtime : int = getTimer() - startTime;
			// 路程进度
			var progress : Number = runtime / et;
			if (progress < 1)
			{
				// _position = preTargetPostion.add(toTargetDirection.multiply(progress));
				_position.x = preTargetPostion.x + toTargetDirection.x * progress;
				_position.y = preTargetPostion.y + toTargetDirection.y * progress;
				moveTo(_position.x, _position.y, false);
				if (animalFollowDrive) animalFollowDrive.moveing(_position.x, _position.y);
			}
			else
			{
				moveTo(targetPosition.x, targetPosition.y, false);
				// if(animalFollowDrive)
				// {
				// animalFollowDrive.moveEnd();
				// }
				// 到达目标点
				arriveComplete();
			}

			updateChildIndex();
		}

		/** 传送 */
		public function transport(toX : int, toY : int) : void
		{
			stopMove();
			moveTo(toX, toY);
			if (animalFollowDrive)
			{
				animalFollowDrive.transport(toX, toY);
			}
		}

		// // // // // // // // ///////////////////////////////////////////////////////////////
		// 跟随 开始
		// // // // // // // // ///////////////////////////////////////////////////////////////
		public var animalFollowDrive : AnimalFollowDrive;
		private var followUp : Animal;

		public function addFollower(animalDown : Animal) : void
		{
			if (animalDown == null) return;
			if (animalFollowDrive == null) animalFollowDrive = new AnimalFollowDrive(this);
			animalFollowDrive.add(animalDown);
			animalDown.followUp = this;
		}

		public function removeFollower(animalDown : Animal, destruct : Boolean = false) : void
		{
			if (animalDown == null || animalFollowDrive == null) return;
			animalFollowDrive.remove(animalDown);
			if (destruct == false) animalDown.cancelFollowAnimal();
		}

		public function clearFollower() : void
		{
			if (animalFollowDrive == null) return;
			while (animalFollowDrive.list.length > 0)
			{
				removeFollower(animalFollowDrive.list.shift());
			}
			animalFollowDrive = null;
		}

		// // // // // // // // ///////////////////////////////////////////////////////////////
		public function followAnimal(animalUp : Animal) : void
		{
			if (animalUp == null) return;
			animalUp.addFollower(this);
			followUp = animalUp;
		}

		public function cancelFollowAnimal() : void
		{
			if (followUp)
			{
				followUp.removeFollower(this, true);
				followUp = null;
			}
		}

		// // // // // // // // ///////////////////////////////////////////////////////////////
		// 跟随 结束
		// // // // // // // // ///////////////////////////////////////////////////////////////
		/** 更新显示索引 */
		protected function updateChildIndex() : void
		{
			if (linkNode == null || visible == false) return;
			var isChange : Boolean = linkList.sortUpdate(linkNode);
			// trace(linkList.toString() + " _position.y =" + _position.y + "   position.y = " + position.y);
			// trace("isChange = " + isChange);
			if (isChange == false) return;
			var index : int = 0;
			if (linkNode.preNode)
			{
				index = elementLayer.getChildIndex(linkNode.preNode.data);
				if (index < elementLayer.numChildren - 1) index += 1;
			}
			else
			{
				index = elementLayer.getMinIndexGate() + 1;
			}
			elementLayer.setChildIndex(avatar, index);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 移动回调函数列表 */
		protected var moveCallFunList : Vector.<Function> = new Vector.<Function>();

		/** 添加移动回调函数 */
		public function addMoveCallFun(fun : Function) : void
		{
			if (fun == null) return;
			var index : int = moveCallFunList.indexOf(fun);
			if (index == -1)
			{
				moveCallFunList.push(fun);
			}
		}

		/** 移除移动回调函数 */
		public function removeMoveCallFun(fun : Function) : void
		{
			if (fun == null) return;
			var index : int = moveCallFunList.indexOf(fun);
			if (index != -1)
			{
				moveCallFunList.splice(index, 1);
			}
		}

		/** 清理移动回调函数 */
		public function clearMoveCallFun() : void
		{
			while (moveCallFunList.length > 0)
			{
				moveCallFunList.shift();
			}
		}

		/** 运行移动回调函数 */
		protected function runMoveCallFun() : void
		{
			for (var i : int = 0; i < moveCallFunList.length; i++)
			{
				moveCallFunList[i].apply(null, [this]);
			}
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 停止移动回调函数列表 */
		protected var stopMoveCallFunList : Vector.<Function> = new Vector.<Function>();

		/** 添加停止移动回调函数 */
		public function addstopMoveCallFun(fun : Function) : void
		{
			if (fun == null) return;
			var index : int = stopMoveCallFunList.indexOf(fun);
			if (index == -1)
			{
				stopMoveCallFunList.push(fun);
			}
		}

		/** 移除停止移除移动回调函数 */
		public function removeStopMoveCallFun(fun : Function) : void
		{
			if (fun == null) return;
			var index : int = stopMoveCallFunList.indexOf(fun);
			if (index != -1)
			{
				stopMoveCallFunList.splice(index, 1);
			}
		}

		/** 清理停止移除移动回调函数 */
		public function clearStopMoveCallFun() : void
		{
			while (stopMoveCallFunList.length > 0)
			{
				stopMoveCallFunList.shift();
			}
		}

		/** 运行停止移动回调函数 */
		protected function runStopMoveCallFun() : void
		{
			for (var i : int = 0; i < stopMoveCallFunList.length; i++)
			{
				stopMoveCallFunList[i].apply(null, [this]);
			}
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 战斗回调函数列表 */
		protected var battleCallFunList : Vector.<Function> = new Vector.<Function>();

		/** 添加战斗回调函数 */
		public function addBattleeCallFun(fun : Function) : void
		{
			if (fun == null) return;
			var index : int = battleCallFunList.indexOf(fun);
			if (index == -1)
			{
				battleCallFunList.push(fun);
			}
		}

		/** 停止战斗回调函数 */
		public function removeBattleCallFun(fun : Function) : void
		{
			if (fun == null) return;
			var index : int = battleCallFunList.indexOf(fun);
			if (index != -1)
			{
				battleCallFunList.splice(index, 1);
			}
		}

		/** 运行战斗回调函数 */
		protected function runBattleCallFun() : void
		{
			for (var i : int = 0; i < battleCallFunList.length; i++)
			{
				battleCallFunList[i].apply(null, [this]);
			}
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 数据结构里面的ID */
		public function get id() : int
		{
			if (struct == null) return 0;
			return struct.id;
		}

		/** 数据结构 */
		public function get struct() : AbstractStruct
		{
			return _struct;
		}

		/** 动物类型 */
		public function get animalType() : String
		{
			if (struct) return struct.animalType;
			return AnimalType.UNKNOW;
		}


		/** x坐标 */
		public function get x() : int
		{
			if (avatar == null) return 0;
			return avatar.x;
		}

		public function set x(value : int) : void
		{
			avatar.x = value;
		}

		/** y坐标 */
		public function get y() : int
		{
			if (avatar == null) return 0;
			return avatar.y;
		}

		public function set y(value : int) : void
		{
			avatar.y = value;
		}

		/** 获取位置 */
		public function get position() : Vector2D
		{
			_position.x = x;
			_position.y = y;
			return _position;
		}

		/** 移动速度 */
		public function get speed() : int
		{
			return _speed;
		}

		public function set speed(speed : int) : void
		{
			if (_speed == speed) return;
			_speed = speed;
			if (animalFollowDrive) animalFollowDrive.speed = _speed;
			if (isMoveing == true)
			{
				arrive(targetPosition.x, targetPosition.y);
			}
		}

		public function setSpeed(value : Number) : void
		{
			_speed = value;
		}

		/** 状态 */
		public function get status() : String
		{
			return _status;
		}

		public function set status(status : String) : void
		{
			_status = status;
		}

		/** 场景舞台 */
		public function get stage() : Stage
		{
			return UIManager.stage;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		public function setName(name : String, color : String = "#ffee00") : void
		{
			if (avatar) avatar.setName(name, color);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 添加死亡滤镜 */
		public function addDieFilter() : void
		{
			if (avatar == null) return;
			FilterUtils.addFilter(avatar.player, FilterUtils.dieFilter, ColorMatrixFilter);
		}

		/** 去除死亡滤镜 */
		public function removeDieFilter() : void
		{
			if (avatar == null) return;
			FilterUtils.removeFilter(avatar.player, ColorMatrixFilter);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		private static var _testStrIndex : String = "";
		private static var alert : Alert;

		public static function testStrIndex(str : String) : void
		{
			_testStrIndex += str + "\n";
			trace(_testStrIndex);
			if (alert == null) alert = Alert.show(_testStrIndex, "", 9, null, 0, true, false, 500, 400);
			alert.text = _testStrIndex + "\n" + linkList.toString();
		}
	}
}
