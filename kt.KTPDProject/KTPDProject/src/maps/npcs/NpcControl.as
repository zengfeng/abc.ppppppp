package maps.npcs
{
	import game.core.avatar.AvatarNpc;

	import maps.MapUtil;
	import maps.elements.avatars.AvatarFactory;
	import maps.elements.core.NpcElement;
	import maps.elements.core.pools.NpcElementPool;
	import maps.elements.structs.NpcStruct;

	import flash.utils.Dictionary;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
     */
    public class NpcControl
    {
        /** 单例对像 */
        private static var _instance : NpcControl;

        /** 获取单例对像 */
        static public function get instance() : NpcControl
        {
            if (_instance == null)
            {
                _instance = new NpcControl(new Singleton());
            }
            return _instance;
        }

        function NpcControl(singleton : Singleton) : void
        {
            singleton;
            dic = new Dictionary();
            mapNpcs = MapNpcs.instance;
            avatarFactory = AvatarFactory.instance;
            npcElementPool = NpcElementPool.instance;
            NpcSignals.START_INSTALL.add(startInstall);
            NpcSignals.STOP_INSTALL.add(stopInstall);
            NpcSignals.REMOVE.add(remove);
            NpcSignals.REMOVE_ALL.add(removeAll);
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        private var dic : Dictionary;
        private var mapNpcs : MapNpcs;
        private var avatarFactory : AvatarFactory;
        private var npcElementPool : NpcElementPool;

        public function add(npcId : int) : void
        {
            var struct : NpcStruct = MapUtil.getNpcStruct(npcId);
            if (struct == null)
            {
                return;
            }
            var avatar : AvatarNpc = AvatarFactory.instance.createAvatar(struct) as AvatarNpc;
            if (avatar == null)
            {
                return;
            }
            var npcElement : NpcElement = npcElementPool.getObject(struct, avatar);
            dic[npcId] = npcElement;
            NpcSignals.INSTALLED.dispatch(npcId);
        }

        public function remove(npcId : int) : void
        {
            var npcElement : NpcElement = dic[npcId];
            npcElement.destory();
            dic[npcId] = null;
            delete  dic[npcId];
        }

        private var keyArr : Array = [];

        public function removeAll() : void
        {
            var key : String;
            for (key  in  dic)
            {
                keyArr.push(key);
            }
            var npcElement : NpcElement ;
            while (keyArr.length > 0)
            {
                key = keyArr.pop();
                npcElement = dic[key];
                npcElement.destory();
                dic[key] = null;
                delete  dic[key];
            }
        }

        public function startInstall() : void
        {
            NpcSignals.ADD.add(add);
            var list : Vector.<uint> = mapNpcs.waitInstallList;
            for (var i : int = 0; i < list.length; i++)
            {
                add(list[i]);
            }
        }

        public function stopInstall() : void
        {
            NpcSignals.ADD.remove(add);
        }
    }
}
class Singleton
{
}