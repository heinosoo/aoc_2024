import gleam/int
import gleam/list
import gleam/result
import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_11/test1.txt", "55312"),
  TestCase("inputs/day_11/input.txt", "212655"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  common.readlines(input_file)
  |> string.concat
  |> string.split(" ")
  |> list.map(stones(_, 25))
  |> int.sum
  |> int.to_string
}

fn stones(stone: String, blinks: Int) -> Int {
  case blinks, stone, string.length(stone) % 2 == 0 {
    0, _, _ -> 1
    _, "0", _ -> stones("1", blinks - 1)
    _, _, True -> stone |> split(blinks)
    _, _, False ->
      stone
      |> int.parse
      |> result.unwrap(0)
      |> int.multiply(2024)
      |> int.to_string
      |> stones(blinks - 1)
  }
}

fn split(stone: String, blinks) -> Int {
  let half = string.length(stone) / 2
  let left_half = stone |> string.drop_right(half) |> trim
  let right_half = stone |> string.drop_left(half) |> trim
  stones(left_half, blinks - 1) + stones(right_half, blinks - 1)
}

fn trim(stone: String) -> String {
  stone |> int.parse |> result.unwrap(0) |> int.to_string
}
