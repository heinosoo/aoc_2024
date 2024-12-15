import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import utils/common
import utils/grid.{type Grid, type Point}
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_15/test1.txt", "2028"),
  TestCase("inputs/day_15/test2.txt", "10092"),
  TestCase("inputs/day_15/input.txt", "1486930"),
]

type Direction {
  Up
  Down
  Left
  Right
}

type State =
  #(Point, Grid(String))

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  let #(map_lines, move_lines) =
    common.readlines(input_file) |> list.split_while(fn(x) { x != "" })

  let initial_state = parse_map(map_lines)

  let #(_, final_map) =
    parse_moves(move_lines) |> list.fold(initial_state, next_state)

  final_map |> gps_score |> int.to_string
}

fn next_state(state: State, direction: Direction) -> State {
  let #(robot, map) = state

  case robot |> push(map, direction) {
    None -> state
    Some(empty_space) -> {
      let new_robot = move(robot, direction)
      case empty_space == new_robot {
        True -> #(new_robot, map)
        False -> #(
          new_robot,
          map |> dict.insert(new_robot, ".") |> dict.insert(empty_space, "O"),
        )
      }
    }
  }
}

fn push(
  object: Point,
  map: Grid(String),
  direction: Direction,
) -> option.Option(Point) {
  let next = object |> move(direction)

  case map |> dict.get(next) {
    Ok("O") -> push(next, map, direction)
    Ok(".") -> Some(next)
    _ -> None
  }
}

fn move(object: Point, direction: Direction) -> Point {
  case direction {
    Up -> #(object.0, object.1 - 1)
    Down -> #(object.0, object.1 + 1)
    Left -> #(object.0 - 1, object.1)
    Right -> #(object.0 + 1, object.1)
  }
}

fn gps_score(map: Grid(String)) -> Int {
  map
  |> dict.fold(0, fn(sum, point, value) {
    case value {
      "O" -> sum + point.0 + 100 * point.1
      _ -> sum
    }
  })
}

fn parse_moves(move_lines: List(String)) -> List(Direction) {
  move_lines
  |> string.concat
  |> string.to_graphemes
  |> list.map(fn(x) {
    case x {
      "^" -> Ok(Up)
      "v" -> Ok(Down)
      "<" -> Ok(Left)
      ">" -> Ok(Right)
      _ -> Error(Nil)
    }
  })
  |> result.values
}

fn parse_map(map_lines: List(String)) -> State {
  let map = map_lines |> list.map(string.to_graphemes) |> grid.from_lists

  let assert Ok(robot) =
    map |> grid.find_subgrids(grid.from_value(Some("@"), #(0, 0))) |> list.first

  #(robot, map |> dict.insert(robot, "."))
}
