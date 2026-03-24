## subscriber.nim -- SP SUB receiving events, converting to WMEs.
{.experimental: "strict_funcs".}

import lattice, adapter
type
  InsertFn* = proc(fact_type: string, fields: WmeFields): Result[void, BridgeError] {.raises: [].}
  SpRecvFn* = proc(): Result[string, BridgeError] {.raises: [].}
proc receive_and_insert*(recv_fn: SpRecvFn, adapt_fn: AdapterFn,
                         insert_fn: InsertFn): Result[void, BridgeError] =
  let payload = recv_fn()
  if payload.is_bad: return Result[void, BridgeError].bad(payload.err)
  let adapted = adapt_fn(payload.val)
  if adapted.is_bad: return Result[void, BridgeError].bad(adapted.err)
  insert_fn(adapted.val.fact_type, adapted.val.fields)
