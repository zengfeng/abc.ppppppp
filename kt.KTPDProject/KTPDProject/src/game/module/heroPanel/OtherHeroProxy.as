package game.module.heroPanel
{
	import game.core.hero.HeroManager;
	import game.core.hero.VoHero;
	import game.core.item.ItemManager;
	import game.core.item.equipable.EquipableItem;
	import game.core.item.equipment.Equipment;
	import game.core.item.gem.Gem;
	import game.core.item.gem.GemSlot;
	import game.core.item.prop.ItemProp;
	import game.core.item.soul.Soul;
	import game.core.item.soul.SoulSlot;
	import game.core.item.sutra.Sutra;
	import game.core.menu.MenuManager;
	import game.core.menu.MenuType;
	import game.module.formation.FMControler;
	import game.net.core.Common;
	import game.net.data.StoC.SCOtherInfo;
	import game.net.data.StoC.SCOtherInfo.OtherHeroInfo;
	import game.net.socket.SocketClient;

	/**
	 * @author jian
	 */
	public class OtherHeroProxy
	{
		// ===============================================================
		// 单例
		// ===============================================================
		private static var __instance : OtherHeroProxy;

		public static function get instance() : OtherHeroProxy
		{
			if (!__instance)
				__instance = new OtherHeroProxy();

			return __instance;
		}

		public function OtherHeroProxy()
		{
			if (__instance)
				throw (Error("单例错误！"));

			__instance = this;

			initiate();
		}

		// ===============================================================
		// 属性
		// ===============================================================
		private var _gameServer : SocketClient = Common.game_server;
		private var _heroManager : HeroManager = HeroManager.instance;
		private var _itemManager : ItemManager = ItemManager.instance;
		private var _otherHeroes : Array;

		// ===============================================================
		// 方法
		// ===============================================================
		private function initiate() : void
		{
			_gameServer.addCallback(0x14, onOtherInfo);
		}

		private function onOtherInfo(msg : SCOtherInfo) : void
		{
			_otherHeroes = parseOtherInfo(msg);
			var panel : OtherHeroPanel = MenuManager.getInstance().openMenuView(MenuType.OTHER_HERO_PANEL).target as OtherHeroPanel;
			panel.heroes = _otherHeroes;
		}

		// 解析其他玩家包
		private function parseOtherInfo(msg : SCOtherInfo) : Array
		{
			var formationId : int = msg.formationId >> 8;
			var formationLevel : int = msg.formationId & 0xFF;
//			var player : OtherPlayerVO = new OtherPlayerVO(msg.name, msg.level, msg.profLevel, formationId, formationLevel);

			// 解析将领
			var heroInfo : OtherHeroInfo;
			var hero : VoHero;
			var formationPos : int;
			var formationProp : ItemProp;
			var heroes : Array = [];

			for each (heroInfo in msg.heroes)
			{
				hero = parseOtherHeroInfo(heroInfo, msg.level);

				formationPos = msg.formationHeroes.indexOf(hero.id);

				if (formationId > 0 && formationPos >= 0)
				{
					formationProp = FMControler.instance.getFormationProp(formationLevel, formationId, formationPos);
//					hero.prop = HeroManager.calculateHeroProp(hero, msg.profLevel, formationProp);
				}
				else
				{
//					hero.prop = HeroManager.calculateHeroProp(hero, msg.profLevel, null);
				}

				heroes.push(hero);
			}
			
			heroes[0].name = msg.name;

			return heroes;
		}

		// 解析其他将领包
		private function parseOtherHeroInfo(msg : OtherHeroInfo, level : int) : VoHero
		{
			var hero : VoHero = _heroManager.newHero(msg.id, level);
			hero.potential = msg.potential;
			hero.sutraSlot.equip(_itemManager.newItem(hero.config.sutraId));

			var soulPos : int = 0;
			var gemPos : int = 0;
			var item : EquipableItem;
			var itemId:uint;
			var enhanceLevel:uint;
			for each (var compactedId:uint in msg.equips)
			{
				itemId = compactedId & 0xFFFF;
				enhanceLevel = compactedId >> 16;
				
				item = _itemManager.newItem(itemId, true);

				if (item is Sutra)
				{
					(item as Sutra).enhanceLevel = enhanceLevel;
					hero.sutraSlot.onEquipped(item);
				}
				else if (item is Equipment)
				{
					(item as Equipment).enhanceLevel = enhanceLevel;
					hero.getEqSlot(item.type).onEquipped(item);
				}
				else if (item is Soul)
				{
					if (soulPos > 5)
						throw(Error("超出6个元神！"));
						
					(hero.soulSlots[soulPos] as SoulSlot).onEquipped(item);
					soulPos++;
				}
				else if (item is Gem)
				{
					(hero.gemSlots[gemPos] as GemSlot).onEquipped(item);
					gemPos++;
				}
			}
			
			hero.sutra.step = msg.wpLevel;
			return hero;
		}
	}
}
