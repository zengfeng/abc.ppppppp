package game.module.map.preload
{
	import game.module.map.struct.MapStruct;
	import game.module.map.utils.MapUtil;

	import net.LibData;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-14
     */
    public class PreloadBigMap
    {
        function PreloadBigMap(singleton : Singleton)
        {
            singleton;
        }

        /** 单例对像 */
        private static var _instance : PreloadBigMap;

        /** 获取单例对像 */
        static public function get instance() : PreloadBigMap
        {
            if (_instance == null)
            {
                _instance = new PreloadBigMap(new Singleton());
            }
            return _instance;
        }
        
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		private var mapPreloadMananger : MapPreloadManager = MapPreloadManager.instance;
		private var isSetCommon : Boolean = false;

		public function setLoadList(mapId : int,mapX : int, mapY : int, stageWidth : int, stageHeight : int) : void
		{
			var mapStruct : MapStruct = MapUtil.getMapStruct(mapId);
			var list : Vector.<LibData> = new Vector.<LibData>();
			var libData : LibData;
			libData = LibDataUtil.pathDataSwf(mapStruct.assetsMapId);
			list.push(libData);
			libData = LibDataUtil.thumbnail(mapStruct.assetsMapId);
			list.push(libData);
			LibDataUtil.mapPieceScreenList(mapId, mapX, mapY, stageWidth, stageHeight);
//			mapPreloadMananger.list = list;
			if (isSetCommon == false)
			{
				setCommon();
			}
		}

		private function setCommon() : void
		{
			isSetCommon = true;
		}
    }
}
class Singleton
{
}