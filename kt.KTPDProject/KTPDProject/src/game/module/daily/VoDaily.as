package game.module.daily
{
	import game.core.menu.MenuManager;
	import game.core.menu.MenuType;
	import game.core.user.UserData;
	import game.manager.VersionManager;
	import game.module.bossWar.ProxyBossWar;
	import game.module.map.MapSystem;
	import game.module.quest.QuestManager;
	import game.module.quest.QuestUtil;

	import flash.events.Event;
	import flash.events.EventDispatcher;


	/**
	 * @author yangyiqiang
	 */
	public class VoDaily extends EventDispatcher
	{
		/*
		 *	   daily  对应日常的   每日活动 
		 *	   id 活动的编号    id小的排在上面
		 *	   name
		 *	   description
		 *	   type    1：点击传送至NPC面前
		 *	   		   2: vip传送,如没vip 慢慢爬过去
		 *	   		   3: 打开指定功能面板
		 *	   link    type =1,2 时  mapId|npcId    type=3 时  menuId(参照menu.xml)  
		 *	   ioc     活动图标名
		 */
		public var id : int = 0;

		public var name : String ;

		public var _description : String ;

		public var description2 : String ;

		public var type : int;

		private var ico : String;

		private var link : String;

		private var _vars : Array = [0, 0];

		/**
		 * 状态
		 *  0 - 今日无活动  1 - 未开启  2 - 已开启  3 - 已结束
		 */
		public var state : int;

		// 日常面板值   A + (B << 4) + (C << 8) + (D << 12) + (E << 16) + (F << 20) + (G << 24) + (H << 31)
		// A - 悬榜令剩余次数
		// B - 仙龟拜佛烧香剩余次数
		// C - 仙龟拜佛打劫剩余次数
		// D - 钓鱼剩余次数
		// E - 开天斧剩余次数
		// F - 竞技场剩余次数
		// G - 副本剩余次数
		// H - 1表示剩余的为收费次数，0表示剩余的为免费次数
		// 日常状态 A + (B << 2) + (C << 4) + (D << 6)
		// A - boss战
		// B - 派对
		// C - 阵营战
		// D - 守卫唐僧
		// 0 - 今日无活动  1 - 未开启  2 - 已开启  3 - 已结束
		public function parse(xml : XML) : void
		{
			id = xml.@id;
			name = xml.@name;
			_description = xml.@description;
			description2 = xml.@description2;
			type = xml.@type;
			link = xml.@link;
			ico = xml.@ico;
		}

		public function refresh() : void
		{
			this.dispatchEvent(new Event("refresh"));
		}

		public function get description() : String
		{
			var str : String = _description;
			for (var i : int = 0;i < _vars.length;i++)
			{
				str = str.replace("xx" + (i + 1), _vars[i]);
			}
			return str;
		}

		public function execute() : void
		{
			if (id == 1)
			{
//				if (!QuestManager.getInstance().toDaily())
//					MenuManager.getInstance().closeMenuView(MenuType.DAILY);
//				return;
				MenuManager.getInstance().changMenu(MenuType.DAILY_QUEST);
				return;
			}
			if(id==6){
				ProxyBossWar.instance.joyInBossWar();
				MenuManager.getInstance().closeMenuView(MenuType.DAILY);
				return;
			}
			if (id == 7)
			{
				MapSystem.mapTo.toGroupBattle();
				MenuManager.getInstance().closeMenuView(MenuType.DAILY);
				return;
			}
			if (type == 3)
				MenuManager.getInstance().openMenuView(Number(link));
			else
			{
				QuestUtil.goAndClickNpc(Number(link), type == 1 || UserData.instance.vipLevel > 0);
				MenuManager.getInstance().closeMenuView(MenuType.DAILY);
			}
		}

		public function getIcoUrl() : String
		{
			return VersionManager.instance.getUrl("assets/ico/daily/daily" + id + ".png");
		}

		public function refreshVars(var1 : int, var2 : int) : void
		{
			_vars = [var1, var2];
			refresh();
		}
	}
}
