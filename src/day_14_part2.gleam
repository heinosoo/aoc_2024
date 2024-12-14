import gleam/dict
import gleam/erlang
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/regexp
import gleam/result
import utils/common
import utils/grid
import utils/testing.{TestCase}

const test_cases = [TestCase("inputs/day_14/input.txt", "7055")]

const space = #(101, 103)

const pattern_first = 86

const pattern_period = 101

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
      Ok([Ok(px), Ok(py), Ok(vx), Ok(vy)]) -> Some(#(px, py, vx, vy))
      _ -> None
    }
  })
  |> option.values
  |> find_tree(pattern_first)
  |> int.to_string
}

fn find_tree(robots: List(Robot), seconds: Int) -> Int {
  print(robots, seconds)
  case
    erlang.get_line("Seconds: " <> int.to_string(seconds) <> "\nIs it a tree? ")
  {
    Ok("yes\n") -> seconds
    Ok(_) -> find_tree(robots, seconds + pattern_period)
    Error(_) -> 0
  }
}

fn print(robots: List(Robot), seconds) {
  robots
  |> list.map(move(_, seconds))
  |> list.fold(
    grid.from_value(" ", #(space.0 - 1, space.1 - 1)),
    fn(map, robot) { dict.insert(map, #(robot.0, robot.1), "@") },
  )
  |> grid.print
  robots
}

fn move(robot: Robot, seconds: Int) -> Robot {
  #(
    { { robot.0 + robot.2 * seconds } % space.0 + space.0 } % space.0,
    { { robot.1 + robot.3 * seconds } % space.1 + space.1 } % space.1,
    robot.2,
    robot.3,
  )
}
