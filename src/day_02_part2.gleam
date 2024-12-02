import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_02/test1.txt", Some("4")),
  TestCase("inputs/day_02/test2.txt", Some("1")),
  TestCase("inputs/day_02/input.txt", Some("311")),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  common.readlines(input_file)
  |> list.map(parse_line)
  |> list.count(fn(report) {
    list.range(0, list.length(report))
    |> list.any(valid_with_dropped_index(_, report))
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

fn valid_with_dropped_index(dropped_index, report) {
  let #(first_part_1, _) = list.split(report, dropped_index)
  let #(_, second_part_2) = list.split(report, dropped_index + 1)

  let first_part_with_next =
    list.append(first_part_1, result.values([list.first(second_part_2)]))

  let last_part_with_previous =
    list.append(result.values([list.last(first_part_1)]), second_part_2)

  {
    increasing_slowly(first_part_with_next)
    && increasing_slowly(last_part_with_previous)
  }
  || {
    decreasing_slowly(first_part_with_next)
    && decreasing_slowly(last_part_with_previous)
  }
}
