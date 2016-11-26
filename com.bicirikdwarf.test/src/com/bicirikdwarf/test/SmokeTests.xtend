package com.bicirikdwarf.test

import com.bicirikdwarf.dwarf.Dwarf32Context
import com.bicirikdwarf.elf.Elf32Context
import com.bicirikdwarf.emf.DwarfModelFactory
import com.bicirikdwarf.emf.dwarf.ArrayType
import com.bicirikdwarf.emf.dwarf.BaseType
import com.bicirikdwarf.emf.dwarf.CompositeType
import com.bicirikdwarf.emf.dwarf.ConstType
import com.bicirikdwarf.emf.dwarf.EnumerationType
import com.bicirikdwarf.emf.dwarf.FormalParameter
import com.bicirikdwarf.emf.dwarf.PointerType
import com.bicirikdwarf.emf.dwarf.StructureType
import com.bicirikdwarf.emf.dwarf.SubrangeType
import com.bicirikdwarf.emf.dwarf.SubroutineType
import com.bicirikdwarf.emf.dwarf.Type
import com.bicirikdwarf.emf.dwarf.Typedef
import com.bicirikdwarf.emf.dwarf.UnionType
import com.bicirikdwarf.emf.dwarf.Variable
import com.bicirikdwarf.emf.dwarf.VolatileType
import com.bicirikdwarf.utils.ElfUtils
import java.io.File
import java.io.PrintWriter
import java.io.RandomAccessFile
import java.nio.ByteOrder
import java.nio.channels.FileChannel
import org.junit.Test

import static com.bicirikdwarf.utils.ElfUtils.*

class SmokeTests {
	@Test
	def void MPC5643L_core0() {
		smokeTestElfFile(
			'elf-files/MPC5643L_core0.elf',
			'log/MPC5643L_core0.log'
		)
	}

	def smokeTestElfFile(String elfFilePath, String logFilePath) {
		val elfFile = new File(elfFilePath)
		val out = new PrintWriter(logFilePath)

		val fileChannel = new RandomAccessFile(elfFile, 'r').getChannel();
		val buffer = fileChannel.map(FileChannel.MapMode::READ_ONLY, 0, fileChannel.size);

		buffer.order(ByteOrder.LITTLE_ENDIAN)

		ElfUtils::debugLog = out
		try {
			val elf = new Elf32Context(buffer)
			val dwarf = new Dwarf32Context(elf)
			elf.toString
			dwarf.toString

			val model = DwarfModelFactory::createModel(dwarf)
			model.eAllContents.filter(Variable).forEach [
				out.println('''«it.name» @ «if(it.location!=null) Integer::toHexString(it.location)»''')
			]
			model.eAllContents.filter(StructureType).forEach[out.println(it.dumpStruct.toString)]
		} finally {
			out.close
		}
	}

	def dumpStruct(CompositeType struct) '''
		«switch(struct) {StructureType:'struct' UnionType:'union' default:'composite?'}» «struct.typedef?.name» {
		    «FOR m : struct.members»
		    	«m.type.dumpType» «m.name»  @«m.dataMemberLocation»
		    «ENDFOR»
		}
	'''

	def dispatch String dumpType(Type type) { type.toString }

	def dispatch String dumpType(BaseType baseType) '''«baseType.name»<«baseType.encoding ?: 'void'»>'''

	def dispatch String dumpType(Typedef typedef) '''«typedef.name»'''

	def dispatch String dumpType(
		ArrayType arrayType) '''«arrayType.type.dumpType»«arrayType.subranges.map[it.dumpType].join»'''

	def dispatch String dumpType(SubrangeType subRange) '''[«subRange.upperBound+1»]'''

	def dispatch String dumpType(PointerType ptr) '''«ptr.type.dumpType» *'''

	def dispatch String dumpType(ConstType const) '''const «const.type.dumpType»'''

	def dispatch String dumpType(VolatileType vol) '''volatile «vol.type.dumpType»'''

	def dispatch String dumpType(EnumerationType ^enum) '''enum «enum.name»'''

	def dispatch String dumpType(StructureType struct) '''struct «struct.typedef?.name»'''

	def dispatch String dumpType(UnionType union) '''union «union.typedef?.name»'''

	def dispatch String dumpType(
		SubroutineType sub) '''(«sub.parameters.map[it.dump].join(',')») -> «sub.returnType.dumpType»'''

	def String dump(FormalParameter param) '''«param.type.dumpType» «param.name»'''
}
