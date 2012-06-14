package game.module.mapClanEscort
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import game.manager.ViewManager;
    import game.module.map.MapProto;
    import game.module.mapClanEscort.element.Dray;
    import game.module.mapClanEscort.element.DrayStatus;
    import game.module.mapClanEscort.ui.ClanEscortResultPanel;
    import game.net.data.StoC.GEDrayData;
    import game.net.data.StoC.SCGEDraySyn;
    import gameui.controls.GButton;
    import gameui.data.GButtonData;



    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-13 ����6:20:18
     */
    public class TestCEUi extends Sprite
    {
        public function TestCEUi()
        {
//            initView();
        }

        /** 单例对像 */
        private static var _instance : TestCEUi;

        /** 获取单例对像 */
        public static function get instance() : TestCEUi
        {
            if (_instance == null)
            {
                _instance = new TestCEUi();
            }
            return _instance;
        }

        private function initView() : void
        {
            var buttonData : GButtonData;
            var button : GButton;

            buttonData = new GButtonData();
            buttonData.labelData.text = "建立镖车";
			buttonData.visible = false;
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, addDray);

            buttonData = new GButtonData();
            buttonData.labelData.text = "移动";
			buttonData.visible = false;
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, move);
            
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "遇怪";
			buttonData.visible = false;
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, beRob);
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "销毁";
			buttonData.visible = false;
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, beDestroy);
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "完成";
			buttonData.visible = false;
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, complete);
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "离开";
			buttonData.visible = false;
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, quit);
            
            buttonData = new GButtonData();
            buttonData.labelData.text = "结算";
			buttonData.visible = false;
            button = new GButton(buttonData);
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, result);

            for (var i : int = 0; i < numChildren; i++)
            {
                var dis : DisplayObject = getChildAt(i);
                dis.x = i * 100;
            }

            x = 500;
            y = 450;
        }

        private function result(event : MouseEvent) : void
        {
            ClanEscortResultPanel.instance.show();
        }

        private function quit(event : MouseEvent) : void
        {
            MapProto.instance.cs_transport(1090, 1026, 30);
        }

        private function complete(event : MouseEvent) : void
        {
            var msg : SCGEDraySyn = new SCGEDraySyn();
            var drayData : GEDrayData = new GEDrayData();
            msg.dray = drayData;
            drayData.drayId = 0;
            drayData.status = DrayStatus.COMPLETE << 16 | placeId;
            proto.sc_draySynchro(msg);
        }

        private function beDestroy(event : MouseEvent) : void
        {
            var msg : SCGEDraySyn = new SCGEDraySyn();
            var drayData : GEDrayData = new GEDrayData();
            msg.dray = drayData;
            drayData.drayId = 0;
//            drayData.status = DrayStatus.BE_DESTROY << 16 | placeId;
            proto.sc_draySynchro(msg);
        }

        private function beRob(event : MouseEvent) : void
        {
            var msg : SCGEDraySyn = new SCGEDraySyn();
            var drayData : GEDrayData = new GEDrayData();
            msg.dray = drayData;
            drayData.drayId = 0;
            drayData.status = DrayStatus.BE_ROB << 16 | placeId;
            drayData.monsterHP = 101;
            drayData.monsterTotalHP = 200;
            proto.sc_draySynchro(msg);
        }
		
        private function move(event : MouseEvent) : void
        {
            var msg : SCGEDraySyn = new SCGEDraySyn();
            var drayData : GEDrayData = new GEDrayData();
            msg.dray = drayData;
            drayData.drayId = 0;
            drayData.status = DrayStatus.MOVE << 16 | placeId;
            proto.sc_draySynchro(msg);
            placeId ++;
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

        private var proto : MCEProto = MCEProto.instance;
        private var placeId : int = 0;

        private function addDray(event : MouseEvent) : void
        {
            var dray : Dray = new Dray();
            dray.id = 0;
            dray.pathId = 0;
            dray.placeId = placeId;
            dray.status = DrayStatus.MOVE;
            dray.HP = 100;
            dray.monsterHP = 0;
            dray.monsterTotalHP = 0;
            controller.addDray(dray);
        }
    }
}
