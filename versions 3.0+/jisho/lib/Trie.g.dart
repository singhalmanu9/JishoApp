// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Trie.dart';

// **************************************************************************
// SerializableGenerator
// **************************************************************************

abstract class _$TrieSerializable extends SerializableMap {
  int get id;
  String get v;
  List<int> get t;
  Map<dynamic, dynamic> get c;
  set id(int v);
  set v(String v);
  set t(List<int> v);
  set c(Map<dynamic, dynamic> v);
  void insertTerminal(int term);
  void insertString(String vals, int terminal);

  operator [](Object __key) {
    switch (__key) {
      case 'id':
        return id;
      case 'v':
        return v;
      case 't':
        return t;
      case 'c':
        return c;
      case 'insertTerminal':
        return insertTerminal;
      case 'insertString':
        return insertString;
    }
    throwFieldNotFoundException(__key, 'Trie');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'id':
        id = __value;
        return;
      case 'v':
        v = __value;
        return;
      case 't':
        t = fromSerialized(__value, () => List<int>());
        return;
      case 'c':
        c = fromSerialized(__value, () => Map<dynamic, dynamic>());
        return;
    }
    throwFieldNotFoundException(__key, 'Trie');
  }

  Iterable<String> get keys => const ['id', 'v', 't', 'c'];
}
