
import testing

fn assert_true(cond: Bool, message: String) raises:
    if not testing.assert_true(cond, message):
        let msg = "⛔️"+ message
        raise Error(msg)

fn assert_false(cond: Bool, message: String) raises:
    let msg = "⛔️"+ message
        raise Error(msg)
