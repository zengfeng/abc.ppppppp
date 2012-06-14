package game.module.map.preload
{
    import com.utils.UrlUtils;
    import flash.geom.Point;
    import game.core.avatar.AvatarManager;
    import game.core.avatar.AvatarType;
    import game.module.map.struct.MapStruct;
    import game.module.map.utils.MapUtil;
    import game.module.map.utils.ResKey;
    import net.LibData;




    /**
     *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-18
     */
    public class LibDataUtil
    {
        // ==================
        // 公共
        // ==================
        public static function gate() : LibData
        {
            var url : String = UrlUtils.FILE_GATE;
            var key : String = ResKey.gate;
            return new LibData(url, key, true);
        }

        // ==================
        // 独立地图
        // ==================
        public static function pathDataSwf(mapId : uint) : LibData
        {
            var url : String = UrlUtils.getMapPathDataSwf(mapId);
            var key : String = ResKey.pathDataSwf(mapId);
            return new LibData(url, key, true);
        }

        public static function thumbnail(mapId : uint) : LibData
        {
            var url : String = UrlUtils.getMapThumbnail(mapId);
            var key : String = ResKey.thumbnail(mapId);
            return new LibData(url, key, true);
        }

        public static function mapPieceList(mapId : uint, list : Vector.<LibData> = null) : Vector.<LibData>
        {
            if (list == null)
            {
                list = new Vector.<LibData>();
            }
            var mapStruct : MapStruct = MapUtil.getMapStruct(mapId);
            var pieceRepeatHW : Point = new Point();

            var libData : LibData;
            pieceRepeatHW.x = Math.ceil(mapStruct.mapWH.x / mapStruct.singlePieceHW.x) - 1;
            pieceRepeatHW.y = Math.ceil(mapStruct.mapWH.y / mapStruct.singlePieceHW.y) - 1;
            for (var y : int = 0; y <= pieceRepeatHW.y; y++)
            {
                for (var x : int = 0; x <= pieceRepeatHW.x; x++)
                {
                    libData = mapPiece(mapStruct.assetsMapId, x, y);
                    list.push(libData);
                }
            }
            return list;
        }

        public static function mapPieceScreenList(mapId : uint, mapX : int, mapY : int, stageWidth : int, stageHeight : int, list : Vector.<LibData> = null) : Vector.<LibData>
        {
            if (list == null)
            {
                list = new Vector.<LibData>();
            }
            var mapStruct : MapStruct = MapUtil.getMapStruct(mapId);

            var libData : LibData;
            var countX:int = Math.ceil(mapX/ mapStruct.singlePieceHW.x) - 1;
            var countY:int  = Math.ceil(mapX / mapStruct.singlePieceHW.y) - 1;
            var startX:int = mapX/ mapStruct.singlePieceHW.x;
            var startY:int = mapY/ mapStruct.singlePieceHW.y;
            var endX:int = startX + int(stageWidth /  mapStruct.singlePieceHW.x);
            var endY:int = startY + int(stageHeight /  mapStruct.singlePieceHW.x);
            if(endX > countX) endX = countX;
            if(endY > countY) endY = countY;
            for (var y : int = startY; y <= endY; y++)
            {
                for (var x : int = startX; x <= endX; x++)
                {
                    libData = mapPiece(mapStruct.assetsMapId, x, y);
                    list.push(libData);
                }
            }
            return list;
        }

        public static function mapPiece(mapId : int, x : int, y : int) : LibData
        {
            var key : String = ResKey.piece(mapId, x, y);
            var url : String = UrlUtils.getMapPiece2(mapId, x, y);
            return new LibData(url, key, true);
        }

        public static function monster(avatarId : int) : LibData
        {
            return avatar(avatarId, AvatarType.MONSTER_TYPE);
        }

        public static function avatar(avatarId : uint, type : uint, cloth : uint = 0) : LibData
        {
            var uuid : int = AvatarManager.instance.getUUId(avatarId, type, cloth);
            var url : String = UrlUtils.getAvatar(uuid);
            var key : String = uuid + "";
            return new LibData(url, key, true);
        }
    }
}
