package com.commUI.tooltip
{
	import com.utils.StringUtils;
	import game.core.hero.VoHero;


	/**
	 * @author jian
	 */
	public class SimpleHeroTip extends ToolTip
	{
		public function SimpleHeroTip(data : ToolTipData)
		{
			super(data);
		}
		
		override protected function getToolTipText():String
		{
			var text : String = "";
			var hero : VoHero = _source as VoHero;

//			text += '<font size="14"><b>' + hero.htmlName + " " + hero.level + "级" + '</b></font>' + "\r";
			text += '<font size="14"><b>' + hero.htmlName + '</b></font>' + "\r";
			text += "职业：" + hero.jobName + "\r";
			// TODO
			text += "战斗力：" + hero.bt + "\r\r";
			text += StringUtils.addColor("CTRL+左键发送到聊天频道", "#999999");
			
			return text;
		}
	}
}
