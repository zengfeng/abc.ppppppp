package game.module.mapWorld
{
	import game.core.avatar.AvatarManager;
	import game.core.avatar.AvatarMySelf;
	import game.core.avatar.AvatarType;
	import game.module.map.animalstruct.SelfPlayerStruct;
	import game.module.map.utils.MapUtil;

	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;

	import flash.display.Sprite;



    /**
     * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012 2012-3-26 ����5:11:14
     */
    public class WorldMapPlayer extends Sprite
    {
        public function WorldMapPlayer(singleton : Singleton)
        {
            singleton;
            init();
        }

        /** 单例对像 */
        private static var _instance : WorldMapPlayer;

        /** 获取单例对像 */
        static public function get instance() : WorldMapPlayer
        {
            if (_instance == null)
            {
                _instance = new WorldMapPlayer(new Singleton());
            }
            return _instance;
        }

        // ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
        public function get playerStruct() : SelfPlayerStruct
        {
            return MapUtil.selfPlayerStruct;
        }

        public var avatar : AvatarMySelf;

        private function init() : void
        {
            avatar = AvatarManager.instance.getAvatar(playerStruct.heroId, AvatarType.MY_AVATAR, playerStruct.cloth) as AvatarMySelf;
            addChild(avatar);
            scaleX = scaleY = 0.7;
			mouseEnabled = false;
			mouseChildren = false;
        }

        public function updateAvatar() : void
        {
//             avatar.setName(playerStruct.name, playerStruct.colorStr);
			 avatar.changeCloth(playerStruct.cloth, playerStruct.heroId);
        }
		
		public function close():void
		{
			if(tweenLite) tweenLite.kill();
			avatar.stand();
		}

        private var tweenLite : TweenLite;
        private var tweenLiteVars : Object;

        public function moveTo(toX : int, toY : int) : void
        {
            var dx : int = toX - x;
            var dy : int = toY - y;
            var d : int = Math.sqrt(dx * dx + dy * dy);
            var time : Number = d / 100;
            //trace(time);
            avatar.run(toX, toY, x, y);
            if (tweenLite == null)
            {
                tweenLiteVars = {x:toX, y:toY, onComplete:moveComplete, ease:Linear.easeNone};
            }
            else
            {
                tweenLiteVars["x"] = toX;
                tweenLiteVars["y"] = toY;
            }
            tweenLite = TweenLite.to(this, time, tweenLiteVars);
        }

        private function moveComplete() : void
        {
//            avatar.stand();
			avatar.setAction(1);
//            Alert.show("到达");
			WorldMapController.instance.playerMoveComplete();
        }
    }
}
class Singleton
{
}