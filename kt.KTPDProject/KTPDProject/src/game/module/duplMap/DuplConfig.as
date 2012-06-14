package game.module.duplMap
{
    /**
     *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-16
     */
    public class DuplConfig
    {
        /** 波:服务器反回通关 */
        public static const WAVE_PASS : int = 100;
        /** 波:服务器反回战斗失败 */
        public static const WAVE_BATTLE_LOSE : int = 99;
        public static const MIN_PACK_EMPTY : int = 8;
        /** 退出时打开面板 */
        private static var _QUIT_OPEN_WEINDOW_ENTER : Boolean = true;

        public static function get QUIT_OPEN_WEINDOW_ENTER() : Boolean
        {
            return _QUIT_OPEN_WEINDOW_ENTER;
        }

        public static function set QUIT_OPEN_WEINDOW_ENTER(value : Boolean) : void
        {
            _QUIT_OPEN_WEINDOW_ENTER = value;
        }

//        /** 退出时是否退出到父地图 */
//        private static var _QUIT_IS_TO_PARENT_MAP : Boolean = true;
//
//        public static function get QUIT_IS_TO_PARENT_MAP() : Boolean
//        {
//            return _QUIT_IS_TO_PARENT_MAP;
//        }
//
//        public static function set QUIT_IS_TO_PARENT_MAP(value : Boolean) : void
//        {
//            _QUIT_IS_TO_PARENT_MAP = value;
//            if (_QUIT_IS_TO_PARENT_MAP == false) QUIT_OPEN_WEINDOW_ENTER = false;
//        }
    }
}
