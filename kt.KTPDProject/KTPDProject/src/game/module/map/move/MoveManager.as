package game.module.map.move
{
    import flash.display.Stage;
    import flash.events.Event;
    import game.module.map.utils.MapUtil;



    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-31 ����2:32:19
     */
    public class MoveManager
    {
        function MoveManager(singleton : Singleton) : void
        {
            singleton;
            init();
        }

        /** 单例对像 */
        private static var _instance : MoveManager;

        /** 获取单例对像 */
        static public function get instance() : MoveManager
        {
            if (_instance == null)
            {
                _instance = new MoveManager(new Singleton());
            }
            return _instance;
        }

        private function init() : void
        {
            moveDriveList = new Vector.<MoveDrive>();
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public function get stage() : Stage
        {
            return MapUtil.stage;
        }

        /** 移动驱动列表 */
        private var moveDriveList : Vector.<MoveDrive>;
        /** 是否在运行 */
        private var _runing : Boolean = false;

        public function set runing(value : Boolean) : void
        {
            if (_runing == value) return;
            _runing = value;
            if (_runing)
            {
                stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            }
            else
            {
                stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            }
        }

        public function get runing() : Boolean
        {
            return _runing;
        }

        /** 添加移动驱动 */
        public function addMoveDrive(moveDrive : MoveDrive) : void
        {
            if (moveDrive == null) return;
            var index : int = moveDriveList.indexOf(moveDrive);
            if (index == -1) moveDriveList.push(moveDrive);
            runCheck();
        }

        /** 移除移动驱动 */
        public function removeDrive(moveDrive : MoveDrive) : void
        {
            if (moveDrive == null) return;
            var index : int = moveDriveList.indexOf(moveDrive);
            if (index != -1) moveDriveList.splice(index, 1);
            runCheck();
        }

        /** 运行检查 */
        private function runCheck() : void
        {
            runing = (moveDriveList.length > 0);
        }

        private function onEnterFrame(event : Event) : void
        {
            for (var i : int = 0; i < moveDriveList.length; i++)
            {
                moveDriveList[i].update();
            }
        }

        public function clear() : void
        {
            runing = false;
            while (moveDriveList.length > 0)
            {
                moveDriveList.shift();
            }
        }
    }
}
class Singleton
{
}
