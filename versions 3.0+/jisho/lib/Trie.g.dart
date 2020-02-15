// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Trie.dart';

// **************************************************************************
// SerializableGenerator
// **************************************************************************

abstract class _$TrieSerializable extends SerializableMap {
  String get value;
  List<int> get terminalDefinitions;
  Map<String, Trie> get children;
  set value(String v);
  set terminalDefinitions(List<int> v);
  set children(Map<String, Trie> v);
  void insertTerminal(int term);
  void insertString(String vals, int terminal);

  operator [](Object __key) {
    switch (__key) {
      case 'value':
        return value;
      case 'terminalDefinitions':
        return terminalDefinitions;
      case 'children':
        return children;
      case 'insertTerminal':
        return insertTerminal;
      case 'insertString':
        return insertString;
    }
    throwFieldNotFoundException(__key, 'Trie');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'value':
        value = __value;
        return;
      case 'terminalDefinitions':
        terminalDefinitions = fromSerialized(__value, () => List<int>());
        return;
      case 'children':
        children = fromSerialized(
            __value, [() => Map<String, Trie>(), null, () => Trie()]);
        return;
    }
    throwFieldNotFoundException(__key, 'Trie');
  }

  Iterable<String> get keys =>
      const ['value', 'terminalDefinitions', 'children'];
}
