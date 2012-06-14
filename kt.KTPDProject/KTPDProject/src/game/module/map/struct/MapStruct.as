package game.module.map.struct
{
    import flash.geom.Point;
    import flash.utils.Dictionary;
    import game.module.map.MapSystem;
    import game.module.map.animalstruct.NpcStruct;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-26 ����7:32:52
     */
    public class MapStruct
    {
        /** 地图ID号 */
        public var id:uint;
        /** 美术资源地图ID */
        public var assetsMapId:int= 0;
        /** 地图名称 */
		public var name:String;
        /** 每一块的高宽 */
		public var singlePieceHW:Point=new Point(256,256);
        /** 整个地图的完整高宽 */
		public var mapWH:Point;
        /** 整个地图有多少块组成 */
		public var pieceRepeatWH:Point;
        /** 路径图比例尺 */
		public var pathPercentage:uint = MapSystem.PATH_PERCENTAGE;
        /** 迷你地图比例尺 */
		public var miniPercentage:uint = 16;
        /** 远景文件 */
        public var distantFile:String;
		
        /** 八卦阵(地图连接门) 存入 GateStruct 使用 toMapId 做索引 */
		public var linkGates:Dictionary	= new Dictionary();
        /** 八卦阵(地图自由传送门) 存入 GateStruct 使用 toMapId 做索引 */
		public var freeGates:Dictionary	= new Dictionary();
		/** 地图NPC字典列表 存入 NpcStruct 使用 id 做索引 */
		public var npcDic:Dictionary = new Dictionary();
        /** 地图遮罩列表 存入 maskStruct */
        public var maskList:Vector.<MaskStruct> = new Vector.<MaskStruct>();
        /** 背景特效列表 */
        public var backgroundEffectList:Vector.<BackgroundEffectStruct> = new Vector.<BackgroundEffectStruct>();
        /** 前景特效列表 */
        public var foregroundEffectList:Vector.<ForegroundEffectStruct> = new Vector.<ForegroundEffectStruct>();
        
        /** 获取NPC数据结构 */
        public function getNpcStruct(npcId:uint):NpcStruct
        {
            return npcDic[npcId];
        }
        
        /** 获取本地图的 八卦阵(地图自由传送门)*/
        public function get freeGate():GateStruct
        {
            return freeGates[id];
        }
    }
}
