package maps.elements.actions
{
	import game.core.avatar.AvatarThumb;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
     */
    public class RenderMaskAction
    {
        private var avatar : AvatarThumb;

        function RenderMaskAction(avatar : AvatarThumb) : void
        {
            this.avatar = avatar;
        }

        public function inMask() : void
        {
            avatar.alpha = 0.5;
        }

        public function outMask() : void
        {
            avatar.alpha = 1;
        }
    }
}
