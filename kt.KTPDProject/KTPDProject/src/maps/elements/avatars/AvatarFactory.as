package maps.elements.avatars
{
	import game.core.avatar.AvatarManager;
	import game.core.avatar.AvatarMonster;
	import game.core.avatar.AvatarNpc;
	import game.core.avatar.AvatarPlayer;
	import game.core.avatar.AvatarThumb;
	import game.core.avatar.AvatarType;

	import maps.elements.structs.BaseStruct;
	import maps.elements.structs.DuplMonsterStruct;
	import maps.elements.structs.NpcStruct;
	import maps.elements.structs.PlayerStruct;

    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-5-24
     */
    public class AvatarFactory
    {
        /** 单例对像 */
        private static var _instance : AvatarFactory;

        /** 获取单例对像 */
        public static  function get instance() : AvatarFactory
        {
            if (_instance == null)
            {
                _instance = new AvatarFactory(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        private var avatarManager : AvatarManager;

        function AvatarFactory(singleton : Singleton) : void
        {
            singleton;
            avatarManager = AvatarManager.instance;
        }

        public function destoryAvatar(avatar : AvatarThumb) : void
        {
            avatarManager.removeAvatar(avatar);
        }

        public function createAvatar(struct : BaseStruct) : AvatarThumb
        {
            var avatar : AvatarThumb;
            if (struct is PlayerStruct)
            {
                avatar = createPlayer(struct as PlayerStruct);
            }
            else if (struct is NpcStruct)
            {
                avatar = createNpc(struct as NpcStruct);
            }
            else if (struct is DuplMonsterStruct)
            {
                avatar = createDuplMonsterStruct(struct as DuplMonsterStruct);
            }
            return avatar;
        }

        private function createPlayer(struct : PlayerStruct) : AvatarPlayer
        {
            var avatar : AvatarPlayer;
            avatar = avatarManager.getAvatar(struct.heroId, AvatarType.MY_AVATAR, struct.clothId) as AvatarPlayer;
            avatar.setName(struct.name, struct.colorStr);
            return avatar;
        }

        private function createNpc(struct : NpcStruct) : AvatarNpc
        {
            return avatarManager.getAvatar(struct.id, AvatarType.NPC_TYPE, 0) as  AvatarNpc;
        }

        private function createDuplMonsterStruct(struct : DuplMonsterStruct) : AvatarMonster
        {
            var avatar : AvatarMonster;
            avatar = avatarManager.getAvatar(struct.avatarId, AvatarType.MONSTER_TYPE, 0) as AvatarMonster;
            avatar.setName(struct.name);
            return avatar;
        }

        public static function destoryAvatar(avatar : AvatarThumb) : void
        {
            instance.destoryAvatar(avatar);
        }
    }
}
class Singleton
{
}