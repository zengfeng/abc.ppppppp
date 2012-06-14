package maps.elements.actions
{
	import game.core.avatar.AvatarThumb;

	import maps.elements.actions.pools.RenderDepthActionPool;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
     */
    public class RenderDepthAction
    {
        private var avatar : AvatarThumb;
        public var index:int = 0;

        function RenderDepthAction(avatar : AvatarThumb) : void
        {
            this.avatar = avatar;
            initialize();
        }

        public function reset(avatar : AvatarThumb) : void
        {
            this.avatar = avatar;
            initialize();
        }

        private function initialize() : void
        {
        }

        public function destory() : void
        {
            avatar = null;
            RenderDepthActionPool.instance.destoryObject(this, true);
        }
    }
}
