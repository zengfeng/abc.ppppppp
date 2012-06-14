package game.net.data.StoC {
	/**
	 * Server to Client 协议号0x2C8
	 **/
	import com.protobuf.*;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	public dynamic final class SCGuildInvite extends com.protobuf.Message {
		 /**
		  *@gid   gid
		  **/
		public var gid:uint;

		 /**
		  *@gname   gname
		  **/
		public var gname:String;

		 /**
		  *@iname   iname
		  **/
		public var iname:String;

		override public final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			var gid$count:uint = 0;
			var gname$count:uint = 0;
			var iname$count:uint = 0;
			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					if (gid$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCGuildInvite.gid cannot be set twice.');
					}
					++gid$count;
					gid = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 2:
					if (gname$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCGuildInvite.gname cannot be set twice.');
					}
					++gname$count;
					gname = com.protobuf.ReadUtils.read$TYPE_STRING(input);
					break;
				case 3:
					if (iname$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCGuildInvite.iname cannot be set twice.');
					}
					++iname$count;
					iname = com.protobuf.ReadUtils.read$TYPE_STRING(input);
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
