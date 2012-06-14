package game.module.map.animal
{
	import game.core.avatar.AvatarThumb;
	import game.core.user.UserData;
	import game.module.map.MapController;
	import game.module.map.animalManagers.GlobalPlayerManager;
	import game.module.map.animalstruct.AbstractStruct;
	import game.module.map.animalstruct.AnimalStructUtil;
	import game.module.map.animalstruct.EscortStruct;
	import game.module.map.layers.ElementLayer;
	import game.module.map.playerVisible.OtherPlayerVisibleMananger;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-30 ����11:46:33
	 */
	public class AnimalManager
	{
		function AnimalManager(singleton : Singleton)
		{
			singleton;
		}

		/** 单例对像 */
		private static var _instance : AnimalManager;

		/** 获取单例对像 */
		static public function get instance() : AnimalManager
		{
			if (_instance == null)
			{
				_instance = new AnimalManager(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 地图控制器 */
		private var _controller : MapController;

		/** 地图元素层 */
		private var _elementLayer : ElementLayer;

		/** 地图控制器 */
		private function get controller() : MapController
		{
			if (_controller == null)
			{
				_controller = MapController.instance;
			}
			return _controller;
		}

        /** 地图元素层 */
        private function get elementLayer() : ElementLayer
        {
            if (_elementLayer == null)
            {
                _elementLayer = controller.elementLayer;
            }
            return _elementLayer;
        }

        /** 自己玩家ID */
        private var _selfPlayerId : int = -1;

        public function get selfPlayerId() : int
        {
            if (_selfPlayerId < 0)
            {
                _selfPlayerId = UserData.instance.playerId;
            }
            return _selfPlayerId;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 是否显示其他玩家管理 */
        private var otherPlayerVisibleManager : OtherPlayerVisibleMananger = OtherPlayerVisibleMananger.instance;
        /** 动物字典 */
        private var animalDictionary : AnimalDictionary = AnimalDictionary.instance;
        /** 自己玩家 */
        public var selfPlayer : SelfPlayerAnimal;
        /** 自己宠物 */
        public var selfPet : SelfPetAnimal;
        /** 自己剧情 */
        public var selfStory : SelfStoryAnimal;

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 添加动物 */
        public function addAnimal(struct : AbstractStruct) : Animal
        {
            var animal : Animal;
            if (struct == null) return null;
            if (otherPlayerVisibleManager.visible == false && struct.id != selfPlayerId && (struct.animalType == AnimalType.FOLLOWER||struct.animalType == AnimalType.PLAYER || struct.animalType == AnimalType.SELF_PET))
            {
                return null;
            }

            // 移除之前的
            removeAnimal(struct.id, struct.animalType);
            // 添加Avatar到元素层
            var avatar : AvatarThumb = elementLayer.addAnimal(struct);
            if (avatar == null) return null;
            // 创建动物
            switch(struct.animalType)
            {
                case AnimalType.SELF_PLAYER:
                    animal = new SelfPlayerAnimal(avatar, struct);
                    selfPlayer = animal as SelfPlayerAnimal;
                    break;
                case AnimalType.SELF_STORY:
                    animal = new SelfStoryAnimal(avatar, struct);
                    selfStory = animal as SelfStoryAnimal;
                    break;
                case AnimalType.SELF_PET:
                    animal = new SelfPetAnimal(avatar, struct);
                    selfPet = animal as SelfPetAnimal;
                    break;
                case AnimalType.PLAYER:
                    animal = new PlayerAnimal(avatar, struct);
                    break;
                case AnimalType.PET:
                    animal = new PetAnimal(avatar, struct);
                    break;
                case AnimalType.NPC:
                    animal = new NpcAnimal(avatar, struct);
                    break;
                case AnimalType.MONSTER:
                    animal = new MonsterAnimal(avatar, struct);
                    break;
                case AnimalType.ESCORT:
                    animal = new EscortAnimal(avatar, struct);
                    break;
                case AnimalType.STORY:
                    animal = new StoryAnimal(avatar, struct);
                    break;
                case AnimalType.DRAY:
                    animal = new DrayAnimal(avatar, struct);
                    break;
                case AnimalType.ROBBER:
                    animal = new RobberAnimal(avatar, struct);
                    break;
				case AnimalType.COUPLE:
					animal = new CoupleAnimal(avatar, struct);
					break;
                case AnimalType.FOLLOWER:
                	animal = new FollowerAnimal(avatar, struct);
                    break;
            }
            animalDictionary.add(animal);
            switch(struct.animalType)
            {
                case AnimalType.SELF_PLAYER:
                case AnimalType.PLAYER:
                GlobalPlayerManager.instance.playerAnimalInstall(struct.id);
                break;
            }
            return animal;
        }

		/** 移除动物 */
		public function removeAnimal(id : uint, animalType : String, destruct : Boolean = false) : void
		{
			elementLayer.removeAnimal(id, animalType);
			var animal : Animal = getAnimal(id, animalType);
			if (animal)
			{
				if (destruct == false) animal.quit();
				animalDictionary.remove(id, animalType);

				switch(animalType)
				{
					case AnimalType.SELF_PLAYER:
						selfPlayer = null;
						break;
					case AnimalType.SELF_STORY:
						selfStory = null;
						break;
					case AnimalType.SELF_PET:
						selfPet = null;
						break;
				}
			}
		}

		/** 获取动物 */
		public function getAnimal(id : uint, animalType : String) : Animal
		{
			if (id == selfPlayerId && (animalType == AnimalType.PLAYER || animalType == AnimalType.SELF_PLAYER)) return selfPlayer;
			return animalDictionary.getAnimal(id, animalType);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 获取玩家 */
		public function getPlayer(playerId : uint) : PlayerAnimal
		{
			if (playerId == UserData.instance.playerId)
			{
				return selfPlayer;
			}
			return animalDictionary.getPlayer(playerId);
		}

		/** 获取玩家列表 */
		public function get playerList() : Vector.<PlayerAnimal>
		{
			return animalDictionary.playerList;
		}

		/** 获取NPC */
		public function getNpc(npcId : uint) : NpcAnimal
		{
			return animalDictionary.getNpc(npcId);
		}

		/** 获取NPC列表 */
		public function get npcList() : Vector.<NpcAnimal>
		{
			return animalDictionary.npcList;
		}

		/** 获取怪物 */
		public function getMonster(wave : uint) : MonsterAnimal
		{
			return animalDictionary.getMonster(wave);
		}

		/** 获取怪物列表 */
		public function get monsterList() : Vector.<MonsterAnimal>
		{
			return animalDictionary.monsterList;
		}

		/** 获取怪物Boss列表 */
		public function get monsterBossList() : Vector.<MonsterAnimal>
		{
			return animalDictionary.monsterBossList;
		}

		/** 获取剧情 */
		public function getStory(id : uint) : StoryAnimal
		{
			return animalDictionary.getStory(id);
		}

		/** 获取剧情列表 */
		public function get storyList() : Vector.<StoryAnimal>
		{
			return animalDictionary.storyList;
		}
        
        /** 获取护送任务被护送者列表 */
        public function get escortList():Vector.<EscortAnimal>
        {
			return animalDictionary.escortList;
        }

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 克隆NPC成跟随者 */
		public function cloneNpcToEscort(npcId : int, x : int = 0, y : int = 0) : EscortAnimal
		{
			var escortAnimal : EscortAnimal = animalDictionary.getEscort(npcId);
			if (escortAnimal)
			{
				if (x != 0 && y != 0)
				{
					escortAnimal.moveTo(x, y);
				}
			}
			else
			{
				var escortStruct : EscortStruct = AnimalStructUtil.cloneNpcToEscort(npcId, 0, x, y);
				if (escortStruct) escortAnimal = addAnimal(escortStruct) as EscortAnimal;
			}
			return escortAnimal;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		public function clear() : void
		{
			animalDictionary.quit();
			selfPlayer = null;
			selfPet = null;
			selfStory = null;
		}
	}
}
class Singleton
{
}