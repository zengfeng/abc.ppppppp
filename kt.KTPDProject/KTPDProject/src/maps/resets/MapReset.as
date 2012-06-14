package maps.resets
{
    import maps.MapUtil;
    import maps.auxiliarys.MapStage;
    import maps.configs.structs.MapStruct;
    import maps.layers.ElementLayer;
    import maps.layers.LayerContainer;
    import maps.layers.lands.installs.LandInstall;
    import maps.preloads.MapPreload;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-22
     */
    public class MapReset
    {
        /** 单例对像 */
        private static var _instance : MapReset;

        /** 获取单例对像 */
        static public function get instance() : MapReset
        {
            if (_instance == null)
            {
                _instance = new MapReset(new Singleton());
            }
            return _instance;
        }

        function MapReset(singleton : Singleton) : void
        {
            singleton;
            mapPreload = MapPreload.instance;
            elementLayer = ElementLayer.instance;
            landInstall = LandInstall.instance;
            layerContainer = LayerContainer.instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        // ======================
        // 地图基本信息
        // ======================
        public var mapId : int;
        public var mapAssetId : int;
        public var selfInitX : int;
        public var selfInitY : int;
        public var mapInitX : int;
        public var mapInitY : int;
        public var mapWidth : int;
        public var mapHeight : int;
        private var landIsFullMode : Boolean;
        // ======================
        // 功能类
        // ======================
        private var module : AbstractReset;
        private var mapPreload : MapPreload;
        private var landInstall : LandInstall;
        private var elementLayer:ElementLayer;
        private var layerContainer:LayerContainer;

        // ===============
        // 重设
        // ===============
        public function reset(mapId : int, selfInitX : int, selfInitY : int) : void
        {
            this.mapId = mapId;
            this.selfInitX = selfInitX;
            this.selfInitY = selfInitY;
            MapUtil.setCurrentMapId(mapId);
            var mapStruct : MapStruct = MapUtil.currentMapStruct;
            landIsFullMode = mapId > 20;
            mapAssetId = mapStruct.assetId;
            mapWidth = mapStruct.mapWidth;
            mapHeight = mapStruct.mapHeight;
            mapInitX = MapUtil.selfToMapX(selfInitX);
            mapInitY = MapUtil.selfToMapX(selfInitY);

            uninstall();
            setModule();
            setPreloadData();
            startPreload();
        }

        private function setModule() : void
        {
            if (MapUtil.isCapitalMap(mapId))
            {
                module = ResetCapital.instance;
            }
            else if (MapUtil.isNormalMap(mapId))
            {
                module = ResetNormal.instance;
            }
            else
            {
                module = ResetNormal.instance;
            }
        }

        // ===============
        // 卸载
        // ===============
        public function uninstall() : void
        {
            if (module) module.uninstall();
            landInstall.preset(mapId, mapWidth, mapHeight, landIsFullMode);
            elementLayer.reset(mapWidth, mapHeight);
        }

        // ===============
        // 设置预加载数据
        // ===============
        public function setPreloadData() : void
        {
            module.setPreloadData();
            mapPreload.reset(mapId, -mapInitX, -mapInitY, mapWidth, mapHeight, MapStage.stageWidth, MapStage.stageHeight, mapAssetId, landIsFullMode);
            layerContainer.initPosition(mapInitX, mapInitY);
        }

        // ===============
        // 开始预加载
        // ===============
        public function startPreload() : void
        {
            mapPreload.signalComplete.add(preloadComplete);
            mapPreload.startLoad();
        }

        // ===============
        // 预加载完成
        // ===============
        public function preloadComplete() : void
        {
            startInstall();
        }

        // ===============
        // 开始安装
        // ===============
        public function startInstall() : void
        {
            landInstall.install();
            module.startInstall();
        }

        // ===============
        // 安装完成
        // ===============
        public function finish() : void
        {
        }
    }
}
class Singleton
{
}