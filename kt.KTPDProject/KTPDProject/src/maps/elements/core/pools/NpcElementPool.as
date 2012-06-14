package maps.elements.core.pools
{
	import game.core.avatar.AvatarNpc;

	import maps.elements.core.NpcElement;
	import maps.elements.structs.NpcStruct;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
     */
    public class NpcElementPool
    {
        /** 单例对像 */
        private static var _instance : NpcElementPool;

        /** 获取单例对像 */
        static public function get instance() : NpcElementPool
        {
            if (_instance == null)
            {
                _instance = new NpcElementPool(new Singleton());
            }
            return _instance;
        }

        private const MAX_COUNT : int = 50;
        public var list : Vector.<NpcElement> = new Vector.<NpcElement>();

        function NpcElementPool(singleton : Singleton)
        {
        }

        public function getObject(npcStruct : NpcStruct, avatar : AvatarNpc) : NpcElement
        {
            if (list.length > 0)
            {
                var npcElement : NpcElement = list.pop();
                npcElement.reset(npcStruct, avatar);
                return npcElement;
            }
            return new NpcElement(npcStruct, avatar);
        }

        public function destoryObject(npcElement : NpcElement, destoryed : Boolean = false) : void
        {
            if (npcElement == null) return;
            if (list.indexOf(npcElement) != -1) return;
            if (!destoryed) npcElement.destory();
            if (list.length < MAX_COUNT) list.push(npcElement);
        }
    }
}
class Singleton
{
}