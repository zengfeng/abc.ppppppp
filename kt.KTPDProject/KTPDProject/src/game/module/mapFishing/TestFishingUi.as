package game.module.mapFishing
{
    import com.commUI.tooltip.ToolTip;
    import com.commUI.tooltip.ToolTipManager;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import game.core.user.UserData;
    import game.module.map.MapProto;
    import game.module.mapClanEscort.MCEController;
    import game.module.mapConvoy.ui.ConvoyInfoBox;
    import game.module.mapConvoy.ui.ConvoyOptionPanel;
    import game.net.data.StoC.SCAvatarInfoChange;
    import gameui.controls.GButton;
    import gameui.data.GButtonData;
    import gameui.data.GToolTipData;
    import gameui.manager.GToolTipManager;





    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-13 ����6:20:18
     */
    public class TestFishingUi extends Sprite
    {
        public function TestFishingUi()
        {
            initView();
        }

        /** 单例对像 */
        private static var _instance : TestFishingUi;

        /** 获取单例对像 */
        public static function get instance() : TestFishingUi
        {
            if (_instance == null)
            {
                _instance = new TestFishingUi();
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
            buttonData.labelData.text = "加入钓鱼";
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, selfIn);

            buttonData = new GButtonData();
            buttonData.labelData.text = "离开钓鱼";
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, selfOut);


            for (var i : int = 0; i < numChildren; i++)
            {
                var dis : DisplayObject = getChildAt(i);
                dis.x = i * 100;
            }
			
            x = 500;
            y = 250;
        }
     
        private function selfOut(event : MouseEvent) : void
        {
            var msg : SCAvatarInfoChange = new SCAvatarInfoChange();
            msg.id = UserData.instance.playerId;
            msg.model = 0;
            MapProto.instance.playerAvatarInfoChange(msg);
        }

        private function selfIn(event : MouseEvent) : void
        {
            var msg : SCAvatarInfoChange = new SCAvatarInfoChange();
            msg.id = UserData.instance.playerId;
            msg.model = 11;
            MapProto.instance.playerAvatarInfoChange(msg);
        }

        private function panel(event : MouseEvent) : void
        {
            ConvoyOptionPanel.instance.show();
            ConvoyInfoBox.instance.show();
        }
    }
}
