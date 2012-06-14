package game.module.mapConvoy
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import game.core.user.UserData;
    import game.module.map.MapProto;
    import game.module.mapClanEscort.MCEController;
    import game.module.mapConvoy.ui.ConvoyInfoBox2;
    import game.module.mapConvoy.ui.ConvoyOptionPanel;
    import game.net.data.StoC.SCAvatarInfoChange;
    import gameui.controls.GButton;
    import gameui.data.GButtonData;



    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-13 ����6:20:18
     */
    public class TestConvoyUi extends Sprite
    {
        public function TestConvoyUi()
        {
            initView();
            ConvoyInfoBox2.instance.show();
        }

        /** 单例对像 */
        private static var _instance : TestConvoyUi;

        /** 获取单例对像 */
        public static function get instance() : TestConvoyUi
        {
            if (_instance == null)
            {
                _instance = new TestConvoyUi();
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
            buttonData.labelData.text = "传送";
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, tran);
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "传送1";
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, tran1);
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "传送2";
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, tran2);
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "传送3";
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, tran3);
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "传送4";
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, tran4);
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "传送5";
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, tran5);
            
            
//            buttonData = new GButtonData();
//            buttonData.labelData.text = "面板";
//            button = new GButton(buttonData);
//            addChild(button);
//            button.addEventListener(MouseEvent.CLICK, panel);
//
//            buttonData = new GButtonData();
//            buttonData.labelData.text = "加入龟拜";
//            button = new GButton(buttonData);
//            addChild(button);
//            button.addEventListener(MouseEvent.CLICK, selfIn);
//
//            buttonData = new GButtonData();
//            buttonData.labelData.text = "加速";
//            button = new GButton(buttonData);
//            addChild(button);
//            button.addEventListener(MouseEvent.CLICK, selfSpeedUp);
//
//            buttonData = new GButtonData();
//            buttonData.labelData.text = "离开龟拜";
//            button = new GButton(buttonData);
//            addChild(button);
//            button.addEventListener(MouseEvent.CLICK, selfOut);
//
//            buttonData = new GButtonData();
////            buttonData.toolTipData = new GToolTipData();
//            buttonData.labelData.text = "TIP";
//            button = new GButton(buttonData);
//            button.toolTip = new GToolTip(new GToolTipData());
//            button.toolTip.source = "啦啦啦。。。。。。。。。。。。。。。。";
//            addChild(button);

//            var str : String = "<b><font size='14' color='#FFCC00'>分组规则：</font></b>系统将根据参赛者的等级随机分配至任意一组\n";
//            str += "<b><font size='14' color='#FFCC00'>胜败机制：</font></b>蜀山论剑结束时，获得总积分较多的一组为胜利组";
            // var toolTipData:GToolTipData = new GToolTipData();
            // toolTipData.labelData.minWidth = 210;
            // var toolTip:ToolTip = new ToolTip(toolTipData);
            // toolTip.source = str;
            // button.toolTip = toolTip;
            // GToolTipManager.registerToolTip(button);
            
//            ToolTipManager.instance.registerToolTip(button, ToolTip, getTipContent);
//             ToolTipManager.instance.destroyToolTip(button);

            for (var i : int = 0; i < numChildren; i++)
            {
                var dis : DisplayObject = getChildAt(i);
                dis.x = i * 100;
            }
			
            x = 500;
            y = 180;
        }

        private function tran5(event : MouseEvent) : void
        {
            MapProto.instance.cs_transport(4544, 2960, 2);
        }

        private function tran(event : MouseEvent) : void
        {
            MapProto.instance.cs_transport(5000, 3000, 20);
        }

        private function tran1(event : MouseEvent) : void
        {
            MapProto.instance.cs_transport(3968, 2272, 20);
        }

        private function tran2(event : MouseEvent) : void
        {
            MapProto.instance.cs_transport(2448, 3824, 20);
        }
        
        

        private function tran3(event : MouseEvent) : void
        {
            MapProto.instance.cs_transport(5072, 4544, 20);
        }
        
        private function tran4(event : MouseEvent) : void
        {
            MapProto.instance.cs_transport(7296,3616, 20);
        }
        public function getTipContent() : String
        {
            var str : String = "";
            str += "<font color='__PLAYER_COLOR__' size='14'><b>__PLAYER_NAME__</b></font>   __LEVEL__级\n";
            str += "护送香炉:<font color='__XIANG_LU_COLOR__'>__XIANG_LU_NAME__</font>\n";
            str += "剩余时间:__TIME__\n";
            str += "被截次数:<font color='#DDDD2C'>__BE_ROB_NUM__/__BE_ROB_MAX_NUM__</font>\n";
            str += "打劫获得:__SIVLER__银币\n";
            str += "         __HONOUR__声望\n";
            
            str = str.replace(/__PLAYER_COLOR__/, "#FF0000");
            str = str.replace(/__PLAYER_NAME__/, "大海明月");
            str = str.replace(/__LEVEL__/, 999);
            str = str.replace(/__XIANG_LU_COLOR__/, "#6d8E3F");
            str = str.replace(/__XIANG_LU_NAME__/, "中等香炉");
            str = str.replace(/__TIME__/, "25:36");
            str = str.replace(/__BE_ROB_NUM__/, 1);
            str = str.replace(/__BE_ROB_MAX_NUM__/, 2);
            str = str.replace(/__SIVLER__/, 999999959);
            str = str.replace(/__HONOUR__/, 54564654);
            return str;
        }

        private function selfSpeedUp(event : MouseEvent) : void
        {
            var msg : SCAvatarInfoChange = new SCAvatarInfoChange();
            msg.id = UserData.instance.playerId;
            msg.model = 5;
            MapProto.instance.playerAvatarInfoChange(msg);
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
            msg.model = 1;
            MapProto.instance.playerAvatarInfoChange(msg);
        }

        private function panel(event : MouseEvent) : void
        {
            ConvoyOptionPanel.instance.show();
            ConvoyInfoBox2.instance.show();
//            ConvoyInfoBox.instance.show();
        }
    }
}
