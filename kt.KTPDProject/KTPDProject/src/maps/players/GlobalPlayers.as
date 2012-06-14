package maps.players
{
	import game.core.user.UserData;

	import maps.elements.structs.PlayerStruct;
	import maps.elements.structs.SelfPlayerStruct;

	import flash.utils.Dictionary;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-23
     */
    public class GlobalPlayers
    {
        /** 单例对像 */
        private static var _instance : GlobalPlayers;

        /** 获取单例对像 */
        static public function get instance() : GlobalPlayers
        {
            if (_instance == null)
            {
                _instance = new GlobalPlayers(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public var selfId : int;
        public var self : SelfPlayerStruct;
        public var dic : Dictionary = new Dictionary();

        function GlobalPlayers(singleton : Singleton) : void
        {
            singleton;
            selfId = UserData.instance.playerId;
            self = new SelfPlayerStruct();
            self.id = UserData.instance.playerId;
            self.name = UserData.instance.playerName;
        }

        public function getPlayer(playerId : int) : PlayerStruct
        {
            if (playerId == selfId) return self;
            return dic[playerId];
        }

        public function addPlayer(playerStruct : PlayerStruct) : void
        {
            if (playerStruct == null || playerStruct.id == selfId) return;
            if (dic[playerStruct.id] == null)
            {
                dic[playerStruct.id] = playerStruct;
            }
        }
    }
}
class Singleton
{
}