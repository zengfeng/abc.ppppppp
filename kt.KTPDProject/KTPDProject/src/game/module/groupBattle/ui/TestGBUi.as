package game.module.groupBattle.ui
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import game.core.avatar.AvatarThumb;
    import game.module.groupBattle.GBController;
    import game.module.groupBattle.GBProto;
    import game.module.map.animal.AnimalManager;
    import gameui.controls.GButton;
    import gameui.data.GButtonData;



    
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-13 ����6:20:18
     */
    public class TestGBUi extends Sprite
    {
        public function TestGBUi()
        {
            initView();
//			var gbuc:GBUC = new GBUC();
//			gbuc.show();
        }
        
        /** 单例对像 */
        private static var _instance : TestGBUi;

        /** 获取单例对像 */
        public static function get instance() : TestGBUi
        {
            if (_instance == null)
            {
                _instance = new TestGBUi();
            }
            return _instance;
        }
        
        private function initView():void
        {
            var buttonData:GButtonData;
            var button:GButton;
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "进入国战";
            button = new GButton(buttonData);
            
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, enter);
            
            
            
            for(var i:int = 0; i <numChildren; i++)
            {
                var dis:DisplayObject = getChildAt(i);
                dis.x = i * 100;
            }
           
            x = 500;
            y = 250;
            
        }

        private function enter(event:Event) : void
        {
			GBController.instance.testEnter();
        }
    }
}
