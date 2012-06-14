package com.commUI.tooltip
{
	import game.module.prop.Prop;

	import com.utils.ItemUtils;
	import com.utils.ColorUtils;
	import com.utils.StringUtils;

	import game.core.item.equipable.HeroSlot;
	import game.core.item.equipment.Equipment;
	import game.core.item.prop.ItemProp;
	import game.module.debug.GMMethod;
	import game.module.prop.PropManager;

	/**
	 * @author yangyiqiang
	 */
	public class EquipmentTip extends ItemTip
	{
		public function EquipmentTip(data : ToolTipData)
		{
			super(data);
		}

		override protected function getToolTipText() : String
		{
			var text : String = "";
			text += getEquipmentTypeText() + "\r";
			text += getPropertyText() + "\r";
			text += getSuiteText() + "\r";
			text += getSellPriceText() + "\r";
			text += getSendChatText() + "\r";

			if (GMMethod.isDebug)
			{
				var eq : Equipment = source as Equipment;
				text += "typeid = " + eq.type + "\r";
				text += "uuid = " + eq.uuid + "\r";
			}

			return text;
		}

		override protected function getItemNameText() : String
		{
			var eq : Equipment = _source as Equipment;
			var text : String = '<font size="14"><b>' + eq.htmlName + "</b></font>";

			if (eq.slot)
				text += '<font size="12">（已装备）</font>';
			return text;
		}

		protected function getEquipmentTypeText() : String
		{
			var eq : Equipment = _source;
			return "装备类型：" + eq.typeName;
		}

		protected function getPropertyText() : String
		{
			var text : String = "";
			var eq : Equipment = _source;
			var prop : ItemProp = eq.prop;
			var key : String;
			var propName : String;
			var propVal : Number;
			var p : Prop;

			var enhanceKey : String = ItemUtils.getEnhancePropKey(eq.type);

			for each (key in prop.allKeys)
			{
				propVal = prop[key];
				p = PropManager.instance.getPropByKey(key);
				if (p)
					propName = p.name;
				else
					propName = "未知属性";

				if (propVal != 0)
				{
					text += propName + " +" + propVal + "\r";
				}
			}

			if (eq.enhanceLevel > 0)
			{
				p = PropManager.instance.getPropByKey(enhanceKey);
				text += StringUtils.addColorById(String(eq.enhanceLevel) + "级强化：" + p.name + "+" + eq.enhanceValue, eq.enhanceColor) + "\r";
			}

			return text;
		}

		protected function getSuiteText() : String
		{
			var text : String = "";
			var eq : Equipment = _source;
			var nums : int = 0;

			if (eq.slot)
			{
				var suite : Array = (eq.slot as HeroSlot).hero.getSuiteById(eq.suiteId);
				if (suite)
					nums = suite.length;
			}

			text += StringUtils.addColor("套装属性（" + nums + "/" + "6）", nums == 0 ? ColorUtils.GRAY : ColorUtils.HIGHLIGHT_DARK) + "\r";
			text += StringUtils.addColor("3件：", nums < 3 ? ColorUtils.GRAY : ColorUtils.HIGHLIGHT_DARK) + StringUtils.addColor(getPropString(eq.halfSuiteProp), nums < 3 ? ColorUtils.GRAY : ColorUtils.GOOD) + "\r";
			text += StringUtils.addColor("6件：", nums < 6 ? ColorUtils.GRAY : ColorUtils.HIGHLIGHT_DARK) + StringUtils.addColor(getPropString(eq.fullSuiteProp), nums < 6 ? ColorUtils.GRAY : ColorUtils.GOOD) + "\r";

			return text;
		}

		private function getPropString(prop : ItemProp) : String
		{
			var text : String = "";
			for each (var key:String in prop.allKeys)
			{
				if (prop[key] > 0)
				{
					text += PropManager.instance.getPropByKey(key).name + " +" + prop[key] + " ";
				}
			}

			return text;
		}
	}
}
