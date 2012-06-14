package game.module.map.animalstruct
{
    import com.utils.PotentialColorUtils;

    import flash.geom.Point;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-30 ����3:17:47
     * 抽象动物类
     */
    public class AbstractStruct
    {
        private var _id:int;
        private var _name:String = "";
        private var _position:Point = new Point(); 
        private var toPostion:Point = new Point();
        public var toWalkedTime:Number = 0;
        public var startWalkTime:Number = 0;
        protected var _speed:Number = 20;
        protected var _avatarId:int = 0;
        /** 潜力 */
        public var potential:int = -1;
        public function get color():uint
        {
            if(potential == -1) return 0xFF7E00;
            return PotentialColorUtils.getColor(potential);
        }
        
        public function get colorStr():String
        {
            if(potential == -1) return "#FF7E00";
            return PotentialColorUtils.getColorOfStr(potential);
        }
        
        
        public function get id():int
        {
            return _id;
        }
        
        public function set id(value:int):void
        {
            _id = value;
        }
        
        /** 获取名称 */
        public function get name():String
        {
            return _name;
        }
        
        public function set name(value:String):void
        {
            _name = value;
        }
        
        public function get position():Point
        {
            return _position;
        }
        
        public function get x() : int
        {
            return _position.x;
        }

        public function get y() : int
        {
            return _position.y;
        }

        public function get toX() : int
        {
            return toPostion.x;
        }

        public function get toY() : int
        {
            return toPostion.y;
        }

        public function set x(value : int) : void
        {
            _position.x = value;
        }

        public function set y(value : int) : void
        {
            _position.y = value;
        }

        public function set toX(value : int) : void
        {
            toPostion.x = value;
        }

        public function set toY(value : int) : void
        {
            toPostion.y = value;
        }
        
		/** 移动速度 */
        public function get speed() : Number
        {
            return _speed;
        }

        public function set speed(speed : Number) : void
        {
            _speed = speed;
        }
        
        public function get avatarId() : int
        {
            return _avatarId;
        }

        public function set avatarId(avatarId : int) : void
        {
            _avatarId = avatarId;
        }
        
        /** 动物类型 */
        public function get animalType():String
        {
            throw new Error("Abstract Method!");
        }

    }
}
