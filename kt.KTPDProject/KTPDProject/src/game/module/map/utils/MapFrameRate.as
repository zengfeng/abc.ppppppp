package game.module.map.utils
{
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-29 ����10:38:09
     */
    public class MapFrameRate
    {/** 单例对像 */
        private static var _instance : MapFrameRate;

        /** 获取单例对像 */
        static public function get instance() : MapFrameRate
        {
            if (_instance == null)
            {
                _instance = new MapFrameRate();
            }
            return _instance;
        }
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 加载地图块，每多少帧运行一次 */
        public const LOAD_PIECE:int = 30;
        /** 加载地图块的当前帧 */
        public var loadPieceFrame:int = 0;
        /** 加载地图块是否运行 */
        public function loadPieceIsRun(isEnforce:Boolean = false):Boolean
        {
            if(isEnforce == true) return true;
            if(loadPieceFrame % LOAD_PIECE == 0) return true;
            return false;
        }
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 八卦阵(出口入口)检测，每多少帧运行一次 */
        public const CHECK_GATE:int = 5;
        /** 八卦阵(出口入口)检测的当前帧 */
        public var checkGateFrame:int = 0;
        /** 八卦阵(出口入口)检测是否运行 */
        public function checkGateIsRun():Boolean
        {
            if(checkGateFrame % CHECK_GATE == 0) return true;
            return false;
        }
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public function clear():void
        {
            //加载地图块的当前帧
            loadPieceFrame = 0;
            //八卦阵(出口入口)检测的当前帧
            checkGateFrame = 0;
        }
    }
}
