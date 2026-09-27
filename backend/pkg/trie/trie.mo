import Text "mo:core/Text";
import Map "mo:core/Map";
import Char "mo:core/Char";
import Queue "mo:core/Queue";
import Bool "mo:core/Bool";

module {
  public type Node<V> = {
    var value : ?V;
    children : Map.Map<Char, Node<V>>;
  };

  public func makeNode<V>() : Node<V> {
    { var value = null; children = Map.empty() };
  };

  public class Trie<V>() {
    private let root : Node<V> = makeNode<V>();

    public func insert(word : Text, value : V) : () {
      var current = root;
      for (c in Text.toIter(word)) {
        switch (Map.get(current.children, Char.compare, c)) {
          case (?next) {
            current := next;
          };
          case (null) {
            let newNode = makeNode<V>();
            Map.add(current.children, Char.compare, c, newNode);
            current := newNode;
          };
        };
      };
      current.value := ?value;
    };

    public func search(word : Text) : ?V {
      var current = root;
      for (c in Text.toIter(word)) {
        switch (Map.get(current.children, Char.compare, c)) {
          case (?next) { current := next; };
          case (null) { return null; };
        };
      };
      current.value;
    };

    public func startsWith(prefix : Text) : Bool {
      var current = root;
      for (c in Text.toIter(prefix)) {
        switch (Map.get(current.children, Char.compare, c)) {
          case (?next) { current := next; };
          case (null) { return false; };
        };
      };
      true;
    };

    private func collectWords(node : Node<V>, currentPrefix : Text, acc : Queue.Queue<Text>) : () {
      switch (node.value) {
        case (?_) { Queue.pushBack(acc, currentPrefix); };
        case (null) ();
      };
      for ((ch, child) in Map.entries(node.children)) {
        collectWords(child, currentPrefix # Char.toText(ch), acc);
      };
    };

    public func findWordsWithPrefix(prefix : Text) : [Text] {
      var current = root;
      for (c in Text.toIter(prefix)) {
        switch (Map.get(current.children, Char.compare, c)) {
          case (?next) { current := next; };
          case (null) { return []; };
        };
      };
      let acc = Queue.empty<Text>();
      collectWords(current, prefix, acc);
      Queue.toArray(acc);
    };
  };
};
