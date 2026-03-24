## publisher.nim -- Regula rule actions publishing SP messages.
{.experimental: "strict_funcs".}
import std/[strutils, tables]
import lattice
type
  SpSendFn* = proc(payload: string): Result[void, BridgeError] {.raises: [].}
proc publish_kv*(send_fn: SpSendFn, fields: Table[string, string]): Result[void, BridgeError] =
  var lines: seq[string]
  for k, v in fields: lines.add(k & "=" & v)
  send_fn(lines.join("\n"))
