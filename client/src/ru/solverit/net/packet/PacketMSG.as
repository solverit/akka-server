package ru.solverit.net.packet {
	import com.netease.protobuf.*;
	use namespace com.netease.protobuf.used_by_generated_code;
	import com.netease.protobuf.fieldDescriptors.*;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.errors.IOError;
	import flash.utils.ByteArray;
	// @@protoc_insertion_point(imports)

	// @@protoc_insertion_point(class_metadata)
	public dynamic final class PacketMSG extends com.netease.protobuf.Message {
		/**
		 *  @private
		 */
		public static const TIME:FieldDescriptor$TYPE_INT64 = new FieldDescriptor$TYPE_INT64("ru.solverit.net.packet.PacketMSG.time", "time", (1 << 3) | com.netease.protobuf.WireType.VARINT);

		public var time:Int64;

		/**
		 *  @private
		 */
		public static const IDSESS:FieldDescriptor$TYPE_INT64 = new FieldDescriptor$TYPE_INT64("ru.solverit.net.packet.PacketMSG.idsess", "idsess", (2 << 3) | com.netease.protobuf.WireType.VARINT);

		public var idsess:Int64;

		/**
		 *  @private
		 */
		public static const PING:FieldDescriptor$TYPE_BOOL = new FieldDescriptor$TYPE_BOOL("ru.solverit.net.packet.PacketMSG.ping", "ping", (3 << 3) | com.netease.protobuf.WireType.VARINT);

		public var ping:Boolean;

		/**
		 *  @private
		 */
		public static const CMD:FieldDescriptor$TYPE_INT32 = new FieldDescriptor$TYPE_INT32("ru.solverit.net.packet.PacketMSG.cmd", "cmd", (4 << 3) | com.netease.protobuf.WireType.VARINT);

		private var cmd$field:int;

		private var hasField$0:uint = 0;

		public function clearCmd():void {
			hasField$0 &= 0xfffffffe;
			cmd$field = new int();
		}

		public function get hasCmd():Boolean {
			return (hasField$0 & 0x1) != 0;
		}

		public function set cmd(value:int):void {
			hasField$0 |= 0x1;
			cmd$field = value;
		}

		public function get cmd():int {
			return cmd$field;
		}

		/**
		 *  @private
		 */
		public static const DATA:FieldDescriptor$TYPE_BYTES = new FieldDescriptor$TYPE_BYTES("ru.solverit.net.packet.PacketMSG.data", "data", (5 << 3) | com.netease.protobuf.WireType.LENGTH_DELIMITED);

		private var data$field:flash.utils.ByteArray;

		public function clearData():void {
			data$field = null;
		}

		public function get hasData():Boolean {
			return data$field != null;
		}

		public function set data(value:flash.utils.ByteArray):void {
			data$field = value;
		}

		public function get data():flash.utils.ByteArray {
			return data$field;
		}

		/**
		 *  @private
		 */
		override com.netease.protobuf.used_by_generated_code final function writeToBuffer(output:com.netease.protobuf.WritingBuffer):void {
			com.netease.protobuf.WriteUtils.writeTag(output, com.netease.protobuf.WireType.VARINT, 1);
			com.netease.protobuf.WriteUtils.write$TYPE_INT64(output, this.time);
			com.netease.protobuf.WriteUtils.writeTag(output, com.netease.protobuf.WireType.VARINT, 2);
			com.netease.protobuf.WriteUtils.write$TYPE_INT64(output, this.idsess);
			com.netease.protobuf.WriteUtils.writeTag(output, com.netease.protobuf.WireType.VARINT, 3);
			com.netease.protobuf.WriteUtils.write$TYPE_BOOL(output, this.ping);
			if (hasCmd) {
				com.netease.protobuf.WriteUtils.writeTag(output, com.netease.protobuf.WireType.VARINT, 4);
				com.netease.protobuf.WriteUtils.write$TYPE_INT32(output, cmd$field);
			}
			if (hasData) {
				com.netease.protobuf.WriteUtils.writeTag(output, com.netease.protobuf.WireType.LENGTH_DELIMITED, 5);
				com.netease.protobuf.WriteUtils.write$TYPE_BYTES(output, data$field);
			}
			for (var fieldKey:* in this) {
				super.writeUnknown(output, fieldKey);
			}
		}

		/**
		 *  @private
		 */
		override com.netease.protobuf.used_by_generated_code final function readFromSlice(input:flash.utils.IDataInput, bytesAfterSlice:uint):void {
			var time$count:uint = 0;
			var idsess$count:uint = 0;
			var ping$count:uint = 0;
			var cmd$count:uint = 0;
			var data$count:uint = 0;
			while (input.bytesAvailable > bytesAfterSlice) {
				var tag:uint = com.netease.protobuf.ReadUtils.read$TYPE_UINT32(input);
				switch (tag >> 3) {
				case 1:
					if (time$count != 0) {
						throw new flash.errors.IOError('Bad data format: PacketMSG.time cannot be set twice.');
					}
					++time$count;
					this.time = com.netease.protobuf.ReadUtils.read$TYPE_INT64(input);
					break;
				case 2:
					if (idsess$count != 0) {
						throw new flash.errors.IOError('Bad data format: PacketMSG.idsess cannot be set twice.');
					}
					++idsess$count;
					this.idsess = com.netease.protobuf.ReadUtils.read$TYPE_INT64(input);
					break;
				case 3:
					if (ping$count != 0) {
						throw new flash.errors.IOError('Bad data format: PacketMSG.ping cannot be set twice.');
					}
					++ping$count;
					this.ping = com.netease.protobuf.ReadUtils.read$TYPE_BOOL(input);
					break;
				case 4:
					if (cmd$count != 0) {
						throw new flash.errors.IOError('Bad data format: PacketMSG.cmd cannot be set twice.');
					}
					++cmd$count;
					this.cmd = com.netease.protobuf.ReadUtils.read$TYPE_INT32(input);
					break;
				case 5:
					if (data$count != 0) {
						throw new flash.errors.IOError('Bad data format: PacketMSG.data cannot be set twice.');
					}
					++data$count;
					this.data = com.netease.protobuf.ReadUtils.read$TYPE_BYTES(input);
					break;
				default:
					super.readUnknown(input, tag);
					break;
				}
			}
		}

	}
}
