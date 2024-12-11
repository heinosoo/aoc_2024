import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_11/test1.txt", "65601038650482"),
  TestCase("inputs/day_11/input.txt", "253582809724830"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

type StoneCache =
  dict.Dict(#(String, Int), Int)

fn solve(input_file: String) -> String {
  common.readlines(input_file)
  |> string.concat
  |> string.split(" ")
  |> list.map_fold(dict.new(), fn(a, x) { stones(x, 75, a) |> pair.swap })
  |> pair.second
  |> int.sum
  |> int.to_string
}

fn stones(stone: String, blinks: Int, cache: StoneCache) -> #(Int, StoneCache) {
  case
    blinks,
    cache |> dict.get(#(stone, blinks)),
    stone,
    string.length(stone) % 2 == 0
  {
    0, _, _, _ -> #(1, cache)
    _, Ok(value), _, _ -> {
      #(value, cache)
    }
    _, _, "0", _ -> stones("1", blinks - 1, cache)
    _, _, _, True ->
      stone
      |> split(blinks, cache)
    _, _, _, False ->
      stone
      |> int.parse
      |> result.unwrap(0)
      |> int.multiply(2024)
      |> int.to_string
      |> stones(blinks - 1, cache)
  }
  |> fn(x) { #(x.0, x.1 |> dict.insert(#(stone, blinks), x.0)) }
}

fn split(stone: String, blinks: Int, cache: StoneCache) -> #(Int, StoneCache) {
  let half = string.length(stone) / 2

  let #(left_half, cache) =
    stone
    |> string.drop_right(half)
    |> trim
    |> stones(blinks - 1, cache)

  let #(right_half, cache) =
    stone
    |> string.drop_left(half)
    |> trim
    |> stones(blinks - 1, cache)

  #(left_half + right_half, cache)
}

fn trim(stone: String) -> String {
  stone |> int.parse |> result.unwrap(0) |> int.to_string
}
