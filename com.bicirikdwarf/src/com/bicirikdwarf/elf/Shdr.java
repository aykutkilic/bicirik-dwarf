package com.bicirikdwarf.elf;

import java.nio.ByteBuffer;

import com.bicirikdwarf.utils.Unsigned;

public class Shdr {
	public long sh_name; // section name - word
	public long sh_type; // SHT_... - word
	public long sh_flags; // SHF_... - word
	public long sh_addr; // virtual address - addr
	public long sh_offset; // file offset - off
	public long sh_size; // section size - word
	public long sh_link; // misc info - word
	public long sh_info; // misc info - word
	public long sh_addralign; // memory alignment - word
	public long sh_entsize; // entry size if table - word

	public void parse(ByteBuffer buffer) {
		sh_name = Unsigned.getU32(buffer);
		sh_type = buffer.getInt();
		sh_flags = buffer.getInt();
		sh_addr = Unsigned.getU32(buffer);
		sh_offset = Unsigned.getU32(buffer);
		sh_size = Unsigned.getU32(buffer);
		sh_link = buffer.getInt();
		sh_info = buffer.getInt();
		sh_addralign = buffer.getInt();
		sh_entsize = buffer.getInt();
	}
}