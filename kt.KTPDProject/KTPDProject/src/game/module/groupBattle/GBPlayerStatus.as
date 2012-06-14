package game.module.groupBattle
{
    import net.RESManager;
    import gameui.manager.UIManager;

    import net.AssetData;

    import com.utils.DrawUtils;

    import flash.display.BitmapData;
    import flash.display.Sprite;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-14 ����6:05:13
     * 玩家状态
     */
    public class GBPlayerStatus
    {
        /** 未知 */
        public static const UNKNOW : uint = 0;
        /** 在交战区处于休息状态 */
        public static const REST : uint = 1;
        /** 战斗状态 */
        public static const VS : uint = 2;
        /** 等待状态 */
        public static const WAIT : uint = 3;
        /** 死亡状态 */
        public static const DIE : uint = 4;
        /** 移动状态 */
        public static const MOVE:uint = 5;
        
        
        /** 在交战区处于休息状态ICON */
        private static var _restIcon : BitmapData;
        /** 在交战区处于休息状态ICON */
        public static function get restIcon() : BitmapData
        {
            if (_restIcon == null)
            {
                _restIcon = RESManager.getBitmapData(new AssetData("GroupBattle_StatusRestIcon"));
            }
            return _restIcon;
        }
        
        
        /** 战斗状态ICON */
        private static var _vsIcon : BitmapData;
        /** 战斗状态ICON */
        public static function get vsIcon() : BitmapData
        {
            if (_vsIcon == null)
            {
                _vsIcon = RESManager.getBitmapData(new AssetData("GroupBattle_StatusVsIcon"));
            }
            return _vsIcon;
        }
        
        
        /** 等待状态ICON */
        private static var _waitIcon : BitmapData;
        /** 等待状态ICON */
        public static function get waitIcon() : BitmapData
        {
            if (_waitIcon == null)
            {
                _waitIcon = RESManager.getBitmapData(new AssetData("GroupBattle_StatusWaitIcon"));
            }
            return _waitIcon;
        }
        
        
        /** 死亡状态ICON */
        private static var _dieIcon : BitmapData;
        /** 死亡状态ICON */
        public static function get dieIcon() : BitmapData
        {
            if (_dieIcon == null)
            {
                _dieIcon = null;
            }
            return _dieIcon;
        }
        
        public static function clear():void
        {
            if(_restIcon) _restIcon.dispose();
            _restIcon = null;
            
            if(_vsIcon) _vsIcon.dispose();
            _vsIcon = null;
            
            if(_waitIcon) _waitIcon.dispose();
            _waitIcon = null;
            
            if(_waitIcon) _waitIcon.dispose();
            _waitIcon = null;
            
            if(_dieIcon) _dieIcon.dispose();
            _dieIcon = null;
        }
    }
}
