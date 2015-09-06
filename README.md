![](http://www.meleklermekani.com/imagehosting/Aydin-Babaoglu-0-259.jpg)
# bicirik-dwarf
Java based Elf/Dwarf parser branched from peter-dwarf. [https://code.google.com/p/peter-dwarf/]

The focus of this library is EMF integration. After parsing the .elf file you can use the objects for code generation or integrate into your DSL.

The core parser project is an eclipse plugin without any dependencies.

    var elf = new Elf32Context(buffer)
    var dwarf = new Dwarf32Context(elf)

For EMF conversion:

    var model = DwarfModelFactory::createModel(dwarf)

Then you can traverse the model tree:

    model.eAllContents.filter(StructureType).forEach[do what ever with it]

Here's a more detailed example:

   	def void example(File elfFile, PrintWriter out) {
		val fileChannel = new RandomAccessFile(elfFile, 'r').getChannel();
		val buffer = fileChannel.map(FileChannel.MapMode::READ_ONLY, 0, fileChannel.size);

		buffer.order(ByteOrder.LITTLE_ENDIAN)

		val elf = new Elf32Context(buffer)
		val dwarf = new Dwarf32Context(elf)
		val model = DwarfModelFactory::createModel(dwarf)
		model.eAllContents.filter(Variable).forEach[out.println('''«it.name» @ «if(it.location!=null) Integer::toHexString(it.location)»''')]
		model.eAllContents.filter(StructureType).forEach[out.println(it.dumpStruct.toString)]
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
	def dispatch String dumpType(ArrayType arrayType) '''«arrayType.type.dumpType»«arrayType.subranges.map[it.dumpType].join»'''
	def dispatch String dumpType(SubrangeType subRange) '''[«subRange.upperBound»]'''
	def dispatch String dumpType(PointerType ptr) '''«ptr.type.dumpType» *'''
	def dispatch String dumpType(ConstType const) '''const «const.type.dumpType»'''
	def dispatch String dumpType(VolatileType vol) '''volatile «vol.type.dumpType»'''
	def dispatch String dumpType(EnumerationType ^enum) '''enum «enum.name»'''
	def dispatch String dumpType(StructureType struct) '''struct «struct.typedef?.name»'''
	def dispatch String dumpType(UnionType union) '''union «union.typedef?.name»'''
	def dispatch String dumpType(SubroutineType sub) '''(«sub.parameters.map[it.dump].join(',')») -> «sub.returnType.dumpType»'''
	
	def String dump(FormalParameter param) '''«param.type.dumpType» «param.name»'''

The parser is tested with GCC 4.9.3. Only C related DebugInfoEntry is converted to EMF model.
