package game.module.map.move
{
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-31 ����1:58:19
     * 移动者
     */
    public interface IMover
    {
        /** x坐标 */
        function get x():int;
        function set x(value:int):void;
        /** y坐标 */
        function get y():int;
        function set y(value:int):void;
        /** 设置位置 */
        function setPostion(x:int, y:int):void;
        /** 移动到 */
        function moveTo(x:int, y:int):void;
        function go(x:int, y:int):void;
        /** 停止移动 */
        function stopMove():void;
        /** 转弯处 */
        function turn(x:int, y:int):void;
    }
}
