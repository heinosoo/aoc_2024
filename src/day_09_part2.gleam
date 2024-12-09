import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/result
import gleam/string
import utils/common
import utils/testing.{TestCase}

type Disk =
  List(#(Option(Int), Int))

const test_cases = [
  TestCase("inputs/day_09/test1.txt", "2858"),
  TestCase("inputs/day_09/test2.txt", "5"),
  TestCase("inputs/day_09/input.txt", "6335972980679"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  let disk =
    common.readlines(input_file)
    |> string.concat
    |> unfold

  let replacements =
    disk
    |> list.filter(fn(x) { option.is_some(x.0) })
    |> list.reverse

  disk
  |> compact(replacements)
  |> checksum(0)
  |> int.to_string
}

fn unfold(raw_disk: String) -> Disk {
  raw_disk
  |> string.to_graphemes
  |> list.index_map(fn(character, index) {
    let assert Ok(n) = int.parse(character)
    case index % 2 == 0 {
      True -> #(Some(index / 2), n)
      False -> #(None, n)
    }
  })
}

fn compact(disk: Disk, replacements: Disk) -> Disk {
  let assert Ok(file) = disk |> list.first
  let assert Ok(disk_rest) = disk |> list.rest

  case
    list.length(disk_rest),
    option.is_some(file.0) && !list.contains(replacements, file),
    try_replace(file, replacements)
  {
    0, True, _ -> []
    0, False, _ -> disk
    _, True, _ -> [#(None, file.1), ..compact(disk_rest, replacements)]
    _, False, #(#(None, _), replacements) -> [
      file,
      ..compact(disk_rest, replacements)
    ]
    _, False, #(replacement, replacements) -> [
      replacement,
      ..compact([#(None, file.1 - replacement.1), ..disk_rest], replacements)
    ]
  }
}

fn try_replace(file: #(Option(Int), Int), replacements: Disk) {
  case
    option.is_some(file.0),
    replacements |> list.pop(fn(replacement) { replacement.1 <= file.1 })
  {
    True, _ -> #(
      #(None, 0),
      replacements
        |> list.pop(fn(x) { x == file })
        |> result.map(pair.second)
        |> result.unwrap(replacements),
    )
    False, Error(_) -> #(#(None, 0), replacements)
    False, Ok(a) -> a
  }
}

fn checksum(disk: Disk, index: Int) -> Int {
  let assert Ok(#(id, size)) = disk |> list.first
  let assert Ok(disk_rest) = disk |> list.rest

  let addition = case id {
    None -> 0
    Some(id) -> {
      { size * { size - 1 } / 2 + { size * index } } * id
    }
  }

  case list.length(disk_rest) {
    0 -> addition
    _ -> addition + checksum(disk_rest, index + size)
  }
}
