import subprocess
import pytest

MOJO_CMD = ["mojo", "run", "-I", "."]
"""
mojo cmd to be run by pytest, assumes your mojo package is a subdirectory of cwd.
"""

TEST_PREFIX = "test_"
"""
example: `test_something.mojo`
"""


def pytest_collect_file(parent, file_path):
    """
    Pytest hook to collect test_*.mojo test files.
    """
    if file_path.suffix in (".mojo", ".🔥") and file_path.name.startswith(TEST_PREFIX):
        return MojoTestFile.from_parent(parent, path=file_path)


class MojoTestFile(pytest.File):
    """
    A custom file handler class for Mojo unit test files.
    """

    def collect(self):
        """
        Overridden collect method to collect the results from each Mojo unit test execution.
        """
        mojo_src = str(self.path)
        shell_cmd = MOJO_CMD.copy()
        shell_cmd.append(mojo_src)

        result = subprocess.run(shell_cmd, capture_output=True, text=True)

        # extract result stdout into one or more MojoTestItem
        lines = result.stdout.split("\n")
        lines = [line.strip() for line in lines]

        item_stdout = []
        cur_item = None
        for line in lines:
            print(line)  # can view with pytest -s
            if line.startswith("#"):  # by convention, a comment line signals the test item name
                if cur_item is not None:
                    # yield the cur item
                    yield MojoTestItem.from_parent(self, name=cur_item, spec=dict(stdout=item_stdout, code=0))
                cur_item = line
                item_stdout = []
            else:
                item_stdout.append(line)
        if cur_item is not None:
            yield MojoTestItem.from_parent(self, name=cur_item, spec=dict(stdout=item_stdout, code=result.returncode))


class MojoTestItem(pytest.Item):
    """
    Pytest.Item subclass to handle each test result item. There may be
    more than one test result from a test function.
    """
    def __init__(self, *, name, parent, spec, **kwargs):
        super().__init__(name, parent, **kwargs)
        self.spec = spec

    def runtest(self):
        """The test has already been run. We just evaluate the result."""
        if self.spec["code"] != 0:
            raise MojoTestException(self, ",".join(self.spec["stdout"]))

    def repr_failure(self, excinfo):
        """
        Called when runtest() raises an exception. The method is used
        to format the output of the failed test result.
        """
        if isinstance(excinfo.value, MojoTestException):
            return str(excinfo.value)

    def reportinfo(self):
        """"Called to display header information about the test case."""
        return self.path, 0, self.name


class MojoTestException(Exception):
    """Custom exception to distinguish Mojo unit test failures from others."""
    pass
