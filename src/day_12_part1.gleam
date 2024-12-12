import gleam/dict
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string
import utils/common
import utils/grid.{type Grid, type Point}
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_12/test1.txt", "140"),
  TestCase("inputs/day_12/test2.txt", "772"),
  TestCase("inputs/day_12/test3.txt", "1930"),
  TestCase("inputs/day_12/input.txt", "1421958"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  let map =
    common.readlines(input_file)
    |> list.map(string.to_graphemes)
    |> grid.from_lists

  fence_everything(map |> dict.keys |> set.from_list, map, 0) |> int.to_string
}

fn fence_everything(remaining: Set(Point), map: Grid(String), cost) -> Int {
  case dict.keys(remaining.dict) |> list.first {
    Error(_) -> cost
    Ok(plot) -> {
      let assert Ok(value) = dict.get(map, plot)
      let region = one_region(value, set.from_list([plot]), set.new(), map)
      fence_everything(
        remaining |> set.difference(region),
        map,
        cost + set.size(region) * perimeter(region),
      )
    }
  }
}

fn one_region(
  value: String,
  edge: Set(Point),
  region: Set(Point),
  map: Grid(String),
) -> Set(Point) {
  let potential_points =
    set.fold(edge, edge, fn(new_edge, point) {
      point
      |> plus
      |> set.union(new_edge)
      |> set.filter(fn(p) { dict.get(map, p) == Ok(value) })
    })

  let new_edge = set.difference(potential_points, region)
  let new_region = set.union(potential_points, region)

  case set.size(new_edge) {
    0 -> new_region
    _ -> one_region(value, new_edge, new_region, map)
  }
}

fn perimeter(points: Set(Point)) {
  points
  |> set.fold(0, fn(sum, point) {
    sum
    + 4
    - { point |> plus |> set.filter(set.contains(points, _)) |> set.size }
  })
}

pub fn plus(p: Point) -> Set(Point) {
  [#(p.0 - 1, p.1), #(p.0 + 1, p.1), #(p.0, p.1 - 1), #(p.0, p.1 + 1)]
  |> set.from_list
}
