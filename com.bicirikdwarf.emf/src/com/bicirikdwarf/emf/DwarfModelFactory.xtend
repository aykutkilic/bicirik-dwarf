package com.bicirikdwarf.emf

import com.bicirikdwarf.dwarf.DebugInfoEntry
import com.bicirikdwarf.dwarf.DwAtType
import com.bicirikdwarf.emf.dwarf.DwarfFactory
import com.bicirikdwarf.emf.dwarf.Type
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.InternalEObject
import com.bicirikdwarf.emf.dwarf.Die
import java.util.HashMap
import java.util.Map
import com.bicirikdwarf.emf.dwarf.BaseType
import com.bicirikdwarf.emf.dwarf.CompileUnit
import com.bicirikdwarf.emf.dwarf.ConstType
import com.bicirikdwarf.emf.dwarf.EnumerationType
import com.bicirikdwarf.emf.dwarf.Enumerator
import com.bicirikdwarf.emf.dwarf.FormalParameter
import com.bicirikdwarf.emf.dwarf.InlinedSubroutine
import com.bicirikdwarf.emf.dwarf.LexicalBlock
import com.bicirikdwarf.emf.dwarf.Member
import com.bicirikdwarf.emf.dwarf.PointerType
import com.bicirikdwarf.emf.dwarf.StructureType
import com.bicirikdwarf.emf.dwarf.Subprogram
import com.bicirikdwarf.emf.dwarf.SubrangeType
import com.bicirikdwarf.emf.dwarf.SubroutineType
import com.bicirikdwarf.emf.dwarf.Typedef
import com.bicirikdwarf.emf.dwarf.UnionType
import com.bicirikdwarf.emf.dwarf.UnspecifiedParameters
import com.bicirikdwarf.emf.dwarf.Variable
import com.bicirikdwarf.emf.dwarf.VolatileType
import com.bicirikdwarf.emf.dwarf.DwarfModel
import org.eclipse.emf.ecore.util.EContentsEList
import org.eclipse.emf.ecore.EObject
import com.bicirikdwarf.dwarf.Dwarf32Context
import com.bicirikdwarf.emf.dwarf.CompositeType
import java.util.Iterator
import com.bicirikdwarf.dwarf.DwOpType
import java.nio.ByteBuffer

public class DwarfModelFactory {
	Map<Integer, Die> dies;
	DwarfModel model

	public static def createModel(Dwarf32Context dwarfContext) {
		var factory = new DwarfModelFactory()
		factory.processContext(dwarfContext)
		factory.model
	}

	private new() {
		dies = new HashMap();
		model = DwarfFactory::eINSTANCE.createDwarfModel
	}
	
	private def processContext(Dwarf32Context dwarfContext) {
		dwarfContext.compilationUnits.forEach[createDie(it.compileUnit)]
		resolveReferences
		resolveCompositeTypeTypedefs
	}

	private def Die createEmfObject(DebugInfoEntry die) {
		var f = DwarfFactory::eINSTANCE

		var Die result = switch (die.abbrev.tag) {
			case DW_TAG_array_type: f.createArrayType
			case DW_TAG_base_type: f.createBaseType
			case DW_TAG_compile_unit: f.createCompileUnit
			case DW_TAG_const_type: f.createConstType
			case DW_TAG_enumeration_type: f.createEnumerationType
			case DW_TAG_enumerator: f.createEnumerator
			case DW_TAG_formal_parameter: f.createFormalParameter
			case DW_TAG_inlined_subroutine: f.createInlinedSubroutine
			case DW_TAG_lexical_block: f.createLexicalBlock
			case DW_TAG_member: f.createMember
			case DW_TAG_pointer_type: f.createPointerType
			case DW_TAG_structure_type: f.createStructureType
			case DW_TAG_subprogram: f.createSubprogram
			case DW_TAG_subrange_type: f.createSubrangeType
			case DW_TAG_subroutine_type: f.createSubroutineType
			case DW_TAG_typedef: f.createTypedef
			case DW_TAG_union_type: f.createUnionType
			case DW_TAG_unspecified_parameters: f.createUnspecifiedParameters
			case DW_TAG_variable: f.createVariable
			case DW_TAG_volatile_type: f.createVolatileType
			default: throw new Exception
		}

		result.address = die.address
		dies.put(die.address, result)
		if (result instanceof CompileUnit)
			model.compileUnits.add(result)

		result
	}

	private def Die createDie(DebugInfoEntry die) {
		return switch (die.abbrev.tag) {
			case DW_TAG_array_type: die.createArrayType
			case DW_TAG_base_type: die.createBaseType
			case DW_TAG_compile_unit: die.createCompileUnit
			case DW_TAG_const_type: die.createConstType
			case DW_TAG_enumeration_type: die.createEnumerationType
			case DW_TAG_enumerator: die.createEnumerator
			case DW_TAG_formal_parameter: die.createFormalParameter
			case DW_TAG_inlined_subroutine: die.createInlinedSubroutine
			case DW_TAG_lexical_block: die.createLexicalBlock
			case DW_TAG_member: die.createMember
			case DW_TAG_pointer_type: die.createPointerType
			case DW_TAG_structure_type: die.createStructureType
			case DW_TAG_subprogram: die.createSubprogram
			case DW_TAG_subrange_type: die.createSubrangeType
			case DW_TAG_subroutine_type: die.createSubroutineType
			case DW_TAG_typedef: die.createTypedef
			case DW_TAG_union_type: die.createUnionType
			case DW_TAG_unspecified_parameters: die.createUnspecifiedParameters
			case DW_TAG_variable: die.createVariable
			case DW_TAG_volatile_type: die.createVolatileType
			default: null
		}
	}

	private def resolveReferences() {
		for (element : model.eAllContents.toIterable) {
			var iterator = element.eCrossReferences.iterator as EContentsEList.FeatureIterator<EObject>

			for (; iterator.hasNext;) {
				var crossRef = iterator.next as InternalEObject
				var feature = iterator.feature

				if (crossRef.eIsProxy) {
					var proxyUri = (crossRef as InternalEObject).eProxyURI.toString
					if( !proxyUri.empty) {
						var address = Integer.parseInt(proxyUri)
						var resolved = dies.get(address)
						if(resolved == null) throw new Exception
						element.eSet(feature, resolved)	
					}
				}
			}
		}
	}
	
	private def resolveCompositeTypeTypedefs() {
		val compositeTypes = model.eAllContents.filter(CompositeType)
		val typedefs = model.eAllContents.filter(Typedef).filter[it.type instanceof CompositeType].toList
		
		compositeTypes.forEach[ c | c.typedef = typedefs.iterator.filter[it.type == c].onlyIfOne ]
	}
	
	def <E> E onlyIfOne(Iterator<E> i) {
		if( !i.hasNext ) return null;
		var result = i.next;
		if( i.hasNext ) return null;
		result
	}

	private def createArrayType(DebugInfoEntry die) {
		var arrayType = DwarfFactory::eINSTANCE.createArrayType
		dies.put(die.address, arrayType)

		arrayType.type = die.createProxyForType
		arrayType.subranges.addAll(die.children.map[it.createDie as SubrangeType])
		arrayType
	}

	private def createBaseType(DebugInfoEntry die) {
		var baseType = die.createEmfObject as BaseType

		baseType.name = die.name
		baseType.byteSize = die.byteSize
		baseType.encoding = die.encoding

		baseType
	}

	private def createCompileUnit(DebugInfoEntry die) {
		var compileUnit = die.createEmfObject as CompileUnit

		compileUnit.producer = die.producer
		compileUnit.children.addAll(die.children.map[it.createDie])
		compileUnit
	}

	private def createConstType(DebugInfoEntry die) {
		var constType = die.createEmfObject as ConstType
		constType.type = die.createProxyForType
		constType
	}

	private def createEnumerationType(DebugInfoEntry die) {
		var enumType = die.createEmfObject as EnumerationType
		enumType
	}

	private def createEnumerator(DebugInfoEntry die) {
		var enum = die.createEmfObject as Enumerator
		enum.name = die.name
		enum.constValue = die.constValue
		enum
	}

	private def createFormalParameter(DebugInfoEntry die) {
		var formalParam = die.createEmfObject as FormalParameter

		formalParam.name = die.name
		formalParam.declFile = die.declFile
		formalParam.declLine = die.declLine

		formalParam.type = die.createProxyForType

		formalParam
	}

	private def createInlinedSubroutine(DebugInfoEntry die) {
		var inlSubr = die.createEmfObject as InlinedSubroutine
		inlSubr
	}

	private def createLexicalBlock(DebugInfoEntry die) {
		var lexBlock = die.createEmfObject as LexicalBlock

		lexBlock.highPc = die.highPc
		lexBlock.lowPc = die.lowPc

		lexBlock.children.addAll(die.children.map[it.createDie])

		lexBlock
	}

	private def createMember(DebugInfoEntry die) {
		var member = die.createEmfObject as Member

		member.name = die.name
		member.declFile = die.declFile
		member.declLine = die.declLine
		member.type = die.createProxyForType
		member.dataMemberLocation = die.dataMemberLocation

		member
	}

	private def createPointerType(DebugInfoEntry die) {
		var pointerType = die.createEmfObject as PointerType

		pointerType.type = die.createProxyForType

		pointerType
	}

	private def createStructureType(DebugInfoEntry die) {
		var structType = die.createEmfObject as StructureType

		structType.declaration = die.declaration
		structType.byteSize = die.byteSize
		structType.declFile = die.declFile
		structType.declLine = die.declLine

		structType.members.addAll(die.children.map[it.createDie as Member])

		structType
	}

	private def createSubprogram(DebugInfoEntry die) {
		var subprogram = die.createEmfObject as Subprogram

		subprogram.external = die.external
		subprogram.name = die.name
		subprogram.declFile = die.declFile
		subprogram.declLine = die.declLine
		subprogram.lowPc = die.lowPc
		subprogram.highPc = die.highPc
		// subprogram.frameBase = die.frameBase
		subprogram.gnuAllCallSites = die.gnuAllCallSites

		subprogram.returnType = die.createProxyForType
		var children = die.children.map[it.createDie]
		subprogram.parameters.addAll(children.filter(FormalParameter))
		subprogram.localVariables.addAll(children.filter(Variable))
		
		subprogram
	}

	private def createSubrangeType(DebugInfoEntry die) {
		var subrangeType = die.createEmfObject as SubrangeType

		subrangeType.lowerBound = die.lowerBound
		subrangeType.upperBound = die.upperBound

		subrangeType
	}

	private def createSubroutineType(DebugInfoEntry die) {
		var subroutineType = die.createEmfObject as SubroutineType

		subroutineType.prototyped = die.prototyped
		subroutineType.returnType = die.createProxyForType

		var children = die.children.map[it.createDie]
		subroutineType.parameters.addAll(children.filter(FormalParameter))
		subroutineType
	}

	private def createTypedef(DebugInfoEntry die) {
		var typedef = die.createEmfObject as Typedef

		typedef.name = die.name
		typedef.type = die.createProxyForType
		typedef.declFile = die.declFile
		typedef.declLine = die.declLine

		typedef
	}

	private def createUnionType(DebugInfoEntry die) {
		var unionType = die.createEmfObject as UnionType

		unionType.byteSize = die.byteSize
		unionType.declFile = die.declFile
		unionType.declLine = die.declLine

		unionType.members.addAll(die.children.map[it.createDie as Member])
		
		unionType
	}

	private def createUnspecifiedParameters(DebugInfoEntry die) {
		var unspec = die.createEmfObject as UnspecifiedParameters
		unspec
	}

	private def createVariable(DebugInfoEntry die) {
		var variable = die.createEmfObject as Variable

		variable.name = die.name
		variable.declFile = die.declFile
		variable.declLine = die.declLine
		variable.type = die.createProxyForType
		variable.external = die.external
		variable.location = die.location
		
		variable
	}

	private def createVolatileType(DebugInfoEntry die) {
		var volType = die.createEmfObject as VolatileType

		volType.type = die.createProxyForType

		volType
	}

	private def byteSize(DebugInfoEntry die) {
		boxToInteger(die.getAttribValue(DwAtType.DW_AT_byte_size))
	}

	private def constValue(DebugInfoEntry die) {
		boxToInteger(die.getAttribValue(DwAtType.DW_AT_const_value))
	}

	private def dataMemberLocation(DebugInfoEntry die) {
		boxToInteger(die.getAttribValue(DwAtType.DW_AT_data_member_location))
	}

	private def declaration(DebugInfoEntry die) {
		boxToBoolean(die.getAttribValue(DwAtType.DW_AT_declaration))
	}

	private def declFile(DebugInfoEntry die) {
		boxToInteger(die.getAttribValue(DwAtType.DW_AT_decl_file))
	}

	private def declLine(DebugInfoEntry die) {
		boxToInteger(die.getAttribValue(DwAtType.DW_AT_decl_line))
	}

	private def encoding(DebugInfoEntry die) {
		boxToInteger(die.getAttribValue(DwAtType.DW_AT_encoding))
	}

	private def external(DebugInfoEntry die) {
		boxToBoolean(die.getAttribValue(DwAtType.DW_AT_external))
	}

	//private def frameBase(DebugInfoEntry die) {
	//	throw new Exception
	//}

	private def gnuAllCallSites(DebugInfoEntry die) {
		boxToInteger(die.getAttribValue(DwAtType.DW_AT_GNU_all_call_sites))
	}

	private def highPc(DebugInfoEntry die) {
		boxToInteger(die.getAttribValue(DwAtType.DW_AT_high_pc))
	}

	private def location( DebugInfoEntry die ) {
		var buffer = die.getAttribValue(DwAtType.DW_AT_location) as ByteBuffer
		
		if(buffer == null || buffer.remaining == 0) return null
		var opType = DwOpType::byValue(buffer.get())
		switch(opType) {
			case DwOpType.DW_OP_addr: return buffer.int
			default: return null
		}
	}
	
	private def lowerBound(DebugInfoEntry die) {
		boxToInteger(die.getAttribValue(DwAtType.DW_AT_lower_bound))
	}

	private def lowPc(DebugInfoEntry die) {
		boxToInteger(die.getAttribValue(DwAtType.DW_AT_low_pc))
	}

	private def name(DebugInfoEntry die) {
		die.getAttribValue(DwAtType.DW_AT_name) as String
	}

	private def producer(DebugInfoEntry die) {
		die.getAttribValue(DwAtType.DW_AT_producer) as String
	}

	private def prototyped(DebugInfoEntry die) {
		boxToBoolean(die.getAttribValue(DwAtType.DW_AT_prototyped))
	}

	private def upperBound(DebugInfoEntry die) {
		boxToInteger(die.getAttribValue(DwAtType.DW_AT_upper_bound))
	}

	private def createProxyForType(DebugInfoEntry die) {
		var address = die.getAttribValue(DwAtType.DW_AT_type) as Integer
		var typeProxy = DwarfFactory::eINSTANCE.createBaseType as InternalEObject
		typeProxy.eSetProxyURI(URI::createFileURI('''«address»'''))
		return typeProxy as Type
	}

	private def boxToBoolean(Object object) {
		var intForm = boxToInteger(object)
		if(object == null) return false

		intForm != 0
	}

	private def boxToInteger(Object object) {
		if(object == null) return null
		switch (object) {
			Byte: new Integer(object as Byte)
			Short: new Integer(object as Short)
			Integer: object as Integer
			String: Integer.parseInt(object as String)
			default: object as Integer
		}
	}

}