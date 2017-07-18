package com.bicirikdwarf.elf.reader;

import java.nio.ByteBuffer;
import java.util.NoSuchElementException;
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
		Objects.requireNonNull(symbolName, "The given symbol name is null");
		Sym symbol = elf.getSymbolByName(symbolName);
		if(symbol == null) throw new NoSuchElementException("No such symbol with name " + symbolName);
		Shdr header = elf.getSectionByIndex(symbol.st_shndx);
		long finalOffset = (symbol.st_value - header.sh_addr) + header.sh_offset;

		ByteBuffer buffer = elf.getElfBuffer();
		buffer.position((int) finalOffset);
		return ElfUtils.getNTString(buffer);
	}
}
