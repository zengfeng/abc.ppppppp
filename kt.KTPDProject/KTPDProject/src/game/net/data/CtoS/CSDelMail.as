package game.net.data.CtoS {
	/**
	 * Client to Server  协议号0xA4
	 **/
	import com.protobuf.*;
	public dynamic final class CSDelMail extends com.protobuf.Message {
		 /**
		  *@idlist   idlist
		  **/
		public var idlist:Vector.<uint> = new Vector.<uint>();

		
		override public final function writeToBuffer(output:com.protobuf.WritingBuffer):void {
			for (var idlistIndex:uint = 0; idlistIndex < idlist.length; ++idlistIndex) {
				com.protobuf.WriteUtils.writeTag(output, com.protobuf.WireType.VARINT, 1);
				com.protobuf.WriteUtils.write$TYPE_UINT32(output, idlist[idlistIndex]);
			}
			for (var fieldKey:* in this) {
				super.writeUnknown(output, fieldKey);
			}
		}

		
	}
}
