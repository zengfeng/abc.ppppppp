package maps.elements.actions.pools
{
	import game.core.avatar.AvatarThumb;

	import maps.elements.actions.RenderDepthAction;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
     */
    public class RenderDepthActionPool
    {
        /** 单例对像 */
        private static var _instance : RenderDepthActionPool;

        /** 获取单例对像 */
        static public function get instance() : RenderDepthActionPool
        {
            if (_instance == null)
            {
                _instance = new RenderDepthActionPool(new Singleton());
            }
            return _instance;
        }

        private const MAX_COUNT : int = 150;
        public var list : Vector.<RenderDepthAction> = new Vector.<RenderDepthAction>();

        function RenderDepthActionPool(singleton : Singleton)
        {
        }

        public function getObject(avatar : AvatarThumb) : RenderDepthAction
        {
            if (list.length > 0)
            {
                var action : RenderDepthAction = list.pop();
                action.reset(avatar);
                return action;
            }
            return new RenderDepthAction(avatar);
        }

        public function destoryObject(action : RenderDepthAction, destoryed:Boolean = false) : void
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