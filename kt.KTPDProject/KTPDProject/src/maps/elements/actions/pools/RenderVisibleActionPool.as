package maps.elements.actions.pools
{
	import game.core.avatar.AvatarThumb;

	import maps.elements.actions.RenderVisibleAction;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
     */
    public class RenderVisibleActionPool
    {
        /** 单例对像 */
        private static var _instance : RenderVisibleActionPool;

        /** 获取单例对像 */
        static public function get instance() : RenderVisibleActionPool
        {
            if (_instance == null)
            {
                _instance = new RenderVisibleActionPool(new Singleton());
            }
            return _instance;
        }

        private const MAX_COUNT : int = 150;
        public var list : Vector.<RenderVisibleAction> = new Vector.<RenderVisibleAction>();

        function RenderVisibleActionPool(singleton : Singleton)
        {
        }

        public function getObject(avatar : AvatarThumb) : RenderVisibleAction
        {
            if (list.length > 0)
            {
                var action : RenderVisibleAction = list.pop();
                action.reset(avatar, 0);
                return action;
            }
            return new RenderVisibleAction(avatar, 0);
        }

        public function destoryObject(action : RenderVisibleAction, destoryed:Boolean = false) : void
        {
            if (action == null) return;
            if (list.indexOf(action) != -1) return;
            if(!destoryed) action.destory();
            if (list.length < MAX_COUNT) list.push(action);
        }
    }
}
class Singleton
{
}