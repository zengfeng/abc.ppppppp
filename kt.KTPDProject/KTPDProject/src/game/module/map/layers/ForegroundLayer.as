package game.module.map.layers
{
    import flash.display.Sprite;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-26 ����3:30:29
     * 地图前景层
     */
    public class ForegroundLayer extends Sprite
    {
        public function ForegroundLayer()
        {
            init();
        }
        
        /** 初始化 */
        public function init():void
        {
            this.mouseChildren = false;
            this.mouseEnabled = false;
        }
    }
}
