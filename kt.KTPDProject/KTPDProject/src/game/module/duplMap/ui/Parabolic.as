package game.module.duplMap.ui
{
	import com.greensock.TweenLite;

	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.utils.setTimeout;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-10 ����2:21:58
     */
    public class Parabolic
    {
        public var startPoint : Point = new Point();
        public var endPoint : Point = new Point();
        public var postion : Point = new Point();
        public var displayObject : DisplayObject;
        public var bindObj:*;
        public var path : Vector.<Point> = new Vector.<Point>();
        public var playCompleteCallFun:Function;

        public function play() : void
        {
            createPath();
            displayObject.cacheAsBitmap = true;
            displayObject.scaleX = 0.5;
            displayObject.scaleY = 0.5;
            var Vscale : Number = (1 - displayObject.scaleX) / (path.length - 1);
            var Vrotation:Number = 360 / (path.length);
            var scale : Number = displayObject.scaleX;
            var rotation:Number = 0;
            var parabolic:Parabolic = this;
            var fun : Function = function(i : int) : void
            {
                scale += Vscale;
                rotation += Vrotation;
                postion = path[i];
                TweenLite.to(displayObject, 0.3, {x:postion.x, y:postion.y, scaleX:scale, scaleY:scale});
                if (i >= path.length - 1)
                {
                    if(playCompleteCallFun!=null) setTimeout(function():void{displayObject.scaleX = displayObject.scaleY= 1;displayObject.rotationY = 0; playCompleteCallFun(parabolic);}, 400);
                }
            };

            for (var i : int = 0; i < path.length; i++)
            {
                setTimeout(fun, 30 * i, i);
            }
        }
        
        public var Vy_0:Number = -20;

        public function createPath() : void
        {
            var x : Number = startPoint.x;
            var y : Number = startPoint.y;
            var Vy_0 : Number = -20;
            var Vy_t : Number = 0;
            var Vy_a : Number = 6;
            var Vx : Number = 0;
            var i : int = 0;
            var postion : Point;

            if (startPoint.y > 0)
            {
                Vy_0 = Vy_0 - Math.round(startPoint.y / 5);
            }
            else if(Vy_0 < 0)
            {
                Vy_0 = Vy_0 + Math.round(startPoint.y / 5);
            }

            var isPassOrigin : Boolean = false;

            for (i = 0; i < 1000; i++)
            {
                Vy_t = Vy_0 + Vy_a * i;
                if (Vy_t >= 0) isPassOrigin = true;
                y += Vy_t;
                //trace(" Vy_t " + Vy_t + " y " + y);
                postion = new Point();
                postion.y = y;
                path.push(postion);
                if (postion.y >= endPoint.y && isPassOrigin == true)
                {
                    postion.y = endPoint.y;
                    break;
                }
            }

            if (path.length > 0) Vx = (endPoint.x - startPoint.x) / path.length;
            for (i = 0; i < path.length; i++)
            {
                x += Vx;
                postion = path[i];
                postion.x = x;
            }
        }
    }
}
