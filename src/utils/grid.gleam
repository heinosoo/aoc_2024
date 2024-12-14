import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string

pub type Point =
  #(Int, Int)

pub type Grid(t) =
  Dict(Point, t)

pub fn from_lists(from: List(List(t))) -> Grid(t) {
  from
  |> list.index_map(fn(inner_list, y) {
    inner_list
    |> list.index_map(fn(value, x) { #(#(x, y), value) })
  })
  |> list.flatten
  |> dict.from_list
}

pub fn from_value(value: t, size: Point) -> Grid(t) {
  list.range(0, size.0)
  |> list.flat_map(fn(x) {
    list.range(0, size.1) |> list.map(fn(y) { #(#(x, y), value) })
  })
  |> dict.from_list
}

pub fn get(grid: Grid(t), x: Int, y: Int) -> t {
  let assert Ok(value) = dict.get(grid, #(x, y))
  value
}

pub fn subgrid(grid: Grid(t), a: Point, b: Point) -> Grid(t) {
  let min_x = int.min(a.0, b.0)
  let min_y = int.min(a.1, b.1)

  point_range(a, b)
  |> list.map(fn(c) { #(#(c.0 - min_x, c.1 - min_y), get(grid, c.0, c.1)) })
  |> dict.from_list
}

fn point_range(a: Point, b: Point) {
  list.range(a.0, b.0)
  |> list.flat_map(fn(x) { list.range(a.1, b.1) |> list.map(fn(y) { #(x, y) }) })
}

pub fn find_subgrids(from: Grid(t), sub: Grid(Option(t))) -> List(Point) {
  let #(max_x, max_y) = max_coords(from)
  let #(sub_x, sub_y) = max_coords(sub)

  case sub_x > max_x || sub_y > max_y {
    True -> list.new()
    False ->
      point_range(#(0, 0), #(max_x - sub_x, max_y - sub_y))
      |> list.filter(fn(a) {
        list.all(dict.keys(sub), fn(sub_point) {
          let value_grid =
            dict.get(from, #(a.0 + sub_point.0, a.1 + sub_point.1))
          let value_subgrid =
            dict.get(sub, sub_point) |> option.from_result |> option.flatten

          case value_grid, value_subgrid {
            Ok(value_grid), option.Some(value_subgrid) ->
              value_grid == value_subgrid
            _, _ -> True
          }
        })
      })
  }
}

pub fn max_coords(grid: Grid(t)) -> Point {
  grid
  |> dict.keys
  |> list.reduce(fn(a, b) {
    case a.0 >= b.0 && a.1 >= b.1 {
      True -> a
      False -> b
    }
  })
  |> result.unwrap(#(0, 0))
}

pub fn print(grid: Grid(String)) -> Grid(String) {
  let #(max_x, max_y) = max_coords(grid)

  list.range(0, max_y)
  |> list.map(fn(y) {
    list.range(0, max_x) |> list.map(get(grid, _, y)) |> string.concat
  })
  |> list.each(io.println)

  grid
}
