import gleam/int
import gleam/list
import gleam/pair
import gleam/regexp
import gleam/result
import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_05/test1.txt", "143"),
  TestCase("inputs/day_05/input.txt", "4185"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) {
  let #(rules, updates) =
    common.readlines(input_file)
    |> list.split_while(fn(x) { x != "" })
    |> pair.map_first(parse_rules)

  updates
  |> list.filter_map(fn(update) {
    case rules |> list.any(regexp.check(_, update)) {
      True -> Error("")
      False -> middle_page(update)
    }
  })
  |> int.sum
  |> int.to_string
}

fn middle_page(update) {
  let len = string.length(update)
  update
  |> string.to_graphemes
  |> list.drop(len / 2 - 1)
  |> list.take(2)
  |> string.concat
  |> int.parse
  |> result.replace_error("")
}

fn parse_rules(rule_lines) {
  rule_lines
  |> list.map(string.split_once(_, "|"))
  |> result.values
  |> list.map(fn(pair) {
    let assert Ok(rule) =
      regexp.from_string("(.*)(" <> pair.1 <> ")(,.*)(" <> pair.0 <> ")(.*)")
    rule
  })
}
