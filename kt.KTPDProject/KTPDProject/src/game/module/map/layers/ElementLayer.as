package game.module.map.layers
{
	import game.module.quest.VoNpc;
	import game.core.avatar.AvatarManager;
	import game.core.avatar.AvatarMonster;
	import game.core.avatar.AvatarNpc;
	import game.core.avatar.AvatarPet;
	import game.core.avatar.AvatarPlayer;
	import game.core.avatar.AvatarThumb;
	import game.core.avatar.AvatarType;
	import game.manager.RSSManager;
	import game.module.map.MapController;
	import game.module.map.MapSystem;
	import game.module.map.animal.AnimalType;
	import game.module.map.animalstruct.AbstractStruct;
	import game.module.map.animalstruct.DrayStruct;
	import game.module.map.animalstruct.EscortStruct;
	import game.module.map.animalstruct.MonsterStruct;
	import game.module.map.animalstruct.PlayerStruct;
	import game.module.map.animalstruct.RobberStruct;
	import game.module.map.animalstruct.SelfStoryStruct;
	import game.module.map.struct.GateStruct;
	import game.module.map.struct.MapStruct;
	import game.module.map.utils.MapUtil;
	import game.module.mapFeast.element.CoupleStruct;
	import game.module.quest.QuestUtil;
	import game.module.quest.VoBase;

	import maps.layers.lands.LandLayer;

	import com.utils.CallFunStruct;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;

	/**
	 * @author ZengFeng (Eamil:zengfeng75[AT])163.com 2011 2011-12-26 ����3:27:44
	 * 地图元素层
	 */
	public class ElementLayer extends Sprite
	{
		/** 地面 */
		private var _land : Sprite;
		/** 地面Bitmap */
		private var _landBitmap : Bitmap;
		/** 缩略图 */
		private var _thumbnail : BitmapData;
		/** 遮罩列表 */
		private var _maskList : Vector.<DisplayObject> = new Vector.<DisplayObject>();
		/** 背景特效列表 */
		private var _backgroundEffectList : Vector.<DisplayObject> = new Vector.<DisplayObject>();
		/** 前景特效列表 */
		private var _foregroundEffectList : Vector.<DisplayObject> = new Vector.<DisplayObject>();
		/** 八卦阵(出入口)列表,存入DisplayObject,以GateStruct.toMapId为键值 */
		public var gateDic : Dictionary = new Dictionary();
		/** 八卦阵(出入口)列表,存入DisplayObject,以gateId为键值 */
		public var gateByIdDic : Dictionary = new Dictionary();
		/** Avatar元素字典 */
		private var avatarDictionary : ElementAvatarDictionary = ElementAvatarDictionary.instance;
		/** 自己玩家 */
		private var _selfPlayer : AvatarPlayer;
		/** 自己宠物 */
		private var _selfPet : AvatarThumb;
		/** 自己剧情 */
		private var _selfStory : AvatarThumb;
		/** 玩家字典列表,AvatarPlayer,以playerId为键值 */
		public var playerDic : Dictionary = new Dictionary();
		/** 宠物字典列表,AvatarPet,以playerId为键值 */
		private var petDic : Dictionary = new Dictionary();
		/** NPC字典列表, 存入AvatarNpc,以npcId为键值 */
		public var npcDic : Dictionary = new Dictionary();
		/** 怪物字典列表, AvatarMonster,以wave为键值 */
		private var monsterDic : Dictionary = new Dictionary();
		/** 护送者字典列表, FollowAvatar,以id为键值 */
		private var escortDic : Dictionary = new Dictionary();
		/** 剧情字典 */
		private var storyDic : Dictionary = new Dictionary();
		/** avatar总数 */
		public var avatarNum : int = 0;
		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** Avatar管理器 */
		private var avatarManager : AvatarManager = AvatarManager.instance;

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		public function ElementLayer()
		{
			this.name = "ElementLayer";
			init();
		}

		/** 初始化 */
		public function init() : void
		{
			addChild(LandLayer.instance);
			// _land.mouseChildren = false;
			// _land.mouseEnabled = false;
			// _landBitmap = new Bitmap(new BitmapData(2048,2048,  false), PixelSnapping.NEVER);
			// //  地面
			// addChild(land);
			// land.addChild(_landBitmap);
		}

		/** 安装地图 */
		public function setupMap() : void
		{
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 移动到 */
		public function moveTo(x : int, y : int) : void
		{
			if (this.x == x && this.y == y) return;
			super.x = x;
			super.y = y;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 获取 地面 索引位置 */
		public function getIndexLand() : int
		{
			return  0;
		}

		/** 获取 背景特效 最小索引位置 */
		public function getMinIndexBE() : int
		{
			if (backgroundEffectList.length == 0) return getIndexLand();
			return this.getChildIndex(backgroundEffectList[0]);
		}

		/** 获取 背景特效 最大索引位置 */
		public function getMaxIndexBE() : int
		{
			if (backgroundEffectList.length == 0) return getIndexLand();
			return this.getChildIndex(backgroundEffectList[backgroundEffectList.length - 1]);
		}

		/** 获取 八卦阵(出入口) 最小索引位置 */
		public function getMinIndexGate() : int
		{
			var gateList : Vector.<DisplayObject> = this.gateList;
			if (gateList.length == 0 || gateList[0].parent == null) return getMaxIndexBE();
			return this.getChildIndex(gateList[0]);
		}

		/** 获取 八卦阵(出入口) 最大索引位置 */
		public function getMaxIndexGate() : int
		{
			var gateList : Vector.<DisplayObject> = this.gateList;
			if (gateList.length == 0 || gateList[0].parent == null) return getMaxIndexBE();
			return this.getChildIndex(gateList[gateList.length - 1]);
		}

		/** 获取 遮罩 最小索引位置 */
		public function getMinIndexMask() : int
		{
			if (maskList.length == 0) return getMaxIndexGate() + avatarNum;
			return this.getChildIndex(maskList[0]);
		}

		/** 获取 遮罩 最大索引位置 */
		public function getMaxIndexMask() : int
		{
			if (maskList.length == 0) return getMinIndexMask();
			return this.getChildIndex(maskList[maskList.length - 1]);
		}

		/** 获取 前景特效 最小索引位置 */
		public function getMinIndexFE() : int
		{
			if (foregroundEffectList.length == 0) return getMinIndexMask();
			return this.getChildIndex(foregroundEffectList[0]);
		}

		/** 获取 前景特效 最大索引位置 */
		public function getMaxIndexFE() : int
		{
			if (foregroundEffectList.length == 0) return getMinIndexMask();
			return this.getChildIndex(foregroundEffectList[foregroundEffectList.length - 1]);
		}

		/** 获取 活动的 索引位置 */
		public function getIndexMovable() : int
		{
			return this.getChildIndex(selfPlayer);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 地面 */
		public function get land() : Sprite
		{
			return _land;
		}

		/** 地面Bitmap */
		public function get landBitmap() : Bitmap
		{
			return _landBitmap;
		}

		/** 缩略图备份 */
		public var thumbnailBak : BitmapData;

		/** 缩略图 */
		public function get thumbnail() : BitmapData
		{
			return _thumbnail;
		}

		/** 设置缩略图 */
		public function set thumbnail(bitmapData : BitmapData) : void
		{
			if (bitmapData == null) return;
			var mapStruct : MapStruct = MapUtil.getMapStruct();

			if (_thumbnail)
			{
				_thumbnail.dispose();
				// thumbnailBak.dispose();
			}
			_thumbnail = bitmapData;
			// thumbnailBak = bitmapData.clone();

			// _thumbnail = new BitmapData(bitmapData.width, bitmapData.height);
			// var pt : Point = new Point(0, 0);
			// var rect : Rectangle = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
			// var threshold : uint = 0xcc000000;
			// var color : uint = 0x00FF0000;
			// var maskColor : uint = 0xFF000000;
			//
			// _thumbnail.threshold(bitmapData, rect, pt, "<", threshold, color, maskColor, true);

			var matrix : Matrix = new Matrix();
			matrix.a = mapStruct.mapWH.x / bitmapData.width;
			matrix.d = mapStruct.mapWH.y / bitmapData.height;
			var g : Graphics = land.graphics;
			g.clear();
			g.beginBitmapFill(_thumbnail, matrix, false);
			g.drawRect(0, 0, mapStruct.mapWH.x, mapStruct.mapWH.y);
			g.endFill();
		}

		/** 遮罩列表 */
		public function get maskList() : Vector.<DisplayObject>
		{
			return _maskList;
		}

		/** 前景特效列表 */
		public function get foregroundEffectList() : Vector.<DisplayObject>
		{
			return _foregroundEffectList;
		}

		/** 背景特效列表 */
		public function get backgroundEffectList() : Vector.<DisplayObject>
		{
			return _backgroundEffectList;
		}

		/** 八卦阵(出入口)列表 */
		public function get gateList() : Vector.<DisplayObject>
		{
			var list : Vector.<DisplayObject> = new Vector.<DisplayObject>();
			for each (var displayObject:DisplayObject in gateDic)
			{
				list.push(displayObject);
			}
			return list;
		}

		/** 获取某个八卦阵(出入口) */
		public function getGate(toMapId : uint) : DisplayObject
		{
			return gateDic[toMapId] as DisplayObject;
		}

		public function getGateById(gateId : int) : DisplayObject
		{
			return gateByIdDic[gateId];
		}

		/** 自己玩家 */
		public function get selfPlayer() : AvatarPlayer
		{
			return _selfPlayer;
		}

		/** 自己宠物 */
		public function get selfPet() : AvatarThumb
		{
			return _selfPet;
		}

		/** 玩家列表 */
		public function get playerList() : Vector.<AvatarPlayer>
		{
			return  avatarDictionary.playerList;
		}

		/** 获取玩家 */
		public function getPlayer(playerId : uint) : AvatarPlayer
		{
			return avatarDictionary.getPlayer(playerId);
		}

		/** 怪物列表 */
		public function get petList() : Vector.<AvatarPet>
		{
			return avatarDictionary.petList;
		}

		/** NPC列表 */
		public function get npcList() : Vector.<AvatarNpc>
		{
			return avatarDictionary.npcList;
		}

		/** 获取NPC */
		public function getNpc(npcId : uint) : AvatarNpc
		{
			return avatarDictionary.getNpc(npcId);
		}

		/** 怪物列表 */
		public function get monsterList() : Vector.<AvatarMonster>
		{
			return avatarDictionary.monsterList;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 添加前景 */
		public function addForegroundEffect(displayObject : DisplayObject) : void
		{
			var index : int = getMaxIndexFE();
			addChildAt(displayObject, index);
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 加入八卦阵(出入口) */
		public function addGate(struct : GateStruct) : DisplayObject
		{
			if (struct == null) return null;
			var index : int = getMaxIndexBE();
			index += 1;
			var elementName : String = ElementName.gate(struct.toMapId, struct.id);
			var element : MovieClip = getChildByName(elementName) as MovieClip;
			if (element)
			{
				element.x = struct.position.x;
				element.y = struct.position.y;
			}
			else
			{
				element = GatePool.instance.getObject();
				element.name = elementName;
				element.x = struct.position.x;
				element.y = struct.position.y;
				element.mouseChildren = false;
				element.mouseEnabled = true;
				element.addEventListener(MouseEvent.CLICK, gateOnclick);
				addChildAt(element, index);
			}
			element.visible = true;
			element.gotoAndPlay(1);
			element.alpha = 1;
			gateDic[struct.toMapId] = element;
			gateByIdDic [struct.id] = element;
			return element;
		}

		/**  八卦阵(出入口) 点击事件 */
		private function gateOnclick(event : MouseEvent) : void
		{
			var gate : MovieClip = event.target as 	MovieClip;
			var str : String = gate.name.replace(ElementName.GATE_PREFIX, "");
			var arr : Array = str.split("_");
			var toMapId : int = parseInt(arr[0]);
			var gateId : int = parseInt(arr[1]);
			MapSystem.mapTo.toGate(toMapId, 0, false, false, MapController.instance.arriveGate, [toMapId, 0, gateId]);
			event.stopPropagation();
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 加入动物 */
		public function addAnimal(struct : AbstractStruct) : AvatarThumb
		{
			if (struct == null) return null;
			var elementName : String = ElementName.animal(struct.id, struct.animalType);
			var element : AvatarThumb = getChildByName(elementName) as AvatarThumb;

			if (element && struct.animalType == AnimalType.MONSTER)
			{
				removeAnimal(struct.id, struct.animalType);
			}

			if (element && struct.animalType != AnimalType.MONSTER)
			{
				element.x = struct.x;
				element.y = struct.y;
			}
			else
			{
				var playerStruct : PlayerStruct;
				var monsterStruct : MonsterStruct;
				var callFunStruct : CallFunStruct;
				var voBase : VoBase;
				var voNpc : VoNpc;
				var heroId : int = 0;
				switch(struct.animalType)
				{
					case AnimalType.SELF_PLAYER:
						playerStruct = struct as PlayerStruct;
						heroId = playerStruct.avatarVer == -1 ? -1 : playerStruct.heroId;
						element = avatarManager.getAvatar(heroId, AvatarType.MY_AVATAR, playerStruct.cloth) as AvatarPlayer;
						if (struct.animalType == AnimalType.SELF_PLAYER)
						{
							_selfPlayer = element as AvatarPlayer;
						}
						element.setName(struct.name, struct.colorStr);
						break;
					case AnimalType.PLAYER:
						playerStruct = struct as PlayerStruct;
						heroId = playerStruct.avatarVer == -1 ? -1 : playerStruct.heroId;
						element = avatarManager.getAvatar(heroId, AvatarType.PLAYER_RUN, playerStruct.cloth) as AvatarPlayer;
						if (struct.animalType == AnimalType.SELF_PLAYER)
						{
							_selfPlayer = element as AvatarPlayer;
						}
						element.setName(struct.name, struct.colorStr);
						break;
					case AnimalType.NPC:
						voNpc = RSSManager.getInstance().getNpcById(struct.id);
						if (voNpc.isHit == false)
						{
							element = avatarManager.getAvatar(struct.id, AvatarType.NPC_TYPE, 0);
							callFunStruct = new CallFunStruct(MapSystem.mapTo.toNpc, [struct.id, 0, false, QuestUtil.npcClick, [struct.id, 0]]);
							element.addClickCall(callFunStruct);
						}
						else
						{
							element = avatarManager.getAvatar(voNpc.avatarId, AvatarType.MONSTER_TYPE, 0);
							element.setName(voNpc.name);
						}
//						callFunStruct = new CallFunStruct(MapSystem.mapTo.toNpc, [struct.id, 0, false, QuestUtil.npcClick, [struct.id, 0]]);
//						element.addClickCall(callFunStruct);
						// element.setName(voBase.name);
						break;
					case AnimalType.MONSTER:
						monsterStruct = struct as MonsterStruct;
						voBase = RSSManager.getInstance().getNpcById(monsterStruct.monsterId);
						element = avatarManager.getAvatar(voBase.avatarId, AvatarType.MONSTER_TYPE, 0);
						element.setName(voBase.name);
						break;
					case AnimalType.PET:
						break;
					case AnimalType.ESCORT:
						var dscortStruct : EscortStruct = struct as EscortStruct;
						element = avatarManager.getAvatar(dscortStruct.id, AvatarType.FLLOW_TYPE, 0);
						break;
					case AnimalType.SELF_STORY:
						var selfStoryStruct : SelfStoryStruct = struct as SelfStoryStruct;
						element = avatarManager.getAvatar(selfStoryStruct.heroId, AvatarType.PLAYER_RUN, selfStoryStruct.cloth);
						element.setName(struct.name);
						_selfStory = element;
						break;
					case AnimalType.STORY:
						element = avatarManager.getAvatar(struct.id, AvatarType.PERFORMER_TYPE, 0);
						break;
					case AnimalType.DRAY:
						var drayStruct : DrayStruct = struct as DrayStruct;
						element = avatarManager.getAvatar(drayStruct.avatarId, AvatarType.MONSTER_TYPE, 0);
						element.setName(struct.name);
						break;
					case AnimalType.ROBBER:
						var robberStruct : RobberStruct = struct as RobberStruct;
						element = avatarManager.getAvatar(robberStruct.avatarId, AvatarType.MONSTER_TYPE, 0);
						element.setName(struct.name);
						break;
					case AnimalType.COUPLE :
						var coupleStruct : CoupleStruct = struct as CoupleStruct ;
						element = avatarManager.getAvatar(coupleStruct.coupleId, AvatarType.COUPLE_TYPE, 0);
						break;
					case AnimalType.FOLLOWER:
						element = avatarManager.getAvatar(struct.avatarId, AvatarType.TURTLE_AVATAR, 0);
						element.setName(struct.name);
						break;
				}
				if (element == null) return null;
				avatarDictionary.add(element, struct.id, struct.animalType);
				avatarNum++;
				var index : int = getMinIndexGate();
				index += 1;
				element.name = elementName;
				element.x = struct.x;
				element.y = struct.y;
				// addChildAt(element, index);
			}
			return element;
		}

		/** 移除动物 */
		public function removeAnimal(id : uint, animalType : String) : AvatarThumb
		{
			var elementName : String = ElementName.animal(id, animalType);
			if (!elementName) return null;

			var element : AvatarThumb = getChildByName(elementName) as AvatarThumb;
			if (element)
			{
				element.clearClickCallList();
				element.hide();
				if (element.parent) element.parent.removeChild(element);
				avatarManager.removeAvatar(element);
				avatarNum--;
			}
			avatarDictionary.remove(id, animalType);
			switch(animalType)
			{
				case AnimalType.SELF_PLAYER:
					_selfPlayer = null;
					break;
				case AnimalType.SELF_STORY:
					_selfStory = null;
			}
			return element;
		}

		public var mapWidth : int;
		public var mapHeight : int;
		public var piecelCountX : int = 0;
		public var piecelCountY : int = 0;
		public var bitmapPool : BitmapPool = BitmapPool.instance;
		public var bitmapDataPool : BitmapDataPool = BitmapDataPool.instance;
		public var piecelDic : Dictionary = new Dictionary();

		public function resize(mapWidth : int, mapHeight : int) : void
		{
			var countX : int = mapWidth / 256;
			var countY : int = mapHeight / 256;
			var x : int;
			var y : int;
			var bitmap : Bitmap;
			var key : String;
			if (piecelCountX == 0 && piecelCountY == 0)
			{
				for (y = 0; y < countY; y++)
				{
					for (x = 0; x < countX; x++)
					{
						bitmap = bitmapPool.getObject();
						bitmap.x = x * 256;
						bitmap.y = y * 256;
						key = y + "_" + x;
						piecelDic[key] = bitmap;
						_land.addChild(bitmap);
					}
				}
				piecelCountX = countX ;
				piecelCountY = countY;
			}
			else if (countX > piecelCountX && countY > piecelCountY)
			{
				for (y = piecelCountY; y < countY; y++)
				{
					for (x = piecelCountX; x < countX; x++)
					{
						bitmap = bitmapPool.getObject();
						bitmap.x = x * 256;
						bitmap.y = y * 256;
						key = y + "_" + x;
						piecelDic[key] = bitmap;
						_land.addChild(bitmap);
					}
				}
				piecelCountX = countX ;
				piecelCountY = countY;
			}
			else if (countX < piecelCountX && countY < piecelCountY)
			{
				for (y = countY; y < piecelCountY; y++)
				{
					for (x = countX; x < piecelCountX; x++)
					{
						key = y + "_" + x;
						bitmap = piecelDic[key] ;
						_land.removeChild(bitmap);
						bitmapPool.destoryObject(bitmap);
					}
				}
				piecelCountX = countX ;
				piecelCountY = countY;
			}
			else if (countX > piecelCountX && countY < piecelCountY)
			{
				for (y = countY; y < piecelCountY; y++)
				{
					for (x = 0; x < piecelCountX; x++)
					{
						key = y + "_" + x;
						bitmap = piecelDic[key] ;
						_land.removeChild(bitmap);
						bitmapPool.destoryObject(bitmap);
					}
				}

				for (y = 0; y < countY; y++)
				{
					for (x = piecelCountX; x < countX; x++)
					{
						bitmap = bitmapPool.getObject();
						bitmap.x = x * 256;
						bitmap.y = y * 256;
						key = y + "_" + x;
						piecelDic[key] = bitmap;
						_land.addChild(bitmap);
					}
				}
				piecelCountX = countX ;
				piecelCountY = countY;
			}
			else if (countX < piecelCountX && countY > piecelCountY)
			{
				for (y = 0; y < piecelCountY; y++)
				{
					for (x = countX; x < piecelCountX; x++)
					{
						key = y + "_" + x;
						bitmap = piecelDic[key] ;
						_land.removeChild(bitmap);
						bitmapPool.destoryObject(bitmap);
					}
				}

				for (y = piecelCountY; y < countY; y++)
				{
					for (x = 0; x < countY; x++)
					{
						bitmap = bitmapPool.getObject();
						bitmap.x = x * 256;
						bitmap.y = y * 256;
						key = y + "_" + x;
						piecelDic[key] = bitmap;
						_land.addChild(bitmap);
					}
				}
				piecelCountX = countX ;
				piecelCountY = countY;
			}
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		/** 清理 */
		public function clear() : void
		{
			avatarNum = 0;
			var displayObject : DisplayObject;
			var avatarThumb : AvatarThumb;
			var key : String;
			// 地面
			if (land)
			{
				land.graphics.clear();
				while (land.numChildren > 0)
				{
					displayObject = land.removeChildAt(0);
					if (displayObject is Bitmap) (displayObject as Bitmap).bitmapData.dispose();
				}
			}

			// 缩略图
			if (_thumbnail)
			{
				_thumbnail.dispose();
				_thumbnail = null;
			}
			// 背景特效列表
			while (backgroundEffectList.length > 0)
			{
				displayObject = backgroundEffectList.shift();
				if (displayObject.parent) displayObject.parent.removeChild(displayObject);
			}
			// 前景特效列表
			while (foregroundEffectList.length > 0)
			{
				displayObject = foregroundEffectList.shift();
				if (displayObject.parent) displayObject.parent.removeChild(displayObject);
			}
			// 八卦阵(出入口)列表
			for (key in gateDic)
			{
				displayObject = gateDic[key];
				if (displayObject.parent) displayObject.parent.removeChild(displayObject);
				GatePool.instance.destoryObject(displayObject as MovieClip);
				delete gateDic[key];
			}

			var keyArr : Array = [];
			for (key in  gateByIdDic)
			{
				keyArr.push(key);
			}
			while (keyArr.length > 0)
			{
				delete gateByIdDic[keyArr.shift()];
			}

			avatarDictionary.quit();
			_selfPlayer = null;
			_selfPet = null;
			_selfStory = null;
		}
	}
}
