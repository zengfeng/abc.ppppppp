package maps.currentmaps
{
	import game.core.user.UserData;

	import maps.elements.structs.PlayerStruct;

	import flash.utils.Dictionary;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-23
     */
    public class MapPlayers
    {
        /** 单例对像 */
        private static var _instance : MapPlayers;

        /** 获取单例对像 */
        static public function get instance() : MapPlayers
        {
            if (_instance == null)
            {
                _instance = new MapPlayers(new Singleton());
            }
            return _instance;
        }

        function MapPlayers(singleton : Singleton) : void
        {
            singleton;
            selfId = UserData.instance.playerId;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public var selfId : int;
        public var dic : Dictionary = new Dictionary();
        public var list : Vector.<PlayerStruct> = new Vector.<PlayerStruct>();
        public var waitInstallList : Vector.<PlayerStruct> = new Vector.<PlayerStruct>();

        public function clear() : void
        {
            while (list.length > 0)
            {
                var playerStruct : PlayerStruct = list.pop();
                delete dic[playerStruct.id];
            }

            while (waitInstallList.length > 0)
            {
                waitInstallList.pop();
            }
        }

        public function isInstalled(playerStruct : PlayerStruct) : Boolean
        {
            if (playerStruct) return false;
            return list.indexOf(playerStruct) != -1 && waitInstallList.indexOf(playerStruct) == -1;
        }

        public function addWaitInstall(playerStruct : PlayerStruct) : void
        {
            if (playerStruct == null || playerStruct.id == selfId) return;
            dic[playerStruct.id] = playerStruct;

            if (list.indexOf(playerStruct) == -1)
            {
                list.push(playerStruct);
            }

            if (waitInstallList.indexOf(playerStruct) == -1)
            {
                waitInstallList.push(playerStruct);
            }
        }

        public function remove(playerId : int) : void
        {
            var playerStruct : PlayerStruct = getPlayer(playerId);
            if (playerStruct == null || playerStruct.id == selfId) return;
            delete dic[playerId];
            var index : int = waitInstallList.indexOf(playerStruct);
            if (index != -1)
            {
                waitInstallList.splice(index, 1);
            }
            index = list.indexOf(playerStruct);
            if (index != -1)
            {
                list.splice(index, 1);
            }
        }

        public function setInstalled(playerStruct : PlayerStruct) : void
        {
            if (playerStruct == null || playerStruct.id == selfId) return;
            var index : int = waitInstallList.indexOf(playerStruct);
            if (index != -1)
            {
                waitInstallList.splice(index, 1);
            }
        }

        public function getPlayer(playerId : int) : PlayerStruct
        {
            return dic[playerId];
        }
    }
}
class Singleton
{
}