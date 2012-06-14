package game.core.avatar {
	import bd.BDData;
	import bd.BDUnit;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.utils.Dictionary;
	import framerate.SecondsTimer;
	import game.config.StaticConfig;
	import game.module.quest.animation.FollowAvatar;
	import gameui.controls.BDPlayer;
	import gameui.core.GComponentData;
	import log4a.Logger;
	import net.AssetData;
	import net.LibData;
	import net.RESManager;
	import net.SWFLoader;
	import utils.ObjectPool;








	/**
	 * @author yangyiqiang
	 */
	public class AvatarManager
	{
		private static var _instance : AvatarManager;

//		private static var _checkMemory : uint = 507200000;

		private static var _checkMemory : uint = 300000;
		/** 战斗站立 */
		public static const BT_STAND : int = 1;

		/** 被攻击*/
		public static const HURT : int = 2;

		/** 物理攻击 */
		public static const ATTACK : int = 3;

		/** 魔法攻击 */
		public static const MAGIC_ATTACK : int = 4;

		/** 死亡 */
		public static const DIE : int = 5;

		/** 打坐 */
		public static const PRACTICE : int = 20;

		/** avatar的存储源 */
		private var _avatarBDDic : Dictionary = new Dictionary(true);

		private static var _shodow : BitmapData;

		private static var _shodow1 : BitmapData;

		public static var hitTest : BitmapData = new BitmapData(5, 5, false);

		private static var _die : BDData;

		public function AvatarManager()
		{
			if (_instance)
			{
				throw Error("---AvatarManager--is--a--single--model---");
			}
			SecondsTimer.addFunction(gcAvatar);
		}

		public static function get instance() : AvatarManager
		{
			if (_instance == null)
			{
				_instance = new AvatarManager();
			}
			return _instance;
		}

		public function initPlayerAvatar() : void
		{
		}

		public function getShodow(type : int = 0) : BitmapData
		{
			if (type == 0)
			{
				if (!_shodow)
				{
					if (!RESManager.getLoader("shadowPng" + type)) return null;
					_shodow = (RESManager.getLoader("shadowPng" + type).getContent() as Bitmap).bitmapData;
				}
			}
			else
			{
				if (!_shodow1)
				{
					if (!RESManager.getLoader("shadowPng" + type)) return null;
					_shodow1 = (RESManager.getLoader("shadowPng" + type).getContent() as Bitmap).bitmapData;
				}
				return _shodow1;
			}
			return _shodow;
		}

		private static var _commonAvatar : BitmapData;

		/** 没加载前通用avatar */
		public function getCommonAvatar() : BitmapData
		{
			if (!_commonAvatar)
				_commonAvatar = RESManager.getBitmapData(new AssetData("player", "quest"));
			return _commonAvatar;
		}

		public function getDie() : BDData
		{
			if (!_die)
			{
				initDieFrame();
			}
			return _die;
		}

		/** 获取avatar实例 */
		public  function getAvatar(id : int, type : uint, cloth : uint = 0) : AvatarThumb
		{
			var _avatar : AvatarThumb;
			switch(type)
			{
				case AvatarType.PLAYER_RUN:
				case AvatarType.CHANGE_AVATAR:
					type=AvatarType.PLAYER_RUN;
					_avatar = ObjectPool.getObject(AvatarPlayer);
					break;
				case AvatarType.FLLOW_TYPE:
					type=cloth==0?AvatarType.NPC_TYPE:AvatarType.PLAYER_RUN;
					_avatar = ObjectPool.getObject(FollowAvatar);
					break;
				case AvatarType.NPC_TYPE:
					_avatar = ObjectPool.getObject(AvatarNpc);
					(_avatar as AvatarNpc).setId(id);
					_avatar.setAction(1);
					return _avatar;
				case AvatarType.PERFORMER_TYPE:
					_avatar = new PerformerAvatar();
					(_avatar as PerformerAvatar).setId(id);
					return _avatar;
				case AvatarType.MONSTER_TYPE:
//					_avatar = ObjectPool.getObject(AvatarMonster);
                    _avatar =new AvatarMonster();
				case AvatarType.TURTLE_AVATAR:
					type=AvatarType.MONSTER_TYPE;
                    _avatar = ObjectPool.getObject(AvatarTurtle);
				case AvatarType.PET_TYPE:
					_avatar = ObjectPool.getObject(AvatarMonster);
					break;
				case AvatarType.COUPLE_TYPE:
					_avatar = ObjectPool.getObject(AvatarCouple);
					break ;
				case AvatarType.SEAT_TYPE:
					_avatar = ObjectPool.getObject(AvatarSeat);
					break;
				case AvatarType.MY_AVATAR:
					type=AvatarType.PLAYER_RUN;
					_avatar = ObjectPool.getObject(AvatarMySelf);
					break;
				case AvatarType.DRAY_AVATER:
					type=AvatarType.NPC_TYPE;
					_avatar = ObjectPool.getObject(AvatarDray); 
				default :
					_avatar = ObjectPool.getObject(AvatarPlayer);
					break;
			}
			_avatar.initAvatar(id,type,cloth);
			_avatar.setAction(1);
			return _avatar;
		}
		
		public function getMyAvatar(type:int=0):void
		{
			
		}

		public function getUUId(id : int, type : uint, cloth : uint = 0) : uint
		{
			return (type << 24) + (cloth << 20) + id;
		}
		
		/**  移除avatar实例 */
		public function removeAvatar(avatar : AbstractAvatar) : void
		{
			if (!avatar) return;
			avatar.callback();
			Logger.info("removeAvatar===>"+avatar.uuid);
		}

		/**获得avatar的bitMapData源  */
		public function getAvatarBD(id : int) : AvatarBD
		{
			if (!_avatarBDDic[id])
			{
				_avatarBDDic[id] = new AvatarBD(id, new BDData(new Vector.<BDUnit>()));
			}
			return _avatarBDDic[id];
		}

		/**获得avatar的 某一动作的帧系列  */
		public function getAvatarFrame(id : int, type : int) : AvatarUnit
		{
			if (!_avatarBDDic[id])
			{
				_avatarBDDic[id] = new AvatarBD(id, new BDData(new Vector.<BDUnit>()));
			}
			return (_avatarBDDic[id] as AvatarBD).getAvatarFrame(type);
		}

		public function hasDie(id : int) : Boolean
		{
			if (!_avatarBDDic[id]) return false;
			return (_avatarBDDic[id] as AvatarBD).hasDieFrame();
		}

		/** avatar 出现动画 */
		private var _showAction : BDPlayer;

		public function getShowAction() : BDPlayer
		{
			if (!_showAction)
			{
				_showAction = new BDPlayer(new GComponentData());
				_avatarBDDic[AvatarType.AVATAR_SHOW] = new AvatarBD(AvatarType.AVATAR_SHOW, new BDData(new Vector.<BDUnit>()));
				(_avatarBDDic[AvatarType.AVATAR_SHOW] as AvatarBD).getAvatarFrame(1);
				_showAction.setBDData((_avatarBDDic[AvatarType.AVATAR_SHOW] as AvatarBD).bds);
			}
			return _showAction;
		}

		public function initDieFrame() : void
		{
			var loader : SWFLoader = RESManager.getLoader("diessss");
			if (!loader)
			{
				RESManager.instance.load(new LibData(StaticConfig.cdnRoot + "assets/avatar/battle/die.swf", "diessss"), initDieFrame);
				return;
			}
			var _source : BitmapData = new (loader.getClass("Source")) as BitmapData;
			if (!_source) return;
			var text : String = loader.getContent()["text"]["text"];
			var _xml : XML = new XML(text);
			var _bottomX : int = Number(_xml.attribute("bottomX"));
			var _bottomY : int = Number(_xml.attribute("bottomY"));
			for each (var xml:XML in _xml["frame"])
			{
				var frames : Vector.<BDUnit > = new Vector.<BDUnit >;
				for each (var frame:XML in xml["item"])
				{
					var unit : BDUnit = new BDUnit();
					var rect : Rectangle = new Rectangle(frame. @ x, frame. @ y, frame. @ w, frame. @ h);
					var bds : BitmapData = new BitmapData(rect.width, rect.height, true, 0);
					bds.copyPixels(_source, rect, new Point());
					unit.offset = new Point(int(frame.@offsetX) + _bottomX, int(frame.@offsetY) + _bottomY);
					unit.bds = bds;
					frames.push(unit);
				}
			}
			_die = new BDData(frames);
		}

		private function gcAvatar() : void
		{
			if (System.totalMemoryNumber < _checkMemory) return;
			SecondsTimer.removeFunction(gcAvatar);
		/*	for each (var avatarBD:AvatarBD in _avatarBDDic)
			{
				if (avatarBD.userNum <=0 && (getTimer() - avatarBD.userTime) > 10000)
				{
					Logger.info("gcAvatar  avatarBD.id====>"+avatarBD.key);
					//avatarBD.cleanUp();
					//delete _avatarBDDic[avatarBD.id];
				}
			}*/
			ObjectPool.clear();
			SecondsTimer.addFunction(gcAvatar);
		}
	}
}
