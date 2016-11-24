package com.bicirikdwarf.test;

import com.bicirikdwarf.dwarf.Dwarf32Context;
import com.bicirikdwarf.elf.Elf32Context;
import com.bicirikdwarf.emf.DwarfModelFactory;
import com.bicirikdwarf.emf.dwarf.DwarfModel;
import com.bicirikdwarf.emf.dwarf.Variable;
import com.google.common.base.Objects;
import com.google.common.collect.Iterators;
import java.io.RandomAccessFile;
import java.nio.ByteOrder;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.util.Iterator;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IteratorExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.junit.Test;

@SuppressWarnings("all")
public class SmokeTests {
  @Test
  public void deneme() {
    try {
      final String elfFile = "elf-files/MPC5643L_core0.elf";
      RandomAccessFile _randomAccessFile = new RandomAccessFile(elfFile, "r");
      final FileChannel fileChannel = _randomAccessFile.getChannel();
      long _size = fileChannel.size();
      final MappedByteBuffer buffer = fileChannel.map(FileChannel.MapMode.READ_ONLY, 0, _size);
      buffer.order(ByteOrder.LITTLE_ENDIAN);
      Elf32Context elf = new Elf32Context(buffer);
      Dwarf32Context dwarf = new Dwarf32Context(elf);
      final DwarfModel model = DwarfModelFactory.createModel(dwarf);
      TreeIterator<EObject> _eAllContents = model.eAllContents();
      Iterator<Variable> _filter = Iterators.<Variable>filter(_eAllContents, Variable.class);
      final Procedure1<Variable> _function = (Variable it) -> {
        StringConcatenation _builder = new StringConcatenation();
        String _name = it.getName();
        _builder.append(_name, "");
        _builder.append(" @ ");
        String _xifexpression = null;
        Integer _location = it.getLocation();
        boolean _notEquals = (!Objects.equal(_location, null));
        if (_notEquals) {
          Integer _location_1 = it.getLocation();
          _xifexpression = Integer.toHexString((_location_1).intValue());
        }
        _builder.append(_xifexpression, "");
        InputOutput.<String>println(_builder.toString());
      };
      IteratorExtensions.<Variable>forEach(_filter, _function);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
