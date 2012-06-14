package game.module.mapClanEscort.element
{
    import com.utils.CallFunStruct;
    import flash.geom.Point;
    import game.manager.RSSManager;
    import game.module.map.MapSystem;
    import game.module.map.animal.AnimalManager;
    import game.module.map.animal.RobberAnimal;
    import game.module.map.animalstruct.RobberStruct;
    import game.module.map.utils.MapUtil;
    import game.module.mapClanEscort.MCEConfig;
    import game.module.mapClanEscort.MCEPlaceStruct;
    import game.module.mapClanEscort.MCEProto;
    import game.module.quest.VoBase;





    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-2-24   ����10:44:02 
     */
    public class Robber
    {
        /** 地点ID */
        public var placeId : int;
        /** 镖车ID */
        public var drayId : int;
        /** 血量 */
        private var _HP : Number = 100;
        /** 总血量 */
        public var totalHP : Number = 100;
        /** 镖车 */
        public var dray : Dray;
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 动物管理器 */
        private var animalManager : AnimalManager = AnimalManager.instance;
        private var animal : RobberAnimal;
        private var initialized : Boolean = false;

        /** 初始化 */
        public function initialize() : void
        {
            if (initialized == true) return;
            initialized = true;
            var struct : RobberStruct = new RobberStruct();
            struct.id = drayId;

            var placeStruct : MCEPlaceStruct = getPlace();
            var voBase : VoBase = RSSManager.getInstance().getNpcById(placeStruct.monsterId);
            if (voBase != null)
            {
//                struct.name = "怪_" + voBase.name + drayId;
                struct.name = voBase.name;
                struct.avatarId = voBase.avatarId;
            }

            struct.x = dray.x - 70;
            struct.y = dray.y - 20;

            animal = animalManager.addAnimal(struct) as RobberAnimal;
            animal.avatar.addProgressBar();
            // animal.avatar.addClickCall(new CallFunStruct(MapSystem.toMap, [0, animal.x, animal.y, false, onClickAvatar]));
            animal.avatar.addClickCall(new CallFunStruct(onClickAvatar));
            animal.fontAttackAction();
			animal.avatar.getProgressBar().toolTip = null ;
            refreshHP();
        }

        /** 点击Avatar */
        private function onClickAvatar() : void
        {
            MCEProto.instance.cs_playerBattle(drayId);
        }

        /** 获取当前地点所在位置 */
        public function getPlace(placeId : int = 0) : MCEPlaceStruct
        {
            if (placeId == 0) placeId = this.placeId;
            return MCEConfig.getPlace(placeId);
        }

        /** 刷新血条 */
        private function refreshHP() : void
        {
            var value : int = HP / totalHP * 100;
            animal.avatar.showHPBar(value);
        }

        /** 血量 */
        public function get HP() : Number
        {
            return _HP;
        }

        /** 血量 */
        public function set HP(hP : Number) : void
        {
            _HP = hP;
            if (initialized == false || totalHP <= 0) return;
            refreshHP();

            if (hP <= 0)
            {
                quit();
            }
        }

        /** 退出 */
        public function quit() : void
        {
            if (animal) animal.quit();
            animalManager = null;
            animal = null;
            if (dray) dray.monster = null;
            dray = null;
        }

        /** 获取当前位置X */
        public function get x() : Number
        {
            if (initialized == false) return 0;
            return animal.x;
        }

        /** 获取当前位置X */
        public function get y() : Number
        {
            if (initialized == false) return 0;
            return animal.y;
        }
    }
}
