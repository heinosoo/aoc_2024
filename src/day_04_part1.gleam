import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import utils/common
import utils/grid
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_04/test1.txt", Some("18")),
  TestCase("inputs/day_04/input.txt", Some("2642")),
]

const patterns = [
  [[Some("X"), Some("M"), Some("A"), Some("S")]],
  [[Some("S"), Some("A"), Some("M"), Some("X")]],
  [[Some("X")], [Some("M")], [Some("A")], [Some("S")]],
  [[Some("S")], [Some("A")], [Some("M")], [Some("X")]],
  [
    [Some("X"), None, None, None], [None, Some("M"), None, None],
    [None, None, Some("A"), None], [None, None, None, Some("S")],
  ],
  [
    [None, None, None, Some("X")], [None, None, Some("M"), None],
    [None, Some("A"), None, None], [Some("S"), None, None, None],
  ],
  [
    [Some("S"), None, None, None], [None, Some("A"), None, None],
    [None, None, Some("M"), None], [None, None, None, Some("X")],
  ],
  [
    [None, None, None, Some("S")], [None, None, Some("A"), None],
    [None, Some("M"), None, None], [Some("X"), None, None, None],
  ],
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file) {
  let full_grid =
    common.readlines(input_file)
    |> list.map(string.to_graphemes)
    |> grid.from_lists

  patterns
  |> list.map(grid.from_lists)
  |> list.flat_map(grid.find_subgrids(full_grid, _))
  |> list.length
  |> int.to_string
}
