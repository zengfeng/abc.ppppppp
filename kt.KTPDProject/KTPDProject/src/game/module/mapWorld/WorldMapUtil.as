package game.module.mapWorld
{
    import game.module.map.utils.MapUtil;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-3-26 ����9:09:01
     */
    public class WorldMapUtil
    {
        
        /** 获取世界地图ID */
        public static function getWorldMapId(mapId:int = 0):int
        {
            if(mapId == 0) mapId = MapUtil.getCurrentMapId();
			if(MapUtil.isDungeonMap(mapId))
			{
				mapId = MapUtil.getDuplParentMapId(mapId);
			}
            var worldMapStruct:WorldMapStruct = WorldMapConfig.worldMap[mapId];
            if(worldMapStruct == null)
            {
                worldMapStruct = WorldMapConfig.copyMap[mapId];
                mapId = worldMapStruct.parentMap;
            }
            return mapId;
        }
        
    }
}
