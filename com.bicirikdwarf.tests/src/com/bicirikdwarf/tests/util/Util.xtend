package com.bicirikdwarf.tests.util

import java.nio.file.Paths
import java.nio.file.Files
import java.nio.file.Path
import java.util.ArrayList
import java.util.Collection

class Util {
	static def collectElfFiles() {
		Paths::get("elf-files").collectFiles.filter[it.fileName.toString.endsWith('.elf')]
	}

	static def Collection<Path> collectFiles(Path dir) {
		val result = new ArrayList<Path>

		Files::newDirectoryStream(dir).forEach [
			if (Files::isDirectory(it))
				result.addAll(collectFiles(it))
			else
				result.add(it)
		]

		result
	}
}
