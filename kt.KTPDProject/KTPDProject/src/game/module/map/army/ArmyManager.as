package game.module.map.army {
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-1-6 ����8:46:36
     */
    public class ArmyManager
    {
        function ArmyManager(singleton:Singleton):void
        {
            singleton;
        }
        
        /** 单例对像 */
        private static var _instance : ArmyManager;

        /** 获取单例对像 */
        static public function get instance() : ArmyManager
        {
            if (_instance == null)
            {
                _instance = new ArmyManager(new Singleton());
            }
            return _instance;
        }
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public var timer : Timer = new Timer(200);
        public var groupDic : Dictionary = new Dictionary();
		/** 自己阵营 */
		public var selfGroup:ArmyGroup = new ArmyGroup(null, 1, "自己阵营");
		/** 副本怪物阵营 */
		public var dungeonMonsterGroup:ArmyGroup = new ArmyGroup(null, 2, "副本怪物阵营");
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public function init():void
        {
            selfGroup.clear();
            dungeonMonsterGroup.clear();
			addGroup(selfGroup);
			addGroup(dungeonMonsterGroup);
        }
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 添加组 */
        public function addGroup(group :ArmyGroup) : void
        {
            if(group.id <= 0)
            {
                group.id = autoCreateGroupId();
            }
            
            if (groupDic[group.id] != null) return;
            group.manager = this;
            groupDic[group.id] = group;
            addOtherGroups(group);
        }

        /** 移除组 */
        public function removeGroup(group : ArmyGroup) : void
        {
            if (group == null) return;
            group.clear();
            group.manager = null;
            if (groupDic[group.id]) delete group[group.id];
			
			for each(var otherGroup:ArmyGroup in groupDic)
			{
				otherGroup.removeEnemGroup(group);
			}
        }

        /** 加入其他阵营的敌对列表 */
        public function addOtherGroups(group : ArmyGroup) : void
        {
            if (group == null) return;
            for each (var enemyGroup:ArmyGroup in groupDic)
            {
                if (enemyGroup != group)
                {
                    enemyGroup.addEnemGroup(group);
                    group.addEnemGroup(enemyGroup);
                }
            }
        }
		
		
        /** 清理 */
        public function clear() : void
        {
            for each (var group:ArmyGroup in groupDic)
            {
                delete groupDic[group.id];
                group.clear();
                removeGroup(group);
            }
        }
		
		/** 开始运行 */
        public function start() : void
        {
            for each (var group:ArmyGroup in groupDic)
            {
                group.start();
            }

            timer.addEventListener(TimerEvent.TIMER, runing);
            timer.start();
        }
        
        
        /** 继续 */
        public function play():void
        {
            timer.addEventListener(TimerEvent.TIMER, runing);
            timer.start();
        }
        
        /** 暂停 */
        public function pause():void
        {
            timer.stop();
            timer.removeEventListener(TimerEvent.TIMER, runing);
        }

        /** 停止 */
        public function stop() : void
        {
            timer.stop();
            timer.removeEventListener(TimerEvent.TIMER, runing);

            for each (var group:ArmyGroup in groupDic)
            {
                group.stop();
            }
        }
        
        /** 退出 */
        public function quit():void
        {
            stop();
            clear();
        }
		
		/** 运行中 */
        private function runing(event : TimerEvent) : void
        {
            for each (var group:ArmyGroup in groupDic)
            {
                for (var i : int = 0; i < group.list.length; i++)
                {
                    group.list[i].armyRuning();
                }
            }
        }
        
        
        private var _autoCreateLastGroupId:uint = 10000;

        /** 自动生成组ID */
        public function autoCreateGroupId() : uint
        {
            return _autoCreateLastGroupId++;
        }
    }
}
class Singleton
{
    
}
