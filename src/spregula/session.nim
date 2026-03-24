## session.nim -- Combined SP + regula event loop.
{.experimental: "strict_funcs".}

import lattice, adapter, subscriber, publisher
type
  SpRegulaSession* = object
    recv_fn*: SpRecvFn
    send_fn*: SpSendFn
    adapt_fn*: AdapterFn
    insert_fn*: InsertFn
    fire_fn*: proc(): int {.raises: [].}
    events_processed*: int
proc new_session*(recv_fn: SpRecvFn, send_fn: SpSendFn, adapt_fn: AdapterFn,
                  insert_fn: InsertFn, fire_fn: proc(): int {.raises: [].}): SpRegulaSession =
  SpRegulaSession(recv_fn: recv_fn, send_fn: send_fn, adapt_fn: adapt_fn,
                  insert_fn: insert_fn, fire_fn: fire_fn)
proc step*(s: var SpRegulaSession): Result[int, BridgeError] =
  let r = receive_and_insert(s.recv_fn, s.adapt_fn, s.insert_fn)
  if r.is_bad: return Result[int, BridgeError].bad(r.err)
  inc s.events_processed
  let fired = s.fire_fn()
  Result[int, BridgeError].good(fired)
