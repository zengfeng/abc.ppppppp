package game.module.duplPanel.view
{
    import com.commUI.alert.Alert;
    import com.utils.ColorChange;
    import com.utils.FilterUtils;
    import com.utils.Glow;
    import com.utils.UICreateUtils;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.filters.GlowFilter;
    import flash.utils.getTimer;
    import game.module.duplPanel.DuplPanelConfig;
    import gameui.controls.GButton;






    /**
     *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-12
     */
    public class HeadIconEnter extends HeadIcon
    {
        /** 挂机按钮 */
        protected var hookButton : GButton;

        public function HeadIconEnter()
        {
            super();
            isOpenHook = false;
        }

        override public function initView() : void
        {
            super.initView();
            hookButton = UICreateUtils.createGButton("挂机", 42, 22);
            hookButton.y = DuplPanelConfig.HEAD_ICON_Height - hookButton.height / 2;
            hookButton.x = (DuplPanelConfig.HEAD_ICON_WIDTH - hookButton.width) >> 1;
            addChild(hookButton);
        }

        // ===================
        // 滤镜区域
        // ===================
        private static var _colorMatrixFilter_mouseOver : ColorMatrixFilter;

        public static function get colorMatrixFilter_mouseOver() : ColorMatrixFilter
        {
            if (_colorMatrixFilter_mouseOver == null)
            {
                var colorChange : ColorChange = new ColorChange();
                colorChange.adjustContrast(30);
                _colorMatrixFilter_mouseOver = new ColorMatrixFilter(colorChange);
            }
            return _colorMatrixFilter_mouseOver;
        }

        // ===================
        // 鼠标
        // ===================
        private var HEAD_ICON_RADIUS_SQ : int = DuplPanelConfig.HEAD_ICON_RADIUS * DuplPanelConfig.HEAD_ICON_RADIUS ;

        private function isInArea(event : MouseEvent) : Boolean
        {
            var mX : int = event.localX - DuplPanelConfig.HEAD_ICON_RADIUS ;
            var mY : int = event.localY - DuplPanelConfig.HEAD_ICON_RADIUS;
            var radius : int = mX * mX + mY * mY;
            //trace(mX + "  " + mY);
            return radius <= HEAD_ICON_RADIUS_SQ ;
        }

        private var isMouseOver : Boolean = false;
        private static var _glowFilter : GlowFilter;

        public static function get glowFilter() : GlowFilter
        {
            if (_glowFilter == null)
            {
                _glowFilter = new GlowFilter(0xFF6600, 0.8, 8, 8, 2, 1, false, false);
            }
            return _glowFilter;
        }

        private function onMouseRollOver(event : MouseEvent) : void
        {
            // //trace("onMouseRollOver");
            // if (isInArea(event) == false)
            // {
            // onMouseRollOut(event);
            // return;
            // }
            // if (isMouseOver == true) return;
            // isMouseOver = true;
            // isMouseOut = false;

            bg.scaleX = bg.scaleY = 1.05;
            image.scaleX = image.scaleY = 1.05;
            // bg.x -= 2;
            // bg.y -= 2;
            image.x -= 3;
            image.y -= 4;
            // glow.addDisplayObject(bg);
            bg.filters = [glowFilter];
            this.filters = [colorMatrixFilter_mouseOver];
            // bg.filters = [colorMatrixFilter_mouseOver];
            // image.filters = [colorMatrixFilter_mouseOver];
            // nameTF.filters = [colorMatrixFilter_mouseOver];
        }

        private var isMouseOut : Boolean = true;

        private function onMouseRollOut(event : MouseEvent) : void
        {
            // //trace("onMouseRollOut");
            // if (isInArea(event) == false) return;
            // if (isMouseOut == true) return;
            // isMouseOut = true;
            // isMouseOver = false;

            bg.scaleX = bg.scaleY = 1;
            image.scaleX = image.scaleY = 1;
            // bg.x += 2;
            // bg.y += 2;
            image.x += 3;
            image.y += 4;
            // glow.removeDisplayObject(bg);
            this.filters = [];
            bg.filters = [];

            // bg.filters = [];
            // image.filters = [];
            // nameTF.filters = [];
        }

        public var onClickCall : Function;
        public var onClickHookButtonCall : Function;

        private function onClick(event : MouseEvent) : void
        {
            if(getTimer() - onClickHookButtonTime < 100)
            {
                return;
            }
            // if (isInArea(event) == false) return;
            if (onClickCall != null)
            {
                onClickCall.apply(null, [id]);
                return;
            }
            Alert.show("onClick进入副本 " + id);
        }
		
        private var onClickHookButtonTime:Number = 0;
        private function onClickHookButton(event : MouseEvent) : void
        {
            onClickHookButtonTime = getTimer();
            event.stopPropagation();
            if (onClickHookButtonCall != null)
            {
                onClickHookButtonCall.apply(null, [id]);
                return;
            }
            Alert.show("onClickHookButtonCall副本挂机 " + id);
        }

        // ===================
        // enable区块
        // ===================
        override public function set enable(value : Boolean) : void
        {
            if (_enable == value) return;
            super.enable = value;
            if (value == false)
            {
                isOpenHook = false;
                bg.removeEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
                bg.removeEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
                bg.removeEventListener(MouseEvent.CLICK, onClick);
                hookButton.removeEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
                hookButton.removeEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
                hookButton.removeEventListener(MouseEvent.CLICK, onClickHookButton);
            }
            else
            {
                bg.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
                bg.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
                bg.addEventListener(MouseEvent.CLICK, onClick);
                hookButton.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver);
                hookButton.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut);
                hookButton.addEventListener(MouseEvent.CLICK, onClickHookButton);
            }
        }

        override public function clear() : void
        {
            super.clear();
            isOpenHook = false;
        }

        /** 是否开放挂机 */
        override public function set isOpenHook(value : Boolean) : void
        {
            if (_isOpenHook == value) return;
            _isOpenHook = value;
            hookButton.visible = value;
        }
    }
}
