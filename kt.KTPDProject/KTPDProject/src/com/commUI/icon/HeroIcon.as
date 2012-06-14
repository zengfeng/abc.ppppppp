package com.commUI.icon
{
	import game.core.hero.VoHero;
	import game.definition.UI;
	import game.manager.SignalBusManager;

	import gameui.controls.GImage;
	import gameui.core.GAlign;
	import gameui.core.GComponent;
	import gameui.data.GImageData;
	import gameui.manager.UIManager;

	import net.AssetData;

	import com.commUI.tooltip.SimpleHeroTip;
	import com.commUI.tooltip.ToolTipManager;

	import flash.display.Sprite;
	import flash.events.MouseEvent;





	/**
	 * @author jian
	 */
	public class HeroIcon extends GComponent
	{
		// ===============================================================
		// 属性
		// ===============================================================
		private var _hero : VoHero;
		private var _heroImage : GImage;
//		private var _levelBg : Sprite;
//		private var _levelLabel : GLabel;
		private var _emptyIcon : Sprite;
		private var _hasToolTip : Boolean;

		// ===============================================================
		// Getter/Setter
		// ===============================================================
		override public function set source(value : *) : void
		{
			_hero = value;

			if (_hero)
			{
				updateImage();
//				updateLevel();
				updateToolTip();
			}
			else
			{
				clear();
			}
		}

		override public function get source() : *
		{
			return _hero;
		}

		private function get thisdata() : HeroIconData
		{
			return _base as HeroIconData;
		}

		// ===============================================================
		// 方法
		// ===============================================================
		// ------------------------------------------------
		// 创建
		// ------------------------------------------------
		public function HeroIcon(base : HeroIconData)
		{
			super(base);
		}

		override protected function create() : void
		{
			super.create();

			addHeroImage();
			addEmptyIcon();
//			addLevelBg();
//			addLevel();
		}

		private function addHeroImage() : void
		{
			var data : GImageData = new GImageData();
			data.x = 1;
			data.y = 1;
			data.iocData.align = new GAlign(0, 0);
			_heroImage = new GImage(data);
			addChild(_heroImage);
		}

		private function addEmptyIcon() : void
		{
			if (thisdata.showEmpty)
			{
				_emptyIcon = UIManager.getUI(new AssetData(UI.HERO_ICON_EMPTY));
				_emptyIcon.x = 10;
				_emptyIcon.y = 1;
				_emptyIcon.visible = false;
				addChild(_emptyIcon);
			}
		}

//		private function addLevelBg() : void
//		{
//			_levelBg = UIManager.getUI(new AssetData(UI.HERO_ICON_LEVEL_BACKGROUND));
//			_levelBg.x = 1;
//			_levelBg.y = 1;
//			_levelBg.visible = false;
//			addChild(_levelBg);
//		}

//		private function addLevel() : void
//		{
//			_levelLabel = UICreateUtils.createGLabel({x:5, y:0, width:60, height:16});
//			addChild(_levelLabel);
//		}

		// ------------------------------------------------
		// 更新
		// ------------------------------------------------
		private function updateImage() : void
		{
			_heroImage.url = _hero.heroImage;
			if (_emptyIcon)
				_emptyIcon.visible = false;
		}

		private function updateToolTip() : void
		{
			if (!_hasToolTip)
			{
				ToolTipManager.instance.registerToolTip(this, thisdata.toolTip?thisdata.toolTip:SimpleHeroTip);
				_hasToolTip = true;
			}
		}

//		private function updateLevel() : void
//		{
//			_levelLabel.text = _hero.level.toString();
//			_levelBg.visible = true;
//		}

		private function clear() : void
		{
			if (_hasToolTip)
			{
				ToolTipManager.instance.destroyToolTip(this);
				_hasToolTip = false;
			}

			if (_heroImage)
				_heroImage.clearUp();

//			_levelBg.visible = false;
//			_levelLabel.text = "";

			if (_emptyIcon)
				_emptyIcon.visible = true;
		}

		// ------------------------------------------------
		// 交互
		// ------------------------------------------------
		override protected function onShow() : void
		{
			if (thisdata.showToolTip && !_hasToolTip)
				ToolTipManager.instance.registerToolTip(this, thisdata.toolTip?thisdata.toolTip:SimpleHeroTip);
			if (thisdata.sendToChat)
				addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}

		override protected function onHide() : void
		{
			if (_hasToolTip)
			{
				ToolTipManager.instance.destroyToolTip(this);
				_hasToolTip = false;
			}
			
			if (thisdata.sendToChat)
				removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			if (event.ctrlKey && _hero)
			{
				SignalBusManager.sendToChatHero.dispatch(_hero);
			}
		}
	}
}
