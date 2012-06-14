package maps.layers
{
    import maps.layers.lands.installs.LandInstall;
    import game.manager.ViewManager;
    import maps.layers.lands.LandLayer;

    import flash.display.Sprite;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-22
     */
    public class LayerContainer
    {
        /** 单例对像 */
        private static var _instance : LayerContainer;

        /** 获取单例对像 */
        static public function get instance() : LayerContainer
        {
            if (_instance == null)
            {
                _instance = new LayerContainer(new Singleton());
            }
            return _instance;
        }

        function LayerContainer(singleton : Singleton) : void
        {
            singleton;
        }

        /** 容器 */
        public var container : Sprite;
        // ================
        // 层级
        // ================
        /** 陆地层 */
        public var landLayer : LandLayer;
        /** 传送门层 */
        public var gateLayer : GateLayer;
        /** 元素层 */
        public var elementLayer : ElementLayer;
        /** UI层 */
        public var uiLayer : UILayer;
        private var landInstall:LandInstall;

        public function init() : void
        {
            landInstall = LandInstall.instance;
            container = ViewManager.instance.getContainer(ViewManager.MAP_CONTAINER);
//            container.opaqueBackground = 0xFF0000;
//            container.scaleX = container.scaleY = 0.2;
            landLayer = LandLayer.instance;
            gateLayer = new GateLayer(container);
            elementLayer = ElementLayer.instance;
            uiLayer = new UILayer(container);

            container.addChild(landLayer);
            container.addChild(elementLayer);
        }
        
        private var num:int = 0;
        public function setPosition(mapX:int, mapY:int, forceLoad:Boolean = false):void
        {
            num++;
            container.x = -mapX;
            container.y = -mapY;
            if(forceLoad == false && num < 20)
            {
                num = 0;
                landInstall.loadMapPosition(mapX, mapY);
            }
        }
        
        public function initPosition(mapX:int, mapY:int):void
        {
            container.x = mapX;
            container.y = mapY;
        }
    }
}
class Singleton
{
}