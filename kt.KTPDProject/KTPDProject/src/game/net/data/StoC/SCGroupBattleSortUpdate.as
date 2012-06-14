package game.net.data.StoC {
	/**
	 * Server to Client 协议号0xC9
	 **/
	import com.protobuf.*;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	import game.net.data.StoC.GroupBattleSortData;
	public dynamic final class SCGroupBattleSortUpdate extends com.protobuf.Message {
		 /**
		  *@sortList   sortList
		  **/
		public var sortList:Vector.<GroupBattleSortData> = new Vector.<GroupBattleSortData>();

		override public final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			sortList = new Vector.<GroupBattleSortData>();

			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					sortList.push(com.protobuf.ReadUtils.read$TYPE_MESSAGE(input, new game.net.data.StoC.GroupBattleSortData()));
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
