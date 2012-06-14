package game.module.mapStory
{
    import flash.geom.Point;
    import game.module.map.CurrentMapData;
    import game.module.map.MapController;
    import game.module.map.MapHideServer;
    import game.module.map.MapSystem;
    import game.module.map.animal.AnimalManager;
    import game.module.map.animal.AnimalType;
    import game.module.map.animal.EscortAnimal;
    import game.module.map.animal.PlayerAnimal;
    import game.module.map.animal.SelfPlayerAnimal;
    import game.module.map.animal.SelfStoryAnimal;
    import game.module.map.animal.StoryAnimal;
    import game.module.map.animalstruct.AnimalStructUtil;
    import game.module.map.animalstruct.SelfStoryStruct;
    import game.module.map.animalstruct.StoryStruct;
    import game.module.map.utils.MapUtil;


    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-9 ����11:45:03
     * 剧情控制器
     */
    public class StoryController3
    {
        function StoryController3(singleton : Singleton) : void
        {
            singleton;
        }

        /** 单例对像 */
        private static var _instance : StoryController3;

        /** 获取单例对像 */
        public static function get instance() : StoryController3
        {
            if (_instance == null)
            {
                _instance = new StoryController3(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        private var mapHideServer : MapHideServer = MapHideServer.instance;
        /** 当前地图数据 */
        private var _currData : CurrentMapData;

        /** 当前地图数据 */
        public function get currData() : CurrentMapData
        {
            if (_currData == null)
            {
                _currData = CurrentMapData.instance;
            }
            return _currData;
        }

        /** 控制器 */
        private static var _controller : MapController ;

        /** 控制器 */
        private static function get controller() : MapController
        {
            if (_controller == null)
            {
                _controller = MapController.instance;
            }
            return _controller;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 缓存剧情之前玩家是否绑定自己玩家 */
        private var mapMoveIsBindSelfPlayer : Boolean = true;
        /** 点击地图是否能控制自己玩家 */
        private var enMouseMove : Boolean = true;
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        private var animalManger : AnimalManager = AnimalManager.instance;

        public function get selfPlayer() : SelfPlayerAnimal
        {
            return animalManger.selfPlayer;
        }

        public function getPlayer(playerId : int) : PlayerAnimal
        {
            return animalManger.getPlayer(playerId);
        }

        public function getNpc(npcId : int) : StoryAnimal
        {
            return animalManger.getStory(npcId);
        }

        // public function getMonster(monsterId : int) : MonsterAnimal
        // {
        // return animalManger.getMonster(monsterId);
        // }
        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        /** 是否在剧情中 */
        public function get isIn() : Boolean
        {
            return _isIn;
        }

        private var _isIn : Boolean = false;

        /** 安装 */
        public function setup(mapId : int, x : int, y : int) : void
        {
            if (_isIn == true)
            {
                quit();
                setup(mapId, x, y);
                return;
            }
            _isIn = true;
            mapMoveIsBindSelfPlayer = MapSystem.mapMoveIsBindSelfPlayer;
            enMouseMove = controller.enMouseMove;
            controller.enMouseMove = false;
            MapSystem.setHideServerMode(true);
            mapHideServer.convertFromCurrent();
            
            setEscortVisible(false);

            if (currData.setupNpcList)
            {
                while (currData.setupNpcList.length > 0)
                {
                    currData.setupNpcList.shift();
                }
            }

            if (currData.setupMonsterList)
            {
                while (currData.setupMonsterList.length > 0)
                {
                    currData.setupMonsterList.shift();
                }
            }
            currData.selfPlayerStruct.x = x;
            currData.selfPlayerStruct.y = y;

            if (MapUtil.isCurrentMapId(mapId) == true)
            {
                setupMapIsSelfMap(x, y);
            }
            else
            {
                setupMapIsOtherMap(mapId, x, y);
            }

            MapSystem.mapMoveIsBindSelfPlayer = false;
            controller.enMouseMove = false;
        }

        /** 按装地图，地图不是当前地图的时候 */
        private function setupMapIsOtherMap(mapId : int, x : int, y : int) : void
        {
            controller.preSetupMap(mapId, new Point(x, y));
        }

        /** 按装地图，地图是当前地图的时候 */
        private function setupMapIsSelfMap(x : int, y : int) : void
        {
            animalManger.clear();
            MapSystem.mapMoveTo(x, y, 0);
        }

        /** 退出 */
        public function quit() : void
        {
            _isIn = false;
            animalManger.clear();
            MapSystem.mapMoveIsBindSelfPlayer = mapMoveIsBindSelfPlayer;
            controller.enMouseMove = enMouseMove;
            MapSystem.setHideServerMode(false);
            mapHideServer.convertToCurrent();
            setEscortVisible(false);
        }

        /** 显示隐藏任务被护送者 */
        private function setEscortVisible(value : Boolean) : void
        {
            var escortList : Vector.<EscortAnimal> = animalManger.escortList;
            for (var i : int = 0; i < escortList.length; i++)
            {
                if (value == true)
                {
                    escortList[i].show();
                }
                else
                {
                    escortList[i].hide();
                }
            }
        }

        /** 设置地图的位置 */
        public function mapMoveTo(x : int, y : int, spendTime : Number = -1) : void
        {
            MapSystem.mapMoveTo(x, y, spendTime);
        }

        /** 获取自己 */
        public function get self() : SelfStoryAnimal
        {
            return animalManger.selfStory;
            ;
        }

        /** 添加自己 */
        public function addSelf(x : int = 0, y : int = 0, childIndex : int = 1) : void
        {
            if (self == null)
            {
                var selfStoryStruct : SelfStoryStruct = AnimalStructUtil.cloneSelfPlayerToSelfStory(x, y);
                selfStoryStruct.childIndex = childIndex;
                animalManger.addAnimal(selfStoryStruct);
            }
            else
            {
                self.moveTo(x, y);
            }
        }

        /** 移除自己 */
        public function removeSelf() : void
        {
            if (self)
            {
                self.quit();
            }
        }

        /** 设置自己的位置 */
        public function selfMoveTo(toX : int, toY : int, flashStep : Boolean = false) : void
        {
            if (self)
            {
                if (flashStep == false)
                {
                    self.walk(toX, toY);
                }
                else
                {
                    self.moveTo(toX, toY);
                }
            }
        }

        /** 添加NPC */
        public function addNpc(npcId : uint, x : int = 0, y : int = 0, childIndex:int = 1) :StoryAnimal
        {
            var animal : StoryAnimal = animalManger.getStory(npcId);
            if (animal == null)
            {
                var struct : StoryStruct = AnimalStructUtil.cloneNpcToStory(npcId, x, y);
                struct.childIndex = childIndex;
                animal = animalManger.addAnimal(struct) as StoryAnimal;
            }
            else
            {
                animal.moveTo(x, y);
            }

            return animal;
        }

        /** 移除NPC */
        public function removeNpc(npcId : uint) : void
        {
            animalManger.removeAnimal(npcId, AnimalType.STORY);
        }

        /** npc移动到 */
        public function npcMoveTo(npcId : uint, toX : int, toY : int, flashStep : Boolean = false) : void
        {
            var animal : StoryAnimal = getNpc(npcId);
            if (animal)
            {
                if (flashStep == false)
                {
                    animal.walk(toX, toY);
                }
                else
                {
                    animal.moveTo(toX, toY);
                }
            }
        }
    }
}
class Singleton
{
}