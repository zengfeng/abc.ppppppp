package game.module.map.army {
	import flash.geom.Point;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-6 ����8:47:11
	 */
	public class ArmyGroup {
		/** 组ID */
		public var id : uint;
		/** 组名 */
		public var name : String;
		/** 敌人管理 */
		public var manager : ArmyManager;
		/** 成员列表 */
		public var list : Vector.<IArmy> = new Vector.<IArmy>();
		/** 敌对组列表 */
		public var enemyGroupList : Vector.<ArmyGroup> = new Vector.<ArmyGroup>();

		public function ArmyGroup(manager : ArmyManager, id : uint = 0, name : String = "") {
			this.manager = manager;
			this.id = id;
			this.name = name;
			if (this.manager) this.manager.addGroup(this);
		}

		/** 添加指定成员 */
		public function add(army : IArmy) : void {
			if (army == null) {
				//trace("提示: PatrolGroup(" + name + ") 在加入 Patrol 时出错");
				return;
			} else if (army.armyGroup && army.armyGroup != this) {
				army.armyGroup.remove(army);
			}
			army.armyGroup = this;

			var index : int = list.indexOf(army);
			if (index != -1) return;
			list.push(army);
		}

		/** 移除指定成员 */
		public function remove(army : IArmy) : void {
			var index : int = list.indexOf(army);
			if (index != -1) list.splice(index, 1);
		}

		/** 添加敌对组 */
		public function addEnemGroup(enemyGroup : ArmyGroup) : void {
			if (enemyGroup == null) return;
			if (enemyGroupList.indexOf(enemyGroup) == -1) {
				enemyGroupList.push(enemyGroup);
			}
		}

		/** 移除敌对组 */
		public function removeEnemGroup(enemyGroup : ArmyGroup) : void {
			if (enemyGroup == null) return;
			if (enemyGroupList.indexOf(enemyGroup) != -1) {
				enemyGroupList.splice(enemyGroupList.indexOf(enemyGroup), 1);
			}
		}

		/** 移除所有敌对组 */
		public function removeALLEnemGroup() : void {
			for (var i : int = 0; i < enemyGroupList.length; i++) {
				removeEnemGroup(enemyGroupList[i]);
			}
		}

		/** 清空成员 */
		public function clear() : void {
			for (var i : int = 0; i < list.length; i++) {
				remove(list[i]);
			}
			// 移除所有敌对组
			removeALLEnemGroup();
		}

		/** 开始 */
		public function start() : void {
			for (var i : int = 0; i < list.length; i++) {
				list[i].armyStart();
			}
		}

		/** 停止 */
		public function stop() : void {
			for (var i : int = 0; i < list.length; i++) {
				list[i].armyStop();
			}
		}

		/** 退出 */
		public function quit() : void {
			for (var i : int = 0; i < list.length; i++) {
				list[i].quit();
			}
			removeALLEnemGroup();
			if (manager) manager.removeGroup(this);
		}

		/** 排序 */
		public function sort(target : IArmy) : void {
			var sortFun : Function = function(a : IArmy, b : IArmy) : Number {
				var distanceA : Number = Point.distance(a.position, target.position);
				var distanceB : Number = Point.distance(b.position, target.position);
				if (distanceA < distanceB) {
					return -1;
				} else if (distanceA > distanceB) {
					return 1;
				}
				return 0;
			};
			list.sort(sortFun);
		}
	}
}
