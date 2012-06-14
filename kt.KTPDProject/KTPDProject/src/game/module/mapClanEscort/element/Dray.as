package game.module.mapClanEscort.element
{
	import game.module.map.MapSystem;
	import game.core.avatar.AvatarManager;
	import game.module.map.animal.AnimalType;
	import game.core.avatar.AvatarDray;
	import game.core.user.StateManager;
	import game.manager.RSSManager;
	import game.module.map.animal.AnimalManager;
	import game.module.map.animal.DrayAnimal;
	import game.module.map.animalstruct.DrayStruct;
	import game.module.mapClanEscort.MCEConfig;
	import game.module.mapClanEscort.MCEController;
	import game.module.mapClanEscort.MCEPlaceStruct;
	import game.module.quest.VoBase;

	import com.commUI.alert.Alert;
	import com.greensock.TweenLite;

	import flash.utils.setTimeout;



    /**
     * @author ZengFeng (Email:zengfeng75[AT]163.com) 2012-2-24   ����10:36:09 
     */
    public class Dray
    {
        /** 镖车ID */
        public var id : int;
        /** 路线ID */
        public var pathId : int;
        /** 路线地点ID */
        public var placeId : int;
        /** 到下一个地点已经走了多少时间 */
        public var walkedTime : Number;
        /** 镖车血量比例 */
        private var _HP : Number = 100;
        /** 镖车状态 1.前进中    2.被怪拦截     3.被毁(一般不会用到，除非UI上要显示) */
        public var status :int;
        /** 怪物血量 */
        private var _monsterHP : Number = 0;
        /** 怪物总血量 */
        public var monsterTotalHP : Number = 0;
        /** 名称 */
        public var name : String = "";
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 控制器 */
        private var _controller : MCEController;

        /** 控制器 */
        public function get controller() : MCEController
        {
            if (_controller == null)
            {
                _controller = MCEController.instance;
            }
            return _controller;
        }

        /** 动物管理器 */
        private var animalManager : AnimalManager = AnimalManager.instance;
        private var animal : DrayAnimal;
        public var monster : Robber;
        private var initialized : Boolean = false;

        /** 初始化 */
        public function initialize() : void
        {
            if (initialized == true) return;
            initialized = true;

            var struct : DrayStruct = new DrayStruct();
            struct.id = id;
            var baseId:int = MCEConfig.getAvatarId(pathId);

            var voBase : VoBase = RSSManager.getInstance().getNpcById(baseId);
            if (voBase != null)
            {
//                struct.name = "镖车_" + voBase.name + id;
                struct.name = voBase.name;
                name = struct.name;
                struct.avatarId = voBase.avatarId;
            }

            var placeStruct : MCEPlaceStruct = getPlace();
            if (placeStruct == null) Alert.show("没有配置那么高的地址");
            var nextPlaceStruct : MCEPlaceStruct = getPlace(placeId + 1);
            if (nextPlaceStruct)
            {
                struct.x = placeStruct.x + (nextPlaceStruct.x - placeStruct.x) * walkedTime / nextPlaceStruct.time;
                struct.y = placeStruct.y + (nextPlaceStruct.y - placeStruct.y) * walkedTime / nextPlaceStruct.time;
            }
            else
            {
                struct.x = placeStruct.x;
                struct.y = placeStruct.y;
            }
            animal = animalManager.addAnimal(struct) as DrayAnimal;
            animal.avatar.addProgressBar();
            animal.avatar.showHPBar(HP);
            refreshStatus();
        }

        /** 获取当前地点所在位置 */
        public function getPlace(placeId : int = 0) : MCEPlaceStruct
        {
            if (placeId == 0) placeId = this.placeId;
            return MCEConfig.getPlace(placeId);
        }

        /** 移动 */
        public function move() : void
        {
            var moveToPlaceId : int = placeId;
//			animal.avatar.removeEventListener(Event.COMPLETE, onRobComplete);
            if (MCEConfig.getPathEndId(pathId) != placeId)
            {
                moveToPlaceId = placeId + 1;
				trace( "path : " + pathId + "move to :" + placeId + "time :" + (new Date()).time );
                //trace("moveToPlaceId = " + moveToPlaceId);
            }

            var placeStruct : MCEPlaceStruct = getPlace(moveToPlaceId);
            if (placeStruct == null) return;
            animal.autoWalk(placeStruct.x, placeStruct.y);
        }

        /** 
         * 镖车遇怪被抢劫 
         */
        public function beRob() : void
        {
            animal.stopMove();
			(animal.avatar as AvatarDray).defend() ;
            if (monster == null)
            {
                monster = new Robber();
                monster.dray = this;
            }

            monster.drayId = id;
            monster.totalHP = monsterTotalHP;
            monster.HP = monsterHP;
            monster.placeId = placeId;
            monster.initialize();
        }
		

        /** 销毁 */
        public function destroy() : void
        {
			if( !initialized )
				return ;
            if (monster != null)
            {
                monster.quit();
            }
            animal.stopMove();
            controller.drayBeDestroy(id, true);
            setTimeout(quit, 1000);
        }

        /** 完成 */
        public function complete() : void
        {
            if (monster != null)
            {
                monster.quit();
            }

            controller.drayComplete(id, true);
//            StateManager.instance.checkMsg(221, [name]);
            if( animal != null )
			{
				animal.stopMove() ;
				animal.draycomplete();
			}
        }

        /** 退出 */
        public function quit() : void
        {
			if( initialized )
			{
				initialized = false ;
	            if (monster != null)
	            {
	                monster.quit();
	            }
				if( animal != null ){
					TweenLite.to(animal.avatar, 1, {alpha:0});
					setTimeout(onQuitComplete , 1100);
				}
	            controller.drayQuit(id, true);
				
			}
        }
		
		
		public function onQuitComplete():void{
			animalManager.removeAnimal(animal.id, AnimalType.DRAY);
			AvatarManager.instance.removeAvatar(animal.avatar); 
			animal = null ;
		}

        /** 更新状态 */
        public function refreshStatus() : void
        {
            if (initialized == false) return;
            switch(status)
            {
                case DrayStatus.MOVE:
                    move();
                    break;
                case DrayStatus.BE_ROB:
                    beRob();
                    break;
//                case DrayStatus.BE_DESTROY:
                    // destroy();
//                    break;
                case DrayStatus.COMPLETE:
					if( HP != 0 )
                    	complete();
                    break;
            }
        }

        /** 镖车血量比例 */
        public function get HP() : Number
        {
            return _HP;
        }

        public function set HP(hP : Number) : void
        {
            _HP = hP;
            if (initialized == false) return;
            animal.avatar.showHPBar(_HP);
            if (HP <= 0)
            {
                destroy();
            }
        }

        /** 怪物血量 */
        public function get monsterHP() : Number
        {
            return _monsterHP;
        }

        public function set monsterHP(monsterHP : Number) : void
        {
            _monsterHP = monsterHP;
            if (monster != null) monster.HP = monsterHP;
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

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 战斗玩家ID */
        public var battlePlayerList : Vector.<int> = new Vector.<int>();

        /** 添加战斗玩家ID */
        public function addBattlePlayer(playerId : int) : void
        {
            var index : int = battlePlayerList.indexOf(playerId);
            if (index == -1)
            {
                battlePlayerList.push(index);
            }
        }

        /** 移除战斗玩家ID */
        public function reomveBattlePlayer(playerId : int) : void
        {
            var index : int = battlePlayerList.indexOf(playerId);
            if (index != -1)
            {
                battlePlayerList.splice(index, 1);
            }
        }

        /** 清理战斗玩家 */
        public function clearBattlePlayer() : void
        {
            while (battlePlayerList.length > 0)
            {
                battlePlayerList.shift();
            }
        }
    }
}
