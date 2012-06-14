package game.module.map.animal
{
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-30 ����11:15:17
     */
    public interface IAnimal
    {
        /** 站立 */
        function stand():void;
        
        /** 表情姿势动作 */
        function motion():void;
        
        /** 设置位置 */
        function setPosition(x:int, y:int):void;
        
        /** 走路 */
        function walk(x:int, y:int):void;
        
        /** 死亡 */
        function die():void;
        
        /** 退出 */
        function quit():void;
		
		/** 追捕 */
        function pursue(animal : Animal = null):void;
		
		/** 漫游 */
        function wander():void;
		
		/** 状态 */
		function get status():String;
		
		/** 状态 */
		function set status(status:String):void;
		
		
    }
}
