import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import utils/common
import utils/grid.{type Grid, type Point}
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_15/test1.txt", "1751"),
  TestCase("inputs/day_15/test2.txt", "9021"),
  TestCase("inputs/day_15/test3.txt", "618"),
  TestCase("inputs/day_15/input.txt", "1492011"),
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
    parse_moves(move_lines) |> list.fold(initial_state, { next_state })

  final_map |> gps_score |> int.to_string
}

fn next_state(state: State, direction: Direction) -> State {
  let #(robot, map) = state

  case push(set.from_list([robot]), map, direction) {
    None -> state
    Some(pushed) -> #(
      move(robot, direction),
      map |> move_all(pushed, direction),
    )
  }
}

fn move_all(map: Grid(String), objects: Set(Point), direction: Direction) {
  let first_remove =
    objects |> set.fold(map, fn(map, point) { dict.insert(map, point, ".") })

  objects
  |> set.fold(first_remove, fn(new_map, point) {
    let assert Ok(value) = map |> dict.get(point)
    new_map
    |> dict.insert(point |> move(direction), value)
  })
}

fn push(
  objects: Set(Point),
  map: Grid(String),
  direction: Direction,
) -> option.Option(Set(Point)) {
  let next =
    objects
    |> set.fold(set.new(), fn(colliding, object) {
      let moved = move(object, direction)
      case dict.get(map, moved) {
        Ok("#") -> colliding |> set.insert(moved)
        Ok("[") ->
          colliding |> set.insert(moved) |> set.insert(moved |> move(Right))
        Ok("]") ->
          colliding |> set.insert(moved) |> set.insert(moved |> move(Left))
        _ -> colliding
      }
    })

  case
    can_move_further(next, map),
    should_move_further(next |> set.difference(objects), map)
  {
    False, _ -> {
      None
    }
    _, False -> Some(objects)
    True, True -> push(set.union(objects, next), map, direction)
  }
}

fn can_move_further(colliding, map) {
  colliding
  |> set.to_list
  |> list.any(fn(x) { map |> dict.get(x) == Ok("#") })
  |> bool.negate
}

fn should_move_further(colliding, map) {
  colliding
  |> set.to_list
  |> list.all(fn(x) { map |> dict.get(x) == Ok(".") })
  |> bool.negate
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
      "[" -> sum + point.0 + 100 * point.1
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
  let map =
    map_lines
    |> list.map(fn(line) {
      line
      |> string.replace("#", "##")
      |> string.replace("O", "[]")
      |> string.replace(".", "..")
      |> string.replace("@", "@.")
      |> string.to_graphemes
    })
    |> grid.from_lists

  let assert Ok(robot) =
    map |> grid.find_subgrids(grid.from_value(Some("@"), #(0, 0))) |> list.first

  #(robot, map |> dict.insert(robot, "."))
}
