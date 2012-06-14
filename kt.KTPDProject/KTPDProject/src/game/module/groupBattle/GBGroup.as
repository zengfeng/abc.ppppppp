package game.module.groupBattle
{
    import flash.utils.Dictionary;
    import game.module.groupBattle.ui.UiGroup;
    import game.module.groupBattle.ui.UiPlayerList;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-14 ����3:59:47
     * 组(蜀山论剑)
     */
    public class GBGroup
    {
        /** ID */
        public var id:uint;
        /** 组AB */
        public var groupAB:int = 1;
        /** 组名 */
        public var name:String = "组名";
        /** 颜色 */
        public var color:int = 0xFE9966;
        /** 颜色字符串 */
        public var colorStr:String = "#FE9966";
        /** 最小等级 */
        public var minLevel:int = 1;
        /** 最大等级 */
        public var maxLevel:int = 40;
        /** 积分 */
        private var _score:uint = 0;
        /** 玩家人数 */
        private var _playerCount:uint = 0;
        /** 玩家字典 */
        private var playerDic:Dictionary = new Dictionary();
        /** ui玩家列表 */
        public var uiPlayerList:UiPlayerList;
        /** ui组 */
        public var uiGroup:UiGroup;
        /** 蜀山论剑控制器 */
        private var _gbController : GBController;
        /** 蜀山论剑控制器 */
        public function get gbController():GBController
        {
            if(_gbController == null)
            {
                _gbController = GBController.instance;
            }
            return _gbController;
        }
        
        /** 获取玩家 */
        public function getPlayer(playerId:uint):GBPlayer
        {
            return playerDic[playerId];
        }
        
        /** 获取玩家列表 */
        public function getPlayerList():Vector.<GBPlayer>
        {
            var list:Vector.<GBPlayer> = new Vector.<GBPlayer>();
            for each(var gbPlayer:GBPlayer in playerDic)
            {
                list.push(gbPlayer);
            }
            return list;
        }
        
        /** 添加玩家 */
        public function addPlayer(gbPlayer:GBPlayer):void
        {
            if(gbPlayer.group.id != id) gbPlayer.group.removePlayer(gbPlayer.id);
            if(playerDic[gbPlayer.id]) return;
            playerDic[gbPlayer.id] = gbPlayer;
			++playerCount ;
            if(uiPlayerList)
            {
                uiPlayerList.addPlayerData(gbPlayer);
            }
            
            if(gbPlayer.animal == null)
            {
                gbController.addPlayer(gbPlayer);
            }
        }
        
        /** 移除玩家 */
        public function removePlayer(playerId:uint, destruct : Boolean = false):void
        {
            var gbPlayer:GBPlayer = getPlayer(playerId);
			if(gbPlayer != null)
			{
				if(destruct == false ) gbPlayer.quit();
				--playerCount ;
			}
            delete playerDic[gbPlayer.id];
        }
        
        public function clear():void
        {
            for(var key:String in playerDic)
            {
                var gbPlayer:GBPlayer = playerDic[key];
                if(gbPlayer)
                {
                    gbPlayer.quit();
                }
            }
        }
		/** 积分 */
        public function get score() : uint
        {
            return _score;
        }

        public function set score(score : uint) : void
        {
            _score = score;
            if(uiPlayerList)
            {
				gbController.uc.centerMain.setScore(_score, id);
            }
        }
        
		/** 玩家人数 */
        public function get playerCount():uint
        {
            return _playerCount;
        }
        
        public function set playerCount(value:uint):void
        {
            _playerCount = value;
            
            if(uiPlayerList)
            {
				uiPlayerList.setPlayerCount(value);
            }
        }
    }
}
