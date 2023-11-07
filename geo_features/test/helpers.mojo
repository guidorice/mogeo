import testing


fn assert_true(cond: Bool, message: String) raises:
    """
    Wraps testing.assert_true, raises Error on assertion failure.
    """
    if not testing.assert_true(cond, message):
        # TODO: raise Error(message)
        # sometimes fails to compile with error: unable to find '$helpers' symbol

        # raise Error(message)

        print(message)
        raise Error("assertion failed")
