package maps.resets
{
    import maps.npcs.NpcSignals;
    import maps.resets.AbstractReset;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-22
     */
    public class ResetNormal extends AbstractReset
    {
        /** 单例对像 */
        private static var _instance : ResetNormal;

        /** 获取单例对像 */
        static public function get instance() : ResetNormal
        {
            if (_instance == null)
            {
                _instance = new ResetNormal();
            }
            return _instance;
        }
		
        public function ResetNormal()
        {
        }

        override public function uninstall() : void
        {
            NpcSignals.REMOVE_ALL.dispatch();
        }

        override public function setPreloadData() : void
        {
        }

        override public function startInstall() : void
        {
            NpcSignals.START_INSTALL.dispatch();
        }
    }
}