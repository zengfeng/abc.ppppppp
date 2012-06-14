package game.core.menu
{
    import com.utils.UIUtil;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import game.manager.ViewManager;
    import gameui.controls.GButton;
    import gameui.data.GButtonData;




    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-3-1   ����5:59:28 
     */
    public class QuitButton extends Sprite
    {
        private var button : GButton;

        public function QuitButton(singleton : Singleton)
        {
            singleton;
            var buttonData : GButtonData = new GButtonData();
            button = new GButton(buttonData);
            button.text = "离开";
            addChild(button);
            button.addEventListener(MouseEvent.CLICK, onClick);
        }

        /** 单例对像 */
        private static var _instance : QuitButton;

        /** 获取单例对像 */
        static public function get instance() : QuitButton
        {
            if (_instance == null)
            {
                _instance = new QuitButton(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public var clickCall : Function;

        override public function get stage() : Stage
        {
            return  UIUtil.stage;
        }

        private function onClick(event : MouseEvent) : void
        {
            if (clickCall != null) clickCall.apply();
        }

        public function show() : void
        {
            if (this.parent == null)
            {
                layout();
                ViewManager.instance.uiContainer.addChild(this);
                stage.addEventListener(Event.RESIZE, layout);
            }
        }

        public function hide() : void
        {
            if (this.parent != null)
            {
                this.parent.removeChild(this);
                stage.removeEventListener(Event.RESIZE, layout);
            }
        }

        private function layout(event : Event = null) : void
        {
            x = stage.stageWidth - width - 10;
            y = stage.stageHeight - height - 100;
        }
    }
}
class Singleton
{
}