package maps.players
{
	import game.core.user.UserData;
	import game.net.data.StoC.SCAvatarInfo.PlayerAvatar;
	import game.net.data.StoC.SCAvatarInfoChange;
	import game.net.data.StoC.SCMultiAvatarInfoChange;

	import maps.elements.structs.PlayerStruct;
	import maps.elements.structs.SelfPlayerStruct;

	import com.utils.PotentialColorUtils;

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
        public var self : SelfPlayerStruct;
		public var isSelfInstalled:Boolean;
        public var dic : Dictionary = new Dictionary();
        public var waitInstallDic : Dictionary = new Dictionary();
        public var waitInstallInfoNewestList : Vector.<PlayerStruct> = new Vector.<PlayerStruct>();
        private var keyArr : Array = [];

        public function clear() : void
        {
			self = null;
			isSelfInstalled = false;
            var key : String;
            // 全部
            for (key  in dic)
            {
                keyArr.push(key);
            }

            while (keyArr.length > 0)
            {
                key = keyArr.pop();
                dic[key] = null;
                delete dic[key];
            }
            // 等待安装
            for (key  in waitInstallDic)
            {
                keyArr.push(key);
            }

            while (keyArr.length > 0)
            {
                key = keyArr.pop();
                waitInstallDic[key] = null;
                delete waitInstallDic[key];
            }
            // 等待安装信息最新的
            while (waitInstallInfoNewestList.length > 0)
            {
                waitInstallInfoNewestList.pop();
            }
        }

        public function isInstalled(playerStruct : PlayerStruct) : Boolean
        {
            if (playerStruct == null) return false;
            return dic[playerStruct.id] && !waitInstallDic[playerStruct.id];
        }

        public function addWaitInstall(playerStruct : PlayerStruct) : void
        {
            if (playerStruct == null || playerStruct.id == selfId) return;
            dic[playerStruct.id] = playerStruct;
            waitInstallDic[playerStruct.id] = playerStruct;
        }

        public function remove(playerId : int) : void
        {
            var playerStruct : PlayerStruct = getPlayer(playerId);
            if (playerStruct == null || playerStruct.id == selfId) return;
            delete dic[playerId];
            delete waitInstallDic[playerId];
            var index : int = waitInstallInfoNewestList.indexOf(playerStruct);
            if (index != -1)
            {
                waitInstallInfoNewestList.splice(index, 1);
            }
        }

        public function setInstalled(playerStruct : PlayerStruct) : void
        {
            if (playerStruct == null || playerStruct.id == selfId) return;
            delete waitInstallDic[playerStruct.id];
            var index : int = waitInstallInfoNewestList.indexOf(playerStruct);
            if (index != -1)
            {
                waitInstallInfoNewestList.splice(index, 1);
            }
        }

        public function getPlayer(playerId : int) : PlayerStruct
        {
            return dic[playerId];
        }
        
        
        
        public function sc_playerAvatarInfoInit(msg : PlayerAvatar):void
        {
			var playerStruct : PlayerStruct = getPlayer(msg.id);
			if (playerStruct == null) return;
            playerStruct.name = msg.name;
            playerStruct.potential = msg.job >> 4;
            playerStruct.heroId = msg.job & 0xF;
            playerStruct.level = msg.level;
            playerStruct.clothId = msg.cloth;
            playerStruct.rideId = msg.ride;
            playerStruct.avatarVer = msg.avatarVer;
            playerStruct.newAvatarVer = msg.avatarVer;
            playerStruct.color = PotentialColorUtils.getColor( playerStruct.potential);
            playerStruct.colorStr = PotentialColorUtils.getColorOfStr( playerStruct.potential);
            
        }
        
        public function sc_playerAvatarInfoChange(msg : SCAvatarInfoChange):void
        {
			var playerStruct : PlayerStruct = getPlayer(msg.id);
			if (playerStruct == null) return;
            
            if(msg.hasCloth) playerStruct.clothId = msg.cloth;
            if(msg.hasLevel) playerStruct.level = msg.level;
            if(msg.hasRide) playerStruct.rideId = msg.ride;
			playerStruct.avatarVer = msg.avatarVer & 0x1F;
			playerStruct.model = msg.avatarVer >> 5;
            playerStruct.newAvatarVer = playerStruct.avatarVer;
        }
        
        public function sc_multipleAvatarInfoChange(msg : SCMultiAvatarInfoChange):void
        {
            
        }
    }
}
class Singleton
{
}