package com.commUI.tooltip
{
	import com.utils.StringUtils;
	import game.core.item.equipment.Equipment;
	import game.core.item.soul.Soul;
	import game.module.debug.GMMethod;


	/**
	 * @author jian
	 */
	public class SoulTip extends ItemTip
	{
		public function SoulTip(data : ToolTipData)
		{
			super(data);
		}

		override protected function getToolTipText() : String
		{
			var text : String = "";
			var soul : Soul = _source;

			text += "经验：" + soul.exp + "/" + soul.upgradeExp + "\r";
			text += getDescriptionText() + "\r\r";
			text += getSellPriceText() + "\r";
			text += getSendChatText() + "\r";
			
			if (GMMethod.isDebug)
			{
				var eq:Soul = source as Soul;
				text += "typeid = " + eq.type + "\r";
				text += "uuid = " + eq.uuid + "\r";
			}

			return text;
		}

		override protected function getItemNameText() : String
		{
			var soul : Soul = _source as Soul;
			var text : String = '<font size="14"><b>' + StringUtils.addColorById(soul.name + " " + soul.level  + "级", soul.color)+  "</b></font>";
			return text;
		}
	}
}
