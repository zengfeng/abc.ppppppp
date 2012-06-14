package game.module.map.playerVisible
{
    import game.module.map.MapSystem;
    import game.module.map.animalManagers.PlayerManager;
    import game.module.map.animalstruct.PlayerStruct;
    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-3-13   ����7:15:49 
     * 其他玩家是否显示管理
     */
    public class OtherPlayerVisibleMananger
    {
        /** 单例对像 */
        private static var _instance : OtherPlayerVisibleMananger;

        /** 获取单例对像 */
        static public function get instance() : OtherPlayerVisibleMananger
        {
            if (_instance == null)
            {
                _instance = new OtherPlayerVisibleMananger();
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 玩家(地图)数据结构管理 */
        private var playerManager : PlayerManager = PlayerManager.instance;
        private var _visible : Boolean = true;

        public function get visible() : Boolean
        {
            return _visible;
        }

        public function set visible(value : Boolean) : void
        {
            if(_visible == value) return;
            _visible = value;
            var playerStruct:PlayerStruct;
            if(_visible == false)
            {
                for each(playerStruct in playerManager.playerDic)
                {
                    MapSystem.removePlayer(playerStruct.id);
                }
                PlayerTolimitManager.instance.clear();
            }
            else
            {
                for each(playerStruct in playerManager.playerDic)
                {
                    MapSystem.addPlayer(playerStruct);
                }
            }
        }
    }
}