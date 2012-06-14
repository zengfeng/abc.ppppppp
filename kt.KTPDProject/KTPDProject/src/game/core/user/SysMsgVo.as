package game.core.user
{
	import game.manager.RSSManager;
	import game.module.quest.VoBase;
	import com.commUI.ScrollMessage;
	import com.commUI.alert.Alert;
	import com.utils.ColorUtils;
	import com.utils.StringUtils;

	import flash.events.Event;

	import game.core.item.Item;
	import game.core.item.ItemManager;
	import game.manager.ViewManager;
	import game.module.chat.ManagerChat;
	import game.module.quest.QuestUtil;
	import game.module.settings.SettingData;

	/**
	 * @author yangyiqiang
	 */
	public class SysMsgVo
	{
		public var id : int;

		/**
		 * 第16位表示弹框
		 *     弹框类型的对应（单选）和第16位组合
		 *     第1位表示错误浮动框
		 *     第2位表示玩家身上滚动内容
		 *     第3位表示只有<确定>按钮的框
		 *     第4位表示有<确定>、<取消>按钮的框
		 *     第5位表示有<确定>、<取消>、勾选（下次不再提示）的框
		 * 
		 * 第17位表示在聊天频道中显示
		 * 
		 * 第18位表示弹框大滚屏中显示
		 * 
		 * 第19位表示弹框跑马灯中显示
		 */
		public var type : int;

		public var text : String;

		public function prase(xml : XML) : void
		{
			if (xml.@id == undefined) return;
			id = xml.@id;
			type = xml.@type;
			text = xml.children();
			if (text == "") text = xml.@text;
		}

		/** 替换后的内容 */
		public function getContent(arg : *=null, arg2 : *=null) : String
		{
			var msg : String = this.text;
			var num : int = 0;
			if (arg != null)
				for each (var str:String in arg)
				{
					num++;
					msg = msg.replace(new RegExp("xx" + num, "g"), str);
				}
			num = 0;
			if (arg2 != null)
				for each (var numArg:int in arg2)
				{
					num++;
					msg = msg.replace(new RegExp("yy" + num, "g"), numArg);
				}
			return parseRegExpStr(msg);
		}

		/**
		 * 						         [1-19:heroColor]
		 * itemColor(1.白 2.绿 3.蓝)      [20:itemColor]
		 */
		public static function parseRegExpStr(str : String) : String
		{
			var repStr : String;
			var type : int;
			var targetStr : String;
			QuestUtil.reg.lastIndex = 0;
			var result : Array = QuestUtil.reg.exec(str);
			while (result && result.length > 1)
			{
				repStr = result[0];
				result = (result[1] as String).split(":");
				type = result[0];
				targetStr = result[1];
				switch(type)
				{
					case 20:
						var vo : Item = ItemManager.instance.newItem(Number(targetStr));
						if (!vo)
							str = str.replace(repStr, StringUtils.addColor("不认识的物品", "#ff0000"));
						else
							str = str.replace(repStr, vo.htmlName);
						break;
					case 21:
						var npc :VoBase =RSSManager.getInstance().getNpcById((Number(targetStr)));
						if (!npc)
							str = str.replace(repStr, StringUtils.addColor("不认识的怪物", "#ff0000"));
						else
							str = str.replace(repStr, StringUtils.addColorById(npc.name,2));
						break;
					case 22:
						vo  = ItemManager.instance.newItem(Number(targetStr));
						if (!vo)
							str = str.replace(repStr, StringUtils.addColor("不认识的物品", "#ff0000"));
						else
							str = str.replace(repStr, vo.name);
						break;
					break;
					default:
						str = str.replace(repStr, StringUtils.addColor(targetStr, ColorUtils.TEXTCOLOR[type + 1]));
						break;
				}
				result = QuestUtil.reg.exec(str);
			}
			return str;
		}

		/**
		 * type = 0 则用sysmsg 里面的type运行
		 * 其它用传过来的类型滚
		 * <msg id="154" type="147456" name="MSG_154" text="消耗xx1元宝" description="通用-消耗元宝"/>
		<msg id="155" type="147456" name="MSG_155" text="消耗xx1绑元宝" description="通用-消耗绑元宝"/>
		<msg id="156" type="147456" name="MSG_156" text="消耗xx1银币" description="通用-消耗银币"/>
		<msg id="157" type="147456" name="MSG_157" text="消耗xx1修为" description="通用-消耗修为"/>
		<msg id="158" type="147456" name="MSG_158" text="获得xx1经验" description="通用-获得经验（大滚屏）"/>
		<msg id="159" type="147456" name="MSG_159" text="获得xx1元宝" description="通用-获得元宝（大滚屏）"/>
		<msg id="160" type="147456" name="MSG_160" text="获得xx1绑元宝" description="通用-获得绑元宝（大滚屏）"/>
		<msg id="161" type="135170" name="MSG_161" text="获得xx1银币" description="通用-获得银币（身上）"/>
		<msg id="162" type="147456" name="MSG_162" text="获得xx1修为" description="通用-获得修为（大滚屏）"/>
		 */
		public function runMsg(arg : *=null, yesFun : Function = null, arg2 : *=null, type : uint = 0) : Alert
		{
			var msg : String = getContent(arg, arg2);
			var alert : Alert;
			if (type == 0) type = this.type;
			if ((type & 0x1000) == 0x1000)
			{
				var num : int = type & 0xFFF;
				switch(num)
				{
					case 1:
						ScrollMessage.instance.soroll(msg);
						break;
					case 2:
						ScrollMessage.instance.sorollOnMyAvatar(msg);
						break;
					case 4:
						alert = Alert.show(msg, "", Alert.OK);
						break;
					case 8:
						alert = Alert.show(msg, "", Alert.OK | Alert.CANCEL, yesFun);
						break;
					case 16:
						// 带确定，取消，勾选
						if (SettingData.getDataById(id))
							yesFun(Alert.OK_EVENT);
						else
						{
							alert = Alert.show(msg, "", Alert.OK | Alert.CANCEL, yesFun, Alert.RADIO);
							alert.addEventListener(Alert.CLOSE_EVENT, onClose);
						}
						break;
				}
			}
			// 聊天提示
			if ((type & 0x2000) == 0x2000)
			{
				ManagerChat.instance.prompt(msg, true);
			}
			// 大滚屏
			if ((type & 0x4000) == 0x4000)
			{
				ViewManager.instance.rollMessage(msg);
			}
			// 跑马灯
			if ((type & 0x8000) == 0x8000)
			{
			}
			// 在mouse坐标 滚屏
			if ((type & 0x10000) == 0x10000)
			{
				ScrollMessage.instance.sorollMssage(msg);
			}
			// 聊天系统
			if ((type & 0x20000) == 0x20000)
			{
				ManagerChat.instance.system(msg, true);
			}
			// 在身上滚
			if ((type & 0x40000) == 0x40000)
			{
				ScrollMessage.instance.sorollOnMyAvatar(addColor(id, msg, 0x40000));
			}
			// 聊天系统通告
			if ((type & 0x40000) == 0x40000)
			{
				ManagerChat.instance.system(msg);
			}
			// 聊天家族
			if ((type & 0x80000) == 0x80000)
			{
				ManagerChat.instance.system(msg);
			}
			return alert;
		}

		/**
		 *  * <msg id="154" type="147456" name="MSG_154" text="消耗xx1元宝" description="通用-消耗元宝"/>
		<msg id="155" type="147456" name="MSG_155" text="消耗xx1绑元宝" description="通用-消耗绑元宝"/>
		<msg id="156" type="147456" name="MSG_156" text="消耗xx1银币" description="通用-消耗银币"/>
		<msg id="157" type="147456" name="MSG_157" text="消耗xx1修为" description="通用-消耗修为"/>
		<msg id="158" type="147456" name="MSG_158" text="获得xx1经验" description="通用-获得经验（大滚屏）"/>
		<msg id="159" type="147456" name="MSG_159" text="获得xx1元宝" description="通用-获得元宝（大滚屏）"/>
		<msg id="160" type="147456" name="MSG_160" text="获得xx1绑元宝" description="通用-获得绑元宝（大滚屏）"/>
		<msg id="161" type="135170" name="MSG_161" text="获得xx1银币" description="通用-获得银币（身上）"/>
		<msg id="162" type="147456" name="MSG_162" text="获得xx1修为" description="通用-获得修为（大滚屏）"/>
		 * 
		 * 
		<msg id="270" type="147456" name="MSG_270" text="获得xx1银币" description="通用-获得银币（大滚屏）"/>
		<msg id="271" type="196608" name="MSG_271" text="获得获得xx1×xx2" description="通用-获得物品（鼠标处显示）"/>
		<msg id="272" type="135170" name="MSG_272" text="获得xx1元宝" description="通用-获得元宝（身上滚）"/>
		<msg id="273" type="135170" name="MSG_273" text="获得xx1绑元宝" description="通用-获得绑元宝（身上滚）"/>
		<msg id="274" type="135170" name="MSG_274" text="获得xx1修为" description="通用-获得修为（身上滚）"/>
		<msg id="275" type="147456" name="MSG_275" text="获得xx1修为" description="通用-获得修为（大滚屏）"/>
		<msg id="276" type="135170" name="MSG_276" text="获得xx1修为" description="通用-获得修为（身上滚）"/>
		<msg id="277" type="196608" name="MSG_277" text="获得xx1银币" description="通用-获得银币（鼠标滚）"/>
		 */
		private function addColor(id : int, msg : String, type : int = 0x40000) : String
		{
			if (type != 0x40000) return msg;
			switch(id)
			{
				case 154:
				case 159:
				case 272:
				case 155:
				case 160:
				case 273:
				case 272:
					msg = StringUtils.addColorById(msg, ColorUtils.YELLOW);
					/** 元宝 **/
					break;
				case 156:
				case 161:
				case 270:
					break;
				case 157:
				case 162:
				case 274:
				case 275:
				case 276:
					msg = StringUtils.addColorById(msg, ColorUtils.ORANGE);
					/** 修为 **/
					break;
				case 17:
				case 20:
					msg = StringUtils.addColorById(msg, ColorUtils.GREEN);
					/** 经验 **/
					break;
			}
			return msg;
		}

		private function onClose(event : Event) : void
		{
			SettingData.setDataById(id, (event.target as Alert).selected);
		}
	}
}