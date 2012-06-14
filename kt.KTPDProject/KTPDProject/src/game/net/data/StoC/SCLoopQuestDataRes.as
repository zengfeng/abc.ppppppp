package game.net.data.StoC {
	/**
	 * Server to Client 协议号0xD7
	 **/
	import com.protobuf.*;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	public dynamic final class SCLoopQuestDataRes extends com.protobuf.Message {
		 /**
		  *@leftNum   leftNum
		  **/
		public var leftNum:uint;

		 /**
		  *@maxNum   maxNum
		  **/
		public var maxNum:uint;

		 /**
		  *@questId   questId
		  **/
		public var questId:Vector.<uint> = new Vector.<uint>();

		 /**
		  *@quality   quality
		  **/
		public var quality:Vector.<uint> = new Vector.<uint>();

		 /**
		  *@nextNum   nextNum
		  **/
		public var nextNum:uint;

		 /**
		  *@nextTime   nextTime
		  **/
		public var nextTime:uint;

		override public final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			var leftNum$count:uint = 0;
			var maxNum$count:uint = 0;
			questId = new Vector.<uint>();

			quality = new Vector.<uint>();

			var nextNum$count:uint = 0;
			var nextTime$count:uint = 0;
			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					if (leftNum$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCLoopQuestDataRes.leftNum cannot be set twice.');
					}
					++leftNum$count;
					leftNum = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 2:
					if (maxNum$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCLoopQuestDataRes.maxNum cannot be set twice.');
					}
					++maxNum$count;
					maxNum = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 3:
					if ((tag & 7) == com.protobuf.WireType.LENGTH_DELIMITED) {
						com.protobuf.ReadUtils.readPackedRepeated(input, com.protobuf.ReadUtils.read$TYPE_UINT32, questId);
						break;
					}
					questId.push(com.protobuf.ReadUtils.read$TYPE_UINT32(input));
					break;
				case 6:
					if ((tag & 7) == com.protobuf.WireType.LENGTH_DELIMITED) {
						com.protobuf.ReadUtils.readPackedRepeated(input, com.protobuf.ReadUtils.read$TYPE_UINT32, quality);
						break;
					}
					quality.push(com.protobuf.ReadUtils.read$TYPE_UINT32(input));
					break;
				case 7:
					if (nextNum$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCLoopQuestDataRes.nextNum cannot be set twice.');
					}
					++nextNum$count;
					nextNum = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 9:
					if (nextTime$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCLoopQuestDataRes.nextTime cannot be set twice.');
					}
					++nextTime$count;
					nextTime = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
