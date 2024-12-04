import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_04/test1.txt", "18"),
  TestCase("inputs/day_04/input.txt", "2642"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file) {
  common.readlines(input_file)
  |> transform_lines
  |> count_xmas
  |> int.to_string
}

fn transform_lines(lines) -> List(String) {
  let original = string.join(lines, "\n")
  let rotated_90 = string.join(rotate_90(lines), "\n")
  let rotated_45 = string.join(rotate_45(lines), "\n")
  let rotated_315 = string.join(rotate_315(lines), "\n")

  [
    original,
    string.reverse(original),
    rotated_90,
    string.reverse(rotated_90),
    rotated_45,
    string.reverse(rotated_45),
    rotated_315,
    string.reverse(rotated_315),
  ]
}

fn rotate_90(lines: List(String)) {
  lines
  |> list.map(string.to_graphemes)
  |> list.transpose
  |> list.map(string.concat)
}

fn rotate_45(lines: List(String)) {
  let line_length = string.length(result.unwrap(list.first(lines), ""))

  lines
  |> list.map_fold(0, fn(i, line) {
    #(
      i + 1,
      string.repeat("#", i) <> line <> string.repeat("#", line_length - i),
    )
  })
  |> pair.second
  |> rotate_90
}

fn rotate_315(lines: List(String)) {
  let line_length = string.length(result.unwrap(list.first(lines), ""))

  lines
  |> list.map_fold(0, fn(i, line) {
    #(
      i + 1,
      string.repeat("#", line_length - i) <> line <> string.repeat("#", i),
    )
  })
  |> pair.second
  |> rotate_90
}

fn count_xmas(lines) {
  lines
  |> string.join("\n")
  |> string.split("XMAS")
  |> list.length
  |> int.subtract(1)
}
