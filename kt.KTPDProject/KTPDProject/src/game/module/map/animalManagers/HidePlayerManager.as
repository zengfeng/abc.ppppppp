package game.module.map.animalManagers
{
    import game.module.map.animalstruct.PlayerStruct;


    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-10 ����1:46:39
     * 隐藏玩家管理
     */
    public class HidePlayerManager extends PlayerManager
    {
        public function HidePlayerManager(singleton : Singleton)
        {
            singleton;
        }

        /** 单例对像 */
        private static var _instance : HidePlayerManager;

        /** 获取单例对像 */
        static public function get instance() : HidePlayerManager
        {
            if (_instance == null)
            {
                _instance = new HidePlayerManager(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        private function get playerManager() : PlayerManager
        {
            return PlayerManager.instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 
         * 从玩家管理同步过到自己
         * @param isClearPM 同步完是否清理玩家管理
         * @param isClearSelf 同步前是否清理自己玩家列表
         */
        public function syncFromPlayerManagerList(isClearPM : Boolean = true, isClearSelf : Boolean = true) : void
        {
            if (isClearSelf == true)
            {
                clear();
            }
            var list : Vector.<PlayerStruct> = playerManager.getPlayerList();
            for (var i : int = 0; i < list.length; i++)
            {
                addPlayer(list[i]);
            }
            if (isClearPM == true)
            {
                playerManager.clear();
            }
        }

        /**
         * 自己同步过到玩家管理 
         * @param isClearPrePM 同步前是否清理玩家管理
         * @param isClearSelf 同步完是否清理自己玩家列表
         * */
        public function syncToPlayerManagerList(isClearPM : Boolean = true, isClearSelf : Boolean = true) : void
        {
            if (isClearPM == true)
            {
                playerManager.clear();
            }
            var list : Vector.<PlayerStruct> = getPlayerList();
            for (var i : int = 0; i < list.length; i++)
            {
                playerManager.addPlayer(list[i]);
            }
            if (isClearSelf == true)
            {
                clear();
            }
        }
    }
}
class Singleton
{
}
