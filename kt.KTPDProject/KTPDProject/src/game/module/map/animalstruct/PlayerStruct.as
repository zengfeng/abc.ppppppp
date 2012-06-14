package game.module.map.animalstruct
{
	import game.module.map.MapProto;
	import game.module.map.animal.AnimalType;
	import game.net.data.StoC.SCAvatarInfo.PlayerAvatar;
	import game.net.data.StoC.SCAvatarInfoChange;
	import game.net.data.StoC.SCMultiAvatarInfoChange.AvatarInfoChange;

    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-3-12   ����7:59:43 
     */
    public class PlayerStruct extends AbstractStruct
    {
        /** 职业--金刚 */
        public static const JOB_JIN_GANG : uint = 1;
        /** 职业--修罗 */
        public static const JOB_XIU_LUO : uint = 2;
        /** 职业--天师 */
        public static const JOB_TIAN_SHI : uint = 3;
        public var avatarVer : Number = -1;
        public var newAvatarVer : Number = 0;
        public var isMale : Boolean = true;
        public var job : uint = 0;
        /** 将领ID 1-男金刚 2-女金刚 3-男修罗 4-女修罗 5-男天师 6-女天师 */
        protected var _heroId : uint = 0;
        public var level : uint = 0;
        public var cloth : uint = 0;
        public var ride : uint;
        public var model : uint;

        public function PlayerStruct()
        {
        }
        
        public function checkVer():void
        {
            if(avatarVer == -1)
            {
                MapProto.instance.cs_avatarInfo(id);
            }
            else if(avatarVer != newAvatarVer)
            {
                MapProto.instance.cs_avatarInfoChange(id);
            }
        }
        
        public function get modelIsConvoy():Boolean
        {
            return model > 0 && model < 10;
        }

        /** 克隆 */
        public function clone() : PlayerStruct
        {
            var playerStruct : PlayerStruct = new PlayerStruct();
            playerStruct.id = id;
            playerStruct.name = name;
            playerStruct.x = x;
            playerStruct.y = y;
            playerStruct.toX = toX;
            playerStruct.toY = toY;
            playerStruct.speed = speed;
            playerStruct.avatarVer = avatarVer;
            playerStruct.isMale = isMale;
            playerStruct.job = job;
            playerStruct.heroId = heroId;
            playerStruct.level = level;
            playerStruct.cloth = cloth;
            playerStruct.ride = ride;
            playerStruct.model = model;
            return playerStruct;
        }

        /** 镜像 */
        public function mirror(playerStruct : PlayerStruct) : void
        {
            if (playerStruct == null) return;
            id = playerStruct.id;
            name = playerStruct.name;
            x = playerStruct.x;
            y = playerStruct.y;
            toX = playerStruct.toX;
            toY = playerStruct.toY;
            speed = playerStruct.speed;
            avatarVer = playerStruct.avatarVer;
            isMale = playerStruct.isMale;
            job = playerStruct.job;
            heroId = playerStruct.heroId;
            level = playerStruct.level;
            cloth = playerStruct.cloth;
            ride = playerStruct.ride;
            model = playerStruct.model;
            runUpdateCall();
        }

        /** 合并详细Avatar信息 */
        public function mergeSCAvatarInfo(avatarInfo : PlayerAvatar) : void
        {
            this.name = avatarInfo.name;
            this.potential = avatarInfo.job >> 4;
            this.heroId = avatarInfo.job & 0xF;
            this.level = avatarInfo.level;
            this.cloth = avatarInfo.cloth;
            this.ride = avatarInfo.ride;
            this.avatarVer = avatarInfo.avatarVer;
            this.newAvatarVer = avatarInfo.avatarVer;
            runUpdateCall();
        }

        /** 合并详细Avatar改变信息 */
        public function mergeSCAvatarInfoChange(avatarInfo : SCAvatarInfoChange) : void
        {
            if(avatarInfo.hasCloth) this.cloth = avatarInfo.cloth;
            if(avatarInfo.hasLevel) this.level = avatarInfo.level;
            if(avatarInfo.hasRide) this.ride = avatarInfo.ride;
			this.avatarVer = avatarInfo.avatarVer & 0x1F;
			this.model = avatarInfo.avatarVer >> 5;
            this.newAvatarVer = avatarInfo.avatarVer;
            runUpdateCall();
        }
		
        /** 合并详细Avatar改变信息 */
        public function mergeAvatarInfoChange(avatarInfo : AvatarInfoChange) : void
        {
            if(avatarInfo.hasCloth) this.cloth = avatarInfo.cloth;
            if(avatarInfo.hasLevel) this.level = avatarInfo.level;
            if(avatarInfo.hasRide) this.ride = avatarInfo.ride;
			this.newAvatarVer = avatarInfo.avatarVer & 0x1F;
			this.model = avatarInfo.avatarVer >> 5;
            if(this.avatarVer != -1) this.avatarVer = this.newAvatarVer;
            runUpdateCall();
        }

        public function get heroId() : uint
        {
            return _heroId;
        }

        public function set heroId(value : uint) : void
        {
            _heroId = value;
            switch(value)
            {
                case 1:
                    job = JOB_JIN_GANG;
                    isMale = true;
                    break;
                case 2:
                    job = JOB_JIN_GANG;
                    isMale = false;
                    break;
                case 3:
                    job = JOB_XIU_LUO;
                    isMale = true;
                    break;
                case 4:
                    job = JOB_XIU_LUO;
                    isMale = false;
                    break;
                case 5:
                    job = JOB_TIAN_SHI;
                    isMale = true;
                    break;
                case 6:
                    job = JOB_TIAN_SHI;
                    isMale = false;
                    break;
            }
        }
        
        
        private var updateCall : Vector.<Function> = new Vector.<Function>();

        public function clearUpdateCall() : void
        {
            while (updateCall.length > 0)
            {
                updateCall.shift();
            }
        }

        public function addUpdateCall(fun : Function) : void
        {
            if (fun == null) return;
            var index : int = updateCall.indexOf(fun);
            if (index == -1)
            {
                updateCall.push(fun);
            }
        }

        public function removeUpdateCall(fun : Function) : void
        {
            if (fun == null) return;
            var index : int = updateCall.indexOf(fun);
            if (index != -1)
            {
                updateCall.splice(index, 1);
            }
        }

        public function runUpdateCall() : void
        {
            for (var i : int = 0; i < updateCall.length; i++)
            {
                var fun : Function = updateCall[i];
                fun.apply(null, [this]);
            }
        }

        /** 动物类型 */
        override public function get animalType() : String
        {
            return AnimalType.PLAYER;
        }
    }
}
