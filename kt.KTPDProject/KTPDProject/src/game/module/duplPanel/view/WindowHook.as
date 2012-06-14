package game.module.duplPanel.view
{
    import com.commUI.GCommonSmallWindow;
    import com.utils.UIUtil;
    import com.utils.UrlUtils;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import game.core.user.UserData;
    import game.definition.UI;
    import game.manager.ViewManager;
    import game.module.duplPanel.DuplPanelConfig;
    import gameui.controls.GButton;
    import gameui.controls.GTextInput;
    import gameui.data.GButtonData;
    import gameui.data.GTextInputData;
    import gameui.data.GTitleWindowData;
    import gameui.data.GToolTipData;
    import gameui.manager.UIManager;
    import net.AssetData;
    import net.RESManager;





    /**
     *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-12
     */
    public class WindowHook extends GCommonSmallWindow
    {
        /** 单例对像 */
        private static var _instance : WindowHook;

        /** 获取单例对像 */
        public static function get instance() : WindowHook
        {
            if (_instance == null)
            {
                _instance = new WindowHook();
            }
            return _instance;
        }

        public function WindowHook(useMoudel:int = 0)
        {
			this.useMoudel = useMoudel;
            _data = new GTitleWindowData();
            _data.visible = false;
            _data.width = 534;
            _data.height = 320;
            _data.parent = ViewManager.instance.uiContainer;
            _data.modal = false;
            _data.allowDrag = true;
            super(_data);
        }

        /** 文本 挂机剩余时间：00分钟*/
        public const TEXT_TIMELEFT : String = "挂机剩余时间：<font color='#FF3300'>__NUM__分钟</font>";
        /** 文本 今日剩余免费进入次数: */
        public const TEXT_REMAIN_NUM_FREE : String = "（剩余免费进入次数：<font color='#FF3300'>__NUM__</font>）";
        /** 文本 （ 可购买次数:  10 ）*/
        public const TEXT_REMAIN_NUM : String = "<font color='#FF3300'>（ 可购买次数：__NUM__ ）</font>";
        /** 文本 次*/
        public const TEXT_NUM_FREE : String = "次";
        /** 文本 次，需__NUM__元宝*/
        public const TEXT_NUM : String = "次，需<font color='#FF3300'>__NUM__</font>元宝";
        /**正文区块宽 */
        private const BODY_WIDTH : int = 505;
        /** 正文区块高 */
        private const BODY_HEIGHT : int = 295;
        private const CENTER_TOP : int = 15;
        private const CENTER_BOTTOM : int = 68;
        /** 正文容器 */
        private var bodyContainer : Sprite;
        /** 剩余时间 */
        public var timeLeftLabel : TextField;
        /** 头像图标 */
        public var icon : HeadIcon;
        /** 次数输入框容器 */
        /** 正文容器 */
        private var numTextInputContainer : Sprite;
        /** 次数输入框 */
        public var numTextInput : GTextInput;
        /** 次数Label */
        private var numTF : TextField;
        /** 剩余次数Label */
        private var remainNumTF : TextField;
        /** 今日进入副本本次数已满Label */
        private var noNumTF : TextField;
        /** 开始按钮 */
        public var startButton : GButton;
        /** 停止按钮 */
        public var stopButton : GButton;
        /** 立即完成 */
        public  var fastButton : GButton;
        /** 物品栏 */
        public var goodsBox : HookGoodsBox;
        /** 日志栏 */
        public var logBox : HookLogBox;
        public var isFree : Boolean = true;
        public var remainNum : int = 1;
		public var buyGold:int = DuplPanelConfig.BUY_NUM_GOLD;
		public var useMoudel:int = 0;

        override protected function initViews() : void
        {
            super.initViews();
            title = "副本名称挂机";

            var bodyBg : Sprite = UIManager.getUI(new AssetData(UI.PANEL_BACKGROUND));
            bodyBg.width = 522;
            bodyBg.height = 314;
            bodyBg.x = (_data.width - bodyBg.width) / 2;
            _contentPanel.addChild(bodyBg);

            bodyContainer = new Sprite();
            bodyContainer.x = (_data.width - BODY_WIDTH) / 2;
            bodyContainer.y = (_contentPanel.height - BODY_HEIGHT) / 2;
            addChild(bodyContainer);

            var sprite : Sprite;
            // 右侧中背景
            sprite = UIManager.getUI(new AssetData(UI.PANEL_BACKGROUND2));
            sprite.width = 173;
            sprite.height = BODY_HEIGHT - CENTER_TOP - CENTER_BOTTOM ;
            sprite.x = BODY_WIDTH - sprite.width ;
            sprite.y = CENTER_TOP;
            bodyContainer.addChild(sprite);
            var rightCenterBg : Sprite = sprite;

            // 左侧中背景
            sprite = UIManager.getUI(new AssetData(UI.PANEL_BACKGROUND2));
            sprite.width = BODY_WIDTH - rightCenterBg.width - 6;
            sprite.height = rightCenterBg.height;
            sprite.x = 0;
            sprite.y = CENTER_TOP;
            bodyContainer.addChild(sprite);
            var leftCenterBg : Sprite = sprite;

            // 左侧下背景
            sprite = UIManager.getUI(new AssetData(UI.PACK_BACKGROUND));
            sprite.width = leftCenterBg.width;
            sprite.height = CENTER_BOTTOM - 4;
            sprite.x = 0;
            sprite.y = BODY_HEIGHT - sprite.height;
            bodyContainer.addChild(sprite);
            var leftBottomBg : Sprite = sprite;

            // 右侧中
            const RIGHT_CENTER_WIDTH : int = rightCenterBg.width ;
            const RIGHT_CENTER_HEIGHT : int = rightCenterBg.height;
            sprite = new Sprite();
            sprite.x = rightCenterBg.x;
            sprite.y = rightCenterBg.y;
            bodyContainer.addChild(sprite);
            // 剩余时间

            var textFormat : TextFormat = new TextFormat();
            textFormat.font = UIManager.defaultFont;
            textFormat.size = 12;
            textFormat.color = 0x2F1F00;
            textFormat.align = TextFormatAlign.CENTER;
            var tempTF : TextField = new TextField();
            tempTF.selectable = false;
            tempTF.defaultTextFormat = textFormat;
            tempTF.width = RIGHT_CENTER_WIDTH;
            tempTF.height = 20;
            tempTF.x = 0;
            tempTF.y = -20;
            tempTF.htmlText = "挂机剩余时间：<font color='#FF3300'>00分钟</font>";
            sprite.addChild(tempTF);
            timeLeftLabel = tempTF;
            // 头像
            icon = new HeadIcon();
            icon.x = (RIGHT_CENTER_WIDTH - DuplPanelConfig.HEAD_ICON_WIDTH) / 2;
            icon.y = 20;
            sprite.addChild(icon);
            // 次数输入框
            numTextInputContainer = new Sprite();
            numTextInputContainer.x = 60;
            numTextInputContainer.y = RIGHT_CENTER_HEIGHT - 64;
            sprite.addChild(numTextInputContainer);
            var textInputData : GTextInputData = new GTextInputData();
            textInputData.width = 40;
            textInputData.height = 22;
            textInputData.restrict = "0-9";
            textInputData.maxChars = 2;
            var textInput : GTextInput = new GTextInput(textInputData);
            numTextInputContainer.addChild(textInput);
            numTextInput = textInput;
            numTextInput.text = "1";
            numTextInput.textField.addEventListener(Event.CHANGE, numTextInput_changeHandler)
            // 交叉剑
            var bitmapData : BitmapData = RESManager.getBitmapData(new AssetData(UI.ICON_BATTLE));
            var battleIcon : Bitmap = new Bitmap(bitmapData);
            battleIcon.x = textInputData.x - 45;
            battleIcon.y = textInputData.y;
            numTextInputContainer.addChild(battleIcon);

            textFormat = new TextFormat();
            textFormat.font = UIManager.defaultFont;
            textFormat.size = 12;
            textFormat.color = 0x2F1F00;
            textFormat.align = TextFormatAlign.LEFT;
            tempTF = new TextField();
            tempTF.selectable = false;
            tempTF.defaultTextFormat = textFormat;
            tempTF.width = 30;
            tempTF.height = 20;
            tempTF.x = textInputData.x - tempTF.width;
            tempTF.y = textInputData.y + 2;
            tempTF.htmlText = "挂机";
            numTextInputContainer.addChild(tempTF);

            tempTF = new TextField();
            tempTF.selectable = false;
            tempTF.defaultTextFormat = textFormat;
            tempTF.width = 100;
            tempTF.height = 20;
            tempTF.x = textInputData.x + textInputData.width + 2;
            tempTF.y = textInputData.y + 2;
            tempTF.htmlText = "次";
            numTextInputContainer.addChild(tempTF);
            numTF = tempTF;

            textFormat.align = TextFormatAlign.CENTER;
            tempTF = new TextField();
            tempTF.selectable = false;
            tempTF.defaultTextFormat = textFormat;
            tempTF.width = RIGHT_CENTER_WIDTH;
            tempTF.height = 20;
            tempTF.x = 0;
            tempTF.y = RIGHT_CENTER_HEIGHT - 35;
            tempTF.htmlText = "（剩余免费进入次数：<font color='#FF3300'>10</font>)";
            sprite.addChild(tempTF);
            remainNumTF = tempTF;

            textFormat.color = 0x339900;
            textFormat.align = TextFormatAlign.CENTER;
            tempTF = new TextField();
            tempTF.selectable = false;
            tempTF.defaultTextFormat = textFormat;
            tempTF.width = RIGHT_CENTER_WIDTH;
            tempTF.height = 20;
            tempTF.x = 0;
            tempTF.y = RIGHT_CENTER_HEIGHT + (CENTER_BOTTOM - 12) / 2;
            tempTF.htmlText = useMoudel == 0 ? "今日进入副本次数已满" : "今日锁妖次数已满";
            sprite.addChild(tempTF);
            noNumTF = tempTF;

            var buttonData : GButtonData = new GButtonData();
            buttonData.width = 80;
            buttonData.height = 30;
            buttonData.y = leftBottomBg.y + (leftBottomBg.height - buttonData.height) / 2;
            var button : GButton;
            button = new GButton(buttonData);
            button.text = "开始挂机";
            bodyContainer.addChild(button);
            startButton = button;
            button = new GButton(buttonData);
            button.text = "停止挂机";
            bodyContainer.addChild(button);
            stopButton = button;
//            buttonData.toolTipData = new GToolTipData();
//            buttonData.toolTipData.labelData.text = "立即完成每次花费10元宝";
            button = new GButton(buttonData);
            button.text = "立即完成";
            fastButton = button;

            startButton.x = rightCenterBg.x + (RIGHT_CENTER_WIDTH - buttonData.width) / 2;
            updateButtonPosition();
            // startButton.visible = true;
            // stopButton.visible = false;
            // immediatelyButton.visible = false;

            goodsBox = new HookGoodsBox();
            goodsBox.x = leftBottomBg.x + (leftBottomBg.width - goodsBox.width) / 2;
            goodsBox.y = leftBottomBg.y + (leftBottomBg.height - goodsBox.height) / 2;
            bodyContainer.addChild(goodsBox);

            var w : int = leftCenterBg.width - 6;
            var h : int = leftCenterBg.height - 6;
            logBox = new HookLogBox(w, h);
            logBox.x = leftCenterBg.x + 3;
            logBox.y = leftCenterBg.y + 3;
            bodyContainer.addChild(logBox);

            setTimeleft(0);
            // testWH();
        }

        public function testWH() : void
        {
            var g : Graphics = bodyContainer.graphics;
            g.beginFill(0xFF0000, 0.1);
            g.drawRect(0, 0, BODY_WIDTH, BODY_HEIGHT);
            g.endFill();
        }

        // ===================
        // 赋值
        // ===================
        /** 设置剩余时间 */
        public function setTimeleft(num : int) : void
        {
            var str : String = TEXT_TIMELEFT.replace(/__NUM__/, num);
            timeLeftLabel.htmlText = str;
        }

        /** 设置剩余次数 */
        public function setRemainNum(num : int, isFree : Boolean, isBindTextInput : Boolean = true) : void
        {
            this.isFree = isFree;
            remainNum = num;
            var str : String;
            if (isFree == true)
            {
                str = TEXT_REMAIN_NUM_FREE;
                numTextInputContainer.x = 74;
            }
            else
            {
                str = TEXT_REMAIN_NUM;
                numTextInputContainer.x = 48;
            }
            str = str.replace(/__NUM__/gi, num);
            remainNumTF.htmlText = str;
            if (isBindTextInput == false) return;

            var textInputData : GTextInputData = numTextInput.base as GTextInputData;
            if (num <= 0)
            {
                textInputData.minNum = 0;
                textInputData.maxNum = 0;
                numTextInput.text = "0";
                buttonState_noNum();
            }
            else
            {
                textInputData.minNum = 1;
                textInputData.maxNum = num;
                numTextInput.text = "1";
                buttonState_default();
            }
            numTextInput_changeHandler();
            numTextInputContainer.visible = num != 0;
            remainNumTF.visible = numTF.visible = numTextInputContainer.visible;
        }

        private function numTextInput_changeHandler(event : Event = null) : void
        {
            var textInputData : GTextInputData = numTextInput.base as GTextInputData;
            var num : int = getNum();
            if (num < textInputData.minNum)
            {
                num = textInputData.minNum;
                numTextInput.text = num + "";
            }
            else if (num > textInputData.maxNum)
            {
                num = textInputData.maxNum;
                numTextInput.text = num + "";
            }

            var str : String;
            if (isFree == true)
            {
                str = TEXT_NUM_FREE;
            }
            else
            {
                str = TEXT_NUM;
            }

            var gold : int = num * buyGold;
            numTF.htmlText = str;
            str = str.replace(/__NUM__/gi, gold);
            numTF.htmlText = str;
        }

        public function getNum() : int
        {
            return parseInt(numTextInput.text);
        }

        public function setNum(num : int) : void
        {
            numTextInput.text = num + "";
            // numTextInput_changeHandler();
        }

        public function buttonState_noNum() : void
        {
            noNumTF.visible = true;
            startButton.visible = false;
            stopButton.visible = false;
            fastButton.visible = false;
        }

        public function buttonState_default() : void
        {
            noNumTF.visible = false;
            startButton.visible = true;
            stopButton.visible = false;
            fastButton.visible = false;

            startButton.enabled = true;
        }

        public function buttonState_start() : void
        {
            noNumTF.visible = false;
            startButton.visible = false;
            stopButton.visible = true;
            fastButton.visible = true;

            stopButton.enabled = true;
            fastButton.enabled = true;
        }

        public function buttonState_fast() : void
        {
            noNumTF.visible = false;
            startButton.visible = false;
            stopButton.visible = true;
            fastButton.visible = true;

            stopButton.enabled = false;
            fastButton.enabled = false;
        }

        // ===================
        // 布局
        // ===================
        public function updateLayout(event : Event = null) : void
        {
            UIUtil.alignStageCenter(this);
        }

        private function updateButtonPosition() : void
        {
            if (UserData.instance.vipLevel > 0)
            {
                stopButton.x = startButton.x - startButton.width / 2 - 2;
                fastButton.x = startButton.x + startButton.width / 2 + 2;
                if (fastButton.parent == null) bodyContainer.addChild(fastButton);
            }
            else
            {
                stopButton.x = startButton.x;
                fastButton.x = startButton.x + startButton.width / 2 + 2;
                if (fastButton.parent != null) bodyContainer.removeChild(fastButton);
            }
        }

        // ===================
        // 设置显示隐藏
        // ===================
        private var _visible : Boolean = false;

        override public function get visible() : Boolean
        {
            return _visible;
        }

        override public function set visible(value : Boolean) : void
        {
            if (_visible == value) return;
            _visible = value;
            if (value)
            {
                updateButtonPosition();
                updateLayout();
                show();
                stage.addEventListener(Event.RESIZE, updateLayout);
            }
            else
            {
                stage.removeEventListener(Event.RESIZE, updateLayout);
                hide();
            }
        }

        public var onClickCloseCall : Function;

        override protected function onClickClose(event : MouseEvent) : void
        {
            if (onClickCloseCall != null)
            {
                onClickCloseCall.apply();
                _closeButton.enabled = true;
                return;
            }
            super.onClickClose(event);
            _visible = false;
        }

        // ===================
        // 常用Getter
        // ===================
        private var _stage : Stage;

        override public function get stage() : Stage
        {
            if (_stage) return _stage;
            _stage = UIUtil.stage;
            return _stage;
        }
    }
}
