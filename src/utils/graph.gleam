import gleam/dict.{type Dict}
import gleam/list
import gleam/set.{type Set}
import gleam/string
import simplifile

pub opaque type Graph(id, value, label) {
  Graph(node_dict: Dict(id, Node(id, value, label)))
}

pub type Node(id, value, label) {
  Node(id: id, value: value, in: List(id), out: List(id))
}

pub fn new() -> Graph(id, value, label) {
  Graph(dict.new())
}

pub fn add(
  graph: Graph(id, value, label),
  node: Node(id, value, label),
) -> Graph(id, value, label) {
  Graph(dict.insert(graph.node_dict, node.id, node))
}

pub fn get(
  graph: Graph(id, value, label),
  id: id,
) -> Result(Node(id, value, label), Nil) {
  dict.get(graph.node_dict, id)
}

pub fn keys(graph: Graph(id, value, label)) -> List(id) {
  dict.keys(graph.node_dict)
}

pub fn nodes(graph: Graph(id, value, label)) -> List(Node(id, value, label)) {
  dict.values(graph.node_dict)
}

pub fn filter(
  graph: Graph(id, value, label),
  predicate: fn(Node(id, value, label)) -> Bool,
) -> Graph(id, value, label) {
  Graph(dict.filter(graph.node_dict, fn(_, node) { predicate(node) }))
}

pub fn connect(graph: Graph(id, value, label), from: id, to: id) {
  let a = get(graph, from)
  let b = get(graph, to)

  case a, b {
    Ok(a), Ok(b) ->
      Graph(dict.merge(
        graph.node_dict,
        dict.from_list([
          #(from, Node(..a, out: [to, ..a.out])),
          #(to, Node(..b, in: [from, ..b.in])),
        ]),
      ))
    _, _ -> {
      // io.debug("Couldn't connect graph nodes: ")
      // io.debug([from, to])
      graph
    }
  }
}

pub fn from_lists(from: List(List(value))) -> Graph(#(Int, Int), value, label) {
  from
  |> list.index_map(fn(inner_list, y) {
    inner_list
    |> list.index_map(fn(value, x) { #(#(x, y), value) })
  })
  |> list.flatten
  |> list.fold(new(), fn(graph, node_params) {
    let #(id, value) = node_params
    add(graph, Node(id, value, [], []))
  })
}

fn links(graph: Graph(id, String, String)) -> Set(#(id, id)) {
  graph.node_dict
  |> dict.values
  |> list.map(fn(from) {
    from.out
    |> list.map(fn(to_id) { #(from.id, to_id) })
  })
  |> list.flatten
  |> set.from_list
}

pub fn mermaid_graph(graph: Graph(id, String, String)) -> String {
  let node_lines =
    graph.node_dict
    |> dict.values
    |> list.map(fn(node) {
      "    " <> format_id(node.id) <> "[" <> format_label(node.value) <> "]"
    })
    |> string.join("\n")

  let links = links(graph)
  let links_reversed = links |> set.map(fn(ids) { #(ids.1, ids.0) })
  let links_unidirectional = set.difference(links, links_reversed)
  let links_bidirectional = set.difference(links, links_unidirectional)

  let links_bidirectional_lines =
    links_bidirectional
    |> set.fold(set.new(), fn(links_current, link) {
      case
        set.contains(links_current, link)
        || set.contains(links_current, #(link.1, link.0))
      {
        True -> links_current
        False -> set.insert(links_current, link)
      }
    })
    |> set.map(fn(ids) {
      let #(from_id, to_id) = ids
      "    " <> format_id(from_id) <> " <--> " <> format_id(to_id)
    })
    |> set.to_list
    |> string.join("\n")

  let links_unidirectional_lines =
    links_unidirectional
    |> set.map(fn(ids) {
      let #(from_id, to_id) = ids
      "    " <> format_id(from_id) <> " --> " <> format_id(to_id)
    })
    |> set.to_list
    |> string.join("\n")

  "flowchart LR\n"
  <> node_lines
  <> "\n\n"
  <> links_bidirectional_lines
  <> "\n\n"
  <> links_unidirectional_lines
}

pub fn mermaid_markdown(
  graph: Graph(id, String, String),
  filename: String,
) -> Graph(id, String, String) {
  let assert Ok(_) =
    { "```mermaid\n" <> mermaid_graph(graph) <> "\n```" }
    |> simplifile.write(filename, _)
  graph
}

fn format_id(id: id) -> String {
  id
  |> string.inspect
  |> remove_chars(" #\"()")
  |> string.replace(",", "_")
}

fn format_label(id: id) -> String {
  "\""
  <> id
  |> string.inspect
  |> remove_chars("\"")
  <> "\""
}

fn remove_chars(string: String, chars: String) -> String {
  chars
  |> string.to_graphemes
  |> list.fold(string, fn(a, b) { string.replace(a, b, "") })
}

/// Just an example
pub fn main() {
  new()
  |> add(Node(#(1, 1), "A", [], []))
  |> add(Node(#(1, 2), "B", [], []))
  |> add(Node(#(2, 2), "C", [], []))
  |> connect(#(1, 1), #(1, 2))
  |> connect(#(1, 1), #(2, 2))
  |> mermaid_markdown("test_graph.md")
}
