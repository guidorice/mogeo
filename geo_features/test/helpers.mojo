import testing

# TODO: raise with String https://github.com/modularml/mojo/issues/785


fn assert_true(cond: Bool, message: String) raises:
    """
    Wraps testing.assert_true, raises Error on assertion failure.
    """
    if not testing.assert_true(cond, message):
        raise Error("⛔️")  # message is printed by testing.assert_true()
