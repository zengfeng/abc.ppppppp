package game.module.map.animalManagers
{
    import flash.utils.Dictionary;
    import game.module.map.animalstruct.PlayerStruct;


    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-29 ����5:59:08
     */
    public class PlayerManager
    {
        public function PlayerManager()
        {
        }

        /** 单例对像 */
        private static var _instance : PlayerManager;

        /** 获取单例对像 */
        static public function get instance() : PlayerManager
        {
            if (_instance == null)
            {
                _instance = new PlayerManager();
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 玩家字典,存入PlayerStruct以playerId为键值 */
        public var playerDic : Dictionary = new Dictionary();

        /** 加入玩家 */
        public function addPlayer(playerStruct : PlayerStruct) : PlayerStruct
        {
           if(playerStruct == null) return null;
           playerDic[playerStruct.id] = playerStruct;
           return playerStruct;
        }

        /** 移除玩家 */
        public function removePlayer(playerId : uint) : PlayerStruct
        {
            var playerStruct : PlayerStruct = playerDic[playerId];
            delete playerDic[playerId];
            return playerStruct;
        }

        /** 获取玩家 */
        public function getPlayer(playerId : uint) : PlayerStruct
        {
            return playerDic[playerId];
        }



        private var updatePlayerCall : Vector.<Function> = new Vector.<Function>();
        public function addUpdatePlayerCall(fun : Function) : void
        {
            if (fun == null) return;
            var index : int = updatePlayerCall.indexOf(fun);
            if (index == -1)
            {
                updatePlayerCall.push(fun);
            }
        }

        public function removeUpdatePlayerCall(fun : Function) : void
        {
            if (fun == null) return;
            var index : int = updatePlayerCall.indexOf(fun);
            if (index != -1)
            {
                updatePlayerCall.splice(index, 1);
            }
        }

        public function runUpdatePlayerCall(playerStruct : PlayerStruct) : void
        {
            for (var i : int = 0; i < updatePlayerCall.length; i++)
            {
                var fun : Function = updatePlayerCall[i];
                fun.apply(null, [playerStruct]);
            }
        }

        /** 获取玩家列表 */
        public function getPlayerList() : Vector.<PlayerStruct>
        {
            var list : Vector.<PlayerStruct> = new Vector.<PlayerStruct>();
            for each (var playerStruct:PlayerStruct in playerDic)
            {
                list.push(playerStruct);
            }
            return list;
        }

        /** 清理 */
        public function clear() : void
        {
            for (var key:String in playerDic)
            {
                delete playerDic[key];
            }
        }
    }
}
class Singleton
{
}
