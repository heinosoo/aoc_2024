import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import utils/common
import utils/grid
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_04/test1.txt", "9"),
  TestCase("inputs/day_04/input.txt", "1974"),
]

const patterns = [
  [
    [Some("M"), None, Some("S")], [None, Some("A"), None],
    [Some("M"), None, Some("S")],
  ],
  [
    [Some("M"), None, Some("M")], [None, Some("A"), None],
    [Some("S"), None, Some("S")],
  ],
  [
    [Some("S"), None, Some("M")], [None, Some("A"), None],
    [Some("S"), None, Some("M")],
  ],
  [
    [Some("S"), None, Some("S")], [None, Some("A"), None],
    [Some("M"), None, Some("M")],
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
