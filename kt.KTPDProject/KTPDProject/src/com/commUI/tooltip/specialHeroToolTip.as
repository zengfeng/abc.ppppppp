package com.commUI.tooltip
{
	import game.core.item.ItemManager;
	import com.utils.ColorUtils;
	import game.core.hero.VoHero;

	import com.utils.StringUtils;
	/**
	 * @author 1
	 */
	public class specialHeroToolTip extends ToolTip
{
		public function specialHeroToolTip(data : ToolTipData)
		{
			super(data);
		}
		
		override protected function getToolTipText():String
		{
			var text : String = "";
			var hero : VoHero = _source as VoHero;

			text += '<font size="14"><b>' + hero.htmlName + '</b></font>' + "\r";
			text += "职业：" + hero.jobName + "\r";
			text += "技能：" + hero.sutra.skill + "\r";
			text += hero.sutra.story+ "\r\r";;
//			text += StringUtils.addColor("CTRL+左键发送到聊天频道", "#999999");
			
			if(hero.color==ColorUtils.BLUE)
			{
				text +="招募所需"+StringUtils.addColorById("龙纹玉玦",ColorUtils.BLUE) +": 50";
			}
			else if(hero.color==ColorUtils.GREEN)
			{
				text +="招募所需"+StringUtils.addColorById("七星符印", ColorUtils.GREEN) +": 10";
			}
			return text;
		}
	}
}
