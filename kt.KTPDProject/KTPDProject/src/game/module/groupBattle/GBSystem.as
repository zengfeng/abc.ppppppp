package game.module.groupBattle
{
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-12 ����6:26:06
     * 蜀山论剑系统
     */
    public class GBSystem
    {
        /** 阵营级别1 */
        public static const GROUP_LEVEL_1:int = 0;
        /** 阵营级别2 */
        public static const GROUP_LEVEL_2:int = 70;
        
        /** 阵营A的ID */
        public static const GROUP_A_ID:int = 1;
        /** 阵营B的ID */
        public static const GROUP_B_ID:int = 2;
        
        /** 是否有高级阵营 */
        public static var hasHighlevel:Boolean = false;
        
        
        /** 蜀山论剑控制器 */
        private static var gbController : GBController = GBController.instance;
        
        /** 退出 */
        public static function quit():void
        {
            GBProto.instance.cs_quit();
//            gbController.clear();
        }
    }
}
