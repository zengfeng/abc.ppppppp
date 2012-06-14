package maps.npcs
{
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-23
     */
    public class MapNpcs
    {
        /** 单例对像 */
        private static var _instance : MapNpcs;

        /** 获取单例对像 */
        static public function get instance() : MapNpcs
        {
            if (_instance == null)
            {
                _instance = new MapNpcs(new Singleton());
            }
            return _instance;
        }

        function MapNpcs(singleton : Singleton) : void
        {
            singleton;
            NpcSignals.INSTALLED.add(setInstalled);
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public var list : Vector.<uint> = new Vector.<uint>();
        public var waitInstallList : Vector.<uint> = new Vector.<uint>();

        public function clear() : void
        {
            NpcSignals.STOP_INSTALL.dispatch();
            while (list.length > 0)
            {
                list.pop();
            }
            while (waitInstallList.length > 0)
            {
                waitInstallList.pop();
            }
        }

        public function add(npcId : int) : void
        {
            var index : int = list.indexOf(npcId);
            if (index == -1)
            {
                list.push(npcId);
            }
            index = waitInstallList.indexOf(npcId);
            if (index == -1)
            {
                waitInstallList.push(npcId);
                NpcSignals.ADD.dispatch(npcId);
            }
        }

        public function remove(npcId : int) : void
        {
            var index : int = list.indexOf(npcId);
            if (index != -1)
            {
                list.splice(index, 1);
            }
            index = waitInstallList.indexOf(npcId);
            if (index != -1)
            {
                waitInstallList.splice(index, 1);
            }

            NpcSignals.REMOVE.dispatch(npcId);
        }

        public function setInstalled(npcId : int) : void
        {
            var index : int = waitInstallList.indexOf(npcId);
            if (index != -1)
            {
                waitInstallList.splice(index, 1);
            }
        }

        public function isInstalled(npcId : int) : Boolean
        {
            return list.indexOf(npcId) != -1 && waitInstallList.indexOf(npcId) == -1;
        }

        public function hasWaitInstall() : Boolean
        {
            return waitInstallList.length > 0;
        }
    }
}
class Singleton
{
}