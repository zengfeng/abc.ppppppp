package game.net.data.CtoS {
	/**
	 * Client to Server  协议号0x13
	 **/
	import com.protobuf.*;
	public dynamic final class CSProfLevelUp extends com.protobuf.Message {
		 /**
		  *@level   level
		  **/
		public var level:uint;

		
		override public final function writeToBuffer(output:com.protobuf.WritingBuffer):void {
			com.protobuf.WriteUtils.writeTag(output, com.protobuf.WireType.VARINT, 1);
			com.protobuf.WriteUtils.write$TYPE_UINT32(output, level);
			for (var fieldKey:* in this) {
				super.writeUnknown(output, fieldKey);
			}
		}

		
	}
}
