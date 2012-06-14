package game.module.guild {
	import com.utils.TextFormatUtils;
	import com.commUI.button.KTButtonData;
	import com.commUI.pager.Pager;
	import com.utils.FilterUtils;
	import com.utils.UICreateUtils;
	import com.utils.UIUtil;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import gameui.containers.GPanel;
	import gameui.controls.GButton;
	import gameui.data.GPanelData;
	import gameui.skin.SkinStyle;
	import net.AssetData;





	/**
	 * @author zhangzheng
	 */
	public class GuildListPanel extends GPanel {
		
		private static const PAGE_SIZE:int = 12 ;
		
		private var _guildlist:Vector.<GuildListItem> = new Vector.<GuildListItem>() ;
		private var _createbtn:GButton ;
		private var _pager:Pager ;
		private var _manager:GuildManager = GuildManager.instance ;
		
		private var _createwnd:GuildCreateWnd ;
		
		public function GuildListPanel() {
			var data:GPanelData = new GPanelData();
			data.width = 735 ;
			data.height = 415 ;
			data.bgAsset = new AssetData( SkinStyle.emptySkin );
			super(data);
			initView() ;
			initEvent() ;
		}
		
		private function initView():void{
			
			var bg:Sprite = UICreateUtils.createSprite( GuildUtils.clanBack , 720, 410, 5, 0 );
			addChild(bg);
			
			var title:Sprite = UICreateUtils.createSprite( GuildUtils.titleBar , 710 , 24, 10, 31 );
			addChild(title);


			var fmt:TextFormat = TextFormatUtils.key ;
//			fmt.size = 12 ;
//			fmt.color = 0xFFFFFF ;
//			fmt.align = TextFormatAlign.CENTER ;
			var t:TextField = UICreateUtils.createTextField("排名",null, 28 ,18 ,25 ,33 ,fmt);
			t.filters = [FilterUtils.defaultTextEdgeFilter];
			t.selectable = false ;
			addChild(t);


			t = UICreateUtils.createTextField("家族",null, 28 ,18 ,125 ,33 ,fmt);
			t.filters = [FilterUtils.defaultTextEdgeFilter];
			t.selectable = false ;
			addChild(t);

			t = UICreateUtils.createTextField("族长",null, 28 ,18 ,290 ,33 ,fmt);
			t.filters = [FilterUtils.defaultTextEdgeFilter];
			t.selectable = false ;
			addChild(t);

			t = UICreateUtils.createTextField("家族等级",null, 56 ,18 ,409 ,33 ,fmt);
			t.filters = [FilterUtils.defaultTextEdgeFilter];
			t.selectable = false ;
			addChild(t);

			t = UICreateUtils.createTextField("人数",null, 28 ,18 ,527 ,33 ,fmt);
			t.filters = [FilterUtils.defaultTextEdgeFilter];
			t.selectable = false ;
			addChild(t);

			t = UICreateUtils.createTextField("操作",null, 28 ,18 ,644 ,33 ,fmt);
			t.filters = [FilterUtils.defaultTextEdgeFilter];
			t.selectable = false ;
			addChild(t);
			
			for( var i:int = 0 ; i < PAGE_SIZE ; ++ i )
			{
				var item:GuildListItem = new GuildListItem(i);
				item.y = 55 + i * 25;
				item.x = 10;
				addChild(item);
				_guildlist.push(item);
			}
			
			_pager = new Pager(5,true);
			_pager.setPage(1, 1);
			_pager.x = (width - _pager.width) / 2;
			_pager.y = 375;
			addChild(_pager);
			_pager.addEventListener(Event.CHANGE, onChange);
			_createbtn = UICreateUtils.createGButton("创建家族", 66, 26, 26, 4, KTButtonData.SMALL_BUTTON );
			_createbtn.addEventListener( MouseEvent.CLICK, onClickCreate ) ;
			addChild(_createbtn);

			_createbtn.visible = _manager.selfguild == null ;
		}

		private function onChange(event : Event) : void {
			GuildProxy.cs_listguild((_pager.model.page - 1)*PAGE_SIZE, PAGE_SIZE);
		}
		
		private function initEvent():void
		{
			_manager.addEventListener( GuildEvent.GUILD_LIST, onGuildList);
			_manager.addEventListener( GuildEvent.GUILD_LIST_CHANGE , onGuildListChange);
			_manager.addEventListener( GuildEvent.GUILD_LEAVE, onLeaveOrEnter);
			_manager.addEventListener( GuildEvent.GUILD_ENTER, onLeaveOrEnter);
///			_manager.addEventListener( GuildEvent.GUILD_LIST_CHANGE , onGuildListChange);
//			_manager.addEventListener( GuildEvent.SET_SELF_GUILD , onSelfGuild) ;
//			_manager.addEventListener( GuildEvent.LEAVE_GUILD , onLeaveGuild );
		}

		private function onLeaveOrEnter(event : GuildEvent) : void {
			_createbtn.visible = _manager.selfguild == null ;
			for( var i : int = 0 ; i < PAGE_SIZE ; ++ i )
			{
				_guildlist[i].updateStatus() ;
			}
		}

		private function onGuildListChange(event : GuildEvent) : void {
			for( var j:int = 0 ; j < PAGE_SIZE ; ++ j )
			{
				if( _guildlist[j].vo != null && _guildlist[j].vo.id == event.param ){
					_guildlist[j].updateStatus() ;
					break ;
				}
			}
		}

		private function onGuildList(event : GuildEvent) : void {
			for( var i:int = 0 ; i < PAGE_SIZE ; ++ i )
			{
				if( i < _manager.guildList.length ){
					_guildlist[i].vo = _manager.guildList[i];
				}
				else{
					_guildlist[i].vo = null ;
				}
			}
			_pager.setPage( _manager.guildlistbegin/PAGE_SIZE + 1, _manager.guildlisttotal/PAGE_SIZE + 1 );
		}

		private function onClickCreate(event : MouseEvent) : void {
			//open create window ;
			if( _createwnd == null )
				_createwnd = new GuildCreateWnd() ;
			UIUtil.alignStageCenter(_createwnd);
			_createwnd.show() ;
		}
		
		override protected function onShow():void{
			GuildProxy.cs_listguild( 0, PAGE_SIZE );
		}
	}
}
