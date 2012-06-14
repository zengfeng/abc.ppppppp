package game.manager
{
	import game.config.StaticConfig;
	import game.core.menu.MenuManager;
	import game.module.artifact.ArtifactView;
	import game.module.battle.view.BTSystem;
	import game.module.chat.ControllerChat;
	import game.module.chat.ManagerChat;
	import game.module.chatwhisper.ControllerWhisper;
	import game.module.chatwhisper.view.WhisperModuleView;
	import game.module.compete.CompeteView;
	import game.module.daily.DailyNotice;
	import game.module.daily.DailyPanel;
	import game.module.debug.DebugView;
	import game.module.demonTower.DemonTowerView;
	import game.module.formation.FormationView;
	import game.module.gem.GemView;
	import game.module.guild.GuildView;
	import game.module.heroPanel.HeroPanel;
	import game.module.map.utils.MapUtil;
	import game.module.mapConvoy.ui.ConvoyOptionPanel;
	import game.module.mapWorld.WorldMapController;
	import game.module.pack.PackView;
	import game.module.practice.PracticeView;
	import game.module.quest.DialogueSprite;
	import game.module.quest.QuestDisplayManager;
	import game.module.recruitHero.RecruitView;
	import game.module.rewardPackage.PackageRewardPanel;
	import game.module.shop.ShopView;
	import game.module.soul.SoulView;
	import game.module.soul.abyss.AbyssView;
	import game.module.sutra.SutraView;
	import game.module.trade.TradeView;
	import game.module.userPanel.OtherPlayerPanel;

	import gameui.containers.GContainer;
	import gameui.containers.GPanel;
	import gameui.containers.GTitleWindow;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.layout.GLayout;
	import gameui.manager.UIManager;
	import gameui.skin.ASSkin;
	import gameui.theme.BlackTheme;

	import log4a.Logger;

	import net.AssetData;
	import net.LibData;
	import net.RESManager;

	import com.commUI.GCommonWindow;
	import com.commUI.RightMenu;
	import com.commUI.ScrollInfo;
	import com.utils.OpenWindow;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.utils.Dictionary;

	/**
	 * @author yangyiqiang
	 */
	public class ViewManager
	{
		public static const MAP_CONTAINER : int = 0;
		public static const AUTO_CONTAINER : int = 1;
		public static const UIC_CONTAINER : int = 2;
		public static const IOC_CONTAINER : int = 3;
		public static const BATTLE_CONTAINER : int = 4;
		public static const ROLL_CONTAINER : int = 5;
		private static var _instance : ViewManager;
		public static var chat : DisplayObjectContainer;
		private static var debugView : DebugView;
		public static var dialogueSprite : DialogueSprite;
		public static var whisperView : WhisperModuleView;
		public static var otherPlayerPanel : OtherPlayerPanel;

		public function ViewManager()
		{
			if (_instance)
			{
				throw Error("---ViewManager--is--a--single--model---");
			}
		}

		public static function get instance() : ViewManager
		{
			if (_instance == null)
			{
				_instance = new ViewManager();
			}
			return _instance;
		}

		private var _containerDic : Dictionary = new Dictionary();

		public function getContainer(stack : int) : Sprite
		{
			return _containerDic[stack];
		}

		public function get uiContainer() : GContainer
		{
			return _containerDic[UIC_CONTAINER];
		}

		public function addToStage(view : DisplayObject, stack : int = UIC_CONTAINER) : void
		{
			if (!getContainer(stack)) return;
			getContainer(stack).addChild(view);
		}

		public function initializeViewsDebug() : void
		{
			if (ViewManager.debugView) return;
			ViewManager.debugView = new DebugView(UIManager.root);
			Logger.addAppender(ViewManager.debugView);
			createInfo();
		}

		private var rightMenu : RightMenu;

		public function setRightMenu() : void
		{
			rightMenu = new RightMenu(UIManager.root);
			rightMenu.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, handleMenuSelection);
			rightMenu.addMenuItem("官网", true);
			rightMenu.addMenuItem("论坛", true);
			rightMenu.addMenuItem("充值", true);
			rightMenu.addMenuItem(StaticConfig.game_version, true);
			rightMenu.addMenuItem("心动游戏", true);
			rightMenu.hideMenuItem(StaticConfig.game_version);
			rightMenu.hideMenuItem("心动游戏");
		}

		protected function handleMenuSelection(event : ContextMenuEvent) : void
		{
			switch (rightMenu.selectedMenu)
			{
				case "官网" :
					OpenWindow.open(StaticConfig.offcialSite);
					break;
				case "论坛" :
					OpenWindow.open(StaticConfig.bbs);
					break;
				case "充值" :
					OpenWindow.open(StaticConfig.pay);
					break;
				default:
					break;
			}
		}

		public function initializeContainers() : void
		{
			// 嵌入字体
			var allFonts : Array = Font.enumerateFonts(true);
			for each (var str:Object in allFonts)
			{
				if (str["fontName"] == "STXinwei" || str["fontName"] == "华文新魏")
				{
					Logger.info("have STXinwei         ");
					UIManager.hasEmbedFonts = true;
				}
			}

			if (!UIManager.hasEmbedFonts)
				RESManager.instance.load(new LibData(StaticConfig.cdnRoot + "assets/swf/font.swf"));

			var bcData : GComponentData = new GComponentData();
			bcData.parent = UIManager.root;

			var bc : GComponent = new GComponent(bcData);
			bc.mouseEnabled = false;

			var rollContainer : GComponent = new GComponent(bcData.clone());
			rollContainer.name = "ROLL_CONTAINER";
			rollContainer.mouseEnabled = false;
			rollContainer.mouseChildren = false;
			rollContainer.cacheAsBitmap = true;

			var autoContainer : GContainer = new GContainer();
			autoContainer.name = "AUTO_CONTAINER";
			autoContainer.mouseEnabled = false;
			autoContainer.cacheAsBitmap = true;

			var uiContainer : GContainer = new GContainer();
			uiContainer.name = "UIC_CONTAINER";
			uiContainer.mouseEnabled = false;
			uiContainer.cacheAsBitmap = true;

			var ioc : GContainer = new GContainer();
			ioc.name = "IOC_CONTAINER";
			ioc.mouseEnabled = false;
			ioc.cacheAsBitmap = true;

			var mapContainer : Sprite = new Sprite();
			mapContainer.mouseEnabled = false;
			mapContainer.name = "MAP_CONTAINER";

			UIManager.root.addChild(mapContainer);
			UIManager.root.addChild(autoContainer);
			UIManager.root.addChild(uiContainer);
			UIManager.root.addChild(ioc);

			_containerDic[AUTO_CONTAINER] = autoContainer;
			_containerDic[UIC_CONTAINER] = uiContainer;
			_containerDic[IOC_CONTAINER] = ioc;
			_containerDic[BATTLE_CONTAINER] = bc;
			_containerDic[ROLL_CONTAINER] = rollContainer;
			_containerDic[MAP_CONTAINER] = mapContainer;

			UIManager.stage.addEventListener(Event.RESIZE, stageResizeHandler);
			MouseManager.map = mapContainer;
			MouseManager.load();
			BTSystem.INSTANCE().setContainer(bc);
		}

		public  function initializeViews() : void
		{
			// 聊天
			chat = ManagerChat.instance.view;
			// ImmortalContral.instance.cToS();
			addToStage(chat, ViewManager.AUTO_CONTAINER);

			dialogueSprite = new DialogueSprite();

			ControllerChat;
			RecruitView;
			HeroPanel;
			PracticeView;
			SutraView;
			GuildView ;
			// MyClanView;
			// ClanList;
			CompeteView;
			TradeView;

			GemView;
			PackView;
			ShopView;

			ConvoyOptionPanel;
			DailyPanel;
			FormationView;
			WorldMapController.instance;

			AbyssView;
			DemonTowerView;
			PackageRewardPanel;
			ShopView;
			otherPlayerPanel = new OtherPlayerPanel();
			ControllerWhisper.instance;

			// TODO: 分模块时去掉
			SoulView;
			// EnhanceView;
			// MergeView;

			ArtifactView;
		}

		private static function createInfo() : void
		{
			ASSkin.setTheme(AssetData.AS_LIB, new BlackTheme());
		}

		/** 播放动画 **/
		public  function playAnimation(key : String = "quest_complete") : void
		{
			var mc : MovieClip = RESManager.getMC(new AssetData(key, "commonAction"));
			mc.x = int(UIManager.stage.stageWidth / 2);
			mc.y = int(UIManager.stage.stageHeight / 2) - 300;
			mc.gotoAndPlay(0);
			addToStage(mc);
		}

		/** 添加滚屏 **/
		public  function rollMessage(str : String) : void
		{
			var roll : GComponent = getContainer(ROLL_CONTAINER) as GComponent;
			roll.x = UIManager.stage.stageWidth / 2 - 160;
			roll.y = UIManager.stage.stageHeight / 3 - 50;
			roll.show();
			ScrollInfo.instance.add(str);
		}

		private static function stageResizeHandler(event : Event) : void
		{
			if (UIManager.root == null) return;
			for (var i : int = 0;i < UIManager.root.numChildren;i++)
			{
				var child : DisplayObject = UIManager.root.getChildAt(i);
				if (child is GContainer)
				{
					(child as GContainer).stageResizeHandler();
				}
				var component : GComponent = child as GComponent;
				if (component == null) continue;
				if (component.align == null) continue;
				if (component is GPanel)
				{
					var panel : GPanel = component as GPanel;
					if (panel.modal) panel.resizeModal();
				}
				else if (component is GTitleWindow)
				{
					var titleWindow : GTitleWindow = component as GTitleWindow;
					if (titleWindow.modal) titleWindow.resizeModal();
				}
				else if (component is GCommonWindow)
				{
					var commWindow : GTitleWindow = component as GTitleWindow;
					if (commWindow.modal) commWindow.resizeModal();
				}
				GLayout.layout(component);
			}
			UIManager.root.transform.perspectiveProjection.projectionCenter = new Point(UIManager.stage.stageWidth / 2, UIManager.stage.stageHeight / 2);
			runStageResizeCallFun();
		}

		private static var _stageResizeCallFunList : Vector.<Function> = new Vector.<Function>();

		public static function addStageResizeCallFun(fun : Function) : void
		{
			if (_stageResizeCallFunList.indexOf(fun) != -1) return;
			_stageResizeCallFunList.push(fun);
		}

		public static function removeStageResizeCallFun(fun : Function) : void
		{
			var index : int = _stageResizeCallFunList.indexOf(fun);
			if (index == -1) return;
			_stageResizeCallFunList.splice(index, 1);
		}

		private static function runStageResizeCallFun() : void
		{
			for (var i : int = 0; i < _stageResizeCallFunList.length; i++)
			{
				var fun : Function = _stageResizeCallFunList[i];
				fun.apply(null, [UIManager.stage, preStageWH.x, preStageWH.y]);
			}
			preStageWH.x = UIManager.stage.stageWidth;

			preStageWH.y = UIManager.stage.stageHeight;
		}

		public static var preStageWH : Point = new Point();

		/** 更新显示状态 */
		public static function refreshShowState() : void
		{
			// 如果是大地图
			var b : Boolean = MapUtil.isActiveing ;
			if (MapUtil.isGigMap())
			{
				if (MapUtil.isMainMap() == false)
				{
					QuestDisplayManager.getInstance().questView.visible = true;
				}
				else
				{
					QuestDisplayManager.getInstance().questView.visible = !b ;
				}
			}
			else if (MapUtil.isDungeonMap())
			{
				QuestDisplayManager.getInstance().questView.visible = true;
			}
			else
			{
				QuestDisplayManager.getInstance().questView.visible = false;
			}
			MenuManager.getInstance().visible(QuestDisplayManager.getInstance().questView.visible, MenuManager.TOP_MENU);
			DailyNotice.instance.visible = !b ;
		}
	}
}
