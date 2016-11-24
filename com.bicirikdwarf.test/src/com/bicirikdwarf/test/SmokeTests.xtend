package com.bicirikdwarf.test

import org.junit.Test
import com.bicirikdwarf.elf.Elf32Context
import com.bicirikdwarf.dwarf.Dwarf32Context
import java.io.RandomAccessFile
import java.nio.channels.FileChannel
import java.nio.ByteOrder
import com.bicirikdwarf.emf.DwarfModelFactory
import com.bicirikdwarf.emf.dwarf.Variable

class SmokeTests {
	@Test
	def void deneme() {
		val elfFile = "elf-files/MPC5643L_core0.elf"

		val fileChannel = new RandomAccessFile(elfFile, 'r').getChannel();
		val buffer = fileChannel.map(FileChannel.MapMode::READ_ONLY, 0, fileChannel.size);

		buffer.order(ByteOrder.LITTLE_ENDIAN)

		var elf = new Elf32Context(buffer)
		var dwarf = new Dwarf32Context(elf)
		val model = DwarfModelFactory::createModel(dwarf)

		model.eAllContents.filter(Variable).forEach [
			println('''«it.name» @ «if(it.location!=null) Integer::toHexString(it.location)»''')
		]
	}
}
