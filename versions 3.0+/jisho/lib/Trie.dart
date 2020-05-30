import 'dart:convert';
import 'package:serializable/serializable.dart';

part 'Trie.g.dart';

int _id = 0;

/// Resets _id. Should be used whenever a new trie is about to be built.
void resetGlobalID() {
  _id = 0;
}

@serializable
class Trie extends _$TrieSerializable {
  int id;

  /// The value of a Trie node. This should be a string of length 1 EXCEPT
  /// in the case of the root.
  String v;

  /// The integer corresponding to an Answer's Unique identifier
  /// that ends at this Trie instance.
  List<int> t;

  /// A mapping from the character of a child to its id.
  ///
  /// example: Trie {value:'c'.,
  ///           terminalDefinitions: [],
  ///           children{ 'a': 201,
  ///                     'r':1005,
  ///                     ...
  ///                    }
  ///           }
  /// The above example corresponds to a Trie that only represents the strings 'ac...'
  Map c;

  ///The constructor for serialization.
  Trie();

  ///The generic initializer. Creates a Trie with the corresponding value.
  /// This does not insert the Trie node into a larger Trie.
  /// @param value: the value assigned to a Trie
  Trie.withVal(String value) {
    this.id = _id++;
    this.v = value;
    this.t = List();
    this.c = Map();
  }

  ///The root initializer. This should only be called once for any
  ///representation of data.
  Trie.root() {
    this.id = _id++;
    this.v = 'root';
    this.t = List();
    this.c = Map();
  }

  /// An initializer for Tries that come with terminals. This is essentially the
  /// same as:
  ///   x = Trie(value);
  ///   for(int term:terms){
  ///     x.insertTerminal(term);
  ///   }
  ///   return x
  /// This constructor is here in case it is ever needed, but currently there ***SHOULD***
  /// be no use case.
  ///
  /// @param value: the value of the Trie.
  /// @param terms: a list of Answers that end at this position in the Trie.
  Trie.withTerms(String value, List<int> terms) {
    this.v = value;
    this.t = terms;
    this.c = Map();
  }

  /// Adds a terminal to the Trie.
  void insertTerminal(int term) {
    this.t.add(term);
  }

  /// Adds a string to the Trie and associates a terminal to its endpoint
  void insertString(String vals, int terminal) {
    if (vals == null) {
      return;
    }
    if (vals.length == 0) {
      this.insertTerminal(terminal);
    } else {
      String childVal = vals.substring(0, 1);
      String nextVals = vals.substring(1);
      if (!this.c.containsKey(childVal)) {
        Trie newChild = new Trie.withVal(childVal);
        this.c[childVal] = newChild;
      }
      this.c[childVal].insertString(nextVals, terminal);
    }
  }
}
