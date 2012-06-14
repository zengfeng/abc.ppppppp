package game.module.duplPanel
{
	import game.manager.RSSManager;
	import game.module.duplMap.DuplConfig;
	import game.module.duplMap.DuplOpened;
	import game.module.duplMap.DuplUtil;
	import game.module.map.animalstruct.MonsterStruct;

    /**
     *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-18
     */
    public class DuplPanelQuest
    {
        public function DuplPanelQuest(singleton : Singleton)
        {
            singleton;
        }

        /** 单例对像 */
        private static var _instance : DuplPanelQuest;

        /** 获取单例对像 */
        public static function get instance() : DuplPanelQuest
        {
            if (_instance == null)
            {
                _instance = new DuplPanelQuest(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public var duplMapId : int = 0;
        public var duplId : int = 0;
        public var layerId : int = 0;
        public var questCall : Function;
        public var questCallArgs : Array;

        public function openEnterWindow(duplMapId : int, endAutoRunCall : Function = null, questCall : Function = null, questCallArgs : Array = null, guideType : int = 0, guideArgs : Array = null) : void
        {
			this.questCall = questCall;
			this.questCallArgs = questCallArgs;
            if (endAutoRunCall != null)
            {
                endAutoRunCall.apply();
            }

            if (guideType == 0)
            {
                closeGuide();
            }
            else
            {
                openGuide(guideType, guideArgs);
            }
            this.duplMapId = duplMapId;
            duplId = DuplUtil.getDuplId(duplMapId);
            layerId = DuplUtil.getLayerId(duplMapId);
            DuplPanelController.instance.cs_duplInfo(duplId);
            DuplConfig.QUIT_OPEN_WEINDOW_ENTER = true;
        }

        public static const DEFEAT_BOSS : int = 2;
        public static const HOOK : int = 4;
        public static const DUPL_STORY_BATTLE_PRE : int = 8;
        public static const DUPL_STORY_BATTLE_BACK : int = 16;
        public var hasGuide : Boolean = false;
        public var guideType : int = 0;
        public var guideArgs : Array;

        public function openGuide(type : int, guideArgs : Array) : void
        {
            hasGuide = true;
            guideType = type;
            this.guideArgs = guideArgs;
        }

        public function closeGuide() : void
        {
            DuplConfig.QUIT_OPEN_WEINDOW_ENTER = false;
            hasGuide = false;
            guideArgs = null;
            guideType = 0;
        }

        public function cheackDefeatBossGuide(duplId : int, layerId : int, isPass : Boolean) : void
        {
            if (hasCurrentDuplGuide(duplId) == true)
            {
                if (this.layerId == layerId && isPass == true)
                {
                    closeGuide();
                }
            }
        }

        public function hasCurrentDuplGuide(duplId : int) : Boolean
        {
            if (hasGuide == false) return false;
            return this.duplId == duplId;
        }

        public function enFreeEnter(duplId : int, layerId : int) : Boolean
        {
            if (hasCurrentDuplGuide(duplId) == false) return false;
            if (this.layerId == layerId) return true;
            var maxLayerId : int = DuplOpened.getOpenedMaxLayerId(duplId);
            return maxLayerId < this.layerId && layerId <= this.layerId;
        }

        // ====================
        // 副本战斗前剧情
        // ====================
        public function hasDuplStoryBattlePre(duplId : int, layerId : int) : Boolean
        {
            if (hasCurrentDuplGuide(duplId) == false) return false;
            if (this.layerId != layerId) return false;
            return (guideType & DUPL_STORY_BATTLE_PRE) == DUPL_STORY_BATTLE_PRE;
        }

        private var storyActivateMonsterStruct : MonsterStruct;

        public function getStoryActivateMonsterStruct() : MonsterStruct
        {
            if (storyActivateMonsterStruct == null)
            {
                storyActivateMonsterStruct = new MonsterStruct();
                storyActivateMonsterStruct.mapId = duplMapId;
                storyActivateMonsterStruct.duplId = duplId;
                storyActivateMonsterStruct.layerId = layerId;
                storyActivateMonsterStruct.monsterId = 4124;
                storyActivateMonsterStruct.wave = 1024;
                storyActivateMonsterStruct.isBoss = false;
                storyActivateMonsterStruct.standPoint.push(storyActivateMonsterStruct.position);
                storyActivateMonsterStruct.attackRadius = 300;
                storyActivateMonsterStruct.moveRadius = 400;
                storyActivateMonsterStruct.voBase = RSSManager.getInstance().getNpcById(storyActivateMonsterStruct.monsterId);
            }
            if (guideArgs != null)
            {
                storyActivateMonsterStruct.x = guideArgs[0];
                storyActivateMonsterStruct.y = guideArgs[1];
            }
            return storyActivateMonsterStruct;
        }

        public function monsterActivateStory() : void
        {
            if (questCall != null)
            {
                questCall.apply(null, questCallArgs);
            }
        }
    }
}
class Singleton
{
}