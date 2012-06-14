package maps.elements.core
{
	import game.core.avatar.AvatarNpc;

	import maps.elements.actions.RenderDepthAction;
	import maps.elements.actions.RenderVisibleAction;
	import maps.elements.actions.pools.RenderDepthActionPool;
	import maps.elements.actions.pools.RenderVisibleActionPool;
	import maps.elements.avatars.AvatarFactory;
	import maps.elements.core.pools.NpcElementPool;
	import maps.elements.structs.NpcStruct;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
     */
    public class NpcElement extends BaseElement
    {
        protected var struct : NpcStruct;
        protected  var avatar : AvatarNpc;
        protected var renderDepthAction : RenderDepthAction;
        protected var renderVisibleAction:RenderVisibleAction;

        public function NpcElement(npcStruct : NpcStruct, avatarNpc : AvatarNpc)
        {
            struct = npcStruct;
            avatar = avatarNpc;
            initialize();
        }

        public function reset(npcStruct : NpcStruct, avatarNpc : AvatarNpc) : void
        {
            struct = npcStruct;
            avatar = avatarNpc;
            initialize();
        }

        protected function initialize() : void
        {
            avatar.x = struct.x;
            avatar.y = struct.y;
            renderDepthAction = RenderDepthActionPool.instance.getObject(avatar);
            renderVisibleAction = RenderVisibleActionPool.instance.getObject(avatar);
            renderVisibleAction.show();
        }

        override public function destory() : void
        {
            renderDepthAction.destory();
            renderVisibleAction.destory();
            AvatarFactory.destoryAvatar(avatar);
            renderDepthAction = null;
            avatar = null;
            struct = null;
            NpcElementPool.instance.destoryObject(this, true);
        }
    }
}
