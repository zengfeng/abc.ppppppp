package game.module.map.utils
{
    import net.RESManager;

    import flash.utils.Dictionary;
    import flash.utils.clearTimeout;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-28 ����7:12:53
     */
    public class PieceMangager
    {
        function PieceMangager(singleton : Singleton) : void
        {
        }

        /** 单例对像 */
        private static var _instance : PieceMangager;

        /** 获取单例对像 */
        static public function get instance() : PieceMangager
        {
            if (_instance == null)
            {
                _instance = new PieceMangager(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 之前设置加载了的字典,以mapPiece_mapId_y_x为KEY */
        private var alreadySetLoad : Dictionary = new Dictionary();

        /** 加入之前设置加载了的 */
        public function pushAlreadySetLoad(mapPiece_mapId_y_x : String) : void
        {
            alreadySetLoad[mapPiece_mapId_y_x] = true;
        }

        /** 是否之前设置加载了的 */
        public function isAlreadySetLoad(mapPiece_mapId_y_x : String) : Boolean
        {
            return alreadySetLoad[mapPiece_mapId_y_x] == true ? true : false;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 加载完成的字典, 以mapPiece_mapId_y_x为KEY*/
        private var loadComplete : Dictionary = new Dictionary();

        /** 加入加载完成的 */
        public function pusLoadComplete(mapPiece_mapId_y_x : String) : void
        {
            loadComplete[mapPiece_mapId_y_x] = true;
        }

        /** 是否加载完成的 */
        public function isLoadComplete(mapPiece_mapId_y_x : String) : Boolean
        {
            return loadComplete[mapPiece_mapId_y_x] == true ? true : false;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public var loadDelayedTimeList : Vector.<uint> = new Vector.<uint>();
        public var loadKeyList : Vector.<String> = new Vector.<String>();

        /** 清理 */
        public function clear() : void
        {
            while (loadKeyList.length > 0)
            {
                RESManager.instance.remove(loadKeyList.shift());
            }
            
            while (loadDelayedTimeList.length > 0)
            {
                clearTimeout(loadDelayedTimeList.shift());
            }

            var key : String;
            // 之前设置加载了的字典
            for (key in alreadySetLoad)
            {
                delete alreadySetLoad[key];
            }

            // 加载完成的字典
            for (key in loadComplete)
            {
                delete loadComplete[key];
            }
        }
    }
}
class Singleton
{
}
