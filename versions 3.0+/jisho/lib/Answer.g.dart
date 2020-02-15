// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Answer.dart';

// **************************************************************************
// SerializableGenerator
// **************************************************************************

abstract class _$AnswerSerializable extends SerializableMap {
  int get id;
  String get kanjiStr;
  String get kanaStr;
  List<Map<dynamic, dynamic>> get defs;
  set id(int v);
  set kanjiStr(String v);
  set kanaStr(String v);
  set defs(List<Map<dynamic, dynamic>> v);
  String toString();

  operator [](Object __key) {
    switch (__key) {
      case 'id':
        return id;
      case 'kanjiStr':
        return kanjiStr;
      case 'kanaStr':
        return kanaStr;
      case 'defs':
        return defs;
      case 'toString':
        return toString;
    }
    throwFieldNotFoundException(__key, 'Answer');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'id':
        id = __value;
        return;
      case 'kanjiStr':
        kanjiStr = __value;
        return;
      case 'kanaStr':
        kanaStr = __value;
        return;
      case 'defs':
        defs = fromSerialized(__value, [
          () => List<Map<dynamic, dynamic>>(),
          () => Map<dynamic, dynamic>()
        ]);
        return;
    }
    throwFieldNotFoundException(__key, 'Answer');
  }

  Iterable<String> get keys => const ['id', 'kanjiStr', 'kanaStr', 'defs'];
}
