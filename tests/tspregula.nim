{.experimental: "strict_funcs".}
import std/[unittest, strutils, tables]
import spregula
suite "adapter":
  test "kv adapter":
    let r = kv_adapter("type=temperature\nvalue=25\nunit=C")
    check r.is_good
    check r.val.fact_type == "temperature"
    check r.val.fields["value"] == "25"
suite "subscriber":
  test "receive and insert":
    let mock_recv: SpRecvFn = proc(): Result[string, BridgeError] {.raises: [].} =
      Result[string, BridgeError].good("type=test\nk=v")
    var inserted = false
    let mock_insert: InsertFn = proc(ft: string, f: WmeFields): Result[void, BridgeError] {.raises: [].} =
      inserted = true
      Result[void, BridgeError](ok: true)
    let r = receive_and_insert(mock_recv, kv_adapter, mock_insert)
    check r.is_good
    check inserted
suite "publisher":
  test "publish kv":
    var sent = ""
    let mock_send: SpSendFn = proc(p: string): Result[void, BridgeError] {.raises: [].} =
      sent = p; Result[void, BridgeError](ok: true)
    discard publish_kv(mock_send, {"a": "1"}.toTable)
    check sent.contains("a=1")
suite "session":
  test "step":
    let mock_recv: SpRecvFn = proc(): Result[string, BridgeError] {.raises: [].} =
      Result[string, BridgeError].good("type=t\nx=1")
    let mock_send: SpSendFn = proc(p: string): Result[void, BridgeError] {.raises: [].} =
      Result[void, BridgeError](ok: true)
    let mock_insert: InsertFn = proc(ft: string, f: WmeFields): Result[void, BridgeError] {.raises: [].} =
      Result[void, BridgeError](ok: true)
    let mock_fire = proc(): int = 2
    var s = new_session(mock_recv, mock_send, kv_adapter, mock_insert, mock_fire)
    let r = s.step()
    check r.is_good
    check r.val == 2
    check s.events_processed == 1
