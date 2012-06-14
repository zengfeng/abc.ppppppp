package game.module.map.utils
{
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-27 ����9:27:18
     */
    public class ResKey
    {
        /** 缩略图 */
        public static function thumbnail(mapId:uint):String
        {
            return "mapThumbnail_" + mapId;
        }
        
        /** 地图块 */
        public static function piece(mapId:uint, x:int, y:int):String
        {
            return "mapPiece_" + mapId + "_" + y + "_" + x;
        }
        
        /** 寻路数据swf */
        public static function pathDataSwf(mapId:uint):String
        {
            return "mapPathDataSwf_" + mapId;
        }
        
        /** 远景 */
        public static function distant(fileName:String):String
        {
            return fileName;
        }
        
        /** 远景缩略 */
        public static function distantThumbnail(fileName:String):String
        {
            return fileName += "_thum";
        }
        
        
        
        /** 八卦阵(出口入口)swf */
        public static const gate:String = "mapGate";
        
        
    }
}
