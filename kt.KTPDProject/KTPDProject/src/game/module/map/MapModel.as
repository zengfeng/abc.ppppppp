package game.module.map
{
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.utils.Dictionary;
    import game.module.map.struct.MapStruct;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-27 ����1:48:34
     */
    public final class MapModel extends EventDispatcher
    {
        public function MapModel(singleton:Singleton,target : IEventDispatcher = null)
        {
            singleton;
            super(target);
        }
        /** 单例对像 */
        private static var _instance : MapModel;

        /** 获取单例对像 */
        static public function get instance() : MapModel
        {
            if (_instance == null)
            {
                _instance = new MapModel(new Singleton());
            }
            return _instance;
        }
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 地图字典,存入 MapStruct 使用 id 做索引 */
        public var mapDic:Dictionary = new Dictionary();
        
        /** 获取地图数据结构 */
        public function getMapStruct(mapId:uint):MapStruct
        {
            return mapDic[mapId];
        }
        
    }
}
class Singleton
{}