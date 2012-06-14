package game.module.guild {
	import com.utils.TextFormatUtils;
	import game.core.user.StateManager;
	import game.module.guild.vo.VoGuild;

	import gameui.controls.GButton;
	import gameui.data.GTitleWindowData;
	import gameui.manager.UIManager;

	import com.commUI.GCommonSmallWindow;
	import com.commUI.button.KTButtonData;
	import com.utils.ColorUtils;
	import com.utils.FilterTextUtils;
	import com.utils.UICreateUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;





	/**
	 * @author zhangzheng
	 */
	public class GuildIntroWnd extends GCommonSmallWindow {

		private var modifyButton : GButton;
		private var cancelButton : GButton;
		private var introInput : TextField;
		private var wordfilterbg : Sprite ;
		private var wordfiltertxt : TextField ;

		public function GuildIntroWnd() {
			var data:GTitleWindowData = new GTitleWindowData() ;
			data.width = 374;
			data.height = 170;
			data.modal = true;
			data.allowDrag = false;
			data.parent = UIManager.root ;
			super(data);
		}

		override protected function create() : void
		{
			super.create();
			this.title = "家族介绍";
			var bg:Sprite = UICreateUtils.createSprite(GuildUtils.clanBack,363,165,5,0);
			addChild(bg);
			
			bg = UICreateUtils.createSprite( GuildUtils.clanTextBack,345,80,13,28 );
			addChild(bg);
			
			bg = UICreateUtils.createSprite(GuildUtils.iconHint,17,13,13,12);
			addChild(bg);
			
			modifyButton = UICreateUtils.createGButton("确定",80,30,81,125,KTButtonData.SMALL_BUTTON);
			addChild(modifyButton);
			
			cancelButton = UICreateUtils.createGButton("取消",80,30,192,125,KTButtonData.SMALL_BUTTON);
			addChild(cancelButton);
			
			var fmt:TextFormat = TextFormatUtils.panelContent ;
//			fmt.size = 12 ;
//			fmt.align = TextFormatAlign.LEFT ;
//			fmt.color =  ColorUtils.PANELTEXT0X ;
			introInput = UICreateUtils.createTextField(null,null,310,80,31,40,fmt);
			introInput.multiline = true ;
			introInput.maxChars = 130 ;
			introInput.mouseEnabled = true ;
			introInput.wordWrap = true ;
			introInput.type = TextFieldType.INPUT ;
			addChild(introInput);
			
			var tip:TextField = UICreateUtils.createTextField("请输入家族介绍:",null,327,33,31,8,fmt);
			addChild(tip);
			
			modifyButton.addEventListener(MouseEvent.CLICK, onClickConfirm);
			cancelButton.addEventListener(MouseEvent.CLICK, function(evt:Event):void{ hide() ; });
		}

		private function onClickConfirm(event : MouseEvent) : void {
			
			if( FilterTextUtils.checkStr(introInput.text) ){

				StateManager.instance.checkMsg(244);
				//wordfilterbg.visible = true ;
				//wordfiltertxt.visible = true ;
				// 敏感词提示
			}
			else 
			{
				//wordfilterbg.visible = false ;
				//wordfiltertxt.visible = false ;
				GuildProxy.cs_guildintro( introInput.text );
				hide();
			}
		}
		
		override public function show():void
		{
			//隐藏敏感词提示
			//wordfilterbg.visible = false ;
			//wordfiltertxt.visible = false ;
			var vo:VoGuild = GuildManager.instance.selfguild;
			introInput.text = vo == null || vo.intro == null ? "" : vo.intro ;
			super.show();
		}
	}
}
