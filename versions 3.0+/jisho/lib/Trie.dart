import 'dart:convert';
import 'package:serializable/serializable.dart';

part 'Trie.g.dart';


@serializable
class Trie extends  _$TrieSerializable{

   /// The value of a Trie node. This should be a string of length 1 EXCEPT
   /// in the case of the root.
  String value;
  /// The integer corresponding to an Answer's Unique identifier
  /// that ends at this Trie instance.
  List<int> terminalDefinitions;
  /// A mapping from the character of a child to its object.
  ///
  /// example: Trie {value:'c'.,
  ///           terminalDefinitions: [],
  ///           children{ 'a': Trie{value:'a',
  ///                         terminalDefinitions:[],
  ///                          children:{...}
  ///                    }
  ///           }
  /// The above example corresponds to a Trie that only represents the strings 'ac...'
  Map<String,Trie> children;

  ///The constructor for serialization.
  Trie();

  ///The generic initializer. Creates a Trie with the corresponding value.
  /// This does not insert the Trie node into a larger Trie.
  /// @param value: the value assigned to a Trie
  Trie.withVal(String value){
    this.value = value;
    this.terminalDefinitions = List();
    this.children = Map();
  }
  ///The root initializer. This should only be called once for any
  ///representation of data.
  Trie.root(){
    this.value = 'root';
    this.terminalDefinitions = List();
    this.children = Map();
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
  Trie.withTerms(String value,List<int> terms){
    this.value = value;
    this.terminalDefinitions = terms;
    this.children = Map();
  }
  /// Adds a terminal to the Trie.
  void insertTerminal(int term){
    this.terminalDefinitions.add(term);
  }
  /// Adds a string to the Trie and associates a terminal to its endpoint
  void insertString(String vals, int terminal) {
    if (vals.length == 0) {
      this.insertTerminal(terminal);
    } else{
      String childVal = vals.substring(0,1);
      String nextVals = vals.substring(1);
      if (!this.children.containsKey(childVal)){
        Trie newChild = new Trie.withVal(childVal);
        this.children[childVal] = newChild;
      }
      this.children[childVal].insertString(nextVals, terminal);
    }
  }
}