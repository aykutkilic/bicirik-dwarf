package com.bicirikdwarf.utils;

import java.io.PrintWriter;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class ElfUtils {

	public static PrintWriter debugLog = null;

	public static boolean debugging() {
		return debugLog != null;
	}

	public static void log(String line) {
		if (debugLog != null)
			debugLog.println(line);
	}

	/**
	 * Parses next null-terminated string.
	 */
	public static String getNTString(ByteBuffer buffer) {
		StringBuilder result = new StringBuilder();
		while (buffer.remaining() > 0) {
			char c = (char) buffer.get();
			if (c == '\0')
				break;
			result.append(c);
		}

		return result.toString();
	}

	public static void dumpNextNBytes(ByteBuffer buffer, int n) {
		if (!debugging())
			return;

		int oldPosition = buffer.position();

		byte[] bytesToRead = new byte[Math.min(buffer.remaining(), n)];

		buffer.get(bytesToRead);
		log(Integer.toHexString(oldPosition) + "  " + getHexString(bytesToRead));
		buffer.position(oldPosition);
	}

	public static String getHexString(byte[] data) {
		StringBuilder result = new StringBuilder();

		for (byte b : data) {
			result.append(String.format("%02X", b));
		}

		return result.toString();
	}

	/**
	 * Please note that this moves the source buffer forward.
	 * 
	 * @param source
	 * @param count
	 * @return
	 */
	public static ByteBuffer getByteBuffer(ByteBuffer source, int count) {
		byte[] data = new byte[count];
		source.get(data);
		ByteBuffer result = ByteBuffer.wrap(data);
		result.order(source.order());
		return result;
	}

	public static ByteBuffer cloneSection(ByteBuffer source, int start, int count) {
		int oldPosition = source.position();
		source.position(start);
		ByteBuffer result = source.slice();
		result.order(source.order());
		result.limit(count);
		source.position(oldPosition);
		return result;
	}

	/**
	 * @return Little endian byte array
	 */
	public static byte[] getLEArray(ByteBuffer buffer, int count) {
		byte[] result = new byte[count];

		for (int i = 0; i < count; i++) {
			byte val = buffer.get();

			if (buffer.order() == ByteOrder.BIG_ENDIAN)
				result[count - 1 - i] = val;
			else
				result[i] = val;
		}

		return result;
	}

	public static Integer toInteger(byte[] array) {
		Integer result = 0;

		for (int i = 0; i < array.length; i++)
			result = (result << 8) | array[i];

		return result;
	}

	public static Long toLong(byte[] array) {
		Long result = 0l;

		for (int i = 0; i < array.length; i++)
			result = (result << 8) | array[i];

		return result;
	}

	public static Long toLong(ByteBuffer buffer) {
		switch (buffer.remaining()) {
		case 1:
			return (long) Unsigned.getU8(buffer);
		case 2:
			return (long) Unsigned.getU16(buffer);
		case 3:
			return (long) Unsigned.getU24(buffer);
		case 4:
			return (long) Unsigned.getU32(buffer);
		default:
			throw new IllegalArgumentException();
		}
	}
}
