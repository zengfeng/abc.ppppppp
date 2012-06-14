package game.module.trade.unused
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import gameui.containers.GPanel;
	import gameui.data.GPanelData;
	import gameui.skin.SkinStyle;
	import net.AssetData;



	/**
	 * @author zheng
	 */
	public class pageItem extends GPanel
	{
		private var _itemCount : int;
		private static var currentID : int = 0;
		private static var currentPosition : int = 0;

		// 根据ItemCount既页数的多少自动生成Page控件
		public function pageItem(item_Count : int)
		{
			_data = new GPanelData();

			_itemCount = item_Count;

			initData();

			super(_data);

			initView();

			initEvent();
		}

		private function initData() : void
		{
			_data.width = 400;

			_data.height = 20;

			_data.bgAsset = new AssetData(SkinStyle.emptySkin);
			// 取消背景
		}

		private function initEvent() : void
		{
		}

		private function initView() : void
		{
			// addPageBg();

			addIconPanel();
			currentID = 1;
			currentPosition = 1;
			// refreshIconPanel(1,3);
		}

		private var _panelList : GPanel;
		private var _iconItems : Array = new Array();
		private var _iconItem : pageIcon;
		private var _lastIconItem : pageIcon;
		private var _nextIconItem : pageIcon;
		private var _upIconItem : pageIcon;

		private function addIconPanel() : void     // 开始的ID号 换整个结构时的currentID 即当前选中Id.
		{
			var vx : int = 0;
			_iconItem = new pageIcon(5, "第1页");
			_iconItem.addEventListener(MouseEvent.CLICK, onClick);
			_content.addChild(_iconItem);

			_upIconItem = new pageIcon(6, "");
			_upIconItem.x = 48 + 51 * vx;
			_upIconItem.addEventListener(MouseEvent.CLICK, onClick);
			_content.addChild(_upIconItem);
			vx++;

			for (var i : int = 1;i < 5;i++)
			{
				_iconItem = new pageIcon(i, i.toString(), i);
				_iconItem.x = 48 + 51 * vx;
				_iconItem.addEventListener(MouseEvent.CLICK, onClick);
				_content.addChild(_iconItem);
				_iconItems.push(_iconItem);
				vx++;
			}

			_lastIconItem = new pageIcon(7, "..." + _itemCount.toString());
			_lastIconItem.x = 48 + 51 * vx;
			_lastIconItem.addEventListener(MouseEvent.CLICK, onClick);
			_content.addChild(_lastIconItem);

			_nextIconItem = new pageIcon(8, "下一页");
			_nextIconItem.x = 48 + 51 * vx + 51;
			_nextIconItem.addEventListener(MouseEvent.CLICK, onClick);
			_content.addChild(_nextIconItem);

			(_iconItems[0] as pageIcon).filters = [new GlowFilter(0x00CC00)];

			refreshIconPanel(1, 3);

			if (currentID == _itemCount)
			{
				_nextIconItem.enabled = false;
			}

			if (currentID == 1)
			{
				_upIconItem.enabled = false;
			}
		}

		private function addIcon(_data : GPanelData) : void
		{
			_data.bgAsset = new AssetData(SkinStyle.emptySkin);
			// 取消背景
			_panelList = new GPanel(_data);
			_panelList.addEventListener(MouseEvent.CLICK, onClick);
			_content.addChild(_panelList);
		}

		private var _pageIcon1 : pageIcon;

		private function onClick(event : Event) : void
		{
			_pageIcon1 = event.currentTarget as pageIcon;
			var function_id : int = _pageIcon1.getIconId();

			_nextIconItem.enabled = true;
			_upIconItem.enabled = true;

			if (function_id == 2 || function_id == 3)
			{
				(_iconItems[currentPosition - 1] as pageIcon).filters = [];
				currentID = currentID + function_id - currentPosition;
				currentPosition = function_id;
				(_iconItems[currentPosition - 1] as pageIcon).filters = [new GlowFilter(0x00CC00)];
			}
			else if (function_id == 4)
			{
				currentID = currentID + function_id - currentPosition;
				if (currentID == _itemCount)
				{
					(_iconItems[currentPosition - 1] as pageIcon).filters = [];
					_nextIconItem.enabled = false;
					currentPosition = 4;
					(_iconItems[currentPosition - 1] as pageIcon).filters = [new GlowFilter(0x00CC00)];
				}
				else
				{
					_nextIconItem.enabled = true;
					(_iconItems[currentPosition - 1] as pageIcon).filters = [];
					refreshIconPanel(currentID, 1);
					currentPosition = function_id - 2;
					(_iconItems[currentPosition - 1] as pageIcon).filters = [new GlowFilter(0x00CC00)];
				}
			}
			else if (function_id == 1)
			{
				currentID = currentID + function_id - currentPosition;
				(_iconItems[currentPosition - 1] as pageIcon).filters = [];
				if (currentID == 1)
				{
					currentPosition = 1;
					_upIconItem.enabled = false;
				}
				else
				{
					(_iconItems[currentPosition - 1] as pageIcon).filters = [];
					currentPosition = 3;
					refreshIconPanel(currentID, 2);
				}
				(_iconItems[currentPosition - 1] as pageIcon).filters = [new GlowFilter(0x00CC00)];
			}
			else if (function_id == 8)
			{
				if (currentID == _itemCount)
				{
					_nextIconItem.enabled = false;
				}
				else
				{
					currentID++;
					if (currentID == _itemCount)
					{
						_nextIconItem.enabled = false;
						(_iconItems[currentPosition - 1] as pageIcon).filters = [];
						currentPosition++;
						(_iconItems[currentPosition - 1] as pageIcon).filters = [new GlowFilter(0x00CC00)];
					}
					else
					{
						(_iconItems[currentPosition - 1] as pageIcon).filters = [];
						if (currentPosition == 3)
						{
							refreshIconPanel(currentID, 1);
							currentPosition = 2;
						}
						else
						{
							currentPosition++;
						}

						(_iconItems[currentPosition - 1] as pageIcon).filters = [new GlowFilter(0x00CC00)];
					}
				}
			}
			else if (function_id == 7)
			{
				(_iconItems[currentPosition - 1] as pageIcon).filters = [];
				currentID = _itemCount;
				// 选中最后
				refreshIconPanel(currentID, 4);
				// 刷几到几
				currentPosition = 4;

				(_iconItems[currentPosition - 1] as pageIcon).filters = [new GlowFilter(0x00CC00)];

				if (currentID == _itemCount)
				{
					_nextIconItem.enabled = false;
				}
			}
			else if (function_id == 5)
			{
				(_iconItems[currentPosition - 1] as pageIcon).filters = [];
				currentPosition = 1;
				currentID = 1;
				if (_itemCount <= 4)
				{
				}
				else
				{
					refreshIconPanel(currentID, 3);
					// 刷几到几
				}
				(_iconItems[currentPosition - 1] as pageIcon).filters = [new GlowFilter(0x00CC00)];
			}
			else if (function_id == 6)
			{
				if (currentID == 1)
				{
					_upIconItem.enabled = false;
				}
				else
				{
					(_iconItems[currentPosition - 1] as pageIcon).filters = [];
					currentID--;
					if (currentID == 1)
					{
						_upIconItem.enabled = false;
						currentPosition--;
					}
					else
					{
						if (currentPosition == 2)
						{
							refreshIconPanel(currentID, 2);
							currentPosition = 2;
						}
						else
						{
							currentPosition--;
						}
					}
					(_iconItems[currentPosition - 1] as pageIcon).filters = [new GlowFilter(0x00CC00)];
				}
			}

			var myEvent : Event = new Event("itemClickEvent");
			dispatchEvent(myEvent);
		}
	
		//refreshtype 1表示+2 2表示-2 3刷1234 4刷5678 5表示毛都不搞
		private function refreshIconPanel(CurrentSelectId:int,refresh_type:int) : void {	
			var i:int=0;
			if(_itemCount>4)
			{
	          
			  
			  if(refresh_type==3)
	          {
		       for(i=0;i<4;i++)
			
			   {
				
		    	(_iconItems[i] as pageIcon).refreshText((i+1).toString());
			   }
			   
			  } 
			    
				else if(refresh_type==5)
				{
				 (_iconItems[7] as pageIcon).refreshText(_itemCount.toString());
				}
				
				else if(refresh_type==4)
			   {
			   	 var j:int=CurrentSelectId-3;
			    
				 for(i=0;i<4;i++)			
			      {
		    	   (_iconItems[i] as pageIcon).refreshText(j.toString());
			           j++;
				  }
			   }
			   
			   
			   else if(refresh_type==1)
			   {
			       j=CurrentSelectId-1;
			     for(i=0;i<4;i++)			
			      {
					var k:int=j;
		    	   (_iconItems[i] as pageIcon).refreshText(k.toString());
				    j++;
			      }
			   }
			   
			   			  
			 else if(refresh_type==2)
			   {
			   	j=CurrentSelectId-2;
			     for(i=0;i<4;i++)			
			      {
		    	     (_iconItems[i] as pageIcon).refreshText(j.toString());
					 j++;
			      }
			   }
			   
		    }
		
		else if(_itemCount==4)
		{
			//[_iconItems[] as pageIcon] 	
			_lastIconItem.hide();
			_nextIconItem.x=_nextIconItem.x-51;
			
		}
		
		else if(_itemCount<4)
		{
		   _lastIconItem.hide();
		   for(i=_itemCount;i<4;i++)
		   {
			  (_iconItems[i] as pageIcon).hide();
		   }
		    _nextIconItem.x=_nextIconItem.x-(4-_itemCount)*51-51;
		}
					
		}	
		
		public function refershTotel(totle:int):void
		{
			_itemCount=totle;
			refreshIconPanel(currentID, 5);
		}
		
		public function getCurrentID():int
		{
			return currentID;
		}			
	}
}
