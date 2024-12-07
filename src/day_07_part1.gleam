import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_07/test1.txt", "3749"),
  TestCase("inputs/day_07/input.txt", "21572148763543"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  common.readlines(input_file)
  |> list.fold(0, fn(sum, line) {
    let #(test_value, numbers) = parse_line(line)
    find_test_value(numbers, test_value)
    |> option.unwrap(0)
    |> int.add(sum)
  })
  |> int.to_string
}

fn parse_line(line: String) -> #(Int, List(Int)) {
  let assert Ok(#(a, b)) = string.split_once(line, ": ")
  let assert Ok(a) = int.parse(a)
  let b =
    string.split(b, " ") |> list.map(int.parse) |> result.values |> list.reverse
  #(a, b)
}

fn find_test_value(numbers: List(Int), test_value: Int) -> Option(Int) {
  case numbers {
    [] -> None
    [first] ->
      case first == test_value {
        False -> None
        True -> Some(first)
      }
    [first, ..rest] ->
      try_add(first, rest, test_value)
      |> option.or(try_multiply(first, rest, test_value))
  }
}

fn try_add(first: Int, rest: List(Int), test_value: Int) -> Option(Int) {
  case first <= test_value {
    False -> None
    True ->
      find_test_value(rest, test_value - first)
      |> option.map(int.add(_, first))
  }
}

fn try_multiply(first: Int, rest: List(Int), test_value: Int) -> Option(Int) {
  case test_value % first == 0 {
    False -> None
    True ->
      find_test_value(rest, test_value / first)
      |> option.map(int.multiply(_, first))
  }
}
