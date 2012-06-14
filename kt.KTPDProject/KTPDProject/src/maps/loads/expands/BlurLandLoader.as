package maps.loads.expands
{
    import com.utils.UrlUtils;

    import maps.loads.core.ImageLoader;
    import maps.loads.core.LoaderCore;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-17
     */
    public class BlurLandLoader extends ImageLoader
    {
        /** 单例对像 */
        private static var _instance : BlurLandLoader;

        /** 获取单例对像 */
        static public function get instance() : BlurLandLoader
        {
            if (_instance == null)
            {
                _instance = new BlurLandLoader(new Singleton());
            }
            return _instance;
        }

        public var mapId : int;

        public function BlurLandLoader(singleton : Singleton)
        {
            singleton;
            super();
        }

        override public function generateLoader() : LoaderCore
        {
			url = UrlUtils.getMapThumbnail(mapId);
            super.generateLoader();
            return this;
        }

        override public function unloadAndStop(gc : Boolean) : void
        {
            super.unloadAndStop(gc);
            mapId = NaN;
        }
    }
}
class Singleton
{
}