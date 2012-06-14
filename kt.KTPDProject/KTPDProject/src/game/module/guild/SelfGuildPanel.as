package game.module.guild {
	import com.google.analytics.core.ga_internal;
	import gameui.data.GTabData;
	import com.utils.TextFormatUtils;
	import game.core.user.StateManager;
	import com.utils.FilterUtils;
	import com.utils.ColorUtils;
	import flash.events.FocusEvent;
	import game.core.user.UserData;
	import game.module.guild.action.GuildActionTab;
	import game.module.guild.vo.VoGuild;

	import gameui.containers.GPanel;
	import gameui.containers.GTabbedPanel;
	import gameui.controls.GButton;
	import gameui.controls.GProgressBar;
	import gameui.data.GPanelData;
	import gameui.data.GProgressBarData;
	import gameui.data.GTabbedPanelData;
	import gameui.manager.GToolTipManager;
	import gameui.skin.SkinStyle;

	import net.AssetData;

	import com.commUI.button.KTButtonData;
	import com.commUI.tips.PlayerTip;
	import com.commUI.tooltip.ToolTip;
	import com.commUI.tooltip.ToolTipManager;
	import com.utils.FilterTextUtils;
	import com.utils.StringUtils;
	import com.utils.UICreateUtils;
	import com.utils.UIUtil;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;





	/**
	 * @author zhangzheng
	 */
	public class SelfGuildPanel extends GPanel {
		
		private var _guildname:TextField ;
		private var _guildleader:TextField ;
		private var _guildlevel:TextField ;
		private var _guildrank:TextField ;
		private var _membercnt:TextField ;
		private var _announce:TextField ;
		private var _expbar:GProgressBar ;
		private var _expbartxt:TextField ;
		
		private var _votebtn:GButton ;
		private var _introbtn:GButton ;	//介绍按钮
		private var _quitbtn:GButton ;	//退出/解散按钮
		private var _announcebtn:GButton ;	//提交修改按钮
		private var _otherguild:GButton ;
		private var _guildfield:GButton ;
		
		private var _tabpanel:GTabbedPanel ;
		private var _membertab:GuildMemberTab ;
		private var _audittab:GuildAuditTab ;
		private var _actiontab:GuildActionTab ;
		private var _trendtab:GuildTrendTab ;
		
		private var _manager:GuildManager = GuildManager.instance ;
		private var _vo:VoGuild ;
		
		//popup window
		private var _intrownd:GuildIntroWnd ;
		private var _votewnd:GuildVoteWindow ;
		private var _defannounce:String = StringUtils.addColor("请输入公告内容",ColorUtils.GRAY);
		private var _showdefann:Boolean = true ;
		
		public function SelfGuildPanel() {
			var data:GPanelData = new GPanelData() ;
			data.width = 735 ;
			data.height = 417 ;
			data.bgAsset = new AssetData( SkinStyle.emptySkin );
			super(data);
			initView();
		}
		
		private function initView():void {
			//base info background 
			var bg:Sprite = UICreateUtils.createSprite( GuildUtils.clanBack,272,410,5,0 );
			addChild(bg);
			
			
			bg = UICreateUtils.createSprite( GuildUtils.backLine , 255,95,20,34 );
			addChild(bg);
			
			//announce text back ;
			bg = UICreateUtils.createSprite( GuildUtils.clanTextBack , 254, 196, 16, 166 );
			addChild(bg);
			
			//guild name format 
			var namefmt:TextFormat = TextFormatUtils.panelSubTitle ;
//			namefmt.size = 14 ;
//			namefmt.bold = true ;
//			namefmt.color = ColorUtils.PANELTEXT0X;
			//guild base info format 
			var basefmt:TextFormat = TextFormatUtils.panelContent;
//			basefmt.size = 12 ;
//			basefmt.color =  ColorUtils.PANELTEXT0X;
			//guild name text 
			_guildname = UICreateUtils.createTextField(null,null,124,24,16,7,namefmt);
			addChild(_guildname);
			
			var txt:TextField = UICreateUtils.createTextField( "家族族长:",null,100,18,20,34,basefmt );
			addChild(txt);
			
			_guildleader = UICreateUtils.createTextField(null,null,104,18,78,34,basefmt);
			_guildleader.selectable = false ;
			_guildleader.mouseEnabled = true ;
			_guildleader.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverLeader);
			_guildleader.addEventListener(MouseEvent.MOUSE_OUT, onMouseLeaveLeader);
			_guildleader.addEventListener(TextEvent.LINK, onClickLeader);
			addChild(_guildleader);
			
			_guildlevel = UICreateUtils.createTextField("家族等级:",null,100,18,20,52,basefmt);
			addChild(_guildlevel);
			
			_guildrank = UICreateUtils.createTextField("家族排名:",null,100,18,20,70,basefmt);
			addChild(_guildrank);
			
			_membercnt = UICreateUtils.createTextField("家族人数:",null,100,18,20,88,basefmt);
			addChild(_membercnt);
			
			var guildexp:TextField = UICreateUtils.createTextField("家族经验:",null,100,18,20,106,basefmt);
			addChild(guildexp);
			
			var guildann:TextField = UICreateUtils.createTextField("家族公告:",null,100,18,20,147,basefmt);
			addChild(guildann);
			
			_announce = UICreateUtils.createTextField(null,null,254,196,16,166,basefmt);
			_announce.maxChars = 130 ;
			_announce.mouseEnabled = true ;
			_announce.wordWrap = true ;
			_announce.selectable = false ;
			_announce.addEventListener(FocusEvent.FOCUS_IN, onFocusInAnnounce);
			_announce.addEventListener(FocusEvent.FOCUS_OUT, onFocusOutAnnounce);
			addChild(_announce);
			//投票按钮
			_votebtn = UICreateUtils.createGButton("投票", 50, 22, 220, 36, KTButtonData.SMALL_BUTTON);
			_votebtn.addEventListener(MouseEvent.CLICK, onClickVote);
			addChild(_votebtn);
			//介绍按钮
			_introbtn = UICreateUtils.createGButton("介绍", 50, 22, 161, 5, KTButtonData.SMALL_BUTTON);
			_introbtn.addEventListener(MouseEvent.CLICK, onClickIntro);
			addChild(_introbtn);
			//退出按钮
			_quitbtn = UICreateUtils.createGButton("退出", 50, 22, 220, 5, KTButtonData.SMALL_BUTTON);
			_quitbtn.addEventListener(MouseEvent.CLICK, onClickQuit);
			addChild(_quitbtn);
			//提交修改按钮
			_announcebtn = UICreateUtils.createGButton("提交修改", 70, 22, 190, 335, KTButtonData.SMALL_BUTTON);
			_announcebtn.addEventListener(MouseEvent.CLICK, onClickAnnounce);
			addChild(_announcebtn);
			//其他家族按钮
			_otherguild = UICreateUtils.createGButton( "其他家族",80,30,50,372 );
			_otherguild.addEventListener(MouseEvent.CLICK, onClickOtherGuild);
			addChild(_otherguild);
			//进入家园按钮
			_guildfield = UICreateUtils.createGButton( "进入家园",80,30,149,372 );
			_guildfield.addEventListener(MouseEvent.CLICK, onClickGuildField);
			addChild(_guildfield);
			
			//经验条
			var pbdata:GProgressBarData = new GProgressBarData() ;
			pbdata.x = 14 ;
			pbdata.y = 132 ;
			pbdata.width = 260 ;
			pbdata.height = 14 ;
			pbdata.max = 100 ;
			pbdata.padding = 4 ;
			pbdata.trackAsset = new AssetData(GuildUtils.progressTrack);
			pbdata.barAsset = new AssetData(GuildUtils.progressBar);
			pbdata.paddingY = pbdata.padding = 3 ;
			pbdata.paddingX = 3 ;
			_expbar = new GProgressBar(pbdata);
			_expbar.toolTip = ToolTipManager.instance.getToolTip(ToolTip);
			_expbar.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverExpBar);
			_expbar.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutExpBar);
			addChild(_expbar);
			
			var ebfmt:TextFormat = TextFormatUtils.key ;
//			ebfmt.size =12 ;
//			ebfmt.color = 0xFFFFFF ;
//			ebfmt.align = "center";
			_expbartxt = UICreateUtils.createTextField(null,null,48,18,120,130,ebfmt);
			_expbartxt.filters = [FilterUtils.defaultTextEdgeFilter];
			_expbartxt.autoSize = "center";
			_expbartxt.mouseEnabled = false ;
			addChild(_expbartxt);
			_expbartxt.visible = false ;
			
			_membertab = new GuildMemberTab() ;
			_audittab = new GuildAuditTab() ;
			_actiontab = new GuildActionTab();
			_trendtab = new GuildTrendTab();
			
			_membertab.addEventListener(GuildEvent.CLOSE_VIEW, onCloseView );
			_audittab.addEventListener(GuildEvent.CLOSE_VIEW, onCloseView );
			_actiontab.addEventListener(GuildEvent.CLOSE_VIEW, onCloseView );
			_trendtab.addEventListener(GuildEvent.CLOSE_VIEW, onCloseView );
			
			_manager.addEventListener(GuildEvent.GUILD_BASE_CHANGE, onGuildBaseChange);
			_manager.addEventListener(GuildEvent.GUILD_MEMBER_LIST_CHANGE, onMemberListChange);
			_manager.addEventListener(GuildEvent.SELF_POSITION_CHANGE, onSelfPositionChange);
		}
		
		private function get defannounce():String
		{
			return _vo != null && _manager.selfmember.position > 0 ? _defannounce : "" ;
		}

		private function onMouseOutExpBar(event : MouseEvent) : void {
			_expbartxt.visible = false ;
		}

		private function onFocusOutAnnounce(event : FocusEvent) : void {
			if( _announce.text != "" )
				_showdefann = false ;
			else 
			{
				_showdefann = true ;
				_announce.htmlText = defannounce ;
			}
		}

		private function onFocusInAnnounce(event : FocusEvent) : void {
			
			if( _announce.type == TextFieldType.INPUT && _showdefann ){
				_announce.text = "" ;
			}
		}

		private function onSelfPositionChange(event : GuildEvent) : void {
			refreshTabbedPanel();
			_introbtn.visible = _manager.selfmember.position > 0 ;
			_announce.type = _manager.selfmember.position == 0 ? TextFieldType.DYNAMIC : TextFieldType.INPUT ;
			_announce.selectable = _manager.selfmember.position > 0 ;
			_announcebtn.visible = _manager.selfmember.position > 0 ;
		}

		private function onMemberListChange(event : GuildEvent) : void {
				_membercnt.text = "家族人数:" + _vo.memberList.length.toString() + "/20";
				_quitbtn.label.text = _vo.memberList.length <= 1 ? "解散" : "退出" ;
				
			}

		private function onGuildBaseChange(event : GuildEvent) : void {
			if( _vo != null )
			{
				_guildname.text = _vo.name ;
				_guildleader.htmlText = _vo.leader == null ? "" : StringUtils.addEvent( _vo.leader.colorname(), "to") ;
				_guildlevel.text = "家族等级:" + _vo.level.toString() ;
				_guildrank.text = "家族排名:" + _vo.seq.toString() ;
				_membercnt.text = "家族人数:" + _vo.memberList.length.toString() + "/20";
				_showdefann = _vo.announce == null || _vo.announce == "" ;
				_announce.htmlText = _showdefann ? defannounce : _vo.announce ;
				_expbar.value = _vo.levelexp == 0 ? 100 :
				 ( _vo.exp - _vo.prelevelexp )*100/( _vo.levelexp - _vo.prelevelexp );
				_votebtn.visible = _vo.status == 1 ;
			}
		}

		private function onClickLeader(event : TextEvent) : void {
			
			if( _vo != null && _vo.leader != null && _vo.leaderId != UserData.instance.playerId )
			{
				PlayerTip.show( _vo.leader.id, _vo.leader.name , GuildUtils.tiplist[GuildUtils.TL_MEMBER_NORM] );
			}
		}

		private function onMouseLeaveLeader(event : MouseEvent) : void {
			if( _vo != null && _vo.leader != null )
				_guildleader.htmlText = StringUtils.addEvent(_vo.leader.colorname(), "to");
		}

		private function onMouseOverLeader(event : MouseEvent) : void {
			if( _vo != null && _vo.leader != null )
				_guildleader.htmlText = StringUtils.addEvent(_vo.leader.linecolorname(), "to");
		}
		
		private function onCloseView( evt:Event ):void{
			dispatchEvent(evt);
		}

		private function onClickGuildField(event : MouseEvent) : void {
			GuildProxy.cs_enterguildcity() ;
			var evt:GuildEvent = new GuildEvent(GuildEvent.CLOSE_VIEW);
			dispatchEvent(evt);
		}

		private function onClickOtherGuild(event : MouseEvent) : void {
			var evt:GuildEvent = new GuildEvent(GuildEvent.CHANGE_STATE);
			evt.param = 0 ;
			dispatchEvent(evt);
		}

		private function onClickAnnounce(event : MouseEvent) : void {
			if( _showdefann )
			{
				GuildProxy.cs_guildannounce("") ;
				return ;
			}
			if( !FilterTextUtils.checkStr(_announce.text) ){
				GuildProxy.cs_guildannounce( _announce.text );
			}
			else {
				StateManager.instance.checkMsg(244);
			}
		}

		private function onClickQuit(event : MouseEvent) : void {
			if( _vo != null )
			{
				if( _vo.memberList.length == 1 ){
					GuildProxy.cs_guilddisband() ;
				}
				else {
					GuildProxy.cs_guildleave() ;
				}
			}
		}

		private function onClickIntro(event : MouseEvent) : void {
			if( _intrownd == null )
				_intrownd = new GuildIntroWnd() ;
			UIUtil.alignStageCenter(_intrownd);
			_intrownd.show();
//			_manager.showIntroWindow() ;
		}

		private function onClickVote(event : MouseEvent) : void {
			if( _votewnd == null )
				_votewnd = new GuildVoteWindow() ;
			UIUtil.alignStageCenter(_votewnd);
			_votewnd.show() ;
//			_manager.showVoteWindow() ;
		}

		private function onMouseOverExpBar(event : MouseEvent) : void {
			
			if( _vo != null ){
				_expbar.toolTip.source = _vo.levelexp == 0 ? "已满级" : "还需_EXP_经验，家族可升至下级".replace(/_EXP_/g,_vo.levelexp == 0 ? 0 : _vo.levelexp - _vo.exp );
				
				_expbartxt.visible = true ;
				_expbartxt.text = _vo.levelexp == 0 ? "已满级": (_vo.exp - _vo.prelevelexp).toString() + "/" + ( _vo.levelexp - _vo.prelevelexp ).toString();
			}
		}
		
		public function set vo( value:VoGuild ):void
		{
			_vo = value ;
			if( _vo == null )
			{
				_guildname.text =  "" ;
				_guildleader.text = "" ;
				_guildlevel.text = "家族等级:" ;
				_guildrank.text = "家族排名:" ;
				_membercnt.text = "家族人数:0/20" ;
				_announce.text = "" ;
				_expbar.value = 0 ;
				_trendtab.clearTrends();
			}
			else 
			{
				_guildname.text = _vo.name ;
				_guildleader.htmlText = _vo.leader == null ? "" : StringUtils.addEvent( _vo.leader.colorname(), "to") ;
				_guildlevel.text = "家族等级:" + _vo.level.toString() ;
				_guildrank.text = "家族排名:" + _vo.seq.toString() ;
				_membercnt.text = "家族人数:" + _vo.memberList.length.toString() + "/20";
				_showdefann = _vo.announce == null || _vo.announce == "" ;
				_announce.htmlText = _showdefann ? defannounce : _vo.announce ;
				if( _manager.selfmember.position > 0 ){
					_announce.type = TextFieldType.INPUT ;
					_announce.selectable = true ;
				}
				else {
					_announce.type = TextFieldType.DYNAMIC ;
					_announce.selectable = false ;
				}
				_announcebtn.visible = _manager.selfmember.position > 0 ;
				_introbtn.visible = _manager.selfmember.position > 0 ;
				_expbar.value = _vo.levelexp == 0 ? 100 :
				 ( _vo.exp - _vo.prelevelexp )*100/( _vo.levelexp - _vo.prelevelexp );
				_membertab.initMembers() ;
				
				_quitbtn.label.text = _vo.memberList.length <= 1 ? "解散" : "退出" ;
				_votebtn.visible = _vo.status == 1 ;
				refreshTabbedPanel();
			}
		}
		
		override protected function onShow():void{
			
			GToolTipManager.registerToolTip(_expbar);
			_tabpanel.group.selectionModel.index = 0 ;
			
			if( _vo == null || _vo.announce == null || _vo.announce == "")
			{
				_showdefann = true ;
				_announce.htmlText = defannounce ;
			}
			else 
			{
				_showdefann = false ;
				_announce.text = _vo.announce ;
			}
		}
		
		override protected function onHide():void{
			GToolTipManager.destroyToolTip(_expbar);
		}
		
		private function refreshTabbedPanel():void{
			
			if( _tabpanel != null )
				removeChild(_tabpanel);
				
			var tpdata:GTabbedPanelData = new GTabbedPanelData() ;
			tpdata.x = 282 ;
			tpdata.y = 0 ;
			tpdata.tabData.gap = 1 ;
			_tabpanel = new GTabbedPanel(tpdata);
			addChild(_tabpanel);

			_tabpanel.addTab("族员", _membertab);
			if( _manager.selfmember.position > 1 )
				_tabpanel.addTab("审核", _audittab);
			_tabpanel.addTab("活动",_actiontab);
			_tabpanel.addTab("动态",_trendtab);
			_tabpanel.group.selectionModel.index = 0 ;
		}
	}
}
