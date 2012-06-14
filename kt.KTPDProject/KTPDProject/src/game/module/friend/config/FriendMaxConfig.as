package game.module.friend.config
{
    import com.utils.LVUtils;
    /**
     * @author ZengFeng[zengfeng75(At)163.com]  2011 2011-11-9  ����10:41:34 
     */
    public class FriendMaxConfig
    {
        /** 值配置 */
        public static var valueConfig : Array = [
	        										30,	// 非VIP 
											        50,	// VIP3~VIP5 
											        75,	// VIP6~VIP7 
											        100	// VIP8~VIP10
										        ];
        /** 级别配置 */
        public static var levelConfig : Array = [
	        										[0, 2],	// 非VIP 
											        [3, 5],	// VIP3~VIP5 
											        [6, 7],	// VIP6~VIP7 
											        [8, 10]	// VIP8~VIP10
        ];
        
        
        
        /** 获取级别 */
		public static function getLevel(value:Number):uint
		{
            return LVUtils.getLevel(levelConfig, value);
        }
        
		/** 获取值 */
		public static function getValue(vipLevel:uint):uint
		{
            return LVUtils.getValue(levelConfig, valueConfig, vipLevel);
        }
    }
}
