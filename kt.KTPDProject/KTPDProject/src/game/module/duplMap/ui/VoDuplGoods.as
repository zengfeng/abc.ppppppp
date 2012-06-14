package game.module.duplMap.ui
{
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-15 ����8:10:49
     */
    public class VoDuplGoods
    {
        public var id:int = 0;
        public var count:int = 0;
		/**
		 * 是否绑定 0:不绑定
		 */
		public var binding : Boolean = false;
        
        function VoDuplGoods(id:int = 0, count:int = 0, binding:Boolean = false):void
        {
            this.id = id;
            this.count = count;
            this.binding = binding;
        }
    }
}
