package com.commUI.tooltip
{
	import com.utils.StringUtils;
	import flash.text.TextField;
	import game.core.hero.HeroConfigManager;
	import game.core.hero.VoHero;
	import game.core.hero.VoProp;
	import game.module.heroPanel.HeroCell;




	/**
	 * @author jian
	 */
	public class HeroTip extends ToolTip
	{
		public static var propConfigs : Array /* of HeroTipProp */;
		private var _icon : HeroCell;
		private var _info : TextField;

		public function HeroTip(data : ToolTipData)
		{
			super(data);
		}

		override protected function create() : void
		{
			super.create();

			_icon = new HeroCell();
			_info = new TextField();
			_info.textColor = 0xFFFFFF;

			addChild(_icon);
			addChild(_info);
		}

		override public function set source(value : *) : void
		{
			super.source = value;
			if (value)
			{
				updateIcon();
				updateInfo();
				layout();
			}
		}

		private function updateIcon() : void
		{
			_icon.vo = _source;
		}

		private function updateInfo() : void
		{
			var text : String = "";
			var hero : VoHero = _source;

			text += "职业：" + hero.jobName + "\r";
			text += "技能：" + hero.sutra.skill + "\r";

			_info.htmlText = text;
		}

		override protected function getToolTipText() : String
		{
			var text : String = "";
			var hero : VoHero = _source as VoHero;

			text += '<font size="14"><b>' + StringUtils.addColorById(hero._name + " " + hero.level + "级", hero.color) + '</b></font>' + "\r";

			for each (var prop:VoProp in HeroConfigManager.heroDisplayProps)
			{
				var val : Number = hero.prop[prop.name];
				if (val == 0)
					continue;

				text += prop.text + ": ";
				if (prop.id > 20 && prop.id < 30)
					text += Math.round(val * 10) / 10;
				else
					text += Math.round(val);
				text += "\r";
			}

			return text;
		}

		override protected function layout() : void
		{
			_icon.x = _data.padding;
			_icon.y = _data.padding;

			_info.x = _icon.x + 60;
			_info.y = _data.padding + 20;

			_label.y = _icon.y + _icon.height + _data.padding;

			_height = _label.y + _label.height + _data.padding;
			
			_backgroundSkin.width = _width;
			_backgroundSkin.height = _height;
		}
	}
}
