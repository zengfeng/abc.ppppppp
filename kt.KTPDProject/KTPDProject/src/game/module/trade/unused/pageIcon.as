package game.module.trade.unused
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import game.definition.UI;
	import gameui.containers.GPanel;
	import gameui.data.GPanelData;
	import gameui.manager.UIManager;
	import gameui.skin.SkinStyle;
	import net.AssetData;
	/**
	 * @author zheng
	 */



	public class pageIcon extends GPanel
	{
		  private var _iconid:int; 
		  private var _icontext:String;
		  private var _iconpageid:int;
		
         //id固定 为面板的唯一标示， text标示Id上面显示的东西
		
		public function pageIcon(icon_id:int,icon_text:String,icon_pageId:int=0) {
			
			_data = new GPanelData();
			
			_iconid=icon_id;
			
			_icontext=icon_text;
			
			_iconpageid=icon_pageId;
			
			initData();
			
			super(_data);
			
			initView();
			
			initEvent();
	}
	
	private function initData() : void {
				
	//		if(_iconid==5||_iconid==7||_iconid==8)
	//		{
			    _data.width = 45.5;			
			    _data.height = 20;
	//		}
	/*		else
			{
			     _data.width = 16;			
			     _data.height = 20;
			}
	*/		
			_data.bgAsset=new AssetData(SkinStyle.emptySkin);   //取消背景
		}

		private function initEvent() : void {
			
		}

		private function initView() : void {
	//		if(_iconid==5||_iconid==7||_iconid==8)
			{
				addBigIconBg();
				addTextField(_icontext, 45.5, 20);
			}
	/*		else
			{
				addSmallIconBg();
			    addTextField(_icontext, 16, 20);
			}
	*/				
		}
		
		public function refreshText(icon_text:String):void{
			     
				 textField.text=icon_text;
		}
				
		private function addSmallIconBg():void
		{
		   var pageBg:Sprite=UIManager.getUI(new AssetData(UI.TRADE_PAGE_BACKGRAND));
		   pageBg.width=15;
		   pageBg.height=19;
		   addChild(pageBg);
		}
		
		private function addBigIconBg():void
		{
		   var pageBg:Sprite=UIManager.getUI(new AssetData(UI.TRADE_NEWPAGE_BACKGRAND));
		   pageBg.width=45;
		   pageBg.height=19;
		   addChild(pageBg);
		   
		   if(_iconid==6)
		   {
			var pageBg1:Sprite=UIManager.getUI(new AssetData(UI.TRADE_PAGE_UP));
		   pageBg1.width=15;
		   pageBg1.height=7;
		   pageBg1.x=8;
		   pageBg1.y=6;
		   addChild(pageBg1);
		   }
		}
		   
		  private var textField:TextField;
		private function addTextField(text:String,width:int,height:int):void
		{		  
		   textField= new TextField();
           var format : TextFormat = new TextFormat();
            format.size = 12;
            format.color = 0x000000;
            textField.mouseEnabled = false;
            format.font = "黑体";
            textField.width = width;
            textField.height = height;
            textField.text = text;
			format.align = TextFormatAlign.CENTER;
            textField.defaultTextFormat = format;
            textField.x = 1;
            textField.y = 0;
            addChild(textField);
		}
		
		public function getIconId():int
		{
			return _iconid;
		}
		
		public function geticonpageid():int
		{
			return _iconpageid;
		}
  }
}
