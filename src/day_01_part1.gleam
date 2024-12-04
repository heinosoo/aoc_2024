import gleam/int
import gleam/list
import gleam/result
import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_01/test.txt", "11"),
  TestCase("inputs/day_01/input.txt", "3246517"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  common.readlines(input_file)
  |> list.map(parse_line)
  |> result.values
  |> list.unzip
  |> fn(columns) {
    #(list.sort(columns.0, int.compare), list.sort(columns.1, int.compare))
  }
  |> fn(columns) { list.zip(columns.0, columns.1) }
  |> list.fold(0, fn(sum, a) { sum + int.absolute_value(a.0 - a.1) })
  |> int.to_string
}

fn parse_line(line: String) -> Result(#(Int, Int), String) {
  let line_as_list =
    line |> string.split("   ") |> list.map(int.parse) |> result.values

  case line_as_list {
    [first, second] -> Ok(#(first, second))
    _ -> Error("Two numbers expected.")
  }
}
