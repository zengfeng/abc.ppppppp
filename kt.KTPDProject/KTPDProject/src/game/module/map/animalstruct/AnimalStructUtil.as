package game.module.map.animalstruct
{
	import flash.geom.Point;
	import game.manager.RSSManager;
	import game.module.map.CurrentMapData;
	import game.module.map.utils.MapUtil;
	import game.module.quest.VoBase;


    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-2-20 ����5:44:32
     */
    public class AnimalStructUtil
    {
        public static function cloneNpcToEscort(npcId : int, id : int = 0, x : int = 0, y : int = 0) : EscortStruct
        {
            var escortStruct : EscortStruct = new EscortStruct();
            escortStruct.id = id != 0 ? id : npcId;
            if (x != 0) escortStruct.x = x;
            if (y != 0) escortStruct.y = y;
            if (x == 0 && y == 0)
            {
                var npcStruct : NpcStruct = MapUtil.getNpcStruct(npcId);
                if (npcStruct != null)
                {
                    escortStruct.x = npcStruct.x;
                    escortStruct.y = npcStruct.y;
                }
                else
                {
                    var point : Point = MapUtil.selfPlayerPosition;
                    escortStruct.x = point.x;
                    escortStruct.y = point.y;
                }
            }

            var voBase : VoBase = RSSManager.getInstance().getNpcById(npcId);
            if (voBase != null)
            {
                escortStruct.avatarId = voBase.avatarId;
                escortStruct.name = voBase.name;
            }
            return escortStruct;
        }

        public static function cloneSelfPlayerToSelfStory(x : int = 0, y : int = 0) : SelfStoryStruct
        {
            var struct : SelfStoryStruct = new SelfStoryStruct();
            var selfPlayerStruct : SelfPlayerStruct = CurrentMapData.instance.selfPlayerStruct;
            struct.id = selfPlayerStruct.id;
            struct.name = selfPlayerStruct.name;
            if (x != 0 && y != 0)
            {
                struct.x = x;
                struct.y = y;
            }
            else
            {
                struct.x = selfPlayerStruct.x;
                struct.y = selfPlayerStruct.y;
            }
            return struct;
        }

        public static function cloneNpcToStory(id : int, x : int = 0, y : int = 0) : StoryStruct
        {
            var struct : StoryStruct = new StoryStruct();
            struct.id = id;
            if (x != 0) struct.x = x;
            if (y != 0) struct.y = y;
            if (x == 0 && y == 0)
            {
                var npcStruct : NpcStruct = MapUtil.getNpcStruct(id);
                if (npcStruct != null)
                {
                    struct.x = npcStruct.x;
                    struct.y = npcStruct.y;
                }
                else
                {
                    var point : Point = MapUtil.selfPlayerPosition;
                    struct.x = point.x;
                    struct.y = point.y;
                }
            }

            var voBase : VoBase = RSSManager.getInstance().getNpcById(id);
            if (voBase != null) struct.name = voBase.name;
            return struct;
        }
    }
}
