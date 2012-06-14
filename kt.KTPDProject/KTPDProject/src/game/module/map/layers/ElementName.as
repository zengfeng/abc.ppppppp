package game.module.map.layers
{
    import game.module.map.animal.AnimalType;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-26 ����6:09:49
     * 元素名称类
     */
    public class ElementName
    {
        /** 玩家名称前缀 */
        public static const PLAYER_PREFIX : String = "player_";
        /** 宠物名称前缀 */
        public static const PET_PREFIX : String = "pet_";
        /** NPC名称前缀 */
        public static const NPC_PREFIX : String = "npc_";
        /** 怪物名称前缀 */
        public static const MONSTER_PREFIX : String = "monster_";
        /** 护送者名称前缀 */
        public static const ESCORT_PREFIX : String = "escort_";
        /** 剧情名称前缀 */
        public static const STORY_PREFIX : String = "story_";
        /** 自己剧情名称前缀 */
        public static const SELF_STORY_PREFIX : String = "selfStory_";
        /** 镖车名称前缀 */
        public static const DRAY_PREFIX : String = "dray_";
        /** 强盗名称前缀 */
        public static const ROBBER_PREFIX : String = "robber_";
        /** 跟随者名称前缀 */
        public static const FOLLOWER_PREFIX : String = "follower_";
        /** 八卦阵(出入口)名称前缀 */
        public static const GATE_PREFIX : String = "gate_";
        /** 地图块名称前缀 */
        public static const PIECE_PREFIX : String = "piece_";
		
		public static const COUPLE_PREFIX : String = "couple_";

        /** 返回动物元素名称 */
        public static function animal(id : int, animalType : String) : String
        {
            var name : String;
            switch(animalType)
            {
                case  AnimalType.SELF_PLAYER:
                case  AnimalType.PLAYER:
                    name = player(id);
                    break;
                case  AnimalType.NPC:
                    name = npc(id);
                    break;
                case  AnimalType.MONSTER:
                    name = monster(id);
                    break;
                case  AnimalType.SELF_PET:
                case  AnimalType.PET:
                    name = pet(id);
                    break;
                case AnimalType.ESCORT:
                    name = escort(id);
                    break;
                case AnimalType.SELF_STORY:
                    name = selfStory;
                    break;
                case AnimalType.STORY:
                    name = story(id);
                    break;
                case AnimalType.DRAY:
                    name = dray(id);
                    break;
                case AnimalType.ROBBER:
                    name = robber(id);
                    break;
                case AnimalType.FOLLOWER:
                    name = follower(id);
                    break;
				case AnimalType.COUPLE:
					name = couple(id);
					break ;
            }
            return name;
        }

        /** 返回玩家元素名称 */
        public static function player(palyerId : int) : String
        {
            return PLAYER_PREFIX + palyerId;
        }

        /** 返回宠物元素名称 */
        public static function pet(palyerId : int) : String
        {
            return PET_PREFIX + palyerId;
        }

        /** 返回NPC元素名称 */
        public static function npc(npcId : int) : String
        {
            return NPC_PREFIX + npcId;
        }

        /** 返回怪物元素名称 */
        public static function monster(npcId : int) : String
        {
            return MONSTER_PREFIX + npcId;
        }

        /** 返回护送者名称 */
        public static function escort(id : int) : String
        {
            return ESCORT_PREFIX + id;
        }

        /** 返回剧情名称 */
        public static function story(id : int) : String
        {
            return STORY_PREFIX + id;
        }

        /** 返回自己剧情名称 */
        public static function get selfStory() : String
        {
            return SELF_STORY_PREFIX;
        }

        /** 返回镖车名称 */
        public static function dray(id : int) : String
        {
            return DRAY_PREFIX + id;
        }

        /** 返回强盗名称 */
        public static function robber(id : int) : String
        {
            return ROBBER_PREFIX + id;
        }

        /** 返回跟随者名称 */
        public static function follower(id : int) : String
        {
            return FOLLOWER_PREFIX + id;
        }
        

        /** 返回八卦阵(出入口)名称 */
        public static function gate(mapId : int, gateId:int) : String
        {
            return GATE_PREFIX + mapId + "_" + gateId;
        }
		
		public static function couple(id : int) : String
		{
			return COUPLE_PREFIX + id ;
		}
		
        /** 返回地图块名称 */
        public static function piece(x : int, y : int) : String
        {
            return PIECE_PREFIX + y + "_" + x;
        }
    }
}
