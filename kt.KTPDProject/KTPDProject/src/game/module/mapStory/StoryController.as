package game.module.mapStory
{
	import com.commUI.alert.Alert;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import game.manager.SignalBusManager;
	import game.module.map.MapController;
	import game.module.map.MapSystem;
	import game.module.map.animal.Animal;
	import game.module.map.animal.AnimalDictionary;
	import game.module.map.animal.AnimalManager;
	import game.module.map.animal.AnimalType;
	import game.module.map.animal.EscortAnimal;
	import game.module.map.animal.SelfPlayerAnimal;
	import game.module.map.animal.SelfStoryAnimal;
	import game.module.map.animal.StoryAnimal;
	import game.module.map.animalstruct.AnimalStructUtil;
	import game.module.map.animalstruct.SelfStoryStruct;
	import game.module.map.animalstruct.StoryStruct;
	import game.module.map.utils.MapUtil;
	import log4a.Logger;



	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-9 ����11:45:03
	 * 剧情控制器
	 */
	public class StoryController
	{
		function StoryController(singleton : Singleton) : void
		{
			singleton;
		}

		/** 单例对像 */
		private static var _instance : StoryController;

		/** 获取单例对像 */
		public static function get instance() : StoryController
		{
			if (_instance == null)
			{
				_instance = new StoryController(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 控制器 */
		private static var _controller : MapController ;

		/** 控制器 */
		private static function get controller() : MapController
		{
			if (_controller == null)
			{
				_controller = MapController.instance;
			}
			return _controller;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 缓存剧情之前玩家是否绑定自己玩家 */
		private var mapMoveIsBindSelfPlayer : Boolean = true;
		/** 点击地图是否能控制自己玩家 */
		private var enMouseMove : Boolean = true;
		private var position : Point;
		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		private var animalManger : AnimalManager = AnimalManager.instance;

		public function get selfPlayer() : SelfPlayerAnimal
		{
			return animalManger.selfPlayer;
		}

		public function getNpc(npcId : int) : StoryAnimal
		{
			return animalManger.getStory(npcId);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 是否在剧情中 */
		public function get isIn() : Boolean
		{
			return _isIn;
		}

		private var _isIn : Boolean = false;

		/** 安装 */
		public function setup(mapId : int, x : int, y : int) : void
		{
			if (_isIn == true)
			{
				Logger.info("你妹呀 剧情还没退出 你Y就又开新的了");
				return;
			}
			
			if (mapId != 0 && mapId != MapUtil.getCurrentMapId())
			{
				Logger.info("你爷爷的 不能跨地图剧情 知道不");
			}
			_isIn = true;
			SignalBusManager.mapStoryIsEnter.dispatch(true);
			position = MapUtil.selfPlayerPosition;
			mapMoveIsBindSelfPlayer = MapSystem.mapMoveIsBindSelfPlayer;
			enMouseMove = controller.enMouseMove;
			controller.enMouseMove = false;
			setEscortVisible(false);
			setOtherAnimalVisible(false);
			mapMoveTo(x, y, 0);
			MapSystem.mapMoveIsBindSelfPlayer = false;
			controller.enMouseMove = false;
		}

		/** 退出 */
		public function quit() : void
		{
			_isIn = false;
			
			if(animalManger.selfStory)animalManger.selfStory.quit();
			var storyList:Vector.<StoryAnimal> = animalManger.storyList;
			for each(var animal:StoryAnimal in storyList)
			{
				animal.quit();
			}
			
			if (position) mapMoveTo(position.x, position.y, 0);
			setEscortVisible(true);
			setOtherAnimalVisible(true);
			MapSystem.mapMoveIsBindSelfPlayer = mapMoveIsBindSelfPlayer;
			controller.enMouseMove = enMouseMove;
			SignalBusManager.mapStoryIsEnter.dispatch(false);
		}

		public function setOtherAnimalVisible(value : Boolean) : void
		{
			var dic : Dictionary = AnimalDictionary.instance.dic;
			for (var animalType : String in dic)
			{
				if (animalType == AnimalType.STORY || animalType == AnimalType.SELF_STORY) continue;
				var typeDic : Dictionary = dic[animalType];
				for each (var animal:Animal in typeDic)
				{
					if (value == true)
					{
						animal.show();
					}
					else
					{
						animal.hide();
					}
				}
			}
		}

		/** 显示隐藏任务被护送者 */
		private function setEscortVisible(value : Boolean) : void
		{
			var escortList : Vector.<EscortAnimal> = animalManger.escortList;
			for (var i : int = 0; i < escortList.length; i++)
			{
				if (value == true)
				{
					escortList[i].show();
				}
				else
				{
					escortList[i].hide();
				}
			}
		}

		/** 设置地图的位置 */
		public function mapMoveTo(x : int, y : int, spendTime : Number = -1) : void
		{
			MapSystem.mapMoveTo(x, y, spendTime);
		}

		/** 获取自己 */
		public function get self() : SelfStoryAnimal
		{
			return animalManger.selfStory;
			;
		}

		/** 添加自己 */
		public function addSelf(x : int = 0, y : int = 0, childIndex : int = 1) : void
		{
			if (self == null)
			{
				var selfStoryStruct : SelfStoryStruct = AnimalStructUtil.cloneSelfPlayerToSelfStory(x, y);
				selfStoryStruct.childIndex = childIndex;
				animalManger.addAnimal(selfStoryStruct);
			}
			else
			{
				self.moveTo(x, y);
			}
		}

		/** 移除自己 */
		public function removeSelf() : void
		{
			if (self)
			{
				self.quit();
			}
		}

		/** 设置自己的位置 */
		public function selfMoveTo(toX : int, toY : int, flashStep : Boolean = false) : void
		{
			if (self)
			{
				if (flashStep == false)
				{
					self.walk(toX, toY);
				}
				else
				{
					self.moveTo(toX, toY);
				}
			}
		}

		/** 添加NPC */
		public function addNpc(npcId : uint, x : int = 0, y : int = 0, childIndex : int = 1) : StoryAnimal
		{
			var animal : StoryAnimal = animalManger.getStory(npcId);
			if (animal == null)
			{
				var struct : StoryStruct = AnimalStructUtil.cloneNpcToStory(npcId, x, y);
				struct.childIndex = childIndex;
				animal = animalManger.addAnimal(struct) as StoryAnimal;
			}
			else
			{
				animal.moveTo(x, y);
			}

			return animal;
		}

		/** 移除NPC */
		public function removeNpc(npcId : uint) : void
		{
			animalManger.removeAnimal(npcId, AnimalType.STORY);
		}

		/** npc移动到 */
		public function npcMoveTo(npcId : uint, toX : int, toY : int, flashStep : Boolean = false) : void
		{
			var animal : StoryAnimal = getNpc(npcId);
			if (animal)
			{
				if (flashStep == false)
				{
					animal.walk(toX, toY);
				}
				else
				{
					animal.moveTo(toX, toY);
				}
			}
		}
	}
}
class Singleton
{
}