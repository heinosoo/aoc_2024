import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/set
import gleam/string
import utils/common
import utils/grid
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_08/test1.txt", "14"),
  TestCase("inputs/day_08/input.txt", "390"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  let map =
    common.readlines(input_file)
    |> list.map(string.to_graphemes)
    |> grid.from_lists

  let corner = grid.max_coords(map)

  let frequencies =
    common.readlines(input_file)
    |> string.concat
    |> string.replace(".", "")
    |> string.to_graphemes
    |> set.from_list

  let antenna_pairs =
    frequencies
    |> set.to_list
    |> list.flat_map(fn(frequency) {
      grid.find_subgrids(map, grid.from_lists([[Some(frequency)]]))
      |> list.combination_pairs
    })

  let antinodes =
    antenna_pairs
    |> set.from_list
    |> set.fold(set.new(), add_antinodes(corner))

  antinodes |> set.size |> int.to_string
}

fn add_antinodes(corner: #(Int, Int)) {
  fn(antinodes: set.Set(#(Int, Int)), antenna_pair: #(#(Int, Int), #(Int, Int))) -> set.Set(
    #(Int, Int),
  ) {
    let new_antinodes = [
      #(
        antenna_pair.0.0 - { antenna_pair.1.0 - antenna_pair.0.0 },
        antenna_pair.0.1 - { antenna_pair.1.1 - antenna_pair.0.1 },
      ),
      #(
        antenna_pair.1.0 - { antenna_pair.0.0 - antenna_pair.1.0 },
        antenna_pair.1.1 - { antenna_pair.0.1 - antenna_pair.1.1 },
      ),
    ]

    new_antinodes
    |> list.filter(in_map(corner))
    |> set.from_list
    |> set.union(antinodes)
  }
}

fn in_map(corner: #(Int, Int)) {
  fn(point: #(Int, Int)) -> Bool {
    0 <= point.0 && point.0 <= corner.0 && 0 <= point.1 && point.1 <= corner.1
  }
}
