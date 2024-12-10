import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/string
import utils/common
import utils/grid.{type Grid}
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_10/test1.txt", "16"),
  TestCase("inputs/day_10/test2.txt", "81"),
  TestCase("inputs/day_10/input.txt", "1459"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  let map =
    common.readlines(input_file)
    |> list.map(string.to_graphemes)
    |> grid.from_lists
    |> dict.map_values(fn(_, value) {
      let assert Ok(value) = int.parse(value)
      value
    })

  map
  |> grid.find_subgrids(grid.from_lists([[Some(0)]]))
  |> list.fold(0, fn(sum, trailhead) {
    sum + count_trails(dict.from_list([#(trailhead, 1)]), map, 8)
  })
  |> int.to_string
}

fn count_trails(edge: Dict(#(Int, Int), Int), map: Grid(Int), length: Int) {
  case dict.size(edge), length, next(edge, map) {
    0, _, _ -> 0
    _, 0, new_edge -> new_edge |> dict.values |> int.sum
    _, _, new_edge -> count_trails(new_edge, map, length - 1)
  }
}

fn next(edge: Dict(#(Int, Int), Int), map: Grid(Int)) {
  edge
  |> dict.fold(dict.new(), fn(edge, before, rating) {
    [
      #(before.0 - 1, before.1),
      #(before.0 + 1, before.1),
      #(before.0, before.1 - 1),
      #(before.0, before.1 + 1),
    ]
    |> list.filter(fn(after) {
      case dict.get(map, before), dict.get(map, after) {
        Ok(before), Ok(after) -> before + 1 == after
        _, _ -> False
      }
    })
    |> list.map(fn(p) { #(p, rating) })
    |> dict.from_list
    |> dict.combine(edge, int.add)
  })
}
