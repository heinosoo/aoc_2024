import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_xx/test1.txt", "1"),
  TestCase("inputs/day_xx/input.txt", "0"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  common.readlines(input_file) |> string.concat
}
