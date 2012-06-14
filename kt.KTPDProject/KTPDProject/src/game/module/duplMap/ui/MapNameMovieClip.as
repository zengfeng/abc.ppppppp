package game.module.duplMap.ui
{
	import com.greensock.TweenLite;
	import com.utils.UIUtil;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import game.definition.UI;
	import gameui.core.GComponent;
	import gameui.core.GComponentData;
	import gameui.manager.UIManager;
	import net.AssetData;





	/**
	 *  @author ZengFeng (Eamil:zengfeng75[AT])163.com 2012-4-19
	 */
	public class MapNameMovieClip extends GComponent
	{
		/** 单例对像 */
		private static var _instance : MapNameMovieClip;

		/** 获取单例对像 */
		public static function get instance() : MapNameMovieClip
		{
			if (_instance == null)
			{
				_instance = new MapNameMovieClip();
			}
			return _instance;
		}

		// ---------------------------------- 我是优美的长分隔线 ---------------------------------- //
		private var bg : Sprite;
		private var leftTexture : Sprite;
		private var rightTexture : Sprite;
		private var gradientName : GradientName;
		private var CENTER_X : int = 0;
		private var GAP : int = 35;
		private var TEXTTURE_WIDTH : int = 82;
		private var TEXTTURE_HEIGHT : int = 25;
		private var textWidth : int = 300;
		private var textHeight : int = 72;

		public function MapNameMovieClip()
		{
			_base = new GComponentData();
			_base.width = 850;
			_base.height = 122;
			CENTER_X = _base.width / 2;
			super(_base);
			initViews();
            scaleX = scaleY = 0.60;
			hide();
 
//			setName("大海明月");
		}

		private function initViews() : void
		{
			bg = UIManager.getUI(new AssetData(UI.MAP_NAME_MOVIE_CLIP_BACKGROUND));
			if (bg)
			{
				bg.width = _base.width;
				bg.height = _base.height;
				addChild(bg);
			}

			gradientName = new GradientName();
			textWidth = gradientName.textWidth;
			textHeight = gradientName.textHeight;
			gradientName.x = (_base.width - gradientName.width) >> 1;
			gradientName.y = (_base.height - gradientName.height) >> 1;
			addChild(gradientName);

			leftTexture = UIManager.getUI(new AssetData(UI.MAP_NAME_MOVIE_CLIP_TEXTURE));
			rightTexture = UIManager.getUI(new AssetData(UI.MAP_NAME_MOVIE_CLIP_TEXTURE));
			if (leftTexture)
			{
				addChild(leftTexture);
				addChild(rightTexture);
				TEXTTURE_WIDTH = leftTexture.width;
				rightTexture.scaleX = -1;
				leftTexture.y = rightTexture.y = (_base.height - TEXTTURE_HEIGHT) >> 1;
				leftTexture.x = CENTER_X - TEXTTURE_WIDTH - GAP - textWidth / 2;
				rightTexture.x = CENTER_X + TEXTTURE_WIDTH + GAP + textWidth / 2;
			}
		}

		public function setName(str : String) : void
		{
			gradientName.setName(str);
			textWidth = gradientName.textWidth;
			leftTexture.x = CENTER_X - TEXTTURE_WIDTH - GAP - textWidth / 2;
			rightTexture.x = CENTER_X + TEXTTURE_WIDTH + GAP + textWidth / 2 ;
		}

		public function updateLayout(event : Event = null) : void
		{
			this.x = ( stage.stageWidth - this.width * 0.60 ) >> 1;
//			this.y = ( stage.stageHeight - _base.height ) >> 1;
		}
		
		private function initPlay():void
		{
			clearTimeout(playTimer);
			clearTimeout(hideTimer);
			clearTimeout(showTimer);
			bg.alpha = 0;
			leftTexture.alpha = 0;
			rightTexture.alpha = 0;
			gradientName.alpha = 0;
		}
		
		private const SHOW_TIME_BG:Number = 1;
		private const SHOW_TIME_TEXTTURE:Number = 1.5;
		private const SHOW_TIME_NAME:Number = 2.5;
		private const SHOW_PLAY_TIME:Number = 2500;
		private const HIDE_TIME_BG:Number = 0.7;
		private const HIDE_TIME_TEXTTURE:Number = 0.5;
		private const HIDE_TIME_NAME:Number = 1.2;
		private const HIDE_PLAY_TIME:Number =1200;
		private const PUSE_TIME:Number = 500;
		private var showTimer:uint;
		private var hideTimer:uint;
		private function showPlay():void
		{
			TweenLite.to(bg, SHOW_TIME_BG, {alpha:1});
			TweenLite.to(leftTexture, SHOW_TIME_TEXTTURE, {alpha:1});
			TweenLite.to(rightTexture, SHOW_TIME_TEXTTURE, {alpha:1});
			TweenLite.to(gradientName, SHOW_TIME_NAME, {alpha:1});
		}
		
		private function hidePlay():void
		{
			clearTimeout(hideTimer);
			clearTimeout(showTimer);
			TweenLite.to(bg, HIDE_TIME_BG, {alpha:0});
			TweenLite.to(leftTexture, HIDE_TIME_TEXTTURE, {alpha:0});
			TweenLite.to(rightTexture, HIDE_TIME_TEXTTURE, {alpha:0});
			TweenLite.to(gradientName, HIDE_TIME_NAME, {alpha:0});
			hideTimer =  setTimeout(hide, HIDE_PLAY_TIME);
		}
		
		private function play():void
		{
			initPlay();
			showPlay();
			showTimer = setTimeout(hidePlay, SHOW_PLAY_TIME + PUSE_TIME);
		}
		
		private var playTimer:uint;
		override public function show() : void
		{
			initPlay();
			updateLayout();
			stage.addEventListener(Event.RESIZE, updateLayout);
			if (this.parent == null)
			{
				stage.addChild(this);
			}
			playTimer = setTimeout(play, 2000);
		}

		override public function hide() : void
		{
			initPlay();
			stage.removeEventListener(Event.RESIZE, updateLayout);
			if (this.parent != null)
			{
				this.parent.removeChild(this);
			}
		}

		override public function get stage() : Stage
		{
			return UIUtil.stage;
		}
	}
}
import flash.display.Sprite;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import game.definition.UI;
import gameui.core.GComponent;
import gameui.core.GComponentData;
import gameui.manager.UIManager;
import net.AssetData;




class GradientName extends GComponent
{
	private  const FONT_SIZE : int = 72;
	private var maskSprict : Sprite;
	private var textField : TextField;
	public var textWidth : int = 500;
	public var textHeight : int = 74;

	function GradientName() : void
	{
		_base = new GComponentData();
		_base.width = textWidth;
		_base.height = textHeight;
		super(_base);
		initViews();
	}

	private function initViews() : void
	{
		maskSprict = UIManager.getUI(new AssetData(UI.MAP_NAME_MOVIE_CLIP_MASK));
		maskSprict.width = textWidth;
		maskSprict.height = textHeight;
		maskSprict.x = 0;
		maskSprict.y = 0;
		maskSprict.cacheAsBitmap = true;
		addChild(maskSprict);
		var textFormat : TextFormat = new TextFormat();
		textFormat.font = UI.FONT_NAME_EMBED;
		textFormat.align = TextFormatAlign.CENTER;
		textFormat.size = FONT_SIZE;
		textFormat.bold = true;
		textField = new TextField();
		textField.antiAliasType = AntiAliasType.ADVANCED;
		textField.selectable = false;
		textField.defaultTextFormat = textFormat;
		textField.cacheAsBitmap = true;
		textField.width = textWidth;
		textField.height = textHeight;
		textField.text = "深幽树洞";
		maskSprict.mask = textField;
		addChild(textField);
		// setName("深幽树洞");
	}

	public function setName(str : String) : void
	{
		var length : int = str.length;
		textWidth = length * FONT_SIZE;
		textField.width = textWidth;
		maskSprict.width = textWidth;
		textField.x = (_base.width - textWidth) >> 1;
		maskSprict.x = textField.x;
		textField.text = str;
	}
}