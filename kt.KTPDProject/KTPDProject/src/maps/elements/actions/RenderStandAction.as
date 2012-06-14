package maps.elements.actions
{
	import game.core.avatar.AvatarThumb;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
     */
    public class RenderStandAction
    {
        private var avatar : AvatarThumb;

        function RenderStandAction(avatar : AvatarThumb) : void
        {
            this.avatar = avatar;
        }

		/** 站立 */
		public function standAction() : void
		{
            avatar.stand();
		}
		
		/** 站立方向 */
		public function standDirection(targetX:int, targetY:int, x:int = 0, y:int = 0):void
		{
			avatar.standDirection(targetX, targetY, x, y);
		}

		/** 打坐 */
		public function sitdownAction() : void
		{
            avatar.sitdown();
		}
    }
}
