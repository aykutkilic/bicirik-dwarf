package com.bicirikdwarf.elf.reader;

import java.nio.ByteBuffer;
import java.util.Objects;

import com.bicirikdwarf.elf.Elf32Context;
import com.bicirikdwarf.elf.Shdr;
import com.bicirikdwarf.elf.Sym;
import com.bicirikdwarf.utils.ElfUtils;

public class ElfReader {
	private Elf32Context elf;
	
	public ElfReader(Elf32Context elf) {
		Objects.requireNonNull(elf, "The given elf context is null");
		this.elf = elf;
	}
	
	public String getStringSymbolValue(String symbolName) {
		Sym symbol = elf.getSymbolByName(symbolName);
		Shdr header = elf.getSectionByIndex(symbol.st_shndx);
		long finalOffset = (symbol.st_value - header.sh_addr) + header.sh_offset;

		ByteBuffer buffer = elf.getElfBuffer();
		buffer.position((int) finalOffset);
		return ElfUtils.getNTString(buffer);
	}
}
