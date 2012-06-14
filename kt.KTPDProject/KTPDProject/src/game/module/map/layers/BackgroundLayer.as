package game.module.map.layers
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import game.module.map.utils.MapUtil;


    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-26 ����3:28:59
     * 地图背景层
     */
    public class BackgroundLayer extends Sprite
    {
        /** 远景图片 */
        private var _distant : Bitmap = new Bitmap();

        public function BackgroundLayer()
        {
            init();
        }

        /** 初始化 */
        public function init() : void
        {
            this.mouseChildren = false;
            this.mouseEnabled = false;
            addChild(_distant);
        }

        /** 清理 */
        public function clear() : void
        {
            // 远景图片
            if (_distant.bitmapData) _distant.bitmapData.dispose();
            _distant.bitmapData = null;
        }

        /** 远景图片 */
        public function get distant() : BitmapData
        {
            return _distant.bitmapData;
        }

        public function set distant(distant : BitmapData) : void
        {
            if(_distant.bitmapData)
            {
                if(distant && distant.width < _distant.bitmapData.width)
                {
                    distant.dispose();
                    return;
                }
                
                _distant.bitmapData.dispose();
                _distant.bitmapData = null;
            }
            
            _distant.bitmapData = distant;
            if (distant != null)
            {
                var max : Number = Math.max(MapUtil.stage.stageWidth / _distant.bitmapData.width, MapUtil.stage.stageHeight / _distant.bitmapData.height);
                width = _distant.bitmapData.width * max;
                height = _distant.bitmapData.height * max;
            }
        }
    }
}
