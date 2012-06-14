package game.module.debug
{
	import flash.text.TextField;
	import test.toolbox.Toolbox;
	import flash.display.DisplayObject;
	import game.core.user.UserData;
	import game.manager.ViewManager;
	import game.module.battle.BattleInterface;
	import game.module.battle.view.BTSystem;
	import game.module.chat.ManagerChat;
	import game.module.map.CurrentMapData;
	import game.module.map.MapController;
	import game.module.map.MapProto;
	import game.module.map.MapSystem;
	import game.module.map.animal.Animal;
	import game.module.map.animal.AnimalManager;
	import game.module.map.animalManagers.FollowManager;
	import game.module.map.animalManagers.PlayerManager;
	import game.module.map.animalstruct.PlayerStruct;
	import game.module.map.playerVisible.PlayerTolimitManager;
	import game.module.map.utils.MapUtil;
	import game.module.mapStory.StoryController;
	import game.module.settings.SettingData;
	import game.net.core.Common;

	import gameui.manager.UIManager;

	import log4a.Logger;

	import utils.SystemUtil;

	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class GMMethod
	{
		public static var isShowDebugInfo : Boolean = true;
		public static var isDebug : Boolean = false;
		public static const PREFIX : String = "gm";
		public static const HELP : String = "help";
		public static const IS_DEBUG : String = "isDebug";
		public static const SHOW_NET_INFO : String = "net";
		public static const SHOW_AVATAR_SIZE : String = "avatarSize";
		public static const ADD_PLAYER : String = "addPlayer";
		public static const GO_SCENE : String = "goScene";
		public static const IS_HIDE_BATTLE : String = "be";
		public static const AVATAR : String = "avatar";
		public static const RESET : String = "reset";
		public static const TO_MAP : String = "toMap";
		public static const TO_NPC : String = "toNpc";
		public static const TO_GATE : String = "toGate";
		public static const TO_DUPL : String = "toDupl";
		public static const MAP_MOVE_TO : String = "mapMoveTo";
		public static const SELF_POSITION : String = "selfPosition";
		public static const MAP_POSITION : String = "mapPosition";
		public static const MAP_MOVE_Bind_SELF : String = "mapMoveBindSelf";
		public static const EN_MOUSE_MOVE_MAP : String = "enMouseMoveMap";
		public static const EN_MOUSE_MOVE : String = "enMouseMove";
		public static const SM_Setup : String = "smSetup";
		public static const SM_QUIT : String = "smQuit";
		public static const SM_ADD_SELF : String = "smAddSelf";
		public static const SM_REMOVE_SELF : String = "smRemoveSelf";
		public static const SM_SELF_MOVE_TO : String = "smSelfMoveTo";
		public static const SM_MAP_MOVE_TO : String = "smMapMoveTo";
		public static const SM_ADD_NPC : String = "smAddNpc";
		public static const SM_REMOVE_NPC : String = "smRemoveNpc";
		public static const SM_NPC_MOVE_TO : String = "smNpcMoveTo";
		public static const TRANSPORT : String = "transport";
		public static const FOLLOW : String = "follow";
		public static const FOLLOW2 : String = "follow2";
		public static const NPC_FOLLOW_SELF : String = "npcFollowSelf";
		public static const REMOVE_NPC_FOLLOW_SELF : String = "removeNpcFollowSelf";
		public static const PLAYER_LIST : String = "playerList";
		public static const SHAKE : String = "shake";
		public static const SETUP_MAP : String = "setupMap";
		public static const CLAN_PROMPT : String = "clanPrompt";
		public static const VERSION : String = "version";
		public static const ZOOM : String = "zoom";
		public static const ZOOM_UP : String = "zoomUp";
		public static const ZOOM_DOWN : String = "zoomDown";
		public static const ZOOM_RESTORE : String = "zoomRestore";
		public static const SHOW_PAHT_DATA : String = "showPathData";
		public static const SHOW_PAHT : String = "showPath";
		public static const IS_LIMIT_PLAYER_Count : String = "isLimitPlayerCount";
		public static const PS : String = "ps";
		public static const CHAT_PROMPT : String = "chatPrompt";
		public static const CHAT_SYSTEM : String = "chatSystem";
		public static const CHAT_SYSTEM_NOTIC : String = "chatSystemNotic";
		public static const SELF_SPEED : String = "selfSpeed";
		public static const RETURN_BATTLE : String = "returnBattle";
		public static const IS_SHOW_DEBUG_INFO : String = "isShowDebugInfo";
		public static const CACHE_AS_BITMAP : String = "cacheAsBitmap";
		public static const SHOW_UI:String = "showui";
		public static const TF_BORDER:String = "tfborder";
		
		private var startNum : int = 1000;

		private function help() : void
		{
			var info : String = "GM命令:" + "gm help-帮助<br> " + "gm net-流量<br>";
			info += "gm clanPrompt 家族提示消息<br>";
			info += "gm addPlayer n(数量)<br>";
			info += "gm moveTo x y<br>";
			info += "gm getPosition 获取当前角色坐标<br>";
			info += "gm goScene sceneID difficultyLevel 切换地图<br>";
			info += "gm sceneSH 0/1 显示或隐藏地图<br>";
			info += "gm be 结束战斗<br>";
			info += "gm avatar 玩家行走动作改变<br>";
			info += "gm reset id value 初始化勾选<br>";
			info += "gm toMap mapId x y flashStep 去地图某个位置mapId小于等于0是就是当前地图 <br>";
			info += "gm toNpc npcId mapId flashStep 去地图某个NPC位置mapId小于等于0是就是当前地图<br>";
			info += "gm toGate toMapId stand 去地图某个出口入口toMapId小于等于0是就是当前地图, stand 是否站立<br>";
			info += "gm toDupl duplMapId flashStep guideType x y去副本<br>";

			info += "gm enMouseMoveMap 能否鼠标移动地图<br>";
			info += "gm enMouseMove 能否鼠标控制自己玩家<br>";
			info += "gm selfPosition 获取自己玩家位置<br>";
			info += "gm mapPosition 获取地图位置<br>";
			info += "gm mapMoveBindSelf 地图移动是否绑定自己玩家<br>";
			info += "gm mapMoveTo x y spendTime 移动地图到某个位置(spendTime 花费时间 -1：为自动计算时间，0：为瞬间跳动，-2：为固定预时间， 大于为1为自己设置时间) <br>";
			info += "<br> ";
			info += "gm smSetup mapId x y 进入剧情 <br>";
			info += "gm smQuit 进入剧情 <br>";
			info += "gm smAddSelf x y 添加自己 <br>";
			info += "gm smRemoveSelf 移除自己 <br>";
			info += "gm smSelfMoveTo x y flashStep 自己移动到 <br>";
			info += "gm smMapMoveTo x y flashStep 和mapMoveTo一样 <br>";
			info += "gm smAddNpc npcId x y index 添加NPC <br>";
			info += "gm smRemoveNpc npcId 移除NPC <br>";
			info += "gm smNpcMoveTo npcId x y flashStep NPC移动到 <br>";
			info += "<br> ";
			info += "gm transport x y mapId 传送 mapId为0时是当前地图<br>";
			info += "gm follow playerId 跟随 <br>";
			info += "gm follow2 id type beId beType 跟随 <br>";
			info += "gm npcFollowSelf npcId 设置某个NPC跟随自己 <br>";
			info += "gm removeNpcFollowSelf npcId 移除某个NPC跟随自己 <br>";
			info += "gm playerList 获取玩家列表 <br>";
			info += "gm shake 震动 <br>";
			info += "gm setupMap mapId x y 安装一个地图,服务器不关心 <br>";
			info += "gm zoom scale time 地图缩放 <br>";
			info += "gm zoomUp  地图放大 <br>";
			info += "gm zoomDown  地图缩小 <br>";
			info += "gm zoomRestore  地图还原 <br>";
			info += "gm showPathData true/false 是否显示寻路数据 <br>";
			info += "gm showPath true/false 是否显示寻路数据 <br>";
			info += "gm isLimitPlayerCount true/false 是否限制玩家数量 <br>";
			info += "gm ps centerX centerY width height 地图截屏 <br>";
			info += "gm chatPrompt content isHTMLFormat 聊天提示消息 <br>";
			info += "gm chatSystem content isHTMLFormat 聊天系统消息 <br>";
			info += "gm chatSystemNotic content isHTMLFormat 聊天系统通知消息 <br>";
			info += "gm selfSpeed num 自己速度 <br>";
			info += "gm returnBattle true/false 不进入战斗<br>";
			info += "gm isShowDebugInfo true/false 是否显示debug信息<br>";

			Logger.info(info);
		}

		private function showNetInfo() : void
		{
			var info : String = "已读:" + Common.game_server.readBytes + "字节,";
			info += "已发:" + Common.game_server.writeBytes + "字节.";
			Logger.info(info);
		}

		private function addPlayers(num : int) : void
		{
			var struct : PlayerStruct;
			for (var i : int = 0;i < num;i++)
			{
				struct = new PlayerStruct();
				struct.id = startNum++;
				struct.job = 1;
				struct.heroId = 6;
				struct.name = struct.id + "";
				struct.isMale = false;
				struct.avatarVer = 5;
				struct.x = 1580 + UIManager.stage.stageWidth * Math.random();
				struct.y = 1104 + UIManager.stage.stageHeight * Math.random();
				MapSystem.addPlayer(struct);
			}
		}

		public function GMMethod() : void
		{
		}

		public function run(params : Array) : void
		{
			if (params.length == 0) return;
			var method : String = params.shift();
			switch(method)
			{
				case GMMethod.HELP:
					help();
					break;
				case GMMethod.SHOW_NET_INFO:
					showNetInfo();
					break;
				case ADD_PLAYER:
					addPlayers(params.shift());
					break;
				case IS_HIDE_BATTLE:
					BTSystem.INSTANCE().end();
					break;
				case GO_SCENE:
					break;
				case AVATAR:
					MapSystem.selfPlayerAnimal.avatar.setAction(params.shift());
					break;
				case RESET:
					SettingData.setDataById(params.shift(), params.shift() == "true" ? true : false);
					break;
				case TO_MAP:
					MapSystem.mapTo.toMap(params.shift(), params.shift(), params.shift(), params.shift() != "true" ? false : true);
					break;
				case TO_NPC:
					MapSystem.mapTo.toNpc(params.shift(), params.shift(), params.shift() != "true" ? false : true);
					break;
				case TO_GATE:
					MapSystem.mapTo.toGate(params.shift(), params.shift(), params.shift() != "true" ? false : true, params.shift() != "true" ? false : true);
					break;
				case TO_DUPL:
					break;
				case MAP_MOVE_TO:
					MapSystem.mapMoveTo(params.shift(), params.shift(), params.shift());
					break;
				case SELF_POSITION:
					Logger.info("自己玩家位置：" + MapUtil.selfPlayerPosition);
					break;
				case MAP_POSITION:
					Logger.info("地图位置：" + MapUtil.mapPosition);
					break;
				case MAP_MOVE_Bind_SELF:
					MapSystem.mapMoveIsBindSelfPlayer = params.shift() != "false" ? true : false;
					break;
				case EN_MOUSE_MOVE_MAP:
					MapSystem.enMouseMoveMap = params.shift() != "true" ? false : true;
					break;
				case EN_MOUSE_MOVE:
					MapController.instance.enMouseMove = params.shift() == "false" ? false : true;
					break;
				case SM_Setup:
					StoryController.instance.setup(params.shift(), params.shift(), params.shift());
					break;
				case SM_QUIT:
					StoryController.instance.quit();
					break;
				case SM_ADD_SELF:
					StoryController.instance.addSelf(params.shift(), params.shift());
					break;
				case SM_REMOVE_SELF:
					StoryController.instance.removeSelf();
					break;
				case SM_SELF_MOVE_TO:
					StoryController.instance.selfMoveTo(params.shift(), params.shift(), params.shift() == "false" ? false : true);
					break;
				case SM_MAP_MOVE_TO:
					StoryController.instance.mapMoveTo(params.shift(), params.shift(), params.shift());
					break;
				case SM_ADD_NPC:
					StoryController.instance.addNpc(params.shift(), params.shift(), params.shift(), params.shift());
					break;
				case SM_REMOVE_NPC:
					StoryController.instance.removeNpc(params.shift());
					break;
				case SM_NPC_MOVE_TO:
					StoryController.instance.npcMoveTo(params.shift(), params.shift(), params.shift(), params.shift() == "false" ? false : true);
					break;
				case TRANSPORT:
					// var mapId:int = params.shift();
					// if(!mapId) mapId = 0;
					MapProto.instance.cs_transport(params.shift(), params.shift(), params.shift());
					break;
				case FOLLOW:
					var playerId : int = params.shift();
					var animal : Animal = AnimalManager.instance.getPlayer(playerId);
					AnimalManager.instance.selfPlayer.followAnimal(animal);
					break;
				case FOLLOW2:
					MapSystem.follow(params.shift(), params.shift(), params.shift(), params.shift());
					break;
				case PLAYER_LIST:
					var player : PlayerStruct = CurrentMapData.instance.selfPlayerStruct;
					Logger.info("自己玩家 ID = " + player.id + "   NAME = " + player.name);
					Logger.info("<b>列家列表</b>");
					Logger.info("<b>ID</b> ---------- <b>NAME</b>");
					var list : Vector.<PlayerStruct> = PlayerManager.instance.getPlayerList();
					for (var i : int = 0; i < list.length; i++)
					{
						player = list[i];
						Logger.info(player.id + " ---------- " + player.name);
					}
					break;
				case SHAKE:
					MapSystem.shake();
					break;
				case NPC_FOLLOW_SELF:
					FollowManager.instance.npcFollowSelf(params.shift());
					break;
				case REMOVE_NPC_FOLLOW_SELF:
					FollowManager.instance.removeNpcFollowSelf(params.shift());
					break;
				case SETUP_MAP:
					MapSystem.setupMap(params.shift(), new Point(params.shift(), params.shift()));
					break;
				case CLAN_PROMPT:
					ManagerChat.instance.clanPrompt(params.shift());
					break;
				case VERSION:
					Logger.info(SystemUtil.getVersion());
					break;
				case ZOOM:
					MapSystem.zoom(params.shift() ? params.shift() : 1, params.shift() ? params.shift() : 2);
					break;
				case ZOOM_UP:
					MapSystem.zoomUp();
					break;
				case ZOOM_DOWN:
					MapSystem.zoomDown();
					break;
				case ZOOM_RESTORE:
					MapSystem.zoomRestore();
					break;
				case SHOW_PAHT:
					MapSystem.debugShowPath = params.shift() == "true";
					break;
				case IS_LIMIT_PLAYER_Count:
					PlayerTolimitManager.instance.enable = params.shift() == "true";
					break;
				case PS:
					ps(params);
					break;
				case IS_DEBUG:
//					isDebug = params.shift() == "true";
//					if (isDebug)
//					{
//						_miner = new TheMiner();
//						UIManager.root.addChild(_miner);
//					}
//					else if (_miner && _miner.parent)
//					{
//						_miner.parent.removeChild(_miner);
//						_miner = null;
//					}
//					break;
				case CHAT_PROMPT:
					ManagerChat.instance.prompt(params.shift(), true);
					break;
				case CHAT_SYSTEM:
					ManagerChat.instance.system(params.shift(), true);
					break;
				case CHAT_SYSTEM_NOTIC:
					ManagerChat.instance.systemNotic(params.shift(), true);
					break;
				case SELF_SPEED:
					AnimalManager.instance.selfPlayer.speed = parseInt(params.shift());
					AnimalManager.instance.selfPlayer.playerStruct.speed = parseInt(params.shift());
					break;
				case RETURN_BATTLE:
					BattleInterface.DEBUG_RETURN_BATTLE = params.shift() == "true";
					break;
				case IS_SHOW_DEBUG_INFO:
					isShowDebugInfo = params.shift() == "true";
					break;
				case CACHE_AS_BITMAP:
					cacheViewAsBitmap(params.shift() == "true");
					break;
				case SHOW_UI:
					showUI(params.shift() == "true");
					break;
				case TF_BORDER:
					tfborder(UIManager.root);
					break;
			}
		}
		
		private function tfborder(root:DisplayObjectContainer):void
		{
			Toolbox.forEachChildIn(root, ontfborder, -1);
			
		}
		
		private function ontfborder(target:DisplayObject, depth:int):Boolean
		{
			if (target is TextField)
			{
				with ((target.parent as Sprite).graphics)
				{
					lineStyle(1);
					drawRect(target.x, target.y, target.width, target.height);
					drawRect(target.x + 2, target.y + 2, (target as TextField).textWidth, (target as TextField).textHeight);
				}
			}
			return true;
		}

		private function showUI(show : Boolean) : void
		{
			var autoContainer : DisplayObjectContainer = ViewManager.instance.getContainer(ViewManager.AUTO_CONTAINER);
			var uiContainer : DisplayObjectContainer = ViewManager.instance.getContainer(ViewManager.UIC_CONTAINER);
			var ioc : DisplayObjectContainer = ViewManager.instance.getContainer(ViewManager.IOC_CONTAINER);

			for each (var container:DisplayObjectContainer in  [autoContainer, uiContainer, ioc])
			{
				if (show)
				{
					if (!container.parent)
						UIManager.root.addChild(container);
				}
				else
				{
					if (container.parent)
						container.parent.removeChild(container);
				}
			}
			
			if (show)
				Logger.info("开启UI");
			else
				Logger.info("关闭UI");
		}

		private function cacheViewAsBitmap(value : Boolean) : void
		{
			UserData.instance.userPanel.cacheAsBitmap = value;
			ManagerChat.instance.view.cacheAsBitmap = value;
			ViewManager.instance.uiContainer.cacheAsBitmap = value;
			
			if (value)
				Logger.info("开启ＵＩ缓存");
			else
				Logger.info("关闭ＵＩ缓存");
		}

//		private var _miner : TheMiner;
		private var psBitmap : Bitmap;
		private var psSprict : Sprite;

		public function ps(...args : *) : void
		{
			args = args[0];
			if (args[0] == "null" )
			{
				clearPS();
				return;
			}
			if (psBitmap == null)
			{
				psBitmap = new Bitmap();
				psSprict = new Sprite();
				psSprict.addChild(psBitmap);
				psSprict.addEventListener(MouseEvent.MOUSE_DOWN, psSprict_mouseDown);
				psSprict.doubleClickEnabled = true;
				psSprict.addEventListener(MouseEvent.DOUBLE_CLICK, clearPS);
			}

			clearPS();

			psBitmap.bitmapData = MapSystem.printScreen(//
			parseInt(args[0]) ? parseInt(args[0]) : MapSystem.selfPlayerAnimal.x, 
			// 
			parseInt(args[1]) ? parseInt(args[1]) : MapSystem.selfPlayerAnimal.y, 
			// 
			args[2] ? parseInt(args[2]) : 0, 
			// 
			args[3] ? parseInt(args[3]) : 0);
			ViewManager.instance.uiContainer.addChild(psSprict);
		}

		private function psSprict_mouseDown(event : MouseEvent) : void
		{
			psSprict.removeEventListener(MouseEvent.MOUSE_DOWN, psSprict_mouseDown);
			psSprict.addEventListener(MouseEvent.MOUSE_UP, psSprict_mouseUp);
			psSprict.startDrag();
		}

		private function psSprict_mouseUp(event : MouseEvent) : void
		{
			psSprict.stopDrag();
			psSprict.addEventListener(MouseEvent.MOUSE_DOWN, psSprict_mouseDown);
		}

		public function clearPS(event : Event = null) : void
		{
			if (psBitmap)
			{
				if (psSprict.parent) psSprict.parent.removeChild(psSprict);
				if (psBitmap.bitmapData) psBitmap.bitmapData.dispose();
				psBitmap.bitmapData = null;
			}
		}
	}
}
