package game.module.groupBattle
{
    import flash.geom.Rectangle;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-16 ����12:51:48
     * 位置区域
     */
    public class GBPositionArea
    {
        /** 阵营A基地 */
        public static const A_AREA:String = "aArea";
        /** 阵营B基地 */
        public static const B_AREA:String = "bArea";
        /** 战斗区域 */
        public static const VS_AREA:String = "vsArea";
        /** 未知区域 */
        public static const UNKNOW_AREA:String = "unknowArea";
        
        public static var aArea:GBEllipse = new GBEllipse(222, 120, 1110, 1200);
        public static var bArea:GBEllipse = new GBEllipse(222, 120, 2760, 1200);
        public static var vsArea:GBEllipse = new GBEllipse(472, 250, 1938, 780);
        
        public static var _vsPostion:GBPositionVS;
        
        public static function get vsPostion():GBPositionVS
        {
            if(_vsPostion == null)
            {
                _vsPostion = new GBPositionVS();
                var paddindY:int = 60;
                var paddindX:int = 200;
                var rect:Rectangle = new Rectangle();
//                vsArea.innerRadiuX = 150;
                rect.x = vsArea.centerX - vsArea.innerRadiuX + paddindX;
                rect.y = vsArea.centerY - vsArea.radiusY + paddindY;
                rect.width = vsArea.innerRadiuX * 2 - paddindX * 2;
                rect.height = vsArea.radiusY * 2 - paddindY * 2;
                _vsPostion.rect = rect;
                _vsPostion.lineCout = 1;
                _vsPostion.changeLineLength = 7;
                _vsPostion.positionCount = 200;
            }
            return _vsPostion;
        }
        
    }
}