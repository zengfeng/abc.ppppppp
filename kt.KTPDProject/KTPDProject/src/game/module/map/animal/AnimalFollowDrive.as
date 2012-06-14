package game.module.map.animal
{
	import com.utils.Vector2D;

	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;






    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-3-16 ����5:00:12
     */
    public class AnimalFollowDrive
    {
        public var animal : Animal;
        public var list : Vector.<Animal>;
        public var moveingDic : Dictionary;

        function AnimalFollowDrive(animal : Animal) : void
        {
            this.animal = animal;
        }

        public function add(animal : Animal) : void
        {
            if (animal == null) return;
            if (list == null) list = new Vector.<Animal>();
            if (moveingDic == null) moveingDic = new Dictionary();
            var index : int = list.indexOf(animal);
            if (index == -1)
            {
                moveingDic[list.length] = false;
                list.push(animal);
                animal.speed = this.animal.speed;
//                animal.speed = this.animal.speed + this.animal.speed * 0.5;
            }
        }

        public function remove(animal : Animal) : void
        {
            if (animal == null || list == null) return;
            var index : int = list.indexOf(animal);
            if (index != -1)
            {
                animal.speed = animal.struct.speed;
                delete moveingDic[list.length];
                list.splice(index, 1);
            }
            if (list.length == 0)
            {
                clearPathData();
            }
        }

        public function get x() : int
        {
            return animal.x;
        }

        public function get y() : int
        {
            return animal.y;
        }

        public function followPath() : void
        {
        }

        public function set speed(value : Number) : void
        {
            if (list == null || list.length == 0) return;
            if (preSpeed > value)
            {
                speedTimer = setTimeout(setSpeed, 3000, value);
                return;
            }
            setSpeed(value);
        }

        private var speedTimer : uint = 0;

        private function setSpeed(value : Number) : void
        {
//            Alert.show(value);
            clearTimeout(speedTimer);
            for (var i : int = 0; i < list.length; i++)
            {
                var followerAnimal : Animal = list[i];
                followerAnimal.speed = value;
//                followerAnimal.speed = value + value * 0.5;
            }
        }

        private function get preSpeed() : Number
        {
            if (list == null || list.length == 0) return animal.speed;
            return (list[0] as Animal).speed;
        }

        public function moveStart(toX : int, toY : int) : void
        {
            if (list == null || list.length == 0) return;
            preM = 0;
            moveedDistance = 0;
            if (moveedTotalDistance > 100000) moveedTotalDistance = 0;
            selfStartX = x;
            selfStartY = y;
            selfTargetX = toX;
            selfTargetY = toY;
        }

        private function clearPathData() : void
        {
            while (pathData.length > 0)
            {
                pathData.shift();
            }
        }

        private var selfStartX : int;
        private var selfStartY : int;
        private var selfTargetX : int;
        private var selfTargetY : int;
        private var moveedDistanceSQ : Number;
        private var moveedDistance : Number = 0;
        private var moveedTotalDistance : Number = 0;
        private var preM : int = 0;
        private var curM : int = 0;
        private var pathData : Vector.<Vector2D> = new Vector.<Vector2D>();
        private var stepDistance : uint = 100;

        public function moveing(x : int, y : int) : void
        {
            if (list == null || list.length == 0) return;
            var dx : int = x - selfStartX;
            var dy : int = y - selfStartY;
            moveedTotalDistance -= moveedDistance;
            moveedDistanceSQ = dx * dx + dy * dy;
            moveedDistance = Math.sqrt(moveedDistanceSQ);
            moveedTotalDistance += moveedDistance;

            curM = moveedTotalDistance / stepDistance;
            var followerAnimal : Animal ;
            var point : Vector2D;
            if (curM > preM)
            {
                preM = curM;

                point = new Vector2D();
                point.x = x;
                point.y = y;
                pathData.unshift(point);

                for (var i : int = 0; i < list.length; i++)
                {
                    followerAnimal = list[i];
                    if (pathData.length > i )
                    {
                        point = pathData[i];
                        followerAnimal.pathData.push(point);
                        followerAnimal.startArrive();
                    }
                }

                if (pathData.length > list.length * 2 + 2)
                {
                    pathData.pop();
                }
            }
        }

        public function moveEnd() : void
        {
        }

        public function transport(toX : int, toY : int) : void
        {
            if (list == null || list.length == 0) return;
            clearPathData();
            var follower : Animal;
            for (var i : int = 0; i < list.length; i++)
            {
                follower = list[i];
                follower.stopMove();
                follower = list[i];
                var x : int = toX + Math.random() * 100;
                var y : int = toY + Math.random() * 100;
                follower.moveTo(x, y);
            }
        }
    }
}
