import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/string
import utils/common
import utils/testing.{TestCase}

const test_cases = [
  TestCase("inputs/day_13/test1.txt", "480"),
  TestCase("inputs/day_13/input.txt", "36870"),
]

pub fn main() {
  testing.check_solution(solve, test_cases)
}

fn solve(input_file: String) -> String {
  let assert Ok(machine_regex) =
    regexp.from_string(
      "Button A: X\\+(\\d+), Y\\+(\\d+)Button B: X\\+(\\d+), Y\\+(\\d+)Prize: X=(\\d+), Y=(\\d+)",
    )

  common.readlines(input_file)
  |> string.concat
  |> regexp.scan(machine_regex, _)
  |> list.map(fn(x) {
    case x.submatches |> list.map(fn(x) { option.map(x, int.parse) }) {
      [
        Some(Ok(ax)),
        Some(Ok(ay)),
        Some(Ok(bx)),
        Some(Ok(by)),
        Some(Ok(cx)),
        Some(Ok(cy)),
      ] -> solve_machine(ax, ay, bx, by, cx, cy)
      _ -> 0
    }
  })
  |> int.sum
  |> int.to_string
}

fn solve_machine(ax: Int, ay: Int, bx: Int, by: Int, cx: Int, cy: Int) -> Int {
  let ab = ax * by - ay * bx
  let cb = cx * by - cy * bx
  let ca = cx * ay - cy * ax

  case cb % ab, ca % ab {
    0, 0 -> 3 * cb / ab - ca / ab
    _, _ -> 0
  }
}
