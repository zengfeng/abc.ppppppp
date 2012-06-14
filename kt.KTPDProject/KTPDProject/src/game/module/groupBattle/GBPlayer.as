package game.module.groupBattle
{
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import game.core.avatar.AvatarManager;
	import game.core.avatar.AvatarType;
	import game.module.groupBattle.ui.UiPlayerItem;
	import game.module.map.animal.PlayerAnimal;
	import game.module.map.animalManagers.PlayerManager;
	import game.module.map.animalstruct.PlayerStruct;


	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-14 ����3:49:04
	 *  玩家(蜀山论剑)
	 */
	public class GBPlayer
	{
		function GBPlayer(playerStruct : PlayerStruct) : void
		{
			this.playerStruct = playerStruct;
			if (playerStruct) playerStruct.addUpdateCall(playerStructUpdate);
		}

		protected function playerStructUpdate(playerStruct : PlayerStruct) : void
		{
			if (playerStruct)
			{
				setTimeout(setName, 200, playerStruct.name, colorStr);
			}
		}

		/** 玩家(地图)数据结构管理 */
		private var playerManager : PlayerManager = PlayerManager.instance;
		/** 玩家(地图)数据结构 */
		public var playerStruct : PlayerStruct;
		/** 玩家(地图)动物 */
		protected var _animal : PlayerAnimal;
		/** 玩家列表项 */
		public var playerItem : UiPlayerItem;
		/** 组 */
		public var group : GBGroup;
		/** 玩家状态 */
		public var _playerStatus : int = GBPlayerStatus.WAIT;
		/** 连杀数 */
		protected var _killCount : int = 0;
		/** 最高连杀数 */
		protected var _maxKillCount : int = 0;
		/** 胜利场数 */
		protected var _winCount : uint = 0;
		/** 失败场数 */
		protected var _loseCount : uint = 0;
		/** 银币 */
		protected var _silver : int = 0;
		/** 玄铁 */
		protected var _darksteel : int = 0;

		/** 获取Id */
		public function get id() : uint
		{
			if (playerStruct)
			{
				return  playerStruct.id;
			}
			return 0;
		}

		public function set id(value : uint) : void
		{
			if (playerStruct == null)
			{
				playerStruct = new PlayerStruct();
			}
			playerStruct.id = value;
		}

		/** (设置/获取)组Id */
		public function get groupId() : uint
		{
			if (group)
			{
				return group.id;
			}
			return 0;
		}

		public function set groupId(groupId : uint) : void
		{
			group = GBUtil.getGroup(groupId);
			group.addPlayer(this);
		}

		public function get groupAB() : int
		{
			return group.groupAB;
		}

		/** 位置y */
		public function get x() : int
		{
			if (animal)
			{
				return animal.x;
			}
			return playerStruct.x;
		}

		public function set x(value : int) : void
		{
			if (animal)
			{
				animal.x = value;
			}
			playerStruct.x = x;
		}

		/** 位置y */
		public function get y() : int
		{
			if (animal)
			{
				return animal.y;
			}
			return playerStruct.y;
		}

		public function set y(value : int) : void
		{
			if (animal)
			{
				animal.y = value;
			}
			playerStruct.y = y;
		}

		/** 玩家状态 */
		public function get playerName() : String
		{
			if (playerStruct)
			{
				return playerStruct.name;
			}
			return "玩家名称";
		}

		public function set playerName(value : String) : void
		{
			if (playerStruct == null)
			{
				id = 0;
			}
			playerStruct.name = value;
		}

		public function get color() : int
		{
			if (group) return group.color;
			return 0;
		}

		public function get colorStr() : String
		{
			if (group) return group.colorStr;
			return "#000000";
		}

		/** 玩家状态 */
		public function get playerStatus() : int
		{
			return _playerStatus;
		}

		public function set playerStatus(value : int) : void
		{
			if (_playerStatus == GBPlayerStatus.DIE && value != GBPlayerStatus.DIE)
			{
				if (animal) animal.revive();
			}

			_playerStatus = value;
			if (_playerStatus != GBPlayerStatus.VS)
			{
				GBUtil.setVSPositionEmpty(vsPosition, groupAB);
			}

			switch(_playerStatus)
			{
				// 等待状态
				case GBPlayerStatus.WAIT:
					statusWait();
					break;
				// 在交战区处于休息状态
				case GBPlayerStatus.REST:
					statusRest();
					break;
				// 死亡状态
				case GBPlayerStatus.DIE:
					statusDie();
					break;
				// 战斗状态
				case GBPlayerStatus.VS:
					statusVS();
					break;
				// 移动状态
				case GBPlayerStatus.MOVE:
					toAreaRest();
					break;
				default:
					toAreaRest();
					break;
			}

			if (playerItem)
			{
				playerItem.status = _playerStatus;
			}
		}

		public function setPlayerStatus(status : int, time : int) : void
		{
			playerStatus = status;
			time;
		}

		public function updateStatus() : void
		{
			playerStatus = playerStatus;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 等待状态 */
		protected function statusWait() : void
		{
			if (GBUtil.isInAreaRest(x, y) == true)
			{
				// 站立
				stand();
			}
			else
			{
				toAreaRest();
			}
		}

		/** 在交战区处于休息状态 */
		protected function statusRest() : void
		{
			if (GBUtil.isInAreaRest(x, y) == true)
			{
				// 打坐
				practic();
			}
			else
			{
				toAreaRest();
			}
		}

		/** 死亡状态 */
		protected function statusDie() : void
		{
			toAreaGroup();
			// 死亡
			die();
			stand();
		}

		/** 战斗状态 */
		protected function statusVS() : void
		{
			if (GBUtil.isInAreaVS(x, y) == true )
			{
				// 攻击
				attack();
			}
			else
			{
				toAreaVS();
			}
		}

		/** 停止走路回调 */
		public function stopMoveCall(animal : PlayerAnimal) : void
		{
			switch(_playerStatus)
			{
				case GBPlayerStatus.VS:
					attack();
					break;
				case GBPlayerStatus.REST:
					practic();
					break;
				case GBPlayerStatus.WAIT:
					stand();
					break;
			}
		}

		public var vsPosition : Point;

		/** 去对决区域 */
		public function toAreaVS() : void
		{
			if (GBUtil.isInAreaVS(x, y) == false && animal != null && vsPosition)
			{
				// 走路
				walk(vsPosition.x, vsPosition.y);
			}
		}

		/** 去休息区域 */
		public function toAreaRest() : void
		{
			if (playerStatus == GBPlayerStatus.VS) return;
			if (GBUtil.isInAreaRest(x, y) == false)
			{
				var point : Point = GBUtil.getRandomPositionRest(groupAB);
				// 走路
				walk(point.x, point.y);
			}
		}

		/** 去大本营区域 */
		public function toAreaGroup() : void
		{
			var point : Point = getRandomPositionGroup();
			x = point.x;
			y = point.y;
			// 站立
//			stand();
		}

		/** 站立 */
		public function stand() : void
		{
			if (animal)
			{
				if ( groupAB == GBSystem.GROUP_A_ID )
				{
					animal.standDirection(20, 0, 10, 0);
				}
				else
				{
					animal.standDirection(0, 0, 10, 0);
				}
			}
		}

		/** 走路 */
		public function walk(x : int, y : int) : void
		{
			if (animal)
			{
				animal.autoWalk(x, y);
			}
		}

		/** 打坐 */
		public function practic() : void
		{
			if (animal)
			{
				animal.sitdownAction();
			}
		}

		/** 死亡 */
		public function die() : void
		{
			if (animal)
			{
				animal.die();
			}
		}

		/** 攻击 */
		public function attack() : void
		{
			if (animal)
			{
				if ( groupAB == GBSystem.GROUP_A_ID )
				{
					animal.fontSkillAttackAction();
//					animal.fontAttackAction();
				}
				else
				{
					animal.backSkillAttackAction();
//					animal.backAttackAction();
				}
			}
		}

		/** 随机获得本营区域点 */
		protected function getRandomPositionGroup() : Point
		{
			return groupAB == GBSystem.GROUP_A_ID ? GBUtil.getRandomPositionGroupA() : GBUtil.getRandomPositionGroupB();
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 退出 */
		public function quit() : void
		{
			stand();
			if (animal)
			{
				animal.removeStopMoveCallFun(stopMoveCall);
				animal.quit();
			}

			if (playerItem) playerItem.quit();
			if (playerStruct) playerStruct.removeUpdateCall(playerStructUpdate);
			playerManager.removePlayer(id);
			group.removePlayer(id, true);
			GBUtil.setVSPositionEmpty(vsPosition, groupAB);
		}

		public function get animal() : PlayerAnimal
		{
			return _animal;
		}

		public function set animal(animal : PlayerAnimal) : void
		{
			_animal = animal;
			if (_animal && _animal.avatar)
			{
				_animal.addstopMoveCallFun(stopMoveCall);
				setName(playerStruct.name, colorStr);
			}
		}

		public function setName(name : String, color : String = "#ffee00") : void
		{
			if (animal) animal.setName(name, color);
		}

		/** 连杀数 */
		public function get killCount() : uint
		{
			return _killCount;
		}

		public function set killCount(killCount : uint) : void
		{
			_killCount = killCount;
		}

		/** 最高连杀数 */
		public function get maxKillCount() : uint
		{
			return _maxKillCount;
		}

		public function set maxKillCount(maxKillCount : uint) : void
		{
			_maxKillCount = maxKillCount;
			if (playerItem)
			{
				playerItem.maxKill = maxKillCount;
			}
		}

		/** 胜利场数 */
		public function get winCount() : uint
		{
			return _winCount;
		}

		public function set winCount(winCount : uint) : void
		{
			_winCount = winCount;
		}

		/** 失败场数 */
		public function get loseCount() : uint
		{
			return _loseCount;
		}

		public function set loseCount(loseCount : uint) : void
		{
			_loseCount = loseCount;
		}

		/** 银币 */
		public function get silver() : int
		{
			return _silver;
		}

		public function set silver(value : int) : void
		{
			_silver = value;
		}

		/** 玄铁 */
		public function get darksteel() : int
		{
			return _darksteel;
		}

		public function set darksteel(value : int) : void
		{
			_darksteel = value;
		}
	}
}
