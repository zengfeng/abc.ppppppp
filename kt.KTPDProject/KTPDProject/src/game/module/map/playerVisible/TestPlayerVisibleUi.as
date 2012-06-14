package game.module.map.playerVisible
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import game.module.mapClanEscort.MCEController;
    import gameui.controls.GButton;
    import gameui.data.GButtonData;



    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-13 ����6:20:18
     */
    public class TestPlayerVisibleUi extends Sprite
    {
        public function TestPlayerVisibleUi()
        {
            initView();
        }

        /** 单例对像 */
        private static var _instance : TestPlayerVisibleUi;

        /** 获取单例对像 */
        public static function get instance() : TestPlayerVisibleUi
        {
            if (_instance == null)
            {
                _instance = new TestPlayerVisibleUi();
            }
            return _instance;
        }
        
        
        /** 控制器 */
        private var _controller : MCEController;

        /** 控制器 */
        public function get controller() : MCEController
        {
            if (_controller == null)
            {
                _controller = MCEController.instance;
            }
            return _controller;
        }

        private function initView() : void
        {
            var buttonData : GButtonData;
            var button : GButton;

            buttonData = new GButtonData();
            buttonData.labelData.text = "是否显示其他玩家";
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, otherPlayerVisible);

            for (var i : int = 0; i < numChildren; i++)
            {
                var dis : DisplayObject = getChildAt(i);
                dis.x = i * 100;
            }

            x = 100;
            y = 450;
        }

        private function otherPlayerVisible(event : MouseEvent) : void
        {
            OtherPlayerVisibleMananger.instance.visible = !OtherPlayerVisibleMananger.instance.visible;
        }


       

    }
}
