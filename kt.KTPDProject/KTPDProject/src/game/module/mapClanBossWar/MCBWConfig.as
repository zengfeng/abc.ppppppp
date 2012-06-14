package game.module.mapClanBossWar
{
    import com.utils.Ellipse;

    import flash.geom.Rectangle;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-13 ����2:29:55
     * BOSS战地图配置
     */
    public class MCBWConfig
    {
        /** 死亡活动区域关卡颜色 */
        public static const diePassColor : uint = 0xff0000;
        /** 死亡区域 */
        private static var _dieArea : Ellipse;

        /** 死亡区域 */
        public static function get dieArea() : Ellipse
        {
            if (_dieArea == null)
            {
                _dieArea = new Ellipse(110, 75, 1750, 1775);
            }
            return _dieArea;
        }
        
        /** 复活区域 */
        private static var _reviveArea :Rectangle;
        public static function get reviveArea() : Rectangle
        {
            if (_reviveArea == null)
            {
                _reviveArea = new Rectangle(1500, 1630, 445, 230);
            }
            return _reviveArea;
        }
    }
}
