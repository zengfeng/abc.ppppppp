package game.module.mapConvoy
{
    import flash.utils.Dictionary;
    import game.module.mapConvoy.element.ConvoyPlayer;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-3-15 ����11:33:08
     * 运镖玩家管理器
     */
    public class ConvoyPlayerManager
    {
        public function ConvoyPlayerManager(singleton : Singleton)
        {
            singleton;
        }

        /** 单例对像 */
        private static var _instance : ConvoyPlayerManager;

        /** 获取单例对像 */
        static public function get instance() : ConvoyPlayerManager
        {
            if (_instance == null)
            {
                _instance = new ConvoyPlayerManager(new Singleton());
            }
            return _instance;
        }
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        private var playerDic:Dictionary = new Dictionary();
        
        public function addPlayer(convoyPlayer:ConvoyPlayer):void
        {
            playerDic[convoyPlayer.playerId] = convoyPlayer;
        }
        
        public function removePlayer(playerId:int):void
        {
            delete playerDic[playerId];
        }
        
        public function getPlayer(playerId:int):ConvoyPlayer
        {
            return playerDic[playerId];
        }
        
        public function havePlayer(playerId:int):Boolean
        {
            return playerDic[playerId] ? true : false;
        }
        
        public function clear():void
        {
            for(var key:String in playerDic)
            {
                var convoyPlayer:ConvoyPlayer = playerDic[key];
                convoyPlayer.out();
                delete playerDic[key];
            }
        }
        
        
    }
}
class Singleton
{
    
}