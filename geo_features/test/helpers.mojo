import testing


fn assert_true(cond: Bool, message: String) raises:
    """
    Wraps testing.assert_true, raises Error on assertion failure.
    """
    if not testing.assert_true(cond, message):
        print("⛔️", message)
        raise Error("stopping")
        # FIXME https://github.com/modularml/mojo/issues/1004
        # raise Error(message)  # message is printed by testing.assert_true()
