package game.module.map.animalManagers
{
    import game.core.user.UserData;
    import game.module.map.animal.Animal;
    import game.module.map.animal.AnimalManager;
    import game.module.map.animal.AnimalType;
    import game.module.map.animal.EscortAnimal;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-20 ����6:14:52
     */
    public class FollowManager
    {
        public function FollowManager(singleton : Singleton)
        {
            singleton;
        }

        /** 单例对像 */
        private static var _instance : FollowManager;

        /** 获取单例对像 */
        static public function get instance() : FollowManager
        {
            if (_instance == null)
            {
                _instance = new FollowManager(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 动物管理器 */
        private var animalManager : AnimalManager = AnimalManager.instance;

        private function  get selfPlayerId() : int
        {
            return UserData.instance.playerId;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        private var list : Vector.<FollowStruct> = new Vector.<FollowStruct>();

        private function indexOf(followStruct : FollowStruct) : int
        {
            var index : int = -1;
            for (var i : int = 0; i < list.length; i++)
            {
                if (followStruct.equal(list[i]))
                {
                    index = i;
                    break;
                }
            }
            return index;
        }

        private function getFollowStruct(id : int, type : String) : FollowStruct
        {
            var followStruct : FollowStruct;
            for (var i : int = 0; i < list.length; i++)
            {
                followStruct = list[i];
                if (followStruct.id == id && followStruct.type == type)
                {
                    break;
                }
                followStruct = null;
            }
            return followStruct;
        }

        private function getBeFollowStructList(beId : int, beType : String) : Vector.<FollowStruct>
        {
            var beList : Vector.<FollowStruct> = new Vector.<FollowStruct>();
            var followStruct : FollowStruct;
            for (var i : int = 0; i < list.length; i++)
            {
                followStruct = list[i];
                if (followStruct.beId == beId && followStruct.beType == beType)
                {
                    beList.push(followStruct);
                }
            }
            return beList;
        }

        public function clear() : void
        {
            var followStruct : FollowStruct;
            while (list.length > 0)
            {
                followStruct = list.shift();
                removeFollow(followStruct.id, followStruct.type, false);
            }
        }

        public function reset() : void
        {
            var followStruct : FollowStruct;
            var animal : Animal;
            var beAnimal : Animal;
            for (var i : int = 0; i < list.length; i++)
            {
                followStruct = list[i];
                animal = animalManager.getAnimal(followStruct.id, followStruct.type);
                beAnimal = animalManager.getAnimal(followStruct.beId, followStruct.beType);
                
                if(animal && beAnimal)
                {
                    animal.moveTo(beAnimal.x, beAnimal.y);
                    animal.followAnimal(beAnimal);
                }
            }
        }

        /** 添加跟随 */
        public function add(id : int, type : String, beId : int, beType : String, force : Boolean = false) : void
        {
            if (id == beId && type == beType) return;
            var escortAnimal : EscortAnimal;
            if (type == AnimalType.NPC)
            {
                type = AnimalType.ESCORT;
                escortAnimal = animalManager.getAnimal(id, type) as EscortAnimal;
                if (escortAnimal == null)
                {
                    escortAnimal = animalManager.cloneNpcToEscort(id);
                }
            }

            if (beType == AnimalType.NPC)
            {
                beType = AnimalType.ESCORT;
                escortAnimal = animalManager.getAnimal(beId, beType) as EscortAnimal;
                if (escortAnimal == null)
                {
                    escortAnimal = animalManager.cloneNpcToEscort(beId);
                }
            }

            var followStruct : FollowStruct = new FollowStruct(id, type, beId, beType);
            var index : int = indexOf(followStruct);
            if (index == -1 || force == true)
            {
                var animal : Animal;
                var beAnimal : Animal;

                animal = animalManager.getAnimal(id, type);
                beAnimal = animalManager.getAnimal(beId, beType);

                if (animal && beAnimal)
                {
                    var preFollowStruct : FollowStruct = getFollowStruct(id, type);
                    if (preFollowStruct != null)
                    {
                        var preIndex : int = list.indexOf(preFollowStruct);
                        list.splice(preIndex, 1);
                    }
                    animal.followAnimal(beAnimal);
//                    animal.follow(beAnimal);
                    list.push(followStruct);
                }
            }
        }

        /** 移除跟随 */
        public function removeFollow(id : int, type : String, destruct : Boolean = true) : void
        {
            if (type == AnimalType.NPC) type = AnimalType.ESCORT;
            var animal : Animal = animalManager.getAnimal(id, type);
            if (animal)
            {
                animal.cancelFollowAnimal();
                if (type == AnimalType.ESCORT)
                {
                    animal.quit();
                }
            }
            if (destruct == true)
            {
                var followStruct : FollowStruct = getFollowStruct(id, type);
                var index : int = list.indexOf(followStruct);
                if (index != -1)
                {
                    list.splice(index, 1);
                }
            }
        }

        /** 移除被跟随 */
        public function removeBeFollow(beId : int, beType : String) : void
        {
            var beAnimal : Animal = animalManager.getAnimal(beId, beType);
            if (beAnimal) beAnimal.clearFollower();
            var beList : Vector.<FollowStruct> = getBeFollowStructList(beId, beType);
            var followStruct : FollowStruct;
            while (beList.length > 0)
            {
                followStruct = beList.shift();
                var index : int = list.indexOf(followStruct);
                if (index != -1)
                {
                    list.splice(index, 1);
//                    var animal:Animal = animalManager.getAnimal(followStruct.id, followStruct.type);
//                    if(animal) animal.cancelFollowAnimal();
                }
            }
        }

        /** 自己跟随某某 */
        public function selfFollow(id : int, type : String = "player") : void
        {
            add(selfPlayerId, AnimalType.SELF_PLAYER, id, type);
        }

        /** 某某跟随自己 */
        public function followSelf(id : int, type : String = "player") : void
        {
            add(id, type, selfPlayerId, AnimalType.SELF_PLAYER);
        }

        /** 某个NPC跟随自己 */
        public function npcFollowSelf(npcId : int) : void
        {
            followSelf(npcId, AnimalType.NPC);
        }

        /** 自己跟随某个玩家 */
        public function selfFollowPlayer(playerId : int) : void
        {
            selfFollow(playerId, AnimalType.PLAYER);
        }

        /** 移除某个NPC跟随自己 */
        public function removeNpcFollowSelf(npcId : int) : void
        {
            removeFollow(npcId, AnimalType.NPC);
        }
    }
}
class FollowStruct
{
    public var id : int;
    public var type : String;
    public var beId : int;
    public var beType : String;

    function FollowStruct(id : int, type : String, beId : int, beType : String) : void
    {
        this.id = id;
        this.type = type;
        this.beId = beId;
        this.beType = beType;
    }

    public function equal(b : FollowStruct) : Boolean
    {
        if (b == null) return false;
        return id == b.id && type == b.type && beId == b.beId && beType == b.beType;
    }
}
class Singleton
{
}
