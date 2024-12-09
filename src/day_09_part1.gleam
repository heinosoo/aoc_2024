import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_09/test1.txt", "1928"),
  TestCase("inputs/day_09/input.txt", "6310675819476"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  let disk =
    common.readlines(input_file)
    |> string.concat
    |> unfold

  let replacements = disk |> option.values |> list.reverse

  disk
  |> list.take(list.length(replacements))
  |> checksum(replacements, 0, 0)
  |> int.to_string
}

fn unfold(raw_disk: String) {
  raw_disk
  |> string.to_graphemes
  |> list.index_map(fn(character, index) {
    let assert Ok(n) = int.parse(character)
    case index % 2 == 0 {
      True -> list.repeat(Some(index / 2), n)
      False -> list.repeat(None, n)
    }
  })
  |> list.flatten
}

fn checksum(
  disk: List(Option(Int)),
  replacements: List(Int),
  index: Int,
  sum: Int,
) -> Int {
  let assert Ok(disk_first) = disk |> list.first
  let assert Ok(disk_rest) = disk |> list.rest

  let #(next, replacements) = case disk_first {
    None -> {
      let assert Ok(replacements_first) = replacements |> list.first
      let assert Ok(replacements_rest) = replacements |> list.rest
      #(replacements_first, replacements_rest)
    }
    Some(file_id) -> #(file_id, replacements)
  }

  case list.length(disk_rest) {
    0 -> sum + index * next
    _ -> checksum(disk_rest, replacements, index + 1, sum + index * next)
  }
}
