package game.module.map.animalManagers
{
    import game.module.map.animal.AnimalManager;
    import game.module.map.animal.PlayerAnimal;
    import game.module.map.animal.SelfPlayerAnimal;
    import game.net.data.StoC.SCAvatarInfo.PlayerAvatar;
    import game.net.data.StoC.SCAvatarInfoChange;

    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-3-12   ����10:48:03 
     * 玩家信息更新管理
     */
    public class PlayerInfoManager
    {
        /** 单例对像 */
        private static var _instance : PlayerInfoManager;

        /** 获取单例对像 */
        static public function get instance() : PlayerInfoManager
        {
            if (_instance == null)
            {
                _instance = new PlayerInfoManager();
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 动物管理器 */
        private var animalManager : AnimalManager = AnimalManager.instance;

        /** 自己玩家 */
        private function get selfPlayer() : SelfPlayerAnimal
        {
            return animalManager.selfPlayer;
        }

    }
}
