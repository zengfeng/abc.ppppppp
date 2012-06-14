package game.module.map.struct
{
    import flash.geom.Point;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-26 ����7:52:44
     */
    public class GateStruct
    {
		public var id:int = 0;
        /** 位置 */
        public var position:Point;
        /** 前住地图ID */
		public var toMapId:uint;
        /** 站立位置 */
		public var standPosition:Point;
    }
}
