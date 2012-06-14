package game.module.mapFishing
{
	import game.core.user.UserData;
	import game.manager.ViewManager;
	import game.module.fishing.FishingManager;
	import game.module.map.MapController;
	import game.module.map.MapSystem;
	import game.module.map.animal.AnimalManager;
	import game.module.map.animal.AnimalType;
	import game.module.map.animal.FisherAnimal;
	import game.module.map.animal.PlayerAnimal;
	import game.module.map.animalstruct.PlayerStruct;
	import game.module.map.utils.MapUtil;
	import game.module.map.utils.PlayerModelUtil;
	import game.module.mapFishing.element.FishingPlayer;
	import game.module.mapFishing.element.FishingSelfPlayer;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-3-16 ����12:43:08
     */
    public class FishingController
    {
        public function FishingController(singleton : Singleton)
        {
            singleton;
        }

        /** 单例对像 */
        private static var _instance : FishingController;

        /** 获取单例对像 */
        static public function get instance() : FishingController
        {
            if (_instance == null)
            {
                _instance = new FishingController(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 动物管理器 */
        private var animalManager : AnimalManager = AnimalManager.instance;
        /** 龟仙拜佛玩家管理器 */
        private var fishingPlayerManager : FishingPlayerManager = FishingPlayerManager.instance;

        /** 获取玩家动物 */
        private function getPlayerAnimal(playerId : int) : PlayerAnimal
        {
            return animalManager.getPlayer(playerId);
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 是否进入钓鱼地图 */
        private var _isEnter : Boolean = true;

        /** 是否进入钓鱼地图 */
        public function get isEnter() : Boolean
        {
            return _isEnter;
        }

        /** 自己玩家ID */
        private function get selfPlayerId() : int
        {
            return UserData.instance.playerId;
        }

        /** 自己钓鱼玩家 */
        private var fishingSelfPlayer :FishingSelfPlayer;
		
        /** 自己是否在钓鱼中 */
        public function get selfIsFishing():Boolean
        {
            return fishingSelfPlayer ? true : false;
        }
		
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 地图安装完成 */
        public function mapSetupComplete() : void
        {
            if (MapUtil.getCurrentMapId() == MapSystem.MAIN_MAP_ID)
            {
                enterMap();
            }
            else
            {
                quitMap();
            }
        }

        /** 进入钓鱼地图 */
        public function enterMap() : void
        {
            _isEnter = true;
        }

        /** 退出钓鱼地图 */
        public function quitMap() : void
        {
            _isEnter = false;
        }

        /** 验证玩家是否在钓鱼 */
        public function checkPlayer(playerStruct : PlayerStruct) : void
        {
			if(MapUtil.isMainMap() == false)
			{
				return;
			}
			
            if (playerStruct == null) return;
            if (PlayerModelUtil.isNormal(playerStruct.model) == true)
            {
                playerOut(playerStruct.id);
            }
            else if (PlayerModelUtil.isFishing(playerStruct.model))
            {
                playerIn(playerStruct.id);
            }
        }

        /** 自己进入钓鱼模式 */
        public function selfIn() : void
        {
//            MapController.instance.enMouseMove = false;
            ViewManager.refreshShowState();
			FishingManager.instance.fisherAvatar = fishingSelfPlayer.fisherAvatar;
        }

        /** 自己退出钓鱼模式 */
        public function selfOut() : void
        {
//            MapController.instance.enMouseMove = true;
            ViewManager.refreshShowState();
			FishingManager.instance.fisherAvatar = null;
        }

        /** 玩家进入钓鱼模式 */
        public function playerIn(playerId : int) : void
        {		
            var fishingPlayer :FishingPlayer = fishingPlayerManager.getPlayer(playerId);
            // 如果该玩家已经在钓鱼中
            if (fishingPlayer != null)
            {
				fishingPlayer.updateName();
                return;
            }

            fishingPlayer = playerId != selfPlayerId ? new FishingPlayer() : new FishingSelfPlayer();
            fishingPlayer.playerId = playerId;
			
			var playerAnimal:PlayerAnimal = getPlayerAnimal(playerId);
			
			if (!playerAnimal)
				return;
				
            fishingPlayer.playerAnimal = playerAnimal;
            fishingPlayer.enter();

            if (playerId == selfPlayerId)
            {
                fishingSelfPlayer = fishingPlayer as FishingSelfPlayer;
                selfIn();
            }
			
            fishingPlayerManager.addPlayer(fishingPlayer);
        }

        /** 玩家退出钓鱼模式 */
        public function playerOut(playerId : int) : void
        {		
            var fishingPlayer : FishingPlayer = fishingPlayerManager.getPlayer(playerId);
            if (fishingPlayer == null) return;
			
            fishingPlayerManager.removePlayer(playerId);
            if (playerId == selfPlayerId)
            {
                fishingSelfPlayer = null;
                selfOut();
            }
            fishingPlayer.out();
        }
    }
}
class Singleton
{
}