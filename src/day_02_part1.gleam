import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_02/test1.txt", Some("2")),
  TestCase("inputs/day_02/input.txt", None),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  common.readlines(input_file)
  |> list.map(parse_line)
  |> list.count(fn(report: List(Int)) {
    increasing_slowly(report) || decreasing_slowly(report)
  })
  |> int.to_string
}

fn parse_line(line: String) -> List(Int) {
  line |> string.split(" ") |> list.map(int.parse) |> result.values
}

fn increasing_slowly(report: List(Int)) -> Bool {
  report
  |> list.window_by_2
  |> list.all(fn(a) { 0 < a.1 - a.0 && a.1 - a.0 < 4 })
}

fn decreasing_slowly(report: List(Int)) -> Bool {
  report
  |> list.window_by_2
  |> list.all(fn(a) { 0 < a.0 - a.1 && a.0 - a.1 < 4 })
}
