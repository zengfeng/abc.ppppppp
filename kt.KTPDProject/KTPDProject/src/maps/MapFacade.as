package maps
{
    import maps.npcs.NpcControl;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    import gameui.manager.UIManager;
    import maps.auxiliarys.MapStage;
    import maps.configs.MapConfigData;
    import maps.layers.ElementLayer;
    import maps.layers.GateLayer;
    import maps.layers.LayerContainer;
    import maps.layers.UILayer;
    import maps.layers.lands.LandLayer;
    import maps.layers.lands.installs.LandInstall;
    import maps.loads.LoadManager;
    import maps.npcs.MapNpcs;
    import maps.players.GlobalPlayers;
    import maps.players.MapPlayers;
    import maps.preloads.MapPreload;



    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-21
     */
    public class MapFacade
    {
        public static var mapConfigData : MapConfigData;
        // =================
        // 地图协议&玩家数据&NPC列表
        // =================
        public static var mapProto : MapProto;
        public static var globalPlayers : GlobalPlayers;
        public static var mapPlayers : MapPlayers;
        public static var mapNpcs : MapNpcs;
        public static var npcControl:NpcControl;
        // =================
        // 操作方面
        // =================
        public static var mapControl : MapControl;
        // =================
        // 加载
        // =================
        public static var loadManager : LoadManager;
        public static var mapPreload : MapPreload;
        public static var landInstall : LandInstall;
        // =================
        // 层级
        // =================
        public static var layerContainer : LayerContainer;
        public static var landLayer : LandLayer;
        public static var gateLayer : GateLayer;
        public static var elementLayer : ElementLayer;
        public static var uiLayer : UILayer;

        public static function startup() : void
        {
            MapStage.startup(UIManager.root.stage);
            mapConfigData = MapConfigData.instance;

            MapUtil.stageWidth = MapStage.stageWidth;
            MapUtil.stageHeight = MapStage.stageHeight;
            MapUtil.stageWidthHalf = MapUtil.stageWidth >> 1;
            MapUtil.stageHeightHalf = MapUtil.stageHeight >> 1;
            MapStage.addStageResize(onStageResize);
            mapControl = MapControl.instance;

            mapPlayers = MapPlayers.instance;
            mapNpcs = MapNpcs.instance;
            globalPlayers = GlobalPlayers.instance;
            mapProto = MapProto.instance;
            npcControl = NpcControl.instance;

            loadManager = LoadManager.instance;
            mapPreload = MapPreload.instance;
            landInstall = LandInstall.instance;
            // 层级
            layerContainer = LayerContainer.instance;
            layerContainer.init();
            landLayer = layerContainer.landLayer;
            gateLayer = layerContainer.gateLayer;
            elementLayer = layerContainer.elementLayer;
            uiLayer = layerContainer.uiLayer;
            
            MapStage.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }

        private static function onStageResize(stageWidth : int, stageHeight : int) : void
        {
            MapUtil.stageWidth = stageWidth;
            MapUtil.stageHeight = stageHeight;
            MapUtil.stageWidthHalf = stageWidth >> 1;
            MapUtil.stageHeightHalf = stageHeight >> 1;
        }
        
        
        private static var mapX : int = 0;
        private static var mapY : int = 0;
        private static var speedX : int = 0;
        private static var speedY : int = 0;
        private static var speed : int = 4;
        public static function onKeyDown(event : KeyboardEvent) : void
        {
            if (event.ctrlKey == true)
            {
                if (event.keyCode >= Keyboard.NUMBER_0 && event.keyCode <= Keyboard.NUMBER_9)
                {
                    var mapId : int = parseInt(String.fromCharCode(event.keyCode));
                    if(mapId == 5) mapId = 20;
                    if(mapId == 6) mapId = 301;
                    mapProto.cs_changeMap(mapId);
                }
            }
            
            
            if (event.keyCode == Keyboard.LEFT)
            {
                speedX = -speed;
            }
            
            if (event.keyCode == Keyboard.RIGHT)
            {
                speedX = speed;
            }

            if (event.keyCode == Keyboard.UP)
            {
                speedY = -speed;
            }

            if (event.keyCode == Keyboard.DOWN)
            {
                speedY = speed;
            }

            if (event.keyCode == Keyboard.SPACE)
            {
                speedX = 0;
                speedY = 0;
            }

            if (speedX != 0 || speedY != 0)
            {
                MapStage.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            }
            else
            {
                MapStage.stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            }
        }
        
        private static function onEnterFrame(event : Event) : void
        {
            mapX = -layerContainer.container.x + speedX;
            mapY = -layerContainer.container.y +speedY;
            layerContainer.setPosition(mapX, mapY);
//            LandInstall.instance.loadMapPosition(mapX, mapY);
        }
    }
}
