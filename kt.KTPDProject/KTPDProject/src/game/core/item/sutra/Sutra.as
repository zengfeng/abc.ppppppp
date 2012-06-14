package game.core.item.sutra
{
	import game.core.hero.VoHero;
	import game.core.item.config.SutraConfig;
	import game.core.item.equipment.Equipment;
	import game.core.item.gem.Gem;
	import game.core.item.prop.ItemProp;


	/**
	 * @author jian
	 */
	public class Sutra extends Equipment
	{
		// ===============================================================
		// 定义
		// ===============================================================
		public static const MAX_STEP : uint = 60;
		public static const SUTRA_MASTER_KEYS : Array = ["strength", "quick", "physique"];
		// ===============================================================
		// 属性
		// ===============================================================
		public var step : uint;
		public var stepValue : uint;
		public var nowDoaySumbit : uint;
		public var nowSumbitRate : uint;
		private var _hero : VoHero;
		private var _gems : Array;
		// 武将法宝当前提交个数
		public var sutraNowSumbitRate : int;
		// 武将法宝今日提交个数
		public var sutraNowDoaySumbit : int;

		// ===============================================================
		// Getter/Setter
		// ===============================================================
		override public function get totalProp() : ItemProp
		{
			// 基础
			var total : ItemProp = _prop.clone();

			// 升级
			total.plus(stepProp);

			// 灵珠
			for each (var gem:Gem in gems)
			{
				total.plus(gem.prop);
			}

			// 强化
			total[enhanceProp] += enhanceValue;

			return total;
		}
		
		override public function get prop ():ItemProp
		{
			var prop:ItemProp = _prop.clone();
			prop.plus(stepProp);
			
			return prop;
		}
		

		// 本阶属性
		public function get stepProp() : ItemProp
		{
			return StepPropManager.instance.getStepProp(hero.job, step);
		}

		// 下阶属性
		public function get nextStepProp() : ItemProp
		{
			return StepPropManager.instance.getStepProp(hero.job, nextStep);
		}
		
		// 法宝主属性
		override public function get masterKeys():Array
		{
			return SUTRA_MASTER_KEYS;
		}

		// 获得镶嵌的灵珠
		public function get gems() : Array /* of Gem */
		{
			if (!_gems)
				return _hero.gems;
			else
				return _gems;
		}

		public function set gems(value : Array) : void
		{
			_gems = value;
		}

		// 法宝技能
		public function get skill() : String
		{
			return SutraConfig(config).skill;
		}

		// 法宝攻击距离
		public function get range() : String
		{
			return SutraConfig(config).range;
		}

		// 法宝简介
		public function get story() : String
		{
			return SutraConfig(config).story;
		}
		
		public function get nextStep() : uint
		{
			return Math.min(step + 1, MAX_STEP);
		}

		public function get stepString() : String
		{
			return step + "阶";
//			return ItemUtils.getSutraStepString(step);
		}

		// 将领
		public function set hero(value : VoHero) : void
		{
			_hero = value;
		}

		public function get hero() : VoHero
		{
			return _hero;
		}

		public function get stepMaxValue() : uint
		{
			return _hero.config.sutraValue;
		}

		public function get relic() : uint
		{
			return _hero.config.relic;
		}

		public function get stepRelicLevel10() : uint
		{
			return _hero.config.stepRelicLevel10;
		}

		public function get stepRelicLevel10_Num() : uint
		{
			return _hero.config.stepRelicLevel10_Num;
		}

		public function get stepRelicLevel20() : uint
		{
			return _hero.config.stepRelicLevel20;
		}

		public function get stepRelicLevel20_Num() : uint
		{
			return _hero.config.stepRelicLevel20_Num;
		}

		public function get stepRelicLevel30() : uint
		{
			return _hero.config.stepRelicLevel30;
		}

		public function get stepRelicLevel30_Num() : uint
		{
			return _hero.config.stepRelicLevel30_Num;
		}

		public function get stepRelicLevel40_Num() : uint
		{
			return _hero.config.stepRelicLevel40_Num;
		}

		// ===============================================================
		// 方法
		// ===============================================================
		public function Sutra()
		{
			super();
		}

		public static function create(config : SutraConfig, prop : ItemProp) : Sutra
		{
			var sutra : Sutra = new Sutra();
			sutra.config = config;
			sutra.prop = prop;
			sutra.binding = true;

			return sutra;
		}

		override protected function parse(source : *) : void
		{
			super.parse(source);

			var sutra : Sutra = source as Sutra;
			sutra.prop = prop;
			sutra.hero = hero;
		}
	}
}
