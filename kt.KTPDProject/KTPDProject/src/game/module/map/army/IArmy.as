package game.module.map.army {
	import com.utils.Vector2D;
	import game.module.map.animal.Animal;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-6 ����9:11:14
     */
    public interface IArmy
    {
		/** 阵营 */
        function get armyGroup():ArmyGroup;
		/** 阵营 */
        function set armyGroup(armyGroup:ArmyGroup):void;
		
        /** 敌方目标 */
        function get enemy(): Animal;
        /** 敌方目标 */
        function set enemy(army:Animal): void;
        
        function get position():Vector2D;
		
		/** 阵营开始 */
		function armyStart():void;
		/** 阵营停止 */
		function armyStop():void;
		/** 阵营运行 */
		function armyRuning():void;
		/** 阵营退出 */
		function quit():void;
		
//		/** 检测敌人 */
//        function checkEnemy():IArmy;
		/** 追捕 */
        function pursue(animal : Animal = null):void;
		/** 漫游 */
        function wander():void;
        
    }
}
