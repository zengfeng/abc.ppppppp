package maps.resets.configurations
{
    import maps.MapUtil;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-22
     */
    public class MapConfiguration
    {
        public static var current : BaseConfiguration;
        public static var install : BaseConfiguration;

        public static function installFinish() : void
        {
            var tem : BaseConfiguration = current;
            tem.destory();
            current = install;
            install = tem;
            MapUtil.currentMapId = current.mapId;
        }
    }
}
