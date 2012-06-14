package game.net.core
{
	import gameui.manager.UIManager;

	import log4a.Logger;

	import com.protobuf.Message;

	import flash.utils.ByteArray;



	/**
	 */
	public class RequestData
	{
		private var _msgCmd : int;

		private var _args : *;

		public function RequestData(msgCmd : int, args : *)
		{
			_msgCmd = msgCmd;
			_args = args;
		}

		public function get method() : int
		{
			return _msgCmd;
		}

		public function get args() : *
		{
			return _args;
		}

		public function toString() : String
		{
			return "MsgCmd=" + _msgCmd + "ByteArray=" + String(_args);
		}

		public static function parse(value : ByteArray) : RequestData
		{
			if (value == null)
			{
				return null;
			}
			var msgCmd : uint = value.readUnsignedShort();
			if (msgCmd != 32)
				Logger.debug("接收到==>msgCmd=0x" + msgCmd.toString(16));
			try
			{
				var _class : Message = new (UIManager.appDomain.getDefinition(Common.messageDic[msgCmd]) as Class) as Message;
			}
			catch(e : Error)
			{
				Logger.error("Request::parse解析消息出错！0x" + msgCmd.toString(16));
			}
			if (!_class) return null;
			_class.readFromSlice(value, 0);
			return new RequestData(msgCmd, _class);
		}
	}
}
