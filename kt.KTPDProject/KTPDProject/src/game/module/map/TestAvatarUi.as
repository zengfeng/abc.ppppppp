package game.module.map
{
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import game.core.avatar.AvatarThumb;
    import game.module.map.animal.AnimalManager;
    import gameui.controls.GButton;
    import gameui.data.GButtonData;



    
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-13 ����6:20:18
     */
    public class TestAvatarUi extends Sprite
    {
        public function TestAvatarUi()
        {
            initView();
        }
        
        /** 单例对像 */
        private static var _instance : TestAvatarUi;

        /** 获取单例对像 */
        public static function get instance() : TestAvatarUi
        {
            if (_instance == null)
            {
                _instance = new TestAvatarUi();
            }
            return _instance;
        }
        
        public function get avatar():AvatarThumb
        {
//            return AnimalManager.instance.
            return AnimalManager.instance.selfPlayer.avatar;
        }
        
        private function initView():void
        {
            var buttonData:GButtonData;
            var button:GButton;
            
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "站立";
            button = new GButton(buttonData);
            
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, stand);
            
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "正面战斗";
            button = new GButton(buttonData);
            
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, fontAttack);
            
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "反面战斗";
            button = new GButton(buttonData);
            
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, backAttack);
            
            for(var i:int = 0; i <numChildren; i++)
            {
                var dis:DisplayObject = getChildAt(i);
                dis.x = i * 100;
            }
           
            x = 500;
            y = 250;
            
        }
		

        private function backAttack(event : MouseEvent) : void
        {
            avatar.backAttack();
        }

        private function fontAttack(event : MouseEvent) : void
        {
            avatar.fontAttack();
        }

        private function stand(event:Event) : void
        {
            avatar.stand();
        }
    }
}
