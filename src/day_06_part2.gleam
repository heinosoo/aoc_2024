import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/otp/task
import gleam/set.{type Set}
import gleam/string
import utils/common
import utils/grid.{type Point}
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_06/test1.txt", "6"),
  TestCase("inputs/day_06/input.txt", "1984"),
]

type Guard {
  Up(pos: Point)
  Down(pos: Point)
  Left(pos: Point)
  Right(pos: Point)
}

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  let map =
    common.readlines(input_file)
    |> list.map(string.to_graphemes)
    |> grid.from_lists

  let corner = grid.max_coords(map)
  let obstacles =
    grid.find_subgrids(map, grid.from_lists([[Some("#")]]))
    |> set.from_list
  let visited =
    grid.find_subgrids(map, grid.from_lists([[Some("^")]]))
    |> set.from_list
    |> set.map(Up)

  let assert Ok(guard_start) = visited |> set.to_list |> list.first

  map
  |> dict.map_values(fn(pos, item) {
    case item {
      "^" -> task.async(fn() { False })
      "#" -> task.async(fn() { False })
      _ ->
        task.async(fn() {
          walk(guard_start, visited, set.insert(obstacles, pos), corner)
        })
    }
  })
  |> dict.filter(fn(_, task) { task.await(task, 30) })
  |> dict.size
  |> int.to_string
}

fn walk(
  guard: Guard,
  visited: Set(Guard),
  obstacles: Set(Point),
  corner: Point,
) -> Bool {
  let guard = next(guard, obstacles)
  case out(guard, corner) {
    False ->
      case set.contains(visited, guard) {
        False -> walk(guard, set.insert(visited, guard), obstacles, corner)
        True -> True
      }
    True -> False
  }
}

fn out(guard: Guard, corner: Point) -> Bool {
  guard.pos.0 < 0
  || guard.pos.0 > corner.0
  || guard.pos.1 < 0
  || guard.pos.1 > corner.1
}

fn next(guard: Guard, obstacles: Set(Point)) -> Guard {
  let next_guard = case guard {
    Up(pos) -> Up(#(pos.0, pos.1 - 1))
    Right(pos) -> Right(#(pos.0 + 1, pos.1))
    Down(pos) -> Down(#(pos.0, pos.1 + 1))
    Left(pos) -> Left(#(pos.0 - 1, pos.1))
  }

  case guard, set.contains(obstacles, next_guard.pos) {
    _, False -> next_guard
    Up(_), True -> Right(guard.pos)
    Right(_), True -> Down(guard.pos)
    Down(_), True -> Left(guard.pos)
    Left(_), True -> Up(guard.pos)
  }
}
