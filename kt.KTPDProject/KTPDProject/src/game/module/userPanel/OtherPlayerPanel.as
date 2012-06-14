package game.module.userPanel
{
	import game.manager.ViewManager;
	import game.module.chatwhisper.ManagerWhisper;
	import game.module.friend.ManagerFriend;
	import game.net.core.Common;
	import game.net.data.CtoS.CSOtherInfo;

	import gameui.containers.GPanel;
	import gameui.controls.GImage;
	import gameui.controls.GLabel;
	import gameui.core.GAlign;
	import gameui.data.GImageData;
	import gameui.data.GLabelData;
	import gameui.data.GPanelData;
	import gameui.layout.GLayout;
	import gameui.manager.UIManager;

	import net.AssetData;

	import com.utils.StringUtils;
	import com.utils.UrlUtils;

	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;





	/**
	 * @author yangyiqiang
	 */
	public class OtherPlayerPanel extends GPanel
	{
		public function OtherPlayerPanel()
		{
			_data = new GPanelData();
			_data.parent = ViewManager.instance.uiContainer;
			_data.bgAsset = new AssetData("PlayerHeadPhoto_Bg_TargetPlayer");
			_data.width = 255;
			_data.height = 100;
			super(_data);
			initView();
		}

		private var _userHead : GImage ;

		private var _jobImg : Sprite;

		private var _name : GLabel;

		private var _level : GLabel;

		private var _lookMessage : TextField;

		private var _sendMessage : TextField;

		private var _addFriend : TextField;

		private function initView() : void
		{
			var _imgData : GImageData = new GImageData();
			_imgData.x = 13;
			_imgData.y = -2;
			_imgData.iocData.align = new GAlign(0,0);
			_userHead = new GImage(_imgData);
			add(_userHead);
			var bag : Sprite = UIManager.getUI(new AssetData("PlayerHeadPhoto_Fg"));
			bag.y = 10;
			add(bag);
			_jobImg = UIManager.getUI(new AssetData("PlayerHeadPhoto_JobName_1"));
			_jobImg.y = 40;
			add(_jobImg);
			var data : GLabelData = new GLabelData();
			data.textColor = 0xffcc00;
			data.textFormat = UIManager.getTextFormat(16);
			data.textFormat.align = TextFormatAlign.CENTER;
			data.x = 100;
			data.y = 10;
			_name = new GLabel(data);
			addChild(_name);

			data = data.clone();
			data.x = -4;
			data.y = 10;
			data.width = 30;
			data.text = String(10);
			data.textFormat.align = TextFormatAlign.CENTER;
			_level = new GLabel(data);
			addChild(_level);

			_lookMessage = UIManager.getTextField();
			_lookMessage.width = 100;
			_lookMessage.height = 20;
			_lookMessage.htmlText = StringUtils.addEvent(StringUtils.addLine(StringUtils.addColor("查看资料","#FFE400")),"lookMessage");
			_lookMessage.addEventListener(TextEvent.LINK,onLink);
			addChild(_lookMessage);
			_lookMessage.x = 114;
			_lookMessage.y = 30;

			_sendMessage = UIManager.getTextField();
			_sendMessage.width = 100;
			_sendMessage.height = 20;
			_sendMessage.htmlText = StringUtils.addEvent(StringUtils.addLine(StringUtils.addColor("发送私聊","#FFE400")),"sendMessage");
			_sendMessage.addEventListener(TextEvent.LINK,onLink);
			addChild(_sendMessage);
			_sendMessage.x = 180;
			_sendMessage.y = 50;

			_addFriend = UIManager.getTextField();
			_addFriend.width = 100;
			_addFriend.height = 20;
			_addFriend.htmlText = StringUtils.addEvent(StringUtils.addLine(StringUtils.addColor("加为知己","#FFE400")),"friend");
			_addFriend.addEventListener(TextEvent.LINK,onLink);
			addChild(_addFriend);
			_addFriend.x = 180;
			_addFriend.y = 30;
		}

		override public function set source(value : *) : void
		{
			if (!value||!_name) return;
			_name.text = value["name"];
			_userHead.url = UrlUtils.getPlayerHeadPhotoByHeroId(value["heroId"]);
			_level.text=value["level"];
			super.source = value;
		}

		override public function show() : void
		{
			_lookMessage.addEventListener(TextEvent.LINK,onLink);
			_sendMessage.addEventListener(TextEvent.LINK,onLink);
			_addFriend.addEventListener(TextEvent.LINK,onLink);
			this.align = new GAlign(-1,-1,0,-1,0);
			super.show();
			GLayout.layout(this);
		}

		override public function hide() : void
		{
			_lookMessage.removeEventListener(TextEvent.LINK,onLink);
			_sendMessage.removeEventListener(TextEvent.LINK,onLink);
			_addFriend.removeEventListener(TextEvent.LINK,onLink);
			super.hide();
		}

		private function onLink(event : TextEvent) : void
		{
			if (event.text == "lookMessage")
			{
				var msg:CSOtherInfo = new CSOtherInfo();
				msg.name = _source["name"];
				Common.game_server.sendMessage(0x14, msg);
			}
			else if (event.text == "sendMessage")
			{
				ManagerWhisper.instance.showWindowByPlayerName(_name.text);
			}
			else if (event.text == "friend")
			{
				ManagerFriend.getInstance().addFriendByPlayerName(_name.text);
			}
		}
	}
}
