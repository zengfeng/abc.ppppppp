package game.module.map.utils
{
    import flash.geom.Point;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-28 ����7:09:57
     */
    public class CircleLoad
    {
        private var center : Point = new Point();
        private var r : uint = 5;
        private var b : uint = 5;
        private var l : uint = 5;
        private var t : uint = 5;
        private var extend:uint = 2;
        private var mapWH : Point = new Point();
        private var pieceWH : Point = new Point();
        private var stageWH : Point = new Point();
        private var pieceRepeatHW : Point = new Point();
        private var list : Vector.<Point> = new Vector.<Point>();

        public function initData(mapWH : Point, pieceWH : Point, stageWH : Point) : void
        {
            this.mapWH.x = mapWH.x;
            this.mapWH.y = mapWH.y;

            this.pieceWH.x = pieceWH.x;
            this.pieceWH.y = pieceWH.y;

            this.stageWH.x = stageWH.x;
            this.stageWH.y = stageWH.y;

            pieceRepeatHW.x = Math.ceil(this.mapWH.x / this.pieceWH.x);
            pieceRepeatHW.y = Math.ceil(this.mapWH.y / this.pieceWH.y);
        }

        public function load(mapPostion : Point, stageWH : Point = null) :Vector.<Point>
        {
            if (stageWH)
            {
                this.stageWH.x = stageWH.x;
                this.stageWH.y = stageWH.y;
            }
            stageWH = this.stageWH;
            
            center.x = Math.floor(mapPostion.x / pieceWH.x);
            center.y = Math.floor(mapPostion.y / pieceWH.y);
            
            r = l = Math.ceil(stageWH.x / (2 * pieceWH.x)) + extend;
            b = t = Math.ceil(stageWH.y / (2 * pieceWH.y)) + extend;
            
            l = Math.min(l, center.x);
            t = Math.min(t, center.y);
            r = Math.min(r, pieceRepeatHW.x - center.x - 1);
            b = Math.min(b, pieceRepeatHW.y - center.y - 1);
            
            
            while(list.length > 0)
            {
                list.shift();
            }
            
            var max:int = Math.max(r, b, l, t);
            for(var i:int = 0; i < max; i++)
            {
                onceLoop(i);
            }
            return list;
        }
        
        public function onceLoop(i:int):void
        {
            var startPostion : Point = new Point();
            var endPostion : Point = new Point();
            // 右
            startPostion.x = center.x + i;
            startPostion.y = center.y - i;
            endPostion.x = startPostion.x;
            endPostion.y = center.y + i;
            pushR(startPostion, endPostion);

            // 下
            startPostion.x = center.x - i;
            startPostion.y = center.y + i;
            endPostion.x = center.x + i;
            endPostion.y = startPostion.y;
            pushB(startPostion, endPostion);

            // 左
            startPostion.x = center.x - i;
            startPostion.y = center.y - i;
            endPostion.x = startPostion.x;
            endPostion.y = center.y + i;
            publicL(startPostion, endPostion);

            // 上
            startPostion.x = center.x - i;
            startPostion.y = center.y - i;
            endPostion.x = center.x + i;
            endPostion.y = startPostion.y;
            pushT(startPostion, endPostion);
        }
        
        public function pushR(startPostion : Point, endPostion : Point) : void
        {
            if (startPostion.x > center.x + r)
            {
                return;
            }

            if (startPostion.y > endPostion.y)
            {
                var temPostion : Point = startPostion;
                startPostion = endPostion;
                endPostion = temPostion;
            }

            startPostion.y < center.y - t ? startPostion.y = center.y - t : null;
            endPostion.y > center.y + b ? endPostion.y = center.y + b  : null;

            for (var i : int = startPostion.y; i <= endPostion.y; i++)
            {
                pushPoint(startPostion.x, i);
            }
        }

        public function publicL(startPostion : Point, endPostion : Point) : void
        {
            if (startPostion.x < center.x - l)
            {
                return;
            }

            if (startPostion.y > endPostion.y)
            {
                var temPostion : Point = startPostion;
                startPostion = endPostion;
                endPostion = temPostion;
            }

            startPostion.y < center.y - t ? startPostion.y = center.y - t - 1 : null;
            endPostion.y > center.y + b ? endPostion.y = center.y + b + 1 : null;

            for (var i : int = startPostion.y + 1; i < endPostion.y; i++)
            {
                pushPoint(startPostion.x, i);
            }
        }

        public function pushB(startPostion : Point, endPostion : Point) : void
        {
            if (startPostion.y > center.y + b)
            {
                return;
            }

            if (startPostion.x > endPostion.x)
            {
                var temPostion : Point = startPostion;
                startPostion = endPostion;
                endPostion = temPostion;
            }

            startPostion.x < center.x - l ? startPostion.x = center.x - l : null;
            endPostion.x > center.x + r ? endPostion.x = center.x + r + 1 : null;

            for (var i : int = startPostion.x; i < endPostion.x; i++)
            {
                pushPoint(i, startPostion.y);
            }
        }

        public function pushT(startPostion : Point, endPostion : Point) : void
        {
            if (startPostion.y < center.y - t)
            {
                return;
            }

            if (startPostion.x > endPostion.x)
            {
                var temPostion : Point = startPostion;
                startPostion = endPostion;
                endPostion = temPostion;
            }

            startPostion.x < center.x - l ? startPostion.x = center.x - l : null;
            endPostion.x > center.x + r ? endPostion.x = center.x + r + 1 : null;

            for (var i : int = startPostion.x; i < endPostion.x; i++)
            {
                pushPoint(i, startPostion.y);
            }
        }

        public function pushPoint(x : uint, y : uint) : void
        {
            list.push(new Point(x, y));
        }
    }
}
