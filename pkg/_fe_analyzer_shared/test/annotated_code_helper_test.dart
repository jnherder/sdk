// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:_fe_analyzer_shared/src/testing/annotated_code_helper.dart';
import 'package:_fe_analyzer_shared/src/testing/id_generation.dart';
import 'package:_fe_analyzer_shared/src/testing/id_testing.dart';

main() async {
  await testDir('pkg/_fe_analyzer_shared/test/constants/data', sharedMarkers);
  await testDir(
      'pkg/_fe_analyzer_shared/test/flow_analysis/assigned_variables/data',
      cfeAnalyzerMarkers);
  await testDir(
      'pkg/_fe_analyzer_shared/test/flow_analysis/definite_assignment/data',
      cfeAnalyzerMarkers);
  await testDir('pkg/_fe_analyzer_shared/test/flow_analysis/nullability/data',
      cfeAnalyzerMarkers);
  await testDir('pkg/_fe_analyzer_shared/test/flow_analysis/reachability/data',
      cfeAnalyzerMarkers);
  await testDir(
      'pkg/_fe_analyzer_shared/test/flow_analysis/type_promotion/data',
      cfeAnalyzerMarkers);
  await testDir(
      'pkg/_fe_analyzer_shared/test/inheritance/data', cfeAnalyzerMarkers);
}

void expectStringEquals(String value1, String value2) {
  if (value1 != value2) {
    throw StateError('Strings not equal: $value1 != $value2');
  }
}

Future<void> testDir(String dataDirPath, List<String> supportedMarkers) {
  Directory dataDir = Directory(dataDirPath);
  String relativeDir = dataDir.uri.path.replaceAll(Uri.base.path, '');
  print('Data dir: ${relativeDir}');
  List<FileSystemEntity> entities =
      dataDir.listSync().where((entity) => !entity.path.endsWith('~')).toList();
  for (FileSystemEntity entity in entities) {
    print('----------------------------------------------------------------');

    TestData testData = computeTestData(entity,
        supportedMarkers: supportedMarkers,
        createTestUri: (Uri uri, String name) => Uri.parse('memory:$name'),
        onFailure: (String message) => throw message);
    print('Test: ${testData.testFileUri}');
    testData.code.forEach((Uri uri, AnnotatedCode code) {
      expectStringEquals(code.annotatedCode, code.toText());
    });

    Map<Uri, List<Annotation>> annotationsPerUri = computeAnnotationsPerUri(
        testData.code,
        testData.expectedMaps,
        testData.entryPoint,
        const {},
        const StringDataInterpreter());

    annotationsPerUri.forEach((Uri uri, List<Annotation> annotations) {
      AnnotatedCode original = testData.code[uri];
      AnnotatedCode generated = new AnnotatedCode(
          original.annotatedCode, original.sourceCode, annotations);
      expectStringEquals(generated.annotatedCode, generated.toText());
    });
  }
}
