package game.module.map.utils
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import game.module.map.MapSystem;


    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-5 ����11:40:37
     */
    public class TileLoad
    {
        /** 加载区域 */
        private var rec : Rectangle = new Rectangle();
        private var extend : uint = 2;
        private var mapWH : Point = new Point();
        private var pieceWH : Point = new Point();
        private var stageWH : Point = new Point();
        private var pieceRepeatHW : Point = new Point();

        public function initData(mapWH : Point, pieceWH : Point, stageWH : Point) : void
        {
            this.mapWH.x = mapWH.x;
            this.mapWH.y = mapWH.y;

            this.pieceWH.x = pieceWH.x;
            this.pieceWH.y = pieceWH.y;

            this.stageWH.x = stageWH.x;
            this.stageWH.y = stageWH.y;

            pieceRepeatHW.x = Math.ceil(this.mapWH.x / this.pieceWH.x) - 1;
            pieceRepeatHW.y = Math.ceil(this.mapWH.y / this.pieceWH.y) - 1;
        }

        public function loadAll() : Rectangle
        {
            rec.x = 0;
            rec.y = 0;
            rec.width = pieceRepeatHW.x;
            rec.height = pieceRepeatHW.y;
            return rec;
        }

        public function load(mapX : int, mapY : int, stageWH : Point = null) : Rectangle
        {
            if (stageWH)
            {
                this.stageWH.x = stageWH.x;
                this.stageWH.y = stageWH.y;
            }

            if (mapX >= 0)
            {
                rec.x = 0;
            }
            else
            {
                rec.x = Math.floor(-mapX / pieceWH.x);
                rec.x -= extend;
                if (rec.x < 0) rec.x = 0;
            }

            if (mapY >= 0)
            {
                rec.y = 0;
            }
            else
            {
                rec.y = Math.floor(-mapY / pieceWH.y);
                rec.y -= extend;
                if (rec.y < 0) rec.y = 0;
            }

            rec.width = Math.ceil((this.stageWH.x - mapX) / pieceWH.x);
            rec.width += extend;
            if (rec.width > pieceRepeatHW.x) rec.width = pieceRepeatHW.x;

            rec.height = Math.ceil((this.stageWH.y - mapY) / pieceWH.y);
            rec.height += extend;
            if (rec.height > pieceRepeatHW.y) rec.height = pieceRepeatHW.y;

            return rec;
        }
    }
}
