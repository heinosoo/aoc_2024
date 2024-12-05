import gleam/int
import gleam/list
import gleam/order.{type Order, Gt, Lt}
import gleam/pair
import gleam/result
import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_05/test1.txt", "123"),
  TestCase("inputs/day_05/input.txt", "4480"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) {
  let #(rules, updates) =
    common.readlines(input_file)
    |> list.split_while(fn(x) { x != "" })
    |> pair.map_second(list.map(_, string.split(_, ",")))

  let order = create_order(rules)
  let sorted_updates = updates |> list.map(list.sort(_, order))

  list.zip(updates, sorted_updates)
  |> list.map(fn(update_pair) {
    case update_pair.0 == update_pair.1 {
      False -> middle(update_pair.1) |> int.parse |> result.unwrap(0)
      True -> 0
    }
  })
  |> int.sum
  |> int.to_string
}

fn create_order(rules: List(String)) -> fn(String, String) -> Order {
  fn(first, second) {
    case list.any(rules, fn(rule) { rule == first <> "|" <> second }) {
      False -> Gt
      True -> Lt
    }
  }
}

fn middle(update: List(String)) {
  let len = list.length(update)
  update
  |> list.drop(len / 2)
  |> list.first
  |> result.unwrap("0")
}
