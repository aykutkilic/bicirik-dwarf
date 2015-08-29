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

The parser is tested with GCC 4.9.3. Only C related DebugInfoEntry is converted to EMF model.
