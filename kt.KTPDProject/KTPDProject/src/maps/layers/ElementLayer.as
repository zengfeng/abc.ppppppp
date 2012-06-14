package maps.layers
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import maps.auxiliarys.PointShape;
    import maps.elements.ElementSignals;


    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-22
     */
    public class ElementLayer extends Sprite
    {
        /** 单例对像 */
        private static var _instance : ElementLayer;

        /** 获取单例对像 */
        static public function get instance() : ElementLayer
        {
            if (_instance == null)
            {
                _instance = new ElementLayer(new Singleton());
            }
            return _instance;
        }

        // ===========
        // 绘制地图高宽的两个点
        // ===========
        private var leftTopPointShape : PointShape;
        private var rightBottomPointShape : PointShape;

        public function ElementLayer(singleton : Singleton)
        {
            singleton;

            leftTopPointShape = new PointShape();
            rightBottomPointShape = new PointShape();
            addChild(leftTopPointShape);
            addChild(rightBottomPointShape);
            ElementSignals.ADD_TO_LAYER.add(addAt);
            ElementSignals.REMOVE_FROM_LAYER.add(remove);
            ElementSignals.DEPTH_CHANGE.add(addAt);
        }

        /**  重设  */
        public function reset(mapWidth : int, mapHeight : int) : void
        {
            rightBottomPointShape.x = mapWidth - rightBottomPointShape.width;
            rightBottomPointShape.y = mapHeight - rightBottomPointShape.height;
        }

        public function addAt(displayObject:DisplayObject, childIndex:int) : void
        {
            addChildAt(displayObject, childIndex);
        }

        public function remove(displayObject:DisplayObject) : void
        {
            removeChild(displayObject);
        }
    }
}
class Singleton
{
}