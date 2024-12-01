import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub type XY =
  #(Int, Int)

pub type Matrix(t) =
  Dict(XY, t)

pub fn get(matrix: Matrix(t), x: Int, y: Int) -> t {
  let assert Ok(value) = dict.get(matrix, #(x, y))
  value
}

pub fn from_lists(from: List(List(t))) -> Matrix(t) {
  from
  |> list.index_map(fn(inner_list, y) {
    inner_list
    |> list.index_map(fn(value, x) { #(#(x, y), value) })
  })
  |> list.flatten
  |> dict.from_list
}

pub fn max_coords(matrix: Matrix(t)) -> XY {
  matrix
  |> dict.keys
  |> list.reduce(fn(a, b) {
    case a.0 >= b.0 && a.1 >= b.1 {
      True -> a
      False -> b
    }
  })
  |> result.unwrap(#(0, 0))
}

pub fn print(matrix: Matrix(String)) -> Matrix(String) {
  let #(max_x, max_y) = max_coords(matrix)

  list.range(0, max_y)
  |> list.map(fn(y) {
    list.range(0, max_x) |> list.map(get(matrix, _, y)) |> string.concat
  })
  |> list.each(io.println)

  matrix
}
