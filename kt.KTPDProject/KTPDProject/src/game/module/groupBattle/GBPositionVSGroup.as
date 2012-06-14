package game.module.groupBattle
{
    import flash.geom.Point;
    import flash.geom.Rectangle;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-4 ����8:46:33
     */
    public class GBPositionVSGroup
    {
        /** 区域 */
        public var rect : Rectangle;
        /** 列数 */
        public var lineCount : int = 1;
        /** 一列多少个数轮换 */
        public var changeLineLength : int = 10;

        public function getPointList(num : int) : Vector.<Point>
        {
            var list : Vector.<Point> = new Vector.<Point>();
            if (num <= changeLineLength) lineCount = 1;
            var lineLength : int = Math.ceil(num / lineCount);
            var lineList : Array = [];
            var linePositionList : Vector.<Point>;
            var point : Point;
            for (var i : int = 1; i <= lineCount;  i++)
            {
                 var lineX : int = rect.x + getPartPosition(i, rect.width);
                linePositionList = new Vector.<Point>();
                for ( var j : int = 1; j <= lineLength; j++)
                {
                    point = new Point(lineX);
                    point.y = rect.y + getPartPosition(j, rect.height);
                    linePositionList.push(point);
                }
                lineList.push(linePositionList);
            }
			
            i = 0;
            while (lineList.length > 0)
            {
                linePositionList = lineList[i];
                if (linePositionList.length <= 0)
                {
                    lineList.splice(lineList.indexOf(linePositionList), 1);
                    continue;
                }

                for (j = 0; j < changeLineLength; j++)
                {
                    if (linePositionList.length <= 0) break;
                    list.push(linePositionList.shift());
                }
                
                i ++;
                if(i >= lineList.length)
                {
                    i = 0;
                }
            }

            return list;
        }

        /** 求线段的位置 */
        public function getPartPosition(id : int, length : int) : int
        {
            // 2的次方数
            var n : int = Math.floor(id / 2) + 1;
            if (id > 3)
            {
                n = 1;
                var num : int = 1;
                while (1 > 0)
                {
                    n++;
                    num = 2 * num;
                    if (id < num * 2)
                    {
                        break;
                    }
                }
            }
            // 分成多少段
            var part : int = Math.pow(2, n);
            // 分成多少段后的第几段
            var index : int;
            // 如果是1
            if (id == 1)
            {
                index = 0;
            }
            // 如果是偶数
            else if (id % 2 == 0)
            {
                index = part - id - 2;
            }
            // 如果是奇数
            else
            {
                // index = part / 2 + (Math.floor((id - part / 2 )) - 1) * 2;
                index = id - 1;
            }

            // 求值 = 第小段 * (索引 + 1)
            var value : int = (length / part) * (index + 1);
            //trace("id = " + id + "    n = " + n + "   part = " + part + "    index = " + index + "   value = " + value);
            return value;
        }
    }
}
import flash.geom.Point;

class Line
{
    public var x : int = 0;
    public var minY : int = 0;
    public var maxY : int = 100;

    public function getPointList(num : int) : Vector.<Point>
    {
        var index : int = 0;
        var list : Vector.<Point> = new Vector.<Point>();
        var point : Point;

        var segment : Segment = new Segment(minY, maxY);
        var segmentList : Vector.<Segment> = new Vector.<Segment>();
        segmentList.push(segment);
        var newSegment : Segment;

        while (segmentList.length > 0)
        {
            segment = segmentList.shift();

            // 计算中间点
            point = new Point(x);
            point.y = segment.min + (segment.max - segment.min) / 2;
            list.push(point);
            index++;

            // 加入两个新段
            newSegment = new Segment(segment.min, point.y);
            segmentList.push(newSegment);
            newSegment = new Segment(point.y, segment.max);
            segmentList.push(newSegment);

            if (index >= num)
            {
                break;
            }
        }
        return list;
    }
}
class Segment
{
    public var min : int = 0;
    public var max : int = 0;

    function Segment(min : int = 0, max : int = 0) : void
    {
        this.min = min;
        this.max = max;
    }
}