## adapter.nim -- SP message -> regula WME conversion.
{.experimental: "strict_funcs".}
import std/[strutils, tables]
import lattice
type
  WmeFields* = Table[string, string]
  AdapterFn* = proc(payload: string): Result[tuple[fact_type: string, fields: WmeFields], BridgeError] {.raises: [].}
proc kv_adapter*(payload: string): Result[tuple[fact_type: string, fields: WmeFields], BridgeError] =
  var fields: WmeFields
  var fact_type = "event"
  for line in payload.splitLines():
    let trimmed = line.strip()
    if trimmed.len == 0: continue
    let eq = trimmed.find('=')
    if eq > 0:
      let k = trimmed[0 ..< eq].strip()
      let v = trimmed[eq + 1 ..< trimmed.len].strip()
      if k == "type": fact_type = v
      else: fields[k] = v
  Result[tuple[fact_type: string, fields: WmeFields], BridgeError].good((fact_type: fact_type, fields: fields))
