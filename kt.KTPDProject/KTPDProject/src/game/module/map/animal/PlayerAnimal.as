package game.module.map.animal
{
	import game.manager.ViewManager;

	import flash.events.Event;

	import game.core.avatar.AvatarManager;
	import game.core.avatar.AvatarPlayer;
	import game.core.avatar.AvatarThumb;
	import game.core.avatar.AvatarType;
	import game.module.map.MapSystem;
	import game.module.map.animalstruct.AbstractStruct;
	import game.module.map.animalstruct.PlayerStruct;
	import game.module.map.playerVisible.PlayerTolimitManager;
	import game.module.map.playerVisible.PlayerVisibleLinkNode;
	import game.module.map.utils.PlayerModelUtil;

	import com.utils.Vector2D;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-30 ����11:20:05
	 */
	public class PlayerAnimal extends Animal implements IAnimal
	{
		/** 显示链表节点 */
		protected var visibleLinkNode : PlayerVisibleLinkNode;
		/** 玩家显示上限管理 */
		protected var playerTolimitManager : PlayerTolimitManager = PlayerTolimitManager.instance;

		function PlayerAnimal(avatar : AvatarThumb, struct : AbstractStruct) : void
		{
			super(avatar, struct);
			avatar.addEventListener("clickPlayer", onClickPlayer);
			if ((struct.toWalkedTime > 0 || struct.startWalkTime > 0) && struct.animalType == AnimalType.PLAYER)
			{
				// Alert.show("struct.toWalkedTime = " + struct.toWalkedTime);
				// Alert.show(playerStruct.model + " " + (playerStruct.avatarVer != playerStruct.newAvatarVer));
				if (playerStruct.model > 0 && playerStruct.model < 10)
				{
					// if (playerStruct.avatarVer != playerStruct.newAvatarVer)
					// {
					// return;
					// }
					_speed = playerStruct.model > 4 ? 100 : 4;
				}
				arrive(struct.toX, struct.toY);
				startTime = struct.startWalkTime > 0 ? struct.startWalkTime : MapSystem.changeMapTime - struct.toWalkedTime - 1500;
				struct.toWalkedTime = 0;
				updateMove();

				if (playerStruct.model == 20)
				{
					sitdownAction();
				}
				// Common.game_server.socketDelay
			}
		}

		private function onClickPlayer(event : Event) : void
		{
			if (!ViewManager.otherPlayerPanel) return;

			var obj : Object = new Object();
			obj["id"] = playerStruct.id;
			obj["name"] = playerStruct.name;
			obj["heroId"] = playerStruct.heroId;
			obj["level"] = playerStruct.level;
			ViewManager.otherPlayerPanel.source = obj;
			ViewManager.otherPlayerPanel.show();
		}

		override protected function init() : void
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
					//trace(index);
				}
			}
			// var str:String = "index = " + index + "  avatar.y =  " + avatar.y + "   " + struct.name + "   elementLayer.getMaxIndexGate() = " + elementLayer.getMaxIndexGate();
			// testStrIndex(str);
		}

		/** 初始化前检查是否添加AVATAR到地图 */
		override protected function initCheckIsAddAvatar() : Boolean
		{
			if (playerTolimitManager.enable == true && this is SelfPlayerAnimal == false)
			{
				_visible = false;
				visibleLinkNode = new PlayerVisibleLinkNode();
				visibleLinkNode.data = this;
				playerTolimitManager.linkList.sortAdd(visibleLinkNode);
				return false;
			}
			return true;
		}

		override public function set visible(value : Boolean) : void
		{
			if (_visible == value) return;
			super.visible = value;
			// 设置显示关联动物
			setVisibleRelevance(value);

			if (value == true)
			{
				PlayerTolimitManager.playerNum++;
				playerStruct.checkVer();
			}
			else
			{
				PlayerTolimitManager.playerNum--;
			}
		}

		override public function quit() : void
		{
			if (playerTolimitManager.enable == true && this is SelfPlayerAnimal == false)
			{
				if (visibleLinkNode) playerTolimitManager.linkList.removeNode(visibleLinkNode);
				if (visible == true) PlayerTolimitManager.playerNum--;
			}
			avatar.removeEventListener("clickPlayer", onClickPlayer);
			super.quit();
		}

		/** 移动到,和setPostion的区别是会有走路动作 */
		override public function moveTo(x : int, y : int, isRunBeFollow : Boolean = true) : void
		{
			super.moveTo(x, y, isRunBeFollow);

			if (playerTolimitManager.enable == true && visibleLinkNode)
			{
				playerTolimitManager.linkList.sortUpdate(visibleLinkNode);
			}
		}

		private var zuoBiNormalSpeed : Number;
		private var isSetZuoBiSpeed : Boolean = false;

		override public function walk2() : void
		{
			// Logger.info("walk2" + pathData.length);
			// arrive(struct.toX, struct.toY);
			// return;
			// //trace(pathData.length);
			if (pathData.length > 0)
			{
				pathData.pop();
				if (pathData.length > 0)
				{
					pathData.pop();
				}
				if (pathData.length > 0)
				{
					pathData.pop();
				}
				pathData.push(new Vector2D(struct.x, struct.y));
			}
			else
			{
				arrive(struct.x, struct.y);
			}

			// if (pathData.length > 10 && isSetZuoBiSpeed == false)
			// {
			// isSetZuoBiSpeed = true;
			// zuoBiNormalSpeed = struct.speed;
			// speed = struct.speed * 7;
			// }
			// else if (pathData.length < 3 && isSetZuoBiSpeed == true)
			// {
			// speed = zuoBiNormalSpeed;
			// isSetZuoBiSpeed = false;
			// }

			pathData.push(new Vector2D(struct.toX, struct.toY));
			startArrive();
		}

		public function initAvatar() : void
		{
			if (playerStruct == null || avatar == null) return;
			avatar.setName(playerStruct.name, playerStruct.colorStr);
			var cloth : int = PlayerModelUtil.getAvatarCloth(playerStruct.model, playerStruct.cloth);
			cloth < 20 ? avatar.initAvatar(playerStruct.heroId,cloth,AvatarType.PLAYER_RUN) : avatar.changeModel(cloth);
			if (playerStruct.model == 20)
			{
				sitdownAction();
			}

			// if (playerStruct.heroId != 0) avatar.setId(playerStruct.heroId);
			// avatar.setName(playerStruct.name, playerStruct.colorStr);
			// var cloth:int = PlayerModelUtil.getAvatarCloth( playerStruct.model,playerStruct.cloth );
			// var heroId : int = cloth < 20 ? playerStruct.heroId : 0;
			// avatar.changeCloth(cloth, heroId);
		}

		public function updateAvatar() : void
		{
			var cloth : int = PlayerModelUtil.getAvatarCloth(playerStruct.model, playerStruct.cloth);
			cloth < 20 ? avatar.changeCloth(cloth, playerStruct.heroId) : avatar.changeModel(cloth);
			if (playerStruct.model == 20)
			{
				sitdownAction();
			}
		}

		/** 玩家数据结构 */
		public function get playerStruct() : PlayerStruct
		{
			return _struct as PlayerStruct;
		}

		/** 修炼 */
		override public function  practic() : void
		{
			stopMove();
			avatar.setAction(AvatarManager.PRACTICE);
			status = AnimalStatus.PRACTICE;
		}

		/** 死亡 */
		override public function die() : void
		{
			status = AnimalStatus.DIE;
			addDieFilter();
		}

		/** 复活 */
		override public function revive() : void
		{
			removeDieFilter();
		}

		// // // // // // // // // /////////////////////////////////////////
		// 显示关联动物
		// // // // // // // // // /////////////////////////////////////////
		/** 显示关联动物列表 */
		protected var visibleRelevanceList : Vector.<Animal>;

		/** 添加显示关联动物 */
		public function addVisibleRelevance(animal : Animal) : void
		{
			if (animal == null) return;
			if (visibleRelevanceList == null) visibleRelevanceList = new Vector.<Animal>();
			var index : int = visibleRelevanceList.indexOf(animal);
			if (index == -1)
			{
				visibleRelevanceList.push(animal);
			}
		}

		/** 移除显示关联动物 */
		public function removeVisibleRelevance(animal : Animal) : void
		{
			if (animal == null || visibleRelevanceList == null || visibleRelevanceList.length == 0) return;
			var index : int = visibleRelevanceList.indexOf(animal);
			if (index != -1)
			{
				visibleRelevanceList.splice(index, 1);
			}
		}

		/** 设置显示关联动物 */
		public function setVisibleRelevance(visible : Boolean) : void
		{
			if (visibleRelevanceList == null || visibleRelevanceList.length == 0) return;
			var animal : Animal;
			for (var i : int = 0; i < visibleRelevanceList.length; i++)
			{
				animal = visibleRelevanceList[i];
				animal.visible = visible;
			}
		}
	}
}
