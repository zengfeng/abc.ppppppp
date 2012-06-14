package game.net.data.StoC {
	/**
	 * Server to Client 协议号0x33
	 **/
	import com.protobuf.*;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	import game.net.data.StoC.SCNpcTrigger.NpcIterAct;
	public dynamic final class SCNpcTrigger extends com.protobuf.Message {
		 /**
		  *@npcId   npcId
		  **/
		public var npcId:uint;

		 /**
		  *@acts   acts
		  **/
		public var acts:Vector.<NpcIterAct> = new Vector.<NpcIterAct>();

		override public final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			var npcId$count:uint = 0;
			acts = new Vector.<NpcIterAct>();

			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					if (npcId$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCNpcTrigger.npcId cannot be set twice.');
					}
					++npcId$count;
					npcId = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 2:
					acts.push(com.protobuf.ReadUtils.read$TYPE_MESSAGE(input, new game.net.data.StoC.SCNpcTrigger.NpcIterAct()));
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
