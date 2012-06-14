package game.net.data.StoC {
	/**
	 * Server to Client 协议号0xD8
	 **/
	import com.protobuf.*;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	public dynamic final class SCLoopQuestSubmitRes extends com.protobuf.Message {
		 /**
		  *@preQuestId   preQuestId
		  **/
		public var preQuestId:uint;

		 /**
		  *@leftNum   leftNum
		  **/
		public var leftNum:uint;

		 /**
		  *@questId   questId
		  **/
		private var questId$field:uint;

		private var hasField$0:uint = 0;

		public function removeQuestId():void {
			hasField$0 &= 0xfffffffe;
			questId$field = new uint();
		}

		public function get hasQuestId():Boolean {
			return (hasField$0 & 0x1) != 0;
		}

		public function set questId(value:uint):void {
			hasField$0 |= 0x1;
			questId$field = value;
		}

		public function get questId():uint {
			return questId$field;
		}

		 /**
		  *@awardExp   awardExp
		  **/
		private var awardExp$field:uint;

		public function removeAwardExp():void {
			hasField$0 &= 0xfffffffd;
			awardExp$field = new uint();
		}

		public function get hasAwardExp():Boolean {
			return (hasField$0 & 0x2) != 0;
		}

		public function set awardExp(value:uint):void {
			hasField$0 |= 0x2;
			awardExp$field = value;
		}

		public function get awardExp():uint {
			return awardExp$field;
		}

		 /**
		  *@awardProf   awardProf
		  **/
		private var awardProf$field:uint;

		public function removeAwardProf():void {
			hasField$0 &= 0xfffffffb;
			awardProf$field = new uint();
		}

		public function get hasAwardProf():Boolean {
			return (hasField$0 & 0x4) != 0;
		}

		public function set awardProf(value:uint):void {
			hasField$0 |= 0x4;
			awardProf$field = value;
		}

		public function get awardProf():uint {
			return awardProf$field;
		}

		 /**
		  *@awardSilver   awardSilver
		  **/
		private var awardSilver$field:uint;

		public function removeAwardSilver():void {
			hasField$0 &= 0xfffffff7;
			awardSilver$field = new uint();
		}

		public function get hasAwardSilver():Boolean {
			return (hasField$0 & 0x8) != 0;
		}

		public function set awardSilver(value:uint):void {
			hasField$0 |= 0x8;
			awardSilver$field = value;
		}

		public function get awardSilver():uint {
			return awardSilver$field;
		}

		 /**
		  *@awardItem   awardItem
		  **/
		public var awardItem:Vector.<uint> = new Vector.<uint>();

		override public final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			var preQuestId$count:uint = 0;
			var leftNum$count:uint = 0;
			var questId$count:uint = 0;
			var awardExp$count:uint = 0;
			var awardProf$count:uint = 0;
			var awardSilver$count:uint = 0;
			awardItem = new Vector.<uint>();

			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					if (preQuestId$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCLoopQuestSubmitRes.preQuestId cannot be set twice.');
					}
					++preQuestId$count;
					preQuestId = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 3:
					if (leftNum$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCLoopQuestSubmitRes.leftNum cannot be set twice.');
					}
					++leftNum$count;
					leftNum = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 4:
					if (questId$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCLoopQuestSubmitRes.questId cannot be set twice.');
					}
					++questId$count;
					questId = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 5:
					if (awardExp$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCLoopQuestSubmitRes.awardExp cannot be set twice.');
					}
					++awardExp$count;
					awardExp = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 6:
					if (awardProf$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCLoopQuestSubmitRes.awardProf cannot be set twice.');
					}
					++awardProf$count;
					awardProf = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 7:
					if (awardSilver$count != 0) {
						throw new flash.errors.IOError('Bad data format: SCLoopQuestSubmitRes.awardSilver cannot be set twice.');
					}
					++awardSilver$count;
					awardSilver = com.protobuf.ReadUtils.read$TYPE_UINT32(input);
					break;
				case 8:
					if ((tag & 7) == com.protobuf.WireType.LENGTH_DELIMITED) {
						com.protobuf.ReadUtils.readPackedRepeated(input, com.protobuf.ReadUtils.read$TYPE_UINT32, awardItem);
						break;
					}
					awardItem.push(com.protobuf.ReadUtils.read$TYPE_UINT32(input));
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
