package game.module.map.layers
{
	import flash.utils.Dictionary;
	import game.core.avatar.AvatarMonster;
	import game.core.avatar.AvatarNpc;
	import game.core.avatar.AvatarPet;
	import game.core.avatar.AvatarPlayer;
	import game.core.avatar.AvatarThumb;
	import game.core.user.UserData;
	import game.module.map.animal.AnimalType;


	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-22 ����8:53:21
	 */
	public class ElementAvatarDictionary
	{
		function ElementAvatarDictionary(singleton : Singleton)
		{
			singleton;
		}

		/** 单例对像 */
		private static var _instance : ElementAvatarDictionary;

		/** 获取单例对像 */
		static public function get instance() : ElementAvatarDictionary
		{
			if (_instance == null)
			{
				_instance = new ElementAvatarDictionary(new Singleton());
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 总字典 */
		private var dic : Dictionary = new Dictionary();

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
		public function add(avatar : AvatarThumb, id : int, animalType : String) : void
		{
			if (avatar == null || avatar == null) return;
			var typeDic : Dictionary = createTypeDic(animalType);
			typeDic[id] = avatar;
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
		public function getAvatar(id : uint, animalType : String) : AvatarThumb
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
			return getAvatar(id, animalType) != null;
		}

		/** 获取某个类型的动物列表 */
		public function getAvatarList(animalType : String) : Vector.<AvatarThumb>
		{
			var list : Vector.<AvatarThumb> = new Vector.<AvatarThumb>();
			var typeDic : Dictionary = getTypeDic(animalType);
			if (typeDic == null) return list;
			for each (var avatar:AvatarThumb in typeDic)
			{
				list.push(avatar);
			}
			return list;
		}

		/** 获取所有动物列表 */
		public function getAllAvatarList() : Vector.<AvatarThumb>
		{
			var list : Vector.<AvatarThumb> = new Vector.<AvatarThumb>();
			for each (var typeDic:Dictionary in dic)
			{
				for each (var avatar:AvatarThumb in typeDic)
				{
					list.push(avatar);
				}
			}
			return list;
		}

		/** 获取自己玩家 */
		public function get selfPlayer() : AvatarPlayer
		{
			return getAvatar(selfPlayerId, AnimalType.SELF_PLAYER) as AvatarPlayer;
		}

		/** 获取玩家 */
		public function getPlayer(playerId : uint) : AvatarPlayer
		{
			if (playerId == selfPlayerId)
			{
				return selfPlayer;
			}
			return getAvatar(playerId, AnimalType.PLAYER) as AvatarPlayer;
		}

		/** 获取玩家列表 */
		public function get playerList() : Vector.<AvatarPlayer>
		{
			var list : Vector.<AvatarPlayer> = new Vector.<AvatarPlayer>();
			var typeDic : Dictionary = getTypeDic(AnimalType.PLAYER);
			if (typeDic == null) return list;
			for each (var avatar:AvatarThumb in typeDic)
			{
				list.push(avatar);
			}
			return list;
		}

		/** 获取玩家列表 */
		public function get petList() : Vector.<AvatarPet>
		{
			var list : Vector.<AvatarPet> = new Vector.<AvatarPet>();
			var typeDic : Dictionary = getTypeDic(AnimalType.PET);
			if (typeDic == null) return list;
			for each (var avatar:AvatarThumb in typeDic)
			{
				list.push(avatar);
			}
			return list;
		}

		/** 获取NPC */
		public function getNpc(npcId : uint) : AvatarNpc
		{
			return getAvatar(npcId, AnimalType.NPC) as AvatarNpc;
		}

		/** 获取NPC列表 */
		public function get npcList() : Vector.<AvatarNpc>
		{
			var list : Vector.<AvatarNpc> = new Vector.<AvatarNpc>();
			var typeDic : Dictionary = getTypeDic(AnimalType.NPC);
			if (typeDic == null) return list;
			for each (var avatar:AvatarNpc in typeDic)
			{
				list.push(avatar);
			}
			return list;
		}

		/** 获取怪物 */
		public function getMonster(wave : uint) : AvatarMonster
		{
			return getAvatar(wave, AnimalType.MONSTER) as AvatarMonster;
		}

		/** 获取怪物列表 */
		public function get monsterList() : Vector.<AvatarMonster>
		{
			var list : Vector.<AvatarMonster> = new Vector.<AvatarMonster>();
			var typeDic : Dictionary = getTypeDic(AnimalType.MONSTER);
			if (typeDic == null) return list;
			for each (var avatar:AvatarMonster in typeDic)
			{
				list.push(avatar);
			}
			return list;
		}

		/** 获取剧情 */
		public function getStory(id : uint) : AvatarThumb
		{
			return getAvatar(id, AnimalType.STORY) as AvatarThumb;
		}

		/** 获取剧情列表 */
		public function get storyList() : Vector.<AvatarThumb>
		{
			var list : Vector.<AvatarThumb> = new Vector.<AvatarThumb>();
			var typeDic : Dictionary = getTypeDic(AnimalType.STORY);
			if (typeDic == null) return list;
			for each (var avatar:AvatarMonster in typeDic)
			{
				list.push(avatar);
			}
			return list;
		}

		/** 获取被护送者 */
		public function getEscort(id : uint) : AvatarThumb
		{
			return getAvatar(id, AnimalType.ESCORT) as AvatarThumb;
		}
        
        /** 获取跟随者 */
        public function getFollower(id:uint):AvatarThumb
        {
            return getAvatar(id, AnimalType.FOLLOWER) as AvatarThumb;
        }

		/** 退出 */
		public function quit() : void
		{
			for (var typeKey:String in dic)
			{
				if (typeKey == AnimalType.ESCORT) continue;
				var typeDic : Dictionary = dic[typeKey];
				for (var avatarKey:String in typeDic)
				{
					var avatar : AvatarThumb = typeDic[avatarKey];
                    avatar.clearClickCallList();
					if (avatar.parent) avatar.parent.removeChild(avatar);
					avatar.dispose();
					delete typeDic[avatarKey];
				}
			}
		}
	}
}
class Singleton
{
}