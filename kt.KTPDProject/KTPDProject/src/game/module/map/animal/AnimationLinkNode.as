package game.module.map.animal
{
    import com.utils.dataStruct.LinkNode;
    import game.core.avatar.AvatarThumb;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-20 ����10:33:44
     */
    public class AnimationLinkNode extends LinkNode
    {
        public function AnimationLinkNode()
        {
        }
        
        override public function compare(node : LinkNode) : int
        {
            var a:Number = data ? (data as AvatarThumb).y : 0;
            var b:Number = node && node.data ? (node.data as AvatarThumb).y : 0;
            if (a < b)
            {
                return -1;
            }
            else if (a > b)
            {
                return 1;
            }
            return 0;
        }
        
        
        override public function toString() : String
        {
            return data + "  " + "  y=" + data["y"];
        }
    }
}
