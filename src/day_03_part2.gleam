import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_03/test2.txt", "48"),
  TestCase("inputs/day_03/input.txt", "107069718"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  let assert Ok(mul_regex) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")

  common.readlines(input_file)
  |> string.concat
  |> remove_between_dont_and_do
  |> regexp.scan(mul_regex, _)
  |> list.map(multiply)
  |> int.sum
  |> int.to_string
}

fn remove_between_dont_and_do(program: String) -> String {
  let assert Ok(dont_regex) = regexp.from_string("don't\\(\\)")
  let assert Ok(do_regex) = regexp.from_string("do\\(\\)")

  regexp.split(do_regex, program)
  |> list.map(fn(x) {
    regexp.split(dont_regex, x) |> list.first |> result.unwrap("")
  })
  |> string.join("$")
}

fn multiply(match: regexp.Match) -> Int {
  match.submatches
  |> option.values
  |> list.map(int.parse)
  |> result.values
  |> int.product
}
