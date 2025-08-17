import 'dart:io';

void main() {
  final lcovFile = File('coverage/lcov.info');
  final filteredFile = File('coverage/lcov_filtered.info');
  
  if (!lcovFile.existsSync()) {
    print('No se encontró lcov.info');
    return;
  }
  
  final content = lcovFile.readAsStringSync();
  final files = content.split('end_of_record');
  final filteredContent = StringBuffer();
  
  // Solo incluir archivos esenciales
  final includedPaths = [
    'lib/controllers/',
    'lib/models/',
  ];
  
  for (final fileContent in files) {
    if (fileContent.trim().isEmpty) continue;
    
    final lines = fileContent.split('\n');
    String? fileName;
    
    for (final line in lines) {
      if (line.startsWith('SF:')) {
        fileName = line.substring(3).replaceAll('\\', '/');
        break;
      }
    }
    
    // Solo incluir archivos esenciales
    if (fileName != null &&
        includedPaths.any((path) => fileName!.contains(path)) &&
        !fileName.endsWith('.g.dart')) {
      filteredContent.write(fileContent);
      filteredContent.write('end_of_record\n');
    }
  }
  
  filteredFile.writeAsStringSync(filteredContent.toString());
  print('✅ Archivo filtrado creado: coverage/lcov_filtered.info');
  print('🔗 Súbelo a LCOV Viewer para ver solo lo esencial');
}