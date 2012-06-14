package game.module.guild {
	import com.utils.TextFormatUtils;
	import gameui.controls.GButton;
	import gameui.controls.GScrollBar;
	import gameui.data.GScrollBarData;
	import gameui.data.GTitleWindowData;
	import gameui.events.GScrollBarEvent;
	import gameui.manager.UIManager;

	import com.commUI.GCommonSmallWindow;
	import com.utils.ColorUtils;
	import com.utils.FilterUtils;
	import com.utils.UICreateUtils;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;




	/**
	 * @author zhangzheng
	 */
	public class GuildVoteWindow extends GCommonSmallWindow {
		
		private static const PAGE_SIZE:int = 12 ;
		private var _closebtn:GButton ;
		private var _itemlist:Vector.<VoteItem> = new Vector.<VoteItem>() ;
		private var _manager:GuildManager = GuildManager.instance;
		private var _scrollbar:GScrollBar ;
		
		public function GuildVoteWindow() {
			var data:GTitleWindowData = new GTitleWindowData();
			data.width = 323;
			data.height = 424;
			data.allowDrag = true;
			data.modal = true;
			data.parent = UIManager.root ;
			super(data);
		}
		
		override protected function initViews() : void{
			super.initViews();
			title = "族长选举" ;
			var bg:Sprite = UICreateUtils.createSprite(GuildUtils.clanBack,312,415,5,0);
			addChild(bg);
			
			bg = UICreateUtils.createSprite( GuildUtils.titleBar,297,24,13,47);
			addChild(bg);

			var fmtblack:TextFormat = TextFormatUtils.panelContent ;
//			fmtblack.size = 12 ;
//			fmtblack.color = ColorUtils.PANELTEXT0X; ;
			
			var fmtwhite:TextFormat = TextFormatUtils.key ;
//			fmtwhite.size = 12 ;
//			fmtwhite.color = 0xFFFFFF ;
			var tip:TextField = UICreateUtils.createTextField("请投票给你认为能当族长的族员，每人1次投票机会\n(连续5天不上线的族员不可参加竞选)",null,280,44,13,6,fmtblack);
			tip.multiline = true ;
			addChild(tip);
						
			var txt:TextField = UICreateUtils.createTextField("申请人",null,40,25,56,48,fmtwhite);
			txt.selectable = false ;
			txt.filters = [FilterUtils.defaultTextEdgeFilter];
			addChild(txt);
			
			txt = UICreateUtils.createTextField("等级",null,28,25,141,48,fmtwhite);
			txt.selectable = false ;
			txt.filters = [FilterUtils.defaultTextEdgeFilter];
			addChild(txt);
			
			txt = UICreateUtils.createTextField("得票",null,28,25,194,48,fmtwhite);
			txt.selectable = false ;
			txt.filters = [FilterUtils.defaultTextEdgeFilter];
			addChild(txt);

			var memberbg:Sprite = new Sprite() ;
			memberbg.x = 13 ;
			memberbg.y = 71 ;
			addChild(memberbg);
			
			for( var i:int = 0 ; i < PAGE_SIZE ; ++ i )
			{
				var item:VoteItem = new VoteItem();
				item.changebg(i);
				item.x = 0 ;
				item.y = 25 * i ;
				_itemlist.push(item);
				memberbg.addChild(item);
				
				if( i < _manager.selfguild.memberList.length )
				{
					item.vo = _manager.selfguild.memberList[i];
				}
				else 
				{
					item.vo = null ;
				}
			}
			
			var sbdata:GScrollBarData = new GScrollBarData() ;
			sbdata.x = 300;
			sbdata.y = 71;
			sbdata.wheelSpeed = 1;
			sbdata.movePre = 1;
			sbdata.height = PAGE_SIZE * 25;
			_scrollbar = new GScrollBar(sbdata);
			addChild(_scrollbar);
			
			memberbg.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			_scrollbar.addEventListener(GScrollBarEvent.SCROLL, onScroll);
			_manager.addEventListener(GuildEvent.GUILD_MEMBER_LIST_CHANGE, onMemberChange);
			_manager.addEventListener(GuildEvent.GUILD_VOTE_CHANGE, onVoteChange);
			_manager.addEventListener(GuildEvent.GUILD_BASE_CHANGE, onGuildBaseChange);
			
			_closebtn = UICreateUtils.createGButton("关闭",70,26,125,382);
			_closebtn.addEventListener(MouseEvent.CLICK, onClose);
			addChild(_closebtn);
		}

		private function onGuildBaseChange(event : GuildEvent) : void {
			if( _manager.selfguild == null || _manager.selfguild.status != 1 )
			{
				hide();
			}
		}

		private function onVoteChange(event : GuildEvent) : void {
			for each( var item:VoteItem in _itemlist )
			{
				item.update() ;
			}
		}

		private function onMemberChange(event : GuildEvent) : void {

			var pos:int = Math.min( _scrollbar.scrollPosition , _manager.selfguild.memberList.length - PAGE_SIZE );
			pos = Math.max(pos,0);
			for ( var i:int = 0 ; i < PAGE_SIZE ; ++ i )
			{
				_itemlist[i].vo = (pos + i) < _manager.selfguild.memberList.length ? _manager.selfguild.memberList[pos + i]:null;
				_itemlist[i].changebg(pos+i);
			}
			_scrollbar.resetValue(PAGE_SIZE, 0, Math.max(_manager.selfguild.memberList.length,0), pos);
			
		}

		private function onScroll(event : GScrollBarEvent) : void {
			var pos:int = Math.min( event.position , _manager.selfguild.memberList.length - PAGE_SIZE );
			pos = Math.max(pos,0);
			for ( var i:int = 0 ; i < PAGE_SIZE ; ++ i )
			{
				_itemlist[i].vo = (pos + i) < _manager.selfguild.memberList.length ? _manager.selfguild.memberList[pos + i]:null;
				_itemlist[i].changebg(pos+i);
			}
		}
		
		private function onMouseWheel(event : MouseEvent) : void {
			event.stopPropagation() ;
			_scrollbar.scroll(event.delta);
		}

		private function onClose(event : MouseEvent) : void {
			hide();
		}
	}
}
import com.utils.TextFormatUtils;
import game.module.guild.GuildManager;
import game.module.guild.GuildProxy;
import game.module.guild.GuildUtils;
import game.module.guild.vo.VoGuildMember;

import gameui.controls.GButton;
import gameui.manager.UIManager;

import net.AssetData;

import com.commUI.button.KTButtonData;
import com.commUI.tips.PlayerTip;
import com.utils.ColorUtils;
import com.utils.StringUtils;
import com.utils.UICreateUtils;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;





class VoteItem extends Sprite{
	
	private var _name:TextField ;
	private var _level:TextField ;
	private var _tickets:TextField ;
	private var _vote:GButton ;
	private var _deepbg:Sprite ;
	private var _lightbg:Sprite ;
	private var _vo:VoGuildMember ;
	
	function VoteItem(){
		addbg();
		initView() ;
	}
	
	public function set vo( value:VoGuildMember ):void
	{
		_vo = value ;
		if( _vo == null )
		{
			_name.visible = false ;
			_level.visible = false ;
			_tickets.visible = false ;
			_vote.visible = false ;
		}
		else 
		{
			_name.visible = true ;
			_name.htmlText = StringUtils.addEvent(_vo.colorname(), "to");
			_level.visible = true ;
			_level.text = _vo.level.toString();
			_tickets.visible = true ;
			_tickets.text = _vo.ticket.toString();
			_vote.visible = !GuildManager.instance.selfmember.vote ;
		}
	}
	
	public function get vo():VoGuildMember
	{
		return _vo ;
	}
	
	public function update():void{
		if( _vo != null )
		{
			_tickets.text = _vo.ticket.toString();
			_vote.visible = _vo != null && GuildManager.instance.selfmember.vote ;
		}
	}
	
	public function changebg(seq:int):void{
		removeChildAt(0);
		addChildAt( ( seq & 1 ) == 0 ? _deepbg : _lightbg , 0 );
	}

	private function addbg() : void {
		_deepbg = UIManager.getUI(new AssetData(GuildUtils.clanDeepBar));
		_deepbg.width = 287 ;
		_deepbg.height = 25 ;
		
		_lightbg = UIManager.getUI(new AssetData(GuildUtils.clanLightBar));
		_lightbg.width = 287 ;
		_lightbg.height = 25 ;
		
		addChild(_deepbg);
	}

	private function initView() : void {
		
		var fmt:TextFormat = TextFormatUtils.panelContentCenter;
//		fmt.size = 12 ;
//		fmt.align = TextFormatAlign.CENTER ;
//		fmt.color =  ColorUtils.PANELTEXT0X;
		_name = UICreateUtils.createTextField(null,null,100,25,12,4,fmt);
		_name.addEventListener(MouseEvent.ROLL_OVER, onRollOverName);
		_name.addEventListener(MouseEvent.ROLL_OUT, onRollOutName);
		_name.addEventListener(TextEvent.LINK, onClickName);
		_name.selectable = false ;
		addChild(_name);
		
		_level = UICreateUtils.createTextField(null,null,24,25,130,4,fmt);
		_level.selectable = false ;
		addChild(_level);
		
		_tickets = UICreateUtils.createTextField(null,null,40,25,175,4,fmt);
		_tickets.selectable = false ;
		addChild(_tickets);
		
		_vote = UICreateUtils.createGButton("投票",50,22,224,2,KTButtonData.SMALL_BUTTON);
		addChild(_vote);
		_vote.addEventListener(MouseEvent.CLICK, onClickVote);
		_vote.visible = false ;
	}

	private function onClickVote(event : MouseEvent) : void {
		if( _vo != null )
			GuildProxy.cs_guildvote( _vo.id );
	}

	private function onClickName(event : TextEvent) : void {
		
		var self:VoGuildMember = GuildManager.instance.selfmember ;
		if( _vo != null && self != null )
		{
			if( self.position == 2 ){
				if( _vo.position == 1 )
					PlayerTip.show(_vo.id,_vo.name,GuildUtils.tiplist[GuildUtils.TL_MEMBER_LEADER_VICE]);
				else
					PlayerTip.show(_vo.id,_vo.name,GuildUtils.tiplist[GuildUtils.TL_MEMBER_LEADER_NORM]);
			}
			else if( self.position == 1 ){
				if( _vo.position == 2 )
					PlayerTip.show(_vo.id,_vo.name,GuildUtils.tiplist[GuildUtils.TL_MEMBER_VICE_LEADER]);
				else
					PlayerTip.show(_vo.id,_vo.name,GuildUtils.tiplist[GuildUtils.TL_MEMBER_VICE_NORM]);
			}
			else 
				PlayerTip.show(_vo.id ,_vo.name ,GuildUtils.tiplist[GuildUtils.TL_MEMBER_NORM]);
		}

	}

	private function onRollOutName(event : MouseEvent) : void {
		if( _vo != null )
			_name.htmlText = StringUtils.addEvent(_vo.colorname(), "to");
	}

	private function onRollOverName(event : MouseEvent) : void {
		if( _vo != null )
			_name.htmlText = StringUtils.addEvent(_vo.linecolorname() , "to");
	}
}
