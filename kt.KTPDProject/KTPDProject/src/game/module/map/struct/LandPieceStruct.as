package game.module.map.struct
{
    import flash.display.BitmapData;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-28 ����10:57:20
     */
    public class LandPieceStruct
    {
        public var fileName:String = "";
        public var key:String = "";
        public var x:int;
        public var y:int;
        public var bitmapData:BitmapData;
        
        public function clear():void
        {
            if(bitmapData) bitmapData.dispose();
        }
    }
}
