package game.net.data.CtoS {
	/**
	 * Client to Server  协议号0x88
	 **/
	import com.protobuf.*;
	public dynamic final class CSQueryDemon extends com.protobuf.Message {
		 /**
		  *@demonId   demonId
		  **/
		public var demonId:uint;

		
		override public final function writeToBuffer(output:com.protobuf.WritingBuffer):void {
			com.protobuf.WriteUtils.writeTag(output, com.protobuf.WireType.VARINT, 1);
			com.protobuf.WriteUtils.write$TYPE_UINT32(output, demonId);
			for (var fieldKey:* in this) {
				super.writeUnknown(output, fieldKey);
			}
		}

		
	}
}
