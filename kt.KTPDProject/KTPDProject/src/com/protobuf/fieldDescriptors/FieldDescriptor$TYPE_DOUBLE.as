// vim: tabstop=4 shiftwidth=4
// Copyright (c) 2011 , Yang Bo All rights reserved.
//
// Author: Yang Bo (pop.atry@gmail.com)
//
// Use, modification and distribution are subject to the "New BSD License"
// as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.
package com.protobuf.fieldDescriptors {
	import com.protobuf.*

	import flash.utils.*

	public final class FieldDescriptor$TYPE_DOUBLE extends
	FieldDescriptor {
		public function FieldDescriptor$TYPE_DOUBLE(fullName : String, name : String, tag : uint) {
			this.fullName = fullName;
			this.name = name;
			this.tag = tag;
		}

		override public function get type() : Class {
			return Number;
		}

		override public function readSingleField(input : IDataInput) : * {
			return ReadUtils.read$TYPE_DOUBLE(input);
		}

		override public function writeSingleField(output : WritingBuffer, value : *) : void {
			WriteUtils.write$TYPE_DOUBLE(output, value);
		}
	}
}
