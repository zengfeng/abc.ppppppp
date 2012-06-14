package game.core.item
{
	import com.utils.ColorUtils;
	import com.utils.StringUtils;
	import flash.utils.getQualifiedClassName;
	import game.core.item.config.ItemConfig;
	import game.manager.VersionManager;
	import game.module.pack.merge.MergeManager;
	import gameui.manager.UIManager;






	/**
	 * @author jian
	 */
	public class Item implements ISearchable, IComparable, IBindable
	{
		// ====================================================================
		// 定义
		// ====================================================================
		/** 消耗品 */
		public static const EXPEND : int = 1;
		/** 装备 */
		public static const EQ : int = 2;
		/** 元神*/
		public static const SOUL : int = 4;
		/** 灵珠*/
		public static const GEM : int = 8;
		/** 强化*/
		public static const ENHANCE : int = 16;
		/** 天材地宝*/
		public static const JEWEL : int = 32;
		
		public static const TOP_TYPES:Array = [EXPEND, EQ, SOUL, GEM, ENHANCE, JEWEL];
		// ====================================================================
		// 属性
		// ====================================================================
		private var _binding : Boolean;
		private var _config : ItemConfig;
		private var _nums : uint;
		private var _topType : uint;

		// ===================================================================
		// Getter/Setter
		// ===================================================================
		public function get topType() : uint
		{
			return _topType;
		}

		public function set topType(value : uint) : void
		{
			_topType = value;
		}

		public function set binding(value : Boolean) : void
		{
			_binding = value;
		}

		public function get binding() : Boolean
		{
			return _config.binding || _binding;
		}

		public function set nums(value : uint) : void
		{
			_nums = value;
		}

		public function get nums() : uint
		{
			return _nums;
		}

		public function set config(value : ItemConfig) : void
		{
			_config = value;
			setTopType();
		}

		public function get config() : ItemConfig
		{
			return _config;
		}

		public function get type() : uint
		{
			return _config.type;
		}

		public function get name() : String
		{
			return _config.name;
		}

		public function get id() : uint
		{
			return _config.id;
		}

		public function get color() : uint
		{
			return _config.color;
		}

		public function get useLevel() : uint
		{
			return _config.level;
		}

		public function get price() : uint
		{
			return _config.price;
		}

		public function get stackLimit() : uint
		{
			return _config.stackLimit;
		}

		public function get imgUrl() : String
		{
			if (!_config) return "";
			return VersionManager.instance.getUrl("assets/goods_beta/" + _config.imgID + ".png");
		}

		public function get imgLargeUrl() : String
		{
			return VersionManager.instance.getUrl("assets/goods_big/" + _config.imgID + "_large.png");
		}

		public function get mcUrl() : String
		{
			return VersionManager.instance.getUrl("assets/goods_beta/" + _config.imgID + ".swf");
		}

		public function get htmlName() : String
		{
			return StringUtils.addColor(_config.name, ColorUtils.TEXTCOLOR[config.color]);
		}
		
		public function get htmlShortName():String
		{
			return StringUtils.addColorById(_config.name.slice(0, 2), color);
		}
		
		public function get htmlNameCount():String
		{
			return StringUtils.addColor(_config.name + "×" + _nums, ColorUtils.TEXTCOLOR[config.color]);
		}

		public function get description() : String
		{
			return _config.description;
		}

		public function get searchName() : String
		{
			return _config.name;
		}

		public function equals(value : IComparable) : Boolean
		{
			var other : Item = value as Item;

			if (!other) return false;

			return (other.id == id && other.binding == binding);
		}

		public function get usable() : Boolean
		{
			return type == 60 || type == 59;
		}

		// ====================================================================
		// @方法
		// ====================================================================
		public function Item()
		{
		}

		public function clone() : *
		{
			var item : * = new (UIManager.appDomain.getDefinition(getQualifiedClassName(this)) as Class)();
			parse(item);
			return item;
		}

		protected function parse(source : *) : void
		{
			var item : Item = source as Item;
			item.config = config;
			item.binding = binding;
			item.topType = topType;
			item.nums = nums;
		}

		private function setTopType() : void
		{
			var type : uint = _config.type;

			if (type >= 81 && type <= 86)
			{
				topType = Item.EQ;
			}
			else if (type >= 14 && type <= 40)
			{
				topType = Item.SOUL;
			}
			else if (type <= 13)
			{
				topType = Item.GEM;
			}
			else if (type == 63)
			{
				topType = Item.ENHANCE;
			}
			else if (type == 64)
			{
				topType = Item.JEWEL;
			}
			else if (type == 65)
			{
				topType = Item.GEM;
			}
			else
			{
				topType = Item.EXPEND;
			}
		}
	}
}
