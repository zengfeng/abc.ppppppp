package game.module.map.utils
{
    import flash.display.DisplayObject;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-10 ����5:01:18
     */
    public class LinkTableNode
    {
        /** ID */
        private var _id:int;
        /** 数据 */
        public var data:DisplayObject;
        /** 上一个节点 */
        public var prev:LinkTableNode;
        /** 下一个节点 */
        public var next:LinkTableNode;
        
        function LinkTableNode(data:DisplayObject = null):void
        {
            this.data = data;
        }
        
        /** 清理 */
        public function clear():void
        {
            prev = null;
            next = null;
        }
		private static var autoId:int = 593705098;
        public function get id() : int
        {
            if(_id == 0)
            {
                _id = autoId;
                autoId ++;
            }
            return _id;
        }

        public function set id(id : int) : void
        {
            _id = id;
        }

        
    }
}
