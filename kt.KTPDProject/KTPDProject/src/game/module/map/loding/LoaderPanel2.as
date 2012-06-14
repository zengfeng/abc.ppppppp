package game.module.map.loding
{
    import com.greensock.TweenLite;

    import gameui.core.GComponentData;
    import gameui.core.GComponent;
    import gameui.manager.UIManager;

    import net.RESManager;

    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.text.TextField;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-14
     */
    public class LoaderPanel2 extends Sprite
    {
        /** 单例对像 */
        private static var _instance : LoaderPanel2;

        /** 获取单例对像 */
        public static function get instance() : LoaderPanel2
        {
            if (_instance == null)
            {
                _instance = new LoaderPanel2();
            }
            return _instance;
        }

        public var mayParent : DisplayObjectContainer;
        public var mayStage : Stage;

        public function LoaderPanel2()
        {
            mayParent = UIManager.root;
            mayStage = mayParent.stage;
            initViews();
        }

        private var container : GComponent;
        private var swf : MovieClip;
        private var bar : MovieClip;
        private var textField : TextField;
        private var topSprite : Sprite;
        private var bottomSprite : Sprite;

        public function initViews() : void
        {
            var base : GComponentData = new GComponentData();
            base.width = 1280;
            base.height = 700;
            container = new GComponent(base);
            addChild(container);
            swf = RESManager.getLoader("loading").getContent() as MovieClip;
            bar = swf["loaderA"]["loaderA_a"];
            textField = swf["text"];
            swf.x = 0
            container.addChild(swf);
            initMovieClip();

            topSprite = new Sprite();
            topSprite.graphics.beginFill(0x000000);
            topSprite.graphics.drawRect(0, 0, 1300, 400);
            topSprite.graphics.endFill();

            bottomSprite = new Sprite();
            bottomSprite.graphics.beginFill(0x000000);
            bottomSprite.graphics.drawRect(0, 0, 1300, 400);
            bottomSprite.graphics.endFill();
            topSprite.x = container.width - topSprite.width >> 1;
            bottomSprite.x = topSprite.x;
            initCloseSprite();
            container.addChild(topSprite);
            container.addChild(bottomSprite);
        }

        private function initMovieClip() : void
        {
            swf.gotoAndStop(1);
            bar.gotoAndStop(1);
        }

        private function initCloseSprite() : void
        {
            if (tweeLiteTop)
            {
                tweeLiteTop.kill();
                tweeLiteBottom.kill();
            }
            topSprite.y = -topSprite.height;
            bottomSprite.y = container.height;
        }

        private var endY : int = 300;
        private var tweeLiteTop : TweenLite;
        private var tweeLiteBottom : TweenLite;

        public function playClose() : void
        {
            initCloseSprite();
            tweeLiteTop = TweenLite.to(topSprite, 2, {y:endY - topSprite.height, onComplete:close});
            tweeLiteBottom = TweenLite.to(bottomSprite, 2, {y:endY});
        }

        private function close() : void
        {
            if (parent) parent.removeChild(this);
            initMovieClip();
            initCloseSprite();
        }

        public function layout() : void
        {
            this.graphics.clear();
            this.graphics.beginFill(0x000000);
            this.graphics.drawRect(0, 0, mayStage.stageWidth, mayStage.stageHeight);
            this.graphics.endFill();

            container.x = mayStage.stageWidth - container.width >> 1;
            container.y = mayStage.stageHeight - container.height >> 1;
            swf.x = 0;
            swf.y = 0;
        }

        private function onStageResize(event : Event) : void
        {
            layout();
        }

        public function show() : void
        {
            layout();
            initCloseSprite();
            mayParent.addChild(this);
            stage.addEventListener(Event.RESIZE, onStageResize);
        }

        public function hide() : void
        {
            playClose();
        }
    }
}
