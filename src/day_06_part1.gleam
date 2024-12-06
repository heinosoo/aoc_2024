import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/set.{type Set}
import gleam/string
import utils/common
import utils/grid.{type Point}
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_06/test1.txt", "41"),
  TestCase("inputs/day_06/input.txt", "5404"),
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

  let obstacles =
    grid.find_subgrids(map, grid.from_lists([[Some("#")]]))
    |> set.from_list
  let visited =
    grid.find_subgrids(map, grid.from_lists([[Some("^")]]))
    |> set.from_list
  let corner = grid.max_coords(map)
  let assert Ok(guard_start) = visited |> set.to_list |> list.first

  let visited = walk(Up(guard_start), visited, obstacles, corner)

  visited |> set.size |> int.to_string
}

fn walk(
  guard: Guard,
  visited: Set(Point),
  obstacles: Set(Point),
  corner: Point,
) -> Set(Point) {
  let guard = next(guard, obstacles)
  case out(guard, corner) {
    False -> walk(guard, set.insert(visited, guard.pos), obstacles, corner)
    True -> visited
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
