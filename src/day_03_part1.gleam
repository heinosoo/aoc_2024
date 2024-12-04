import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_03/test1.txt", "161"),
  TestCase("inputs/day_03/input.txt", "189600467"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  let assert Ok(mul_regex) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")

  common.readlines(input_file)
  |> string.concat
  |> regexp.scan(mul_regex, _)
  |> list.map(multiply)
  |> int.sum
  |> int.to_string
}

fn multiply(match: regexp.Match) -> Int {
  match.submatches
  |> option.values
  |> list.map(int.parse)
  |> result.values
  |> int.product
}
