package game.module.map.animal
{
	import flash.utils.Dictionary;
	import game.core.user.UserData;
	import game.module.map.animalstruct.MonsterStruct;


	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-22 ����6:03:57
	 * 动物字典
	 */
	public class AnimalDictionary
	{
		function AnimalDictionary(singleton : Singleton)
		{
			singleton;
		}

		/** 单例对像 */
		private static var _instance : AnimalDictionary;

		/** 获取单例对像 */
		static public function get instance() : AnimalDictionary
		{
			if (_instance == null)
			{
				_instance = new AnimalDictionary(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 总字典 */
		public var dic : Dictionary = new Dictionary();

		/** 自己玩家ID */
		private function get selfPlayerId() : int
		{
			return UserData.instance.playerId;
		}

		/** 获取某个类型的动物字典 */
		private function getTypeDic(animalType : String) : Dictionary
		{
			var typeDic : Dictionary = dic[animalType];
			return typeDic;
		}

		/** 创建某个类型的动物字典 */
		private function createTypeDic(animalType : String) : Dictionary
		{
			var typeDic : Dictionary = dic[animalType];
			if (typeDic == null)
			{
				typeDic = new Dictionary();
				dic[animalType] = typeDic;
			}
			return typeDic;
		}

		/** 添加动物 */
		public function add(animal : Animal) : void
		{
			if (animal == null || animal.struct == null) return;
			var typeDic : Dictionary = createTypeDic(animal.struct.animalType);
			typeDic[animal.id] = animal;
		}

		/** 移除动物 */
		public function remove(id : uint, animalType : String) : void
		{
			var typeDic : Dictionary = getTypeDic(animalType);
			if (typeDic)
			{
				delete typeDic[id];
			}
		}

		/** 获取动物 */
		public function getAnimal(id : uint, animalType : String) : Animal
		{
			var typeDic : Dictionary = getTypeDic(animalType);
			if (typeDic)
			{
				return typeDic[id];
			}
			return null;
		}

		/** 是否存在该动物 */
		public function exist(id : uint, animalType : String) : Boolean
		{
			return getAnimal(id, animalType) != null;
		}

		/** 获取某个类型的动物列表 */
		public function getAnimalList(animalType : String) : Vector.<Animal>
		{
			var list : Vector.<Animal> = new Vector.<Animal>();
			var typeDic : Dictionary = getTypeDic(animalType);
			if (typeDic == null) return list;
			for each (var animal:Animal in typeDic)
			{
				list.push(animal);
			}
			return list;
		}

		/** 获取所有动物列表 */
		public function getAllAnimalList() : Vector.<Animal>
		{
			var list : Vector.<Animal> = new Vector.<Animal>();
			for each (var typeDic:Dictionary in dic)
			{
				for each (var animal:Animal in typeDic)
				{
					list.push(animal);
				}
			}
			return list;
		}

		/** 获取自己玩家 */
		public function get selfPlayer() : SelfPlayerAnimal
		{
			return getAnimal(selfPlayerId, AnimalType.SELF_PLAYER) as SelfPlayerAnimal;
		}

		/** 获取玩家 */
		public function getPlayer(playerId : uint) : PlayerAnimal
		{
			if (playerId == selfPlayerId)
			{
				return selfPlayer;
			}
			return getAnimal(playerId, AnimalType.PLAYER) as PlayerAnimal;
		}

		/** 获取玩家列表 */
		public function get playerList() : Vector.<PlayerAnimal>
		{
			var list : Vector.<PlayerAnimal> = new Vector.<PlayerAnimal>();
			var typeDic : Dictionary = getTypeDic(AnimalType.PLAYER);
			if (typeDic == null) return list;
			for each (var animal:Animal in typeDic)
			{
				list.push(animal);
			}
			return list;
		}

		/** 获取NPC */
		public function getNpc(npcId : uint) : NpcAnimal
		{
			return getAnimal(npcId, AnimalType.NPC) as NpcAnimal;
		}

		/** 获取NPC列表 */
		public function get npcList() : Vector.<NpcAnimal>
		{
			var list : Vector.<NpcAnimal> = new Vector.<NpcAnimal>();
			var typeDic : Dictionary = getTypeDic(AnimalType.NPC);
			if (typeDic == null) return list;
			for each (var animal:Animal in typeDic)
			{
				list.push(animal);
			}
			return list;
		}

		/** 获取怪物 */
		public function getMonster(wave : uint) : MonsterAnimal
		{
			return getAnimal(wave, AnimalType.MONSTER) as MonsterAnimal;
		}

		/** 获取怪物列表 */
		public function get monsterList() : Vector.<MonsterAnimal>
		{
			var list : Vector.<MonsterAnimal> = new Vector.<MonsterAnimal>();
			var typeDic : Dictionary = getTypeDic(AnimalType.MONSTER);
			if (typeDic == null) return list;
			for each (var animal:Animal in typeDic)
			{
				list.push(animal);
			}
			return list;
		}

		/** 获取怪物Boss列表 */
		public function get monsterBossList() : Vector.<MonsterAnimal>
		{
			var list : Vector.<MonsterAnimal> = new Vector.<MonsterAnimal>();
			var typeDic : Dictionary = getTypeDic(AnimalType.MONSTER);
			if (typeDic == null) return list;
			for each (var animal:Animal in typeDic)
			{
				var monsterStruct : MonsterStruct = animal.struct as MonsterStruct;
				if (monsterStruct.isBoss)
				{
					list.push(animal);
				}
			}
			return list;
		}

		/** 获取剧情 */
		public function getStory(id : uint) : StoryAnimal
		{
			return getAnimal(id, AnimalType.STORY) as StoryAnimal;
		}

		/** 获取剧情列表 */
		public function get storyList() : Vector.<StoryAnimal>
		{
			var list : Vector.<StoryAnimal> = new Vector.<StoryAnimal>();
			var typeDic : Dictionary = getTypeDic(AnimalType.STORY);
			if (typeDic == null) return list;
			for each (var animal:Animal in typeDic)
			{
				list.push(animal);
			}
			return list;
		}

		/** 获取护送者 */
		public function getEscort(id : uint) : EscortAnimal
		{
			return getAnimal(id, AnimalType.ESCORT) as EscortAnimal;
		}

		/** 获取护送者列表 */
		public function get escortList() : Vector.<EscortAnimal>
		{
			var list : Vector.<EscortAnimal> = new Vector.<EscortAnimal>();
			var typeDic : Dictionary = getTypeDic(AnimalType.ESCORT);
			if (typeDic == null) return list;
			for each (var animal:Animal in typeDic)
			{
				list.push(animal);
			}
			return list;
		}
        
        /** 获取跟随者 */
        public function getFollower(id : uint):FollowerAnimal
        {
            return getAnimal(id, AnimalType.FOLLOWER) as FollowerAnimal;
        }
        

		/** 退出 */
		public function quit() : void
		{
			for (var typeKey:String in dic)
			{
				if (typeKey == AnimalType.ESCORT) continue;
				var typeDic : Dictionary = dic[typeKey];
				for each (var animal:Animal in typeDic)
				{
					animal.quit();
					delete typeDic[animal.id];
				}
			}
		}
	}
}
class Singleton
{
}