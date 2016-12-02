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
import com.bicirikdwarf.test.util.Util
import java.io.RandomAccessFile
import java.nio.ByteOrder
import java.nio.channels.FileChannel
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.Parameterized
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters

@RunWith(Parameterized)
class SmokeTests {
	@Parameters(name = "{0}")
	def static Iterable<? extends Object> data() {
		Util::collectElfFiles.map[it.toString].toList
	}

	@Parameter
	public var String elfFile

	@Test
	def void smokeTest() {
		val fileChannel = new RandomAccessFile(elfFile, 'r').getChannel();
		val buffer = fileChannel.map(FileChannel.MapMode::READ_ONLY, 0, fileChannel.size);

		buffer.order(ByteOrder.LITTLE_ENDIAN)

		var elf = new Elf32Context(buffer)
		var dwarf = new Dwarf32Context(elf)
		val model = DwarfModelFactory::createModel(dwarf)

		model.eAllContents.filter(Variable).forEach [
			println('''«it.name» @ «if(it.location!=null) Integer::toHexString(it.location)»''')
		]

		model.eAllContents.filter(StructureType).forEach[println(it.dumpStruct.toString)]
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

	def dispatch String dumpType(SubrangeType subRange) '''[«subRange.upperBound»]'''

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
