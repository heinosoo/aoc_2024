import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_01/test.txt", Some("31")),
  TestCase("inputs/day_01/input.txt", Some("29379307")),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  common.readlines(input_file)
  |> list.map(parse_line)
  |> result.values
  |> list.unzip
  |> combinations
  |> list.fold(0, fn(sum, pair) {
    case pair.0 == pair.1 {
      True -> sum + pair.1
      False -> sum
    }
  })
  |> int.to_string
}

fn combinations(columns: #(List(Int), List(Int))) -> List(#(Int, Int)) {
  columns.0
  |> list.flat_map(fn(item_0) {
    list.map(columns.1, fn(item_1) { #(item_0, item_1) })
  })
}

fn parse_line(line: String) -> Result(#(Int, Int), String) {
  let line_as_list =
    line |> string.split("   ") |> list.map(int.parse) |> result.values

  case line_as_list {
    [first, second] -> Ok(#(first, second))
    _ -> Error("Two numbers expected.")
  }
}
