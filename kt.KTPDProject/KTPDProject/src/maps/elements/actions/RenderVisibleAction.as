package maps.elements.actions
{
	import game.core.avatar.AvatarThumb;
	import maps.elements.ElementSignals;
	import maps.elements.actions.pools.RenderVisibleActionPool;


    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
     */
    public class RenderVisibleAction
    {
        private var avatar : AvatarThumb;
        private var childIndex:int;

        function RenderVisibleAction(avatar : AvatarThumb, childIndex:uint) : void
        {
            this.avatar = avatar;
            this.childIndex = childIndex;
        }
        
        public function reset(avatar : AvatarThumb, childIndex:uint) : void
        {
            this.avatar = avatar;
            this.childIndex = childIndex;
        }
        

        public function show() : void
        {
            ElementSignals.ADD_TO_LAYER.dispatch(avatar, childIndex);
        }

        public function hide() : void
        {
            ElementSignals.REMOVE_FROM_LAYER.dispatch(avatar);
        }

        public function destory() : void
        {
            hide();
            avatar = null;
            RenderVisibleActionPool.instance.destoryObject(this, true);
        }
    }
}
