package game.module.groupBattle.ui
{
    import framerate.SecondsTimer;


    import gameui.controls.GButton;
    import gameui.core.GComponent;
    import gameui.core.GComponentData;
    import gameui.data.GButtonData;
    import gameui.data.GToolTipData;
    import gameui.manager.UIManager;

    import net.AssetData;

    import com.utils.TimeUtil;

    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-2 ����4:12:42
     */
    public class UiDieTimer extends GComponent
    {
        /** 背景 */
        private var bg : Sprite;
        /** 文本 */
        private var tf : TextField;
        /** 快速复活按钮 */
        private var button : GButton;
        private var _time : int = 0;
        private var running : Boolean = false;
        public var buttonClickCall:Function;
        public var completeCall:Function;

        public function UiDieTimer()
        {
            _base = new GComponentData();
            _base.width = 75;
            _base.height = 24;
            super(_base);

            initViews();
            addEventListener(MouseEvent.CLICK, onClick);
        }

        private function onClick(event : MouseEvent) : void
        {
            event.stopPropagation();
        }

        /** 初始化视图 */
        protected function initViews() : void
        {
            bg = UIManager.getUI(new AssetData("GroupBattle_OverTimeBg"));
            bg.width = _base.width;
            bg.height = _base.height;
            addChild(bg);

            var textFormat : TextFormat = new TextFormat();
            textFormat.size = 16;
            textFormat.color = 0x000000;
            textFormat.align = TextFormatAlign.LEFT;
            textFormat.bold = true;
            textFormat.font = UIManager.defaultFont;
            var tempTF : TextField = new TextField();
            tempTF.selectable = false;
            tempTF.defaultTextFormat = textFormat;
            tempTF.width = 60;
            tempTF.height = _base.height;
            tempTF.x = 0;
            tempTF.y = 0;
            tempTF.text = "30:05";
            addChild(tempTF);
            tf = tempTF;

            // 快速复活按钮
            var buttonData : GButtonData;
            buttonData = new GButtonData();
            buttonData.width = 25;
            buttonData.height = 22;
            buttonData.x = _base.width - buttonData.width;
            buttonData.y = (_base.height - buttonData.height) / 2;
            buttonData.toolTipData = new GToolTipData();
            button = new GButton(buttonData);
            button.toolTip.source = "花费10元宝立即复活";
            button.addEventListener(MouseEvent.CLICK, fastResurrection);
            addChild(button);

            var buttonIcon : Sprite = UIManager.getUI(new AssetData("FastIcon"));
            buttonIcon.x = (button.width - buttonIcon.width) / 2;
            buttonIcon.y = (button.height - buttonIcon.height) / 2;
            button.addChild(buttonIcon);
        }

        /** 快速复活按钮 点击事件 */
        private function fastResurrection(event : MouseEvent) : void
        {
            if(buttonClickCall != null) buttonClickCall.apply(null, []);
            event.stopPropagation();
        }
        
        //设置按钮tips  pic:价格
        public function setTimersTip(pic:int):void{
             button.toolTip.source = "花费"+pic+"元宝立即复活";
        }

        public function get time() : int
        {
            return _time;
        }

        public function set time(time : int) : void
        {
            _time = time;
            tf.text = TimeUtil.toMMSS(time);
            if (_time > 0 && running == false)
            {
                running = true;
                SecondsTimer.addFunction(secondsTimer);
            }
            else if (_time <= 0)
            {
                onComplete();
            }
        }

        private function secondsTimer() : void
        {
            time -= 1;
        }

        public function stop() : void
        {
            running = false;
            SecondsTimer.removeFunction(secondsTimer);
            if (parent) parent.removeChild(this);
        }

        private function onComplete() : void
        {
            if(completeCall != null) completeCall.apply(null, []);
            stop();
        }
    }
}
