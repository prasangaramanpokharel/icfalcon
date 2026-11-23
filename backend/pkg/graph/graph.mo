import Text "mo:core/Text";
import Map "mo:core/Map";
import Set "mo:core/Set";
import Queue "mo:core/Queue";
import Nat "mo:core/Nat";
import Bool "mo:core/Bool";

module {
  public class DirectedGraph() {
    // Adjacency list: fromNode -> Set of toNodes
    private let adjacency = Map.empty<Text, Set.Set<Text>>();
    // In-degree tracking: node -> coun
    private let inDegrees = Map.empty<Text, Nat>();

    public func addNode(node : Text) : () {
      switch (Map.get(adjacency, Text.compare, node)) {
        case (null) {
          Map.add(adjacency, Text.compare, node, Set.empty<Text>());
          Map.add(inDegrees, Text.compare, node, 0);
        };
        case (?_) ();
      };
    };

    public func addEdge(fromNode : Text, toNode : Text) : () {
      addNode(fromNode);
      addNode(toNode);

      switch (Map.get(adjacency, Text.compare, fromNode)) {
        case (null) ();
        case (?neighbors) {
          if (not Set.contains(neighbors, Text.compare, toNode)) {
            Set.add(neighbors, Text.compare, toNode);
            let currentIn = switch (Map.get(inDegrees, Text.compare, toNode)) {
              case (null) 0;
              case (?c) c;
            };
            Map.add(inDegrees, Text.compare, toNode, currentIn + 1);
          };
        };
      };
    };

    public func getNeighbors(node : Text) : [Text] {
      switch (Map.get(adjacency, Text.compare, node)) {
        case (null) [];
        case (?set) Set.toArray(set);
      };
    };

    public func nodes() : [Text] {
      let q = Queue.empty<Text>();
      for ((k, _) in Map.entries(adjacency)) {
        Queue.pushBack(q, k);
      };
      Queue.toArray(q);
    };

    // Kahn's algorithm for topological sorting
    public func topologicalSort() : ?[Text] {
      let tempInDegrees = Map.empty<Text, Nat>();
      for ((k, v) in Map.entries(inDegrees)) {
        Map.add(tempInDegrees, Text.compare, k, v);
      };

      let zeroQueue = Queue.empty<Text>();
      for ((node, inDeg) in Map.entries(tempInDegrees)) {
        if (inDeg == 0) {
          Queue.pushBack(zeroQueue, node);
        };
      };

      let result = Queue.empty<Text>();

      while (Queue.size(zeroQueue) > 0) {
        switch (Queue.popFront(zeroQueue)) {
          case (null) ();
          case (?current) {
            Queue.pushBack(result, current);
            for (neighbor in getNeighbors(current).values()) {
              switch (Map.get(tempInDegrees, Text.compare, neighbor)) {
                case (null) ();
                case (?deg) {
                  let newDeg = if (deg > 0) { deg - 1 } else { 0 };
                  Map.add(tempInDegrees, Text.compare, neighbor, newDeg);
                  if (newDeg == 0) {
                    Queue.pushBack(zeroQueue, neighbor);
                  };
                };
              };
            };
          };
        };
      };

      if (Queue.size(result) == Map.size(adjacency)) {
        ?Queue.toArray(result);
      } else {
        null; // Cycle detected!
      };
    };

    public func hasCycle() : Bool {
      topologicalSort() == null;
    };
  };
};
