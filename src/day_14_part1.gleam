import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/regexp
import gleam/result
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_14/test1.txt", "21"),
  TestCase("inputs/day_14/input.txt", "218619120"),
]

const seconds = 100

const space = #(101, 103)

type Robot =
  #(Int, Int, Int, Int)

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  let assert Ok(pv_regex) =
    regexp.from_string("p=(-?\\d+),(-?\\d+) v=(-?\\d+),(-?\\d+)")

  common.readlines(input_file)
  |> list.map(fn(line) {
    case
      regexp.scan(pv_regex, line)
      |> list.first
      |> result.map(fn(x) {
        x.submatches |> option.values |> list.map(int.parse)
      })
    {
      Ok([Ok(px), Ok(py), Ok(vx), Ok(vy)]) -> Some(move(#(px, py, vx, vy)))
      _ -> None
    }
  })
  |> option.values
  |> list.filter(fn(robot) { robot.0 != space.0 / 2 && robot.1 != space.1 / 2 })
  |> list.group(quadrant)
  |> dict.values
  |> list.map(list.length)
  |> list.fold(1, int.multiply)
  |> int.to_string
}

fn quadrant(robot: Robot) -> Int {
  case robot.0 < space.0 / 2, robot.1 < space.1 / 2 {
    False, False -> 1
    False, True -> 2
    True, False -> 3
    True, True -> 4
  }
}

fn move(robot: Robot) -> Robot {
  #(
    { { robot.0 + robot.2 * seconds } % space.0 + space.0 } % space.0,
    { { robot.1 + robot.3 * seconds } % space.1 + space.1 } % space.1,
    robot.2,
    robot.3,
  )
}
